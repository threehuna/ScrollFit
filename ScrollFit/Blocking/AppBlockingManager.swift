// AppBlockingManager.swift
// ScrollFit

import Foundation
import ManagedSettings
import FamilyControls
import DeviceActivity

extension DeviceActivityName {
    static let screenTimeMonitor = Self("com.scrollfit.screenTimeMonitor")
}

extension DeviceActivityEvent.Name {
    /// Событие: пользователь израсходовал доступные заработанные минуты.
    static let accessExpired = Self("com.scrollfit.accessExpired")

    /// Префикс для промежуточных событий отслеживания (каждые N минут).
    static func usageTrack(_ minutes: Int) -> Self {
        Self("com.scrollfit.usage_\(minutes)")
    }
}

/// Управляет блокировкой выбранных приложений через ManagedSettingsStore.
/// Применяет щит (shield) на приложения, выбранные пользователем.
final class AppBlockingManager {

    static let shared = AppBlockingManager()

    private let store = ManagedSettingsStore()
    private let activityCenter = DeviceActivityCenter()

    private init() {}

    // MARK: - Blocking

    /// Применить блокировку на выбранные приложения.
    func applyBlocking(for selection: FamilyActivitySelection) {
        let applicationTokens = selection.applicationTokens
        let categoryTokens = selection.categoryTokens

        store.shield.applications = applicationTokens.isEmpty ? nil : applicationTokens
        store.shield.applicationCategories = categoryTokens.isEmpty
            ? nil
            : .specific(categoryTokens)
    }

    /// Снять блокировку со всех приложений.
    func removeBlocking() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }

    // MARK: - DeviceActivity Monitoring

    /// Снять блокировку и запустить мониторинг.
    /// Когда пользователь проведёт `availableMinutes` в заблокированных приложениях,
    /// расширение DeviceActivityMonitor автоматически восстановит блокировку.
    func grantAccessAndStartMonitoring(availableMinutes: Int, selection: FamilyActivitySelection) {
        // Остановить предыдущий мониторинг
        activityCenter.stopMonitoring([.screenTimeMonitor])

        // Снять блокировку
        removeBlocking()

        guard availableMinutes > 0 else { return }

        // Сохранить порог в App Group, чтобы расширение знало сколько минут было доступно
        UserDefaults(suiteName: BlockedAppsRepository.appGroupID)?
            .set(availableMinutes, forKey: "monitoring_available_minutes")

        let appTokens = selection.applicationTokens
        let catTokens = selection.categoryTokens

        // Расписание: весь текущий день (полночь — полночь)
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )

        // События
        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]

        // Главное событие: доступ истёк
        events[.accessExpired] = DeviceActivityEvent(
            applications: appTokens,
            categories: catTokens,
            threshold: DateComponents(minute: availableMinutes)
        )

        // Промежуточные события каждые 5 минут для отслеживания прогресса (макс. 20 событий)
        let trackInterval = max(1, availableMinutes / 20)
        for m in stride(from: trackInterval, to: availableMinutes, by: trackInterval) {
            events[.usageTrack(m)] = DeviceActivityEvent(
                applications: appTokens,
                categories: catTokens,
                threshold: DateComponents(minute: m)
            )
        }

        do {
            try activityCenter.startMonitoring(
                .screenTimeMonitor,
                during: schedule,
                events: events
            )
            // Записать статус в App Group для отладки
            UserDefaults(suiteName: BlockedAppsRepository.appGroupID)?
                .set("monitoring_started", forKey: "monitoring_debug_status")
        } catch {
            // Записать ошибку в App Group для отладки
            UserDefaults(suiteName: BlockedAppsRepository.appGroupID)?
                .set("error: \(error.localizedDescription)", forKey: "monitoring_debug_status")
            // Если мониторинг не удалось запустить, восстановить блокировку
            applyBlocking(for: selection)
        }
    }

    /// Остановить мониторинг и восстановить блокировку.
    func stopMonitoringAndReblock() {
        activityCenter.stopMonitoring([.screenTimeMonitor])
        if BlockedAppsRepository.shared.hasSelection {
            applyBlocking(for: BlockedAppsRepository.shared.load())
        }
    }
}
