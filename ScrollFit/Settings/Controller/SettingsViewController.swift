// SettingsViewController.swift
// ScrollFit

import UIKit

/// Экран настроек. Открывается push'ем из HomeViewController.
final class SettingsViewController: UIViewController {

    weak var coordinator: HomeCoordinator?
    weak var mainTabBarController: MainTabBarController?

    // MARK: - Subviews

    private let gradientView = GradientBackgroundView()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Настройки"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: — Соотношение

    private let multiplierSectionLabel: UILabel = makeSectionLabel("Соотношение")
    private let multiplierRow = MultiplierRowView()

    // MARK: — Звуковые эффекты

    private let soundSectionLabel: UILabel = makeSectionLabel("Звуковые эффекты")
    private let soundEffectsRow = SoundEffectsRowView()

    // MARK: — Персональные цели

    private let goalsSectionLabel: UILabel = makeSectionLabel("Персональные цели")

    private lazy var pushUpGoalRow: GoalRowView = {
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let icon = UIImage(named: "muscleArmWhite")
        let row = GoalRowView(icon: icon, title: "Цель по отжиманиям")
        row.onTap = { [weak self] in self?.coordinator?.showPushUpGoal() }
        return row
    }()

    private lazy var usageLimitRow: GoalRowView = {
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let icon = UIImage(systemName: "hourglass", withConfiguration: config)
        let row = GoalRowView(icon: icon, title: "Лимит по использованию")
        row.onTap = { [weak self] in self?.coordinator?.showUsageLimit() }
        return row
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        mainTabBarController?.setCustomTabBarHidden(true)
        multiplierRow.reload()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainTabBarController?.setCustomTabBarHidden(false)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private func setupHierarchy() {
        view.insertSubview(gradientView, at: 0)
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(multiplierSectionLabel)
        multiplierRow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(multiplierRow)
        view.addSubview(soundSectionLabel)
        soundEffectsRow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(soundEffectsRow)
        view.addSubview(goalsSectionLabel)
        pushUpGoalRow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pushUpGoalRow)
        usageLimitRow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usageLimitRow)
    }

    private func setupLayout() {
        gradientView.frame = view.bounds

        NSLayoutConstraint.activate([
            // Back button
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            // Screen title
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // — Соотношение —
            multiplierSectionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            multiplierSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            multiplierRow.topAnchor.constraint(equalTo: multiplierSectionLabel.bottomAnchor, constant: 12),
            multiplierRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            multiplierRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // — Звуковые эффекты —
            soundSectionLabel.topAnchor.constraint(equalTo: multiplierRow.bottomAnchor, constant: 28),
            soundSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            soundEffectsRow.topAnchor.constraint(equalTo: soundSectionLabel.bottomAnchor, constant: 12),
            soundEffectsRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            soundEffectsRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // — Персональные цели —
            goalsSectionLabel.topAnchor.constraint(equalTo: soundEffectsRow.bottomAnchor, constant: 28),
            goalsSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            pushUpGoalRow.topAnchor.constraint(equalTo: goalsSectionLabel.bottomAnchor, constant: 12),
            pushUpGoalRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pushUpGoalRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            usageLimitRow.topAnchor.constraint(equalTo: pushUpGoalRow.bottomAnchor, constant: 12),
            usageLimitRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            usageLimitRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Helpers

private extension SettingsViewController {
    static func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
