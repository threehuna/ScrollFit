// WeekCalendarView.swift
// ScrollFit

import UIKit

/// Отображает 7 дней подряд в горизонтальный ряд.
/// startDate — первый (левый) день периода.
final class WeekCalendarView: UIView {

    // MARK: - State

    var selectedDate: Date?
    var onDaySelected: ((Date) -> Void)?

    private var startDate: Date = Date()
    private var dayViews: [CalendarDayView] = []

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildDayViews()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    func configure(startDate: Date, selectedDate: Date?, goals: UserGoals) {
        self.startDate    = startDate
        self.selectedDate = selectedDate

        let cal     = Calendar.current
        let today   = cal.startOfDay(for: Date())
        let repo    = ActivityRepository.shared

        for (i, dayView) in dayViews.enumerated() {
            let date    = cal.date(byAdding: .day, value: i, to: startDate)!
            let dayDate = cal.startOfDay(for: date)
            let key     = ActivityRepository.dateKey(for: date)
            let record  = repo.record(for: key)
            let status  = dayStatus(date: dayDate, today: today, record: record, goals: goals)
            let isSel   = selectedDate.map { cal.startOfDay(for: $0) == dayDate } ?? false

            dayView.configure(date: date, status: status, isSelected: isSel) { [weak self] tappedDate in
                self?.onDaySelected?(tappedDate)
            }
        }
    }

    // MARK: - Private

    private func buildDayViews() {
        let stack = UIStackView()
        stack.axis         = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        for _ in 0..<7 {
            let dayView = CalendarDayView()
            stack.addArrangedSubview(dayView)
            dayViews.append(dayView)
        }
    }

    private func dayStatus(date: Date, today: Date, record: DayRecord?, goals: UserGoals) -> DayStatus {
        if date == today    { return .today }
        if date > today     { return .today }   // на всякий случай

        let pushUpsMet = (record?.pushUpsCount ?? 0) >= goals.pushUpsGoal
        let scrollMet  = (record?.spentScrollMinutes ?? 0) <= goals.scrollMinutesGoal

        switch (pushUpsMet, scrollMet) {
        case (true,  true):  return .both
        case (true,  false): return .pushUpsOnly
        case (false, true):  return .scrollOnly
        case (false, false): return .none
        }
    }
}
