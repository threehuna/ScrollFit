// UserGoals.swift
// ScrollFit

import Foundation

struct UserGoals: Codable {
    /// Минимальное количество отжиманий в день для выполнения цели.
    var pushUpsGoal: Int = 10
    /// Максимальное количество минут скролла в день (цель — не превысить).
    var scrollMinutesGoal: Int = 60
}
