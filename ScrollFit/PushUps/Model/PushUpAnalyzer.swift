// PushUpAnalyzer.swift
// ScrollFit

import Foundation
import CoreGraphics

// MARK: - Phase

enum PushUpPhase: Equatable {
    case waitingForPose  // No valid skeleton detected
    case ready           // Arms straight, person detected — waiting for descent
    case goingDown       // Arms bending
    case atBottom        // Arms fully bent
    case goingUp         // Pushing back up
    case repCounted      // Rep just registered, brief cooldown
    case poseLostMidRep  // Vision lost the person during a rep — holding state
}

// MARK: - Result

struct PushUpAnalysisResult {
    let phase: PushUpPhase
    let repCount: Int
    let didCompleteRep: Bool
    let elbowAngle: Double
    let instructionText: String
}

// MARK: - Analyzer

/// Подсчёт отжиманий через state machine + recovery-based detection.
///
/// ## Главная проблема, которую решает recovery detection
///
/// Камера на полу — когда человек опускается, тело приближается к камере
/// и Vision **полностью теряет позу** (слишком крупный план, joints не в кадре).
/// Классический подход (ждать угла на каждом фрейме) не работает, потому что
/// во время критической фазы "внизу" данных нет.
///
/// ## Решение: двойной механизм
///
/// **Путь A — нормальный:** все joints видны → state machine по углам:
///   ready → goingDown → atBottom → goingUp → repCounted
///
/// **Путь B — recovery:** поза потеряна в середине повторения:
///   goingDown/atBottom/goingUp → poseLostMidRep → (поза восстановилась с прямыми руками)
///   → repCounted
///
/// Recovery засчитывает повторение если:
/// 1. Мы были в фазе спуска/дна/подъёма когда потеряли позу
/// 2. Поза восстановилась с высоким углом локтей (руки выпрямлены)
/// 3. Прошло достаточно времени для полного повторения
final class PushUpAnalyzer {

    // MARK: - Tunable Parameters

    var topAngleThreshold: Double = 148
    var goingDownThreshold: Double = 138
    var bottomAngleThreshold: Double = 110
    var comingUpThreshold: Double = 120
    var topCompletionThreshold: Double = 143

    var minimumRepDuration: TimeInterval = 0.5
    var repCooldown: TimeInterval = 0.3
    var confirmationFrames: Int = 2
    var angleHistorySize: Int = 3

    /// Кадров без позы в IDLE состоянии (waitingForPose/ready) до сброса.
    var staleIdleLimit: Int = 15

    /// Кадров без позы в MID-REP состоянии до сброса (гораздо больше — даём время на recovery).
    var staleMidRepLimit: Int = 45

    /// Вес плечевого сигнала в комбинированной оценке.
    var shoulderSignalWeight: Double = 0.25

    // MARK: - State

    private(set) var repCount:     Int         = 0
    private(set) var currentPhase: PushUpPhase = .waitingForPose

    private var repStartTime:         Date?
    private var lastRepCompletedTime: Date?
    private var poseLostTime:         Date?    // время входа в poseLostMidRep

    private var goingDownFrames: Int = 0
    private var atBottomFrames:  Int = 0
    private var goingUpFrames:   Int = 0
    private var stalePoseFrames: Int = 0

    private var angleHistory:    [Double] = []
    private var lastKnownAngle:  Double   = 180

    /// Фаза, в которой мы были перед потерей позы (для recovery).
    private var phaseBeforeLoss: PushUpPhase?

    // MARK: - Public

    func analyze(poseData: PoseData) -> PushUpAnalysisResult {
        let poseValid = isValidPose(poseData)

        if !poseValid {
            return handlePoseLost()
        }

        // --- Pose is valid ---
        let wasLost = stalePoseFrames > 2
        stalePoseFrames = 0

        let rawAngle = computeElbowAngle(from: poseData)
        angleHistory.append(rawAngle)
        if angleHistory.count > angleHistorySize { angleHistory.removeFirst() }
        let angle = angleHistory.reduce(0, +) / Double(angleHistory.count)
        lastKnownAngle = angle

        // Recovery check: возвращение позы после потери в середине повторения
        if wasLost, let lostPhase = phaseBeforeLoss {
            phaseBeforeLoss = nil
            let recoveryResult = attemptRecoveryRep(lostPhase: lostPhase, currentAngle: angle)
            if let result = recoveryResult {
                return result
            }
            // Recovery не сработал — восстанавливаем фазу и продолжаем обычный путь
            if currentPhase == .poseLostMidRep {
                currentPhase = mapRecoveryPhase(angle: angle)
            }
        }

        let didComplete = updateStateMachine(angle: angle, now: Date())
        return makeResult(angle: angle, didComplete: didComplete)
    }

    func reset() {
        repCount = 0
        repStartTime = nil
        lastRepCompletedTime = nil
        poseLostTime = nil
        phaseBeforeLoss = nil
        currentPhase = .waitingForPose
        goingDownFrames = 0
        atBottomFrames  = 0
        goingUpFrames   = 0
        stalePoseFrames = 0
        angleHistory.removeAll()
        lastKnownAngle = 180
    }

    // MARK: - Pose Lost Handling

    private func handlePoseLost() -> PushUpAnalysisResult {
        stalePoseFrames += 1

        let isMidRep = [.goingDown, .atBottom, .goingUp].contains(currentPhase)

        if isMidRep {
            // Переходим в poseLostMidRep — ДЕРЖИМ состояние, ждём восстановления
            if currentPhase != .poseLostMidRep {
                phaseBeforeLoss = currentPhase
                poseLostTime = Date()
                currentPhase = .poseLostMidRep
            }
            // Слишком долго без позы — сброс
            if stalePoseFrames > staleMidRepLimit {
                resetToWaiting()
            }
        } else if currentPhase == .poseLostMidRep {
            // Уже в poseLostMidRep — продолжаем ждать
            if stalePoseFrames > staleMidRepLimit {
                resetToWaiting()
            }
        } else {
            // Не в середине повторения — обычный сброс по таймауту
            if stalePoseFrames > staleIdleLimit {
                resetToWaiting()
            }
        }

        return makeResult(angle: lastKnownAngle, didComplete: false)
    }

    // MARK: - Recovery Detection

    /// Попытка засчитать повторение по факту восстановления позы.
    /// Возвращает result если rep засчитан, nil если нет.
    private func attemptRecoveryRep(lostPhase: PushUpPhase, currentAngle: Double) -> PushUpAnalysisResult? {
        // Условие: поза была потеряна в фазе спуска/дна/подъёма,
        // и восстановилась с прямыми руками (top position)
        let wasDescending = [PushUpPhase.goingDown, .atBottom, .goingUp].contains(lostPhase)
        guard wasDescending, currentAngle >= topCompletionThreshold else { return nil }

        let now = Date()
        let repDuration   = repStartTime.map { now.timeIntervalSince($0) } ?? 0
        let timeSinceLast = lastRepCompletedTime.map { now.timeIntervalSince($0) } ?? .infinity

        guard repDuration >= minimumRepDuration, timeSinceLast >= repCooldown else {
            // Слишком быстро — скорее всего ложное срабатывание
            currentPhase = .ready
            goingDownFrames = 0
            return nil
        }

        // Recovery rep!
        repCount += 1
        lastRepCompletedTime = now
        currentPhase = .repCounted
        goingDownFrames = 0
        goingUpFrames   = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            guard let self, self.currentPhase == .repCounted else { return }
            self.currentPhase = .ready
        }

        return makeResult(angle: currentAngle, didComplete: true)
    }

    /// При восстановлении позы без recovery rep — определяем текущую фазу по углу.
    private func mapRecoveryPhase(angle: Double) -> PushUpPhase {
        if angle >= topAngleThreshold { return .ready }
        if angle <= bottomAngleThreshold { return .atBottom }
        if angle < goingDownThreshold { return .goingDown }
        return .ready
    }

    // MARK: - Normal State Machine (Path A)

    @discardableResult
    private func updateStateMachine(angle: Double, now: Date) -> Bool {
        switch currentPhase {

        case .waitingForPose:
            if angle >= topAngleThreshold {
                currentPhase = .ready
                goingDownFrames = 0
            }

        case .ready:
            if angle < goingDownThreshold {
                goingDownFrames += 1
                if goingDownFrames >= confirmationFrames {
                    currentPhase = .goingDown
                    repStartTime = now
                    atBottomFrames = 0
                    goingDownFrames = 0
                }
            } else {
                goingDownFrames = max(0, goingDownFrames - 1)
            }

        case .goingDown:
            if angle <= bottomAngleThreshold {
                atBottomFrames += 1
                if atBottomFrames >= confirmationFrames {
                    currentPhase = .atBottom
                    goingUpFrames = 0
                }
            } else if angle >= topAngleThreshold {
                currentPhase = .ready
                goingDownFrames = 0
            }

        case .atBottom:
            if angle > comingUpThreshold {
                goingUpFrames += 1
                if goingUpFrames >= confirmationFrames {
                    currentPhase = .goingUp
                }
            } else {
                goingUpFrames = max(0, goingUpFrames - 1)
            }

        case .goingUp:
            if angle >= topCompletionThreshold {
                let repDuration   = repStartTime.map { now.timeIntervalSince($0) } ?? 0
                let timeSinceLast = lastRepCompletedTime.map { now.timeIntervalSince($0) } ?? .infinity

                if repDuration >= minimumRepDuration && timeSinceLast >= repCooldown {
                    repCount += 1
                    lastRepCompletedTime = now
                    currentPhase = .repCounted
                    goingDownFrames = 0
                    goingUpFrames   = 0

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                        guard let self, self.currentPhase == .repCounted else { return }
                        self.currentPhase = .ready
                    }
                    return true
                } else {
                    currentPhase = .ready
                    goingDownFrames = 0
                }
            } else if angle <= bottomAngleThreshold {
                currentPhase = .atBottom
                goingUpFrames = 0
            }

        case .repCounted, .poseLostMidRep:
            break
        }

        return false
    }

    // MARK: - Combined Signal

    private func computeElbowAngle(from pose: PoseData) -> Double {
        var elbowAngles: [Double] = []

        if let s = pose.leftShoulder,  s.isValid,
           let e = pose.leftElbow,     e.isValid,
           let w = pose.leftWrist,     w.isValid {
            elbowAngles.append(angleDegrees(a: s.position, vertex: e.position, b: w.position))
        }
        if let s = pose.rightShoulder, s.isValid,
           let e = pose.rightElbow,    e.isValid,
           let w = pose.rightWrist,    w.isValid {
            elbowAngles.append(angleDegrees(a: s.position, vertex: e.position, b: w.position))
        }

        guard !elbowAngles.isEmpty else { return 180 }
        let elbowAngle = elbowAngles.reduce(0, +) / Double(elbowAngles.count)

        let shoulderSignal = computeShoulderSignal(from: pose)
        guard let shoulderAngle = shoulderSignal else { return elbowAngle }
        return (1 - shoulderSignalWeight) * elbowAngle + shoulderSignalWeight * shoulderAngle
    }

    private func computeShoulderSignal(from pose: PoseData) -> Double? {
        var pairs: [(shoulderY: Double, wristY: Double)] = []

        if let s = pose.leftShoulder, s.isValid, let w = pose.leftWrist, w.isValid {
            pairs.append((Double(s.position.y), Double(w.position.y)))
        }
        if let s = pose.rightShoulder, s.isValid, let w = pose.rightWrist, w.isValid {
            pairs.append((Double(s.position.y), Double(w.position.y)))
        }
        guard !pairs.isEmpty else { return nil }

        let avgShoulderY = pairs.map(\.shoulderY).reduce(0, +) / Double(pairs.count)
        let avgWristY    = pairs.map(\.wristY).reduce(0, +)    / Double(pairs.count)

        let scale: Double
        if let ls = pose.leftShoulder, ls.isValid, let rs = pose.rightShoulder, rs.isValid {
            let dx = Double(ls.position.x - rs.position.x)
            let dy = Double(ls.position.y - rs.position.y)
            scale = max(sqrt(dx*dx + dy*dy), 0.05)
        } else {
            scale = 0.15
        }

        let delta = (avgShoulderY - avgWristY) / scale
        return min(180, max(0, delta * 60 + 50))
    }

    private func angleDegrees(a: CGPoint, vertex v: CGPoint, b: CGPoint) -> Double {
        let u = CGPoint(x: a.x - v.x, y: a.y - v.y)
        let w = CGPoint(x: b.x - v.x, y: b.y - v.y)
        let dot = Double(u.x * w.x + u.y * w.y)
        let mag = Double(sqrt(u.x * u.x + u.y * u.y) * sqrt(w.x * w.x + w.y * w.y))
        guard mag > 1e-6 else { return 180 }
        return acos(max(-1, min(1, dot / mag))) * 180 / .pi
    }

    // MARK: - Validity

    private func isValidPose(_ pose: PoseData) -> Bool {
        let hasFullLeftArm  = (pose.leftShoulder?.isValid  == true)
                           && (pose.leftElbow?.isValid     == true)
                           && (pose.leftWrist?.isValid     == true)
        let hasFullRightArm = (pose.rightShoulder?.isValid == true)
                           && (pose.rightElbow?.isValid    == true)
                           && (pose.rightWrist?.isValid    == true)
        return hasFullLeftArm || hasFullRightArm
    }

    // MARK: - Helpers

    private func resetToWaiting() {
        currentPhase = .waitingForPose
        phaseBeforeLoss = nil
        goingDownFrames = 0
        atBottomFrames  = 0
        goingUpFrames   = 0
        stalePoseFrames = 0
        angleHistory.removeAll()
    }

    private func makeResult(angle: Double, didComplete: Bool) -> PushUpAnalysisResult {
        PushUpAnalysisResult(
            phase:           currentPhase,
            repCount:        repCount,
            didCompleteRep:  didComplete,
            elbowAngle:      angle,
            instructionText: instructionText(for: currentPhase)
        )
    }

    private func instructionText(for phase: PushUpPhase) -> String {
        switch phase {
        case .waitingForPose:  return "Расположи телефон на полу перед собой"
        case .ready:           return "Готов! Начни отжиматься"
        case .goingDown:       return "Вниз..."
        case .atBottom:        return "Держи!"
        case .goingUp:         return "Вверх!"
        case .repCounted:      return "Отлично!"
        case .poseLostMidRep:  return "Продолжай, я слежу..."
        }
    }
}
