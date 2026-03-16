// GoalOptionView.swift
// ScrollFit

import UIKit

/// Строка выбора цели на экране онбординга.
/// Поддерживает выбранное и невыбранное состояния.
final class GoalOptionView: UIControl {

    let goal: OnboardingGoal

    // MARK: - UI

    private let backgroundView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 34
        v.isUserInteractionEnabled = false
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-Bold", size: 17)
                  ?? UIFont.systemFont(ofSize: 17, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - State colors

    private static let selectedBackground = UIColor(red: 0.565, green: 0.859, blue: 0.125, alpha: 1)
    private static let normalBackground   = UIColor(red: 0.153, green: 0.153, blue: 0.165, alpha: 1)

    // MARK: - Init

    init(goal: OnboardingGoal) {
        self.goal = goal
        super.init(frame: .zero)
        setupViews()
        updateAppearance()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Override

    override var isSelected: Bool { didSet { updateAppearance(animated: true) } }

    // MARK: - Setup

    private func setupViews() {
        addSubview(backgroundView)
        addSubview(iconImageView)
        addSubview(titleLabel)

        iconImageView.image = goal.icon
        titleLabel.text     = goal.rawValue

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),

            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 59),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    private func updateAppearance(animated: Bool = false) {
        let targetBg   = isSelected ? Self.selectedBackground : Self.normalBackground
        let targetTint = isSelected ? UIColor(.scrollFitBlack) : UIColor.white

        guard animated else {
            backgroundView.backgroundColor = targetBg
            iconImageView.tintColor        = targetTint
            titleLabel.textColor           = targetTint
            return
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.backgroundView.backgroundColor = targetBg
            self.titleLabel.textColor           = targetTint
        }
        UIView.transition(with: iconImageView, duration: 0.25,
                          options: [.transitionCrossDissolve, .curveEaseIn]) {
            self.iconImageView.tintColor = targetTint
        }
    }
}
