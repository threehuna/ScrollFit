// OnboardingGoalsViewController.swift
// ScrollFit

import UIKit

/// Экран 2: выбор целей онбординга.
/// Множественный выбор — пользователь может отметить несколько вариантов.
final class OnboardingGoalsViewController: OnboardingStepViewController {

    // MARK: - Dependencies

    private let userData: OnboardingUserData

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Каких целей ты хочешь достичь?"
        label.font = UIFont(name: "Helvetica-Bold", size: 40)
                  ?? UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var goalViews: [GoalOptionView] = []

    // MARK: - Init

    init(userData: OnboardingUserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        showsBackButton    = true
        showsProgressBar   = true
        stepProgress       = 1.0 / 5.0
        actionButtonTitle  = "Продолжить"
        setupContent()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private func setupContent() {
        view.addSubview(titleLabel)

        goalViews = OnboardingGoal.allCases.map { goal in
            let optionView = GoalOptionView(goal: goal)
            optionView.translatesAutoresizingMaskIntoConstraints = false
            optionView.addTarget(self, action: #selector(goalTapped(_:)), for: .touchUpInside)
            view.addSubview(optionView)
            return optionView
        }

        // Title: center-y=179 in Figma → top ≈ 63pt from safe area
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 63),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 39),
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -39),
        ])

        // Goal rows: first at titleLabel.bottom + 49, then spaced 21pt apart
        var previousAnchor: NSLayoutYAxisAnchor = titleLabel.bottomAnchor
        var spacing: CGFloat = 125

        for optionView in goalViews {
            NSLayoutConstraint.activate([
                optionView.topAnchor.constraint(
                    equalTo: previousAnchor, constant: spacing),
                optionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                optionView.widthAnchor.constraint(equalToConstant: 375),
                optionView.heightAnchor.constraint(equalToConstant: 68),
            ])
            previousAnchor = optionView.bottomAnchor
            spacing = 21
        }
    }

    // MARK: - Actions

    @objc private func goalTapped(_ sender: GoalOptionView) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        sender.isSelected.toggle()
        if sender.isSelected {
            userData.goals.insert(sender.goal)
        } else {
            userData.goals.remove(sender.goal)
        }
    }
}
