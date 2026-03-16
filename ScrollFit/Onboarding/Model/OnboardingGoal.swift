// OnboardingGoal.swift
// ScrollFit

import UIKit

enum OnboardingGoal: String, CaseIterable, Hashable {
    case quitScrolling    = "Бросить вечный скролл ленты"
    case getToned         = "Привести себя в тонус"
    case reduceScreenTime = "Уменьшить экранное время"
    case beProductive     = "Стать более продуктивным"

    var icon: UIImage? {
        switch self {
        case .quitScrolling:    return UIImage(systemName: "infinity")
        case .getToned:         return UIImage(systemName: "dumbbell")
        case .reduceScreenTime: return UIImage(systemName: "hourglass")
        case .beProductive:     return UIImage(systemName: "bolt.fill")
        }
    }
}
