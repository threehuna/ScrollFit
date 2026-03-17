// CalendarDayView.swift
// ScrollFit

import UIKit

// MARK: - DayStatus

enum DayStatus {
    case today           // текущий день — ещё не закончился
    case pushUpsOnly     // только цель по отжиманиям
    case scrollOnly      // только цель по скроллу
    case both            // обе цели
    case none            // ни одна цель не выполнена

    var circleBorderColor: UIColor {
        switch self {
        case .today:                    return UIColor(.scrollFitWhite)
        case .pushUpsOnly, .scrollOnly: return UIColor(.scrollFitGreen)
        case .both:                     return UIColor(.scrollFitOrange)
        case .none:                     return UIColor(.scrollFitRed)
        }
    }

    var icon: UIImage? {
        switch self {
        case .today:
            return UIImage(systemName: "questionmark",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
        case .pushUpsOnly:
            return UIImage(named: "muscleArmWhite")
        case .scrollOnly:
            return UIImage(systemName: "hourglass.and.lock",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .regular))
        case .both:
            return UIImage(systemName: "trophy.fill",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .regular))
        case .none:
            return UIImage(named: "deadFaceWhite")
        }
    }
}

// MARK: - CalendarDayView

final class CalendarDayView: UIView {

    // MARK: Subviews

    private let dayNumberLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "Helvetica", size: 20) ?? UIFont.systemFont(ofSize: 20)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let circleView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        v.layer.borderWidth = 3.5
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let weekdayLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "Helvetica", size: 15) ?? UIFont.systemFont(ofSize: 15)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: State

    private(set) var date: Date = Date()
    private var tapAction: ((Date) -> Void)?

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: Public

    func configure(date: Date, status: DayStatus, isSelected: Bool, onTap: @escaping (Date) -> Void) {
        self.date      = date
        self.tapAction = onTap

        let cal     = Calendar.current
        let dayNum  = cal.component(.day, from: date)
        let weekday = cal.component(.weekday, from: date)

        let weekdayAbbrs = ["", "Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]

        dayNumberLabel.text  = "\(dayNum)"
        weekdayLabel.text    = weekdayAbbrs[weekday]
        iconImageView.image  = status.icon

        let textColor: UIColor = isSelected ? UIColor(.scrollFitGreen) : UIColor(.scrollFitWhite)
        dayNumberLabel.textColor = textColor
        weekdayLabel.textColor   = textColor

        circleView.backgroundColor   = .clear
        circleView.layer.borderColor = status.circleBorderColor.cgColor

        // Иконка: белая для обычных состояний, зелёная если выбран
        iconImageView.tintColor = isSelected ? UIColor(.scrollFitGreen) : UIColor(.scrollFitWhite)
    }

    // MARK: Private

    private func setup() {
        addSubview(dayNumberLabel)
        addSubview(circleView)
        circleView.addSubview(iconImageView)
        addSubview(weekdayLabel)

        NSLayoutConstraint.activate([
            // Число — сверху, по центру
            dayNumberLabel.topAnchor.constraint(equalTo: topAnchor),
            dayNumberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            dayNumberLabel.heightAnchor.constraint(equalToConstant: 28),

            // Круг — по центру между числом и днём
            circleView.topAnchor.constraint(equalTo: dayNumberLabel.bottomAnchor, constant: 6),
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 36),
            circleView.heightAnchor.constraint(equalToConstant: 36),

            // Иконка — внутри круга
            iconImageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            // День недели — снизу
            weekdayLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 6),
            weekdayLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            weekdayLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            weekdayLabel.heightAnchor.constraint(equalToConstant: 20),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    @objc private func tapped() {
        tapAction?(date)
    }
}
