// DayRecord.swift
// ScrollFit

import Foundation

struct DayRecord: Codable, Equatable {
    let date: String       // "yyyy-MM-dd" — primary key
    let weekday: Int       // Calendar.weekday: 1=Вс … 7=Сб
    var pushUpsCount: Int
    var earnedScrollMinutes: Int
    var spentScrollMinutes: Int
}
