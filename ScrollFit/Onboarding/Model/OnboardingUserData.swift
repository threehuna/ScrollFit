// OnboardingUserData.swift
// ScrollFit

/// Данные, собираемые в процессе онбординга.
/// Хранится в координаторе и передаётся каждому шагу по ссылке.
final class OnboardingUserData {
    var goals: Set<OnboardingGoal> = []
    var usageLimitMinutes: Int = 45
    var pushUpGoal: Int = 25
    var currentScreenTimeHours: Int = 8
    var desiredScreenTimeHours: Int = 5
}
