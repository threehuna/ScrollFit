// OnboardingCurrentScreenTimeViewController.swift
// ScrollFit

import UIKit

/// Экран 5: текущее экранное время пользователя.
/// Горизонтальный слайдер 1–16 часов, дефолт 8ч.
final class OnboardingCurrentScreenTimeViewController: OnboardingStepViewController {

    // MARK: - Dependencies

    private let userData: OnboardingUserData

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Сколько времени ты проводишь в телефоне в день?"
        label.font = UIFont(name: "Helvetica-Bold", size: 30)
                  ?? UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-Bold", size: 40)
                  ?? UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textColor = UIColor(red: 0, green: 0.765, blue: 1, alpha: 1) // #00C3FF
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let slider: OnboardingHorizontalSlider = {
        let s = OnboardingHorizontalSlider()
        s.minimumValue = 1
        s.maximumValue = 16
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // MARK: - Init

    init(userData: OnboardingUserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        showsBackButton   = true
        showsProgressBar  = true
        stepProgress      = 4.0 / 5.0
        actionButtonTitle = "Продолжить"

        slider.setValue(userData.currentScreenTimeHours, animated: false)
        updateValueLabel(slider.value)
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

        setupContent()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private func setupContent() {
        [titleLabel, valueLabel, slider].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 63),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 39),
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -39),

            valueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            valueLabel.centerYAnchor.constraint(
                equalTo: view.centerYAnchor, constant: -50),

            slider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            slider.widthAnchor.constraint(equalToConstant: 320),
            slider.heightAnchor.constraint(equalToConstant: 53),
            slider.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 16),
        ])
    }

    // MARK: - Actions

    @objc private func sliderChanged() {
        updateValueLabel(slider.value)
        userData.currentScreenTimeHours = slider.value
    }

    private func updateValueLabel(_ hours: Int) {
        valueLabel.text = "\(hours)ч"
    }
}
