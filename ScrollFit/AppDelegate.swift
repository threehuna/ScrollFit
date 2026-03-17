//
//  AppDelegate.swift
//  ScrollFit
//
//  Created by Иван Иванов on 12.03.2026.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Синхронизировать потраченные минуты из расширения мониторинга
        let monitorSpent = ScreenTimeMonitoringState.spentMinutesToday
        let current = ActivityRepository.shared.todayRecord().spentScrollMinutes
        if monitorSpent > current {
            ActivityRepository.shared.updateToday(spentScrollMinutes: monitorSpent)
        }

        // Восстановить блокировку приложений при запуске
        if BlockedAppsRepository.shared.hasSelection {
            let selection = BlockedAppsRepository.shared.load()
            let available = ActivityRepository.shared.availableMinutes

            if available > 0 {
                // Есть доступные минуты — снять блокировку и запустить мониторинг
                AppBlockingManager.shared.grantAccessAndStartMonitoring(
                    availableMinutes: available,
                    selection: selection
                )
            } else {
                // Минут нет — убедиться что блокировка активна
                AppBlockingManager.shared.applyBlocking(for: selection)
            }
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

