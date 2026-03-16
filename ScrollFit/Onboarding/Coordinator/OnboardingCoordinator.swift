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

    private(set) lazy var containerViewController = OnboardingContainerViewController()

    var rootViewController: UIViewController { containerViewController }

    // MARK: - Coordinator

    func start() {
        showWelcome()
    }

    // MARK: - Navigation

    func showWelcome() {
        let vc = OnboardingFactory.makeWelcome(coordinator: self)
        containerViewController.pushViewController(vc, animated: false)
    }

    func showGoals() {
        let vc = OnboardingFactory.makeGoals(coordinator: self)
        containerViewController.pushViewController(vc, animated: true)
    }

    func showUsageLimit() {
        let vc = OnboardingFactory.makeUsageLimit(coordinator: self)
        containerViewController.pushViewController(vc, animated: true)
    }

    func showPushUpGoal() {
        let vc = OnboardingFactory.makePushUpGoal(coordinator: self)
        containerViewController.pushViewController(vc, animated: true)
    }

    func showCurrentScreenTime() {
        let vc = OnboardingFactory.makeCurrentScreenTime(coordinator: self)
        containerViewController.pushViewController(vc, animated: true)
    }

    func showTimeReturn() {
        let vc = OnboardingFactory.makeTimeReturn(coordinator: self)
        containerViewController.pushViewController(vc, animated: true)
    }

    func showPhoneInfluence() {
        let vc = OnboardingFactory.makePhoneInfluence(coordinator: self)
        containerViewController.pushViewController(vc, animated: true)
    }

    func showDesiredScreenTimeIfNeeded() {
        // Пропускаем экран если текущее время уже 1 час — некуда снижать
        guard userData.currentScreenTimeHours > 1 else {
            userData.desiredScreenTimeHours = userData.currentScreenTimeHours
            showPhoneInfluence()
            return
        }
        let vc = OnboardingFactory.makeDesiredScreenTime(coordinator: self)
        containerViewController.pushViewController(vc, animated: true)
    }

    func goBack() {
        containerViewController.popViewController(animated: true)
    }

    func finish() {
        UserDefaults.standard.set(true, forKey: OnboardingCoordinator.completedKey)
        delegate?.onboardingCoordinatorDidFinish(self)
    }

    // MARK: - Helpers

    static let completedKey = "onboarding_completed"

    static var isCompleted: Bool {
        UserDefaults.standard.bool(forKey: completedKey)
    }
}
