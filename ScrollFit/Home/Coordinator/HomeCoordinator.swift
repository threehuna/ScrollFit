// HomeCoordinator.swift
// ScrollFit

import UIKit

protocol HomeCoordinatorWorkoutDelegate: AnyObject {
    func homeCoordinatorDidRequestWorkout(_ coordinator: HomeCoordinator)
}

/// Управляет навигационным стеком вкладки "Главный".
/// Ответственен за: root (HomeViewController), push на Settings.
final class HomeCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var workoutDelegate: HomeCoordinatorWorkoutDelegate?

    private(set) lazy var navigationController: UINavigationController = {
        let nav = UINavigationController()
        nav.tabBarItem = UITabBarItem(
            title: "Главный",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        return nav
    }()

    func start() {
        let vc = HomeViewController()
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    // MARK: - Navigation

    func showSettings() {
        let vc = SettingsViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func requestWorkout() {
        workoutDelegate?.homeCoordinatorDidRequestWorkout(self)
    }
}
