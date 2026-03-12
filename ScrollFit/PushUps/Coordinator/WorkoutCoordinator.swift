// WorkoutCoordinator.swift
// ScrollFit

import UIKit

protocol WorkoutCoordinatorDelegate: AnyObject {
    func workoutCoordinatorDidFinish(_ coordinator: WorkoutCoordinator)
}

/// Управляет fullscreen-флоу тренировки.
/// Живёт вне TabBar — презентуется поверх него через AppCoordinator.
///
/// Расширение для новых типов тренировок:
/// добавить метод showPullUpWorkout(), showSquatWorkout() и т.д.
/// AppCoordinator передаёт тип тренировки при создании координатора.
final class WorkoutCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var delegate: WorkoutCoordinatorDelegate?

    private(set) lazy var navigationController: UINavigationController = {
        let nav = UINavigationController()
        nav.modalPresentationStyle = .fullScreen
        nav.navigationBar.isHidden = true
        return nav
    }()

    func start() {
        let vc = PushUpCounterViewController()
        vc.onCancel = { [weak self] in
            guard let self else { return }
            self.delegate?.workoutCoordinatorDidFinish(self)
        }
        navigationController.setViewControllers([vc], animated: false)
    }
}
