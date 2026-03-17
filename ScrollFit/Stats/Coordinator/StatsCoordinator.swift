// StatsCoordinator.swift
// ScrollFit

import UIKit

protocol StatsCoordinatorWorkoutDelegate: AnyObject {
    func statsCoordinatorDidRequestWorkout(_ coordinator: StatsCoordinator)
}

/// Управляет навигационным стеком вкладки "Статистика".
final class StatsCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var workoutDelegate: StatsCoordinatorWorkoutDelegate?

    private(set) lazy var navigationController: UINavigationController = {
        let nav = UINavigationController()
        nav.view.backgroundColor = UIColor(.scrollFitBlack)
        nav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )
        return nav
    }()

    func start() {
        let vc = StatsViewController()
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    // MARK: - Navigation

    func requestWorkout() {
        workoutDelegate?.statsCoordinatorDidRequestWorkout(self)
    }
}
