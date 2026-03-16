// OnboardingFactory.swift
// ScrollFit

import UIKit

/// Собирает шаги онбординга и привязывает переходы к координатору.
/// По мере добавления экранов — добавляем методы сюда.
enum OnboardingFactory {

    static func makeWelcome(coordinator: OnboardingCoordinator) -> OnboardingWelcomeViewController {
        let vc = OnboardingWelcomeViewController()
        vc.onNext = { [weak coordinator] in
            coordinator?.showGoals()
        }
        return vc
    }

    static func makeGoals(coordinator: OnboardingCoordinator) -> OnboardingGoalsViewController {
        let vc = OnboardingGoalsViewController(userData: coordinator.userData)
        vc.onNext = { [weak coordinator] in
            coordinator?.showUsageLimit()
        }
        vc.onBack = { [weak coordinator] in
            coordinator?.goBack()
        }
        return vc
    }

    static func makeUsageLimit(coordinator: OnboardingCoordinator) -> OnboardingUsageLimitViewController {
        let vc = OnboardingUsageLimitViewController(userData: coordinator.userData)
        vc.onNext = { [weak coordinator] in
            coordinator?.finish()
        }
        vc.onBack = { [weak coordinator] in
            coordinator?.goBack()
        }
        return vc
    }
}
