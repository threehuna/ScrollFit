// AppBlockingManager.swift
// ScrollFit

import Foundation
import ManagedSettings
import FamilyControls

/// Управляет блокировкой выбранных приложений через ManagedSettingsStore.
/// Применяет щит (shield) на приложения, выбранные пользователем.
final class AppBlockingManager {

    static let shared = AppBlockingManager()

    private let store = ManagedSettingsStore()

    private init() {}

    // MARK: - Public

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

    /// Временно снять блокировку (например, после отжиманий).
    /// Через указанное количество минут блокировка восстановится.
    func grantTemporaryAccess(minutes: Int, selection: FamilyActivitySelection) {
        removeBlocking()

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(minutes * 60)) { [weak self] in
            self?.applyBlocking(for: selection)
        }
    }
}
