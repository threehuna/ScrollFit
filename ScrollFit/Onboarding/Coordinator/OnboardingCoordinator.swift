// OnboardingCoordinator.swift
// ScrollFit

import UIKit

protocol OnboardingCoordinatorDelegate: AnyObject {
    func onboardingCoordinatorDidFinish(_ coordinator: OnboardingCoordinator)
}

final class OnboardingCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var delegate: OnboardingCoordinatorDelegate?

    let userData = OnboardingUserData()

    private(set) lazy var navigationController: UINavigationController = {
        let nav = OnboardingNavigationController()
        nav.setNavigationBarHidden(true, animated: false)
        nav.modalPresentationStyle = .fullScreen
        return nav
    }()

    // MARK: - Coordinator

    func start() {
        showWelcome()
    }

    // MARK: - Navigation

    func showWelcome() {
        let vc = OnboardingFactory.makeWelcome(coordinator: self)
        navigationController.setViewControllers([vc], animated: false)
    }

    func showGoals() {
        let vc = OnboardingFactory.makeGoals(coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func showUsageLimit() {
        let vc = OnboardingFactory.makeUsageLimit(coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func finish() {
        UserDefaults.standard.set(true, forKey: OnboardingCoordinator.completedKey)
        delegate?.onboardingCoordinatorDidFinish(self)
    }

    func goBack() {
        navigationController.popViewController(animated: true)
    }

    // MARK: - Helpers

    static let completedKey = "onboarding_completed"

    static var isCompleted: Bool {
        UserDefaults.standard.bool(forKey: completedKey)
    }
}

// MARK: - Private navigation controller

private final class OnboardingNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? { topViewController }
}
