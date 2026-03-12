// AppCoordinator.swift
// ScrollFit

import UIKit

/// Корневой координатор. Владеет окном и управляет верхнеуровневыми переходами.
/// Единственное место, где решается: показать TabBar или WorkoutFlow.
final class AppCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    private let window: UIWindow

    private var tabBarCoordinator: TabBarCoordinator?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        showMainFlow()
    }

    // MARK: - Flows

    private func showMainFlow() {
        let tabBar = TabBarCoordinator()
        tabBar.workoutDelegate = self
        tabBarCoordinator = tabBar
        addChild(tabBar)
        tabBar.start()
        window.rootViewController = tabBar.tabBarController
        window.makeKeyAndVisible()
    }

    private func showWorkoutFlow() {
        let coordinator = WorkoutCoordinator()
        coordinator.delegate = self
        addChild(coordinator)
        coordinator.start()

        // Презентуем поверх TabBar — тренировка не живёт внутри таббара
        tabBarCoordinator?.tabBarController.present(
            coordinator.navigationController,
            animated: true
        )
    }
}

// MARK: - TabBarCoordinatorWorkoutDelegate

extension AppCoordinator: TabBarCoordinatorWorkoutDelegate {
    func tabBarCoordinatorDidRequestWorkout(_ coordinator: TabBarCoordinator) {
        showWorkoutFlow()
    }
}

// MARK: - WorkoutCoordinatorDelegate

extension AppCoordinator: WorkoutCoordinatorDelegate {
    func workoutCoordinatorDidFinish(_ coordinator: WorkoutCoordinator) {
        tabBarCoordinator?.tabBarController.dismiss(animated: true)
        removeChild(coordinator)
    }
}
