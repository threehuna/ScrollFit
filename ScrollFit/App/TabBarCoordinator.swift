// TabBarCoordinator.swift
// ScrollFit

import UIKit

/// Делегат для проброса запроса на тренировку вверх к AppCoordinator.
protocol TabBarCoordinatorWorkoutDelegate: AnyObject {
    func tabBarCoordinatorDidRequestWorkout(_ coordinator: TabBarCoordinator)
}

/// Управляет MainTabBarController и дочерними tab-координаторами.
/// Не знает, как показать WorkoutFlow — делегирует это AppCoordinator.
final class TabBarCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var workoutDelegate: TabBarCoordinatorWorkoutDelegate?

    private(set) lazy var tabBarController: MainTabBarController = {
        let tb = MainTabBarController()
        tb.onWorkoutRequested = { [weak self] in
            guard let self else { return }
            self.workoutDelegate?.tabBarCoordinatorDidRequestWorkout(self)
        }
        return tb
    }()

    func start() {
        let homeCoordinator = HomeCoordinator()
        homeCoordinator.workoutDelegate = self
        homeCoordinator.mainTabBarController = tabBarController
        addChild(homeCoordinator)
        homeCoordinator.start()

        let statsCoordinator = StatsCoordinator()
        statsCoordinator.workoutDelegate = self
        addChild(statsCoordinator)
        statsCoordinator.start()

        tabBarController.viewControllers = [
            homeCoordinator.navigationController,
            statsCoordinator.navigationController,
        ]
    }
}

// MARK: - HomeCoordinatorWorkoutDelegate

extension TabBarCoordinator: HomeCoordinatorWorkoutDelegate {
    func homeCoordinatorDidRequestWorkout(_ coordinator: HomeCoordinator) {
        workoutDelegate?.tabBarCoordinatorDidRequestWorkout(self)
    }
}

// MARK: - StatsCoordinatorWorkoutDelegate

extension TabBarCoordinator: StatsCoordinatorWorkoutDelegate {
    func statsCoordinatorDidRequestWorkout(_ coordinator: StatsCoordinator) {
        workoutDelegate?.tabBarCoordinatorDidRequestWorkout(self)
    }
}
