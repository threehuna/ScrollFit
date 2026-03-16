// OnboardingFactory.swift
// ScrollFit

import UIKit

/// Собирает шаги онбординга и привязывает переходы к координатору.
/// По мере добавления экранов — добавляем методы сюда.
enum OnboardingFactory {

    static func makeWelcome(coordinator: OnboardingCoordinator) -> OnboardingWelcomeViewController {
        let vc = OnboardingWelcomeViewController()
        vc.onNext = { [weak coordinator] in
            coordinator?.finish()
        }
        return vc
    }
}
