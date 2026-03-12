// PoseSmoother.swift
// ScrollFit

import Vision
import CoreGraphics

// MARK: - PoseSmoother

/// Applies EMA smoothing to raw Vision keypoints.
///
/// При потере joint'а (низкий confidence) выполняет **velocity extrapolation**:
/// позиция продолжает двигаться по последнему вектору скорости с затуханием.
/// Это критично для push-up детекции: когда тело приближается к камере (фаза "вниз"),
/// Vision теряет уверенность, но скелет продолжает корректно двигаться.
final class PoseSmoother {

    // MARK: - Tunable Parameters

    /// EMA alpha: больше = отзывчивее, меньше = глаже.
    var alpha: Double = 0.6

    /// Минимальный confidence для "живого" joint.
    /// 0.1 — очень низкий порог, позволяет ловить joints даже при плохой видимости
    /// (тело близко к камере, плохое освещение, частичная окклюзия).
    var confidenceThreshold: Float = 0.1

    /// Кадров жизни после потери confidence.
    /// При ~15fps = ~0.5s grace period с экстраполяцией скорости.
    var staleFrameLimit: Int = 8

    /// Затухание скорости за кадр при экстраполяции (0 = нет движения, 1 = без затухания).
    var velocityDamping: Double = 0.65

    // MARK: - State

    private typealias JointName = VNHumanBodyPoseObservation.JointName

    private var smoothed: [JointName: CGPoint] = [:]
    private var velocity: [JointName: CGPoint] = [:]
    private var stale:    [JointName: Int]     = [:]

    private let trackedJoints: [JointName] = [
        .leftShoulder, .rightShoulder,
        .leftElbow,    .rightElbow,
        .leftWrist,    .rightWrist,
        .leftHip,      .rightHip,
        .leftKnee,     .rightKnee,
        .leftAnkle,    .rightAnkle,
        .neck,         .root
    ]

    // MARK: - Public

    func smooth(observation: VNHumanBodyPoseObservation) -> PoseData {
        var raw: [JointName: (pos: CGPoint, conf: Float)] = [:]

        if let allPoints = try? observation.recognizedPoints(.all) {
            for (name, point) in allPoints {
                raw[name] = (
                    CGPoint(x: CGFloat(point.location.x), y: CGFloat(point.location.y)),
                    point.confidence
                )
            }
        }

        for joint in trackedJoints {
            if let (pos, conf) = raw[joint], conf >= confidenceThreshold {
                // --- Confident detection: EMA update ---
                if let prev = smoothed[joint] {
                    let newPos = CGPoint(
                        x: CGFloat(alpha) * pos.x + CGFloat(1 - alpha) * prev.x,
                        y: CGFloat(alpha) * pos.y + CGFloat(1 - alpha) * prev.y
                    )
                    // Velocity = разница за кадр (используется при потере confidence)
                    velocity[joint] = CGPoint(
                        x: newPos.x - prev.x,
                        y: newPos.y - prev.y
                    )
                    smoothed[joint] = newPos
                } else {
                    smoothed[joint] = pos
                    velocity[joint] = .zero
                }
                stale[joint] = 0

            } else {
                // --- Low confidence: velocity extrapolation ---
                let age = (stale[joint] ?? 0) + 1
                stale[joint] = age

                if age <= staleFrameLimit, let lastPos = smoothed[joint] {
                    // Продолжаем движение по вектору скорости с затуханием
                    let vel = velocity[joint] ?? .zero
                    let dampedVel = CGPoint(
                        x: vel.x * CGFloat(velocityDamping),
                        y: vel.y * CGFloat(velocityDamping)
                    )
                    let extrapolated = CGPoint(
                        x: max(0, min(1, lastPos.x + dampedVel.x)),
                        y: max(0, min(1, lastPos.y + dampedVel.y))
                    )
                    smoothed[joint] = extrapolated
                    velocity[joint] = dampedVel
                } else {
                    // Превышен staleFrameLimit — удаляем joint
                    smoothed.removeValue(forKey: joint)
                    velocity.removeValue(forKey: joint)
                    stale.removeValue(forKey: joint)
                }
            }
        }

        return buildPoseData(raw: raw)
    }

    func reset() {
        smoothed.removeAll()
        velocity.removeAll()
        stale.removeAll()
    }

    // MARK: - Private

    private func buildPoseData(raw: [JointName: (pos: CGPoint, conf: Float)]) -> PoseData {
        func joint(_ name: JointName) -> JointPoint? {
            guard let pos = smoothed[name] else { return nil }
            let conf     = raw[name]?.conf ?? 0
            let age      = stale[name] ?? 0
            // isValid: высокий confidence ИЛИ stale в пределах grace period (joint был реален)
            let isValid  = conf >= confidenceThreshold || (age > 0 && age <= staleFrameLimit)
            return JointPoint(position: pos, confidence: conf, isValid: isValid, staleAge: age)
        }
        return PoseData(
            leftShoulder:  joint(.leftShoulder),
            rightShoulder: joint(.rightShoulder),
            leftElbow:     joint(.leftElbow),
            rightElbow:    joint(.rightElbow),
            leftWrist:     joint(.leftWrist),
            rightWrist:    joint(.rightWrist),
            leftHip:       joint(.leftHip),
            rightHip:      joint(.rightHip),
            leftKnee:      joint(.leftKnee),
            rightKnee:     joint(.rightKnee),
            leftAnkle:     joint(.leftAnkle),
            rightAnkle:    joint(.rightAnkle),
            neck:          joint(.neck),
            root:          joint(.root)
        )
    }
}
