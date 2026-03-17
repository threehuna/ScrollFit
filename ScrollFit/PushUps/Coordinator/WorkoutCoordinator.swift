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
        vc.onFinish = { [weak self] pushUps in
            guard let self else { return }
            ActivityRepository.shared.recordSession(pushUps: pushUps)

            // Если есть заблокированные приложения и доступные минуты —
            // снять блокировку и запустить мониторинг
            if BlockedAppsRepository.shared.hasSelection {
                let selection = BlockedAppsRepository.shared.load()
                let available = ActivityRepository.shared.availableMinutes
                if available > 0 {
                    AppBlockingManager.shared.grantAccessAndStartMonitoring(
                        availableMinutes: available,
                        selection: selection
                    )
                }
            }

            self.delegate?.workoutCoordinatorDidFinish(self)
        }
        navigationController.setViewControllers([vc], animated: false)
    }
}
