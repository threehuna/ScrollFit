// ProgressChartCardView.swift
// ScrollFit

import UIKit

final class ProgressChartCardView: UIView {

    enum ChartType {
        case pushUps     // синяя карточка, кольцо стартует с 0%
        case screenTime  // зелёная карточка, кольцо стартует со 100%
    }

    // MARK: - Subviews

    /// Внутренняя вью с corner radius и clipsToBounds — отделена от тени
    private let cardView     = UIView()
    private let titleLabel   = UILabel()
    private let iconView     = UIImageView()
    private let ringView     = RingProgressView()
    private let valueLabel   = UILabel()
    private let unitLabel    = UILabel()

    private let type: ChartType

    // MARK: - Init

    init(type: ChartType) {
        self.type = type
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    /// current — фактическое значение за день, goal — цель
    func configure(current: Int, goal: Int) {
        switch type {
        case .pushUps:
            let remaining = max(0, goal - current)
            valueLabel.text = "\(remaining)"
            unitLabel.text  = "повт. осталось"
            valueLabel.textColor = .white
            ringView.progressColor = .white
            ringView.progress = goal > 0 ? CGFloat(current) / CGFloat(goal) : 0

        case .screenTime:
            let spent = current
            let exceeded = spent > goal && goal > 0

            if exceeded {
                let over = spent - goal
                valueLabel.text = "+\(over)"
                unitLabel.text  = "мин сверх\nлимита"
                valueLabel.textColor = UIColor(.scrollFitRed)
                ringView.progressColor = UIColor(.scrollFitRed)
                ringView.progress = 0
            } else {
                let remaining = max(0, goal - spent)
                valueLabel.text = "\(remaining)"
                unitLabel.text  = "мин осталось"
                valueLabel.textColor = .white
                ringView.progressColor = .white
                let fraction = goal > 0 ? CGFloat(max(0, goal - spent)) / CGFloat(goal) : 1
                ringView.progress = fraction
            }
        }
    }

    // MARK: - Setup

    private func setup() {
        // Свечение — на самой вью (не clipsToBounds)
        layer.shadowOffset  = .zero
        layer.shadowRadius  = 19
        layer.shadowOpacity = 0.85
        layer.masksToBounds = false

        // Карточка — округлённая, клипует контент
        layer.borderWidth = 3
        layer.cornerRadius = 24
        cardView.layer.cornerRadius = 24
        cardView.clipsToBounds      = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardView)

        switch type {
        case .pushUps:
            cardView.backgroundColor = UIColor(.scrollFitBlack).withAlphaComponent(0.77)
            layer.shadowColor        = UIColor(.scrollFitBlue).cgColor
            layer.borderColor = UIColor(.scrollFitBlue).cgColor
            titleLabel.text          = "Отжимания\n"
            iconView.image           = UIImage(named: "muscleArmWhite")
            iconView.tintColor       = .white

        case .screenTime:
            cardView.backgroundColor = UIColor(.scrollFitBlack).withAlphaComponent(0.77)
            layer.shadowColor        = UIColor(.scrollFitGreen).cgColor
            layer.borderColor = UIColor(.scrollFitGreen).cgColor
            titleLabel.text          = "Экранное\nвремя на день"
            let cfg                  = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            iconView.image           = UIImage(systemName: "hourglass.and.lock", withConfiguration: cfg)
            iconView.tintColor       = .white
        }

        // Title
        titleLabel.font          = UIFont(name: "Helvetica-Bold", size: 15) ?? .boldSystemFont(ofSize: 15)
        titleLabel.textColor     = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)

        // Icon
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconView)

        // Ring
        ringView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(ringView)

        // Value (крупное число)
        valueLabel.font          = UIFont(name: "Helvetica-Bold", size: 20) ?? .boldSystemFont(ofSize: 22)
        valueLabel.textColor     = .white
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(valueLabel)

        // Unit (подпись)
        unitLabel.font          = UIFont(name: "Helvetica", size: 12) ?? .systemFont(ofSize: 12)
        unitLabel.textColor     = UIColor.white.withAlphaComponent(0.8)
        unitLabel.textAlignment = .center
        unitLabel.numberOfLines = 2
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(unitLabel)

        NSLayoutConstraint.activate([
            // cardView — заполняет self
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Title — левый верхний угол
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.widthAnchor.constraint(equalToConstant: 110),

            // Icon — правый верхний угол
            iconView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            iconView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            iconView.widthAnchor.constraint(equalToConstant: 36),
            iconView.heightAnchor.constraint(equalToConstant: 44),

            // Ring — заполняет нижнюю часть карточки
            ringView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            ringView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            ringView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14),
            ringView.widthAnchor.constraint(equalTo: ringView.heightAnchor),

            // Значение — центр кольца, чуть выше середины
            valueLabel.centerXAnchor.constraint(equalTo: ringView.centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: ringView.centerYAnchor, constant: -10),

            // Подпись — под значением
            unitLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            unitLabel.centerXAnchor.constraint(equalTo: ringView.centerXAnchor),
            unitLabel.widthAnchor.constraint(equalToConstant: 80),
        ])

        // Начальное состояние
        configure(current: 0, goal: 1)
    }
}
