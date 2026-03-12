// CustomTabBarView.swift
// ScrollFit

import UIKit

/// Плавающий таббар в виде pill'а: ←[house] [+] [chart]→
/// Размеры из макета: 236×62, border 4pt #a5f133, cornerRadius 31.
final class CustomTabBarView: UIView {

    var onTabSelected: ((Int) -> Void)?
    var onWorkoutTapped: (() -> Void)?

    private let homeButton    = UIButton(type: .system)
    private let workoutButton = UIButton(type: .system)
    private let statsButton   = UIButton(type: .system)

    private let green = UIColor(red: 0.647, green: 0.945, blue: 0.200, alpha: 1) // #a5f133

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    func selectTab(_ index: Int) {
        homeButton.tintColor  = index == 0 ? green : .systemGray
        statsButton.tintColor = index == 1 ? green : .systemGray
    }

    // MARK: - Setup

    private func setup() {
        setupAppearance()
        setupButtons()
        setupLayout()
        selectTab(0)
    }

    private func setupAppearance() {
        backgroundColor = UIColor(red: 0.196, green: 0.192, blue: 0.196, alpha: 0.7)
        layer.cornerRadius = 31
        layer.borderWidth  = 4
        layer.borderColor  = green.cgColor
        clipsToBounds      = true
    }

    private func setupButtons() {
        // Home
        let iconCfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        homeButton.setImage(UIImage(systemName: "house.fill", withConfiguration: iconCfg), for: .normal)
        homeButton.addTarget(self, action: #selector(homeTapped), for: .touchUpInside)
        homeButton.translatesAutoresizingMaskIntoConstraints = false

        // Workout (center) — green circle with plus
        workoutButton.backgroundColor = green
        workoutButton.layer.cornerRadius = 20
        workoutButton.clipsToBounds = true
        let plusCfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        workoutButton.setImage(UIImage(systemName: "plus", withConfiguration: plusCfg), for: .normal)
        workoutButton.tintColor = UIColor(red: 0.196, green: 0.192, blue: 0.196, alpha: 1)
        workoutButton.addTarget(self, action: #selector(workoutTapped), for: .touchUpInside)
        workoutButton.translatesAutoresizingMaskIntoConstraints = false

        // Stats
        statsButton.setImage(UIImage(systemName: "chart.bar.fill", withConfiguration: iconCfg), for: .normal)
        statsButton.addTarget(self, action: #selector(statsTapped), for: .touchUpInside)
        statsButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(homeButton)
        addSubview(workoutButton)
        addSubview(statsButton)
    }

    private func setupLayout() {
        // From Figma: icons are 40×40, spaced ±72pt from center in a 236pt-wide pill.
        NSLayoutConstraint.activate([
            homeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            homeButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -72),
            homeButton.widthAnchor.constraint(equalToConstant: 40),
            homeButton.heightAnchor.constraint(equalToConstant: 40),

            workoutButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            workoutButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            workoutButton.widthAnchor.constraint(equalToConstant: 40),
            workoutButton.heightAnchor.constraint(equalToConstant: 40),

            statsButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            statsButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 72),
            statsButton.widthAnchor.constraint(equalToConstant: 40),
            statsButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    // MARK: - Actions

    @objc private func homeTapped() {
        selectTab(0)
        onTabSelected?(0)
    }

    @objc private func workoutTapped() {
        onWorkoutTapped?()
    }

    @objc private func statsTapped() {
        selectTab(1)
        onTabSelected?(1)
    }
}
