// BlockedAppsRepository.swift
// ScrollFit

import Foundation
import FamilyControls

/// Хранит выбранные для блокировки приложения в App Group,
/// чтобы Shield Configuration Extension мог прочитать эти данные.
final class BlockedAppsRepository {

    static let shared = BlockedAppsRepository()

    /// App Group ID — должен совпадать с Entitlements основного приложения
    /// и Shield Configuration Extension.
    static let appGroupID = "group.com.ivvlivanov-edu.hse.ScrollFit"

    private let key = "blocked_apps_selection"

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: Self.appGroupID)
    }

    private init() {}

    // MARK: - Read / Write

    /// Сохранить выбранные приложения.
    func save(_ selection: FamilyActivitySelection) {
        guard let data = try? JSONEncoder().encode(selection) else { return }
        defaults?.set(data, forKey: key)
    }

    /// Загрузить сохранённые приложения.
    func load() -> FamilyActivitySelection {
        guard let data = defaults?.data(forKey: key),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else { return FamilyActivitySelection() }
        return selection
    }

    /// Есть ли сохранённые приложения.
    var hasSelection: Bool {
        let selection = load()
        return !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty
    }
}
