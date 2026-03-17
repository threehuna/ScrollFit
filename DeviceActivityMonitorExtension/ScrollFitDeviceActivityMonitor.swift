// ScrollFitDeviceActivityMonitor.swift
// DeviceActivityMonitorExtension

import DeviceActivity
import ManagedSettings
import FamilyControls
import Foundation

/// Расширение мониторинга экранного времени.
/// Отслеживает использование заблокированных приложений и восстанавливает
/// блокировку, когда заработанные минуты исчерпаны.
///
/// Имя класса должно совпадать с NSExtensionPrincipalClass в Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    private let store = ManagedSettingsStore()

    private let appGroupID = "group.com.ivvlivanov-edu.hse.ScrollFit"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    // MARK: - DeviceActivityMonitor

    override func intervalDidStart(for activity: DeviceActivityName) {
        // Начало интервала мониторинга
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        // Конец интервала (полночь) — восстановить блокировку
        reapplyBlocking()
    }

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        let eventRaw = event.rawValue

        if eventRaw == "com.scrollfit.accessExpired" {
            // Заработанные минуты исчерпаны — восстановить блокировку
            // Достаём порог из имени события или из сохранённого значения
            if let available = sharedDefaults?.integer(forKey: "monitoring_available_minutes"),
               available > 0 {
                updateSpentMinutes(available)
            }
            reapplyBlocking()
        } else if eventRaw.hasPrefix("com.scrollfit.usage_") {
            // Промежуточное событие — обновить потраченные минуты
            let minutesStr = eventRaw.replacingOccurrences(of: "com.scrollfit.usage_", with: "")
            if let minutes = Int(minutesStr) {
                updateSpentMinutes(minutes)
            }
        }
    }

    // MARK: - Private

    private func reapplyBlocking() {
        guard let data = sharedDefaults?.data(forKey: "blocked_apps_selection"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else { return }

        let appTokens = selection.applicationTokens
        let catTokens = selection.categoryTokens

        store.shield.applications = appTokens.isEmpty ? nil : appTokens
        store.shield.applicationCategories = catTokens.isEmpty ? nil : .specific(catTokens)
    }

    private func updateSpentMinutes(_ minutes: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let today = formatter.string(from: Date())

        let currentDate = sharedDefaults?.string(forKey: "monitoring_spent_date") ?? ""
        let currentMinutes = (currentDate == today)
            ? sharedDefaults?.integer(forKey: "monitoring_spent_minutes") ?? 0
            : 0

        // Обновить только если новое значение больше текущего
        if minutes > currentMinutes {
            sharedDefaults?.set(minutes, forKey: "monitoring_spent_minutes")
            sharedDefaults?.set(today, forKey: "monitoring_spent_date")
        }
    }
}
