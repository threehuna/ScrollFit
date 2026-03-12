// ActivityStore.swift
// ScrollFit

import Foundation

/// Внутренняя модель сериализации. Пишется в один JSON-файл атомарно.
/// Наружу не светится — используй ActivityRepository.
struct ActivityStore: Codable {
    var records: [String: DayRecord] = [:]   // key = "yyyy-MM-dd"
    var currentStreak: Int = 0
    var bestStreak: Int = 0
}
