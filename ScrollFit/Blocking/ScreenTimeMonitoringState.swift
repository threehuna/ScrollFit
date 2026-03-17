// ScreenTimeMonitoringState.swift
// ScrollFit

import Foundation

/// Общее хранилище состояния мониторинга экранного времени.
/// Доступно и основному приложению, и DeviceActivityMonitor-расширению через App Group.
struct ScreenTimeMonitoringState {

    private static let suiteName = BlockedAppsRepository.appGroupID

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    // MARK: - Keys

    private static let spentMinutesKey = "monitoring_spent_minutes"
    private static let spentDateKey    = "monitoring_spent_date"

    // MARK: - Spent Minutes (обновляется расширением)

    /// Количество минут, проведённых в заблокированных приложениях сегодня.
    static var spentMinutesToday: Int {
        get {
            guard let d = defaults, d.string(forKey: spentDateKey) == todayString else { return 0 }
            return d.integer(forKey: spentMinutesKey)
        }
        set {
            defaults?.set(newValue, forKey: spentMinutesKey)
            defaults?.set(todayString, forKey: spentDateKey)
        }
    }

    // MARK: - Helpers

    private static var todayString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: Date())
    }
}
