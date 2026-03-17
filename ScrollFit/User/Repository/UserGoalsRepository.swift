// UserGoalsRepository.swift
// ScrollFit

import Foundation

final class UserGoalsRepository {

    static let shared = UserGoalsRepository()

    private(set) var goals: UserGoals
    private let fileURL: URL

    private init() {
        fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("user_goals.json")

        if let data    = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(UserGoals.self, from: data) {
            goals = decoded
        } else {
            goals = UserGoals()   // дефолтные значения
        }
    }

    // MARK: - Write

    func update(pushUpsGoal: Int? = nil, scrollMinutesGoal: Int? = nil) {
        if let v = pushUpsGoal      { goals.pushUpsGoal      = max(1, v) }
        if let v = scrollMinutesGoal { goals.scrollMinutesGoal = max(1, v) }
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(goals) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
