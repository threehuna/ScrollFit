// OnboardingTimeReturnViewController.swift
// ScrollFit

import UIKit

/// Экран 8: сколько лет свободного времени вернёт ScrollFit.
/// Формула: floor((currentHours - desiredHours) × 50 / 24)
/// Где 50 — допущение оставшихся лет жизни (~25 лет, живёт до ~75).
final class OnboardingTimeReturnViewController: OnboardingStepViewController {

    // MARK: - Data

    private let savedYears: Int

    // MARK: - UI

    private let topLabel: UILabel = {
        let label = UILabel()
        label.text = "ScrollFit поможет вернуть"
        label.font = UIFont(name: "Helvetica-Bold", size: 40)
                  ?? UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let yearsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-Bold", size: 55)
                  ?? UIFont.systemFont(ofSize: 55, weight: .bold)
        label.textColor = UIColor(.scrollFitGreen)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.text = "твоего свободного времени\nи достичь целей"
        label.font = UIFont(name: "Helvetica", size: 30)
                  ?? UIFont.systemFont(ofSize: 30, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    init(userData: OnboardingUserData) {
        let savings = max(0, userData.currentScreenTimeHours - userData.desiredScreenTimeHours)
        savedYears = max(1, Int(Double(savings) * 50.0 / 24.0))
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        showsBackButton   = true
        showsProgressBar  = false
        actionButtonTitle = "Продолжить"

        yearsLabel.text = "\(savedYears)+ лет"
        setupContent()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private func setupContent() {
        [topLabel, yearsLabel, bottomLabel].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            topLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            topLabel.bottomAnchor.constraint(equalTo: yearsLabel.topAnchor, constant: -32),

            yearsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            yearsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),

            bottomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            bottomLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            bottomLabel.topAnchor.constraint(equalTo: yearsLabel.bottomAnchor, constant: 32),
        ])
    }
}
