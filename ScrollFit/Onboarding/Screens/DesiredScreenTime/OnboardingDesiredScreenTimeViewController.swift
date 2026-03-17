// OnboardingDesiredScreenTimeViewController.swift
// ScrollFit

import UIKit

/// Экран 6: желаемое экранное время.
/// Горизонтальный слайдер 1…currentScreenTimeHours, дефолт min(5, currentScreenTimeHours - 1).
/// Если на экране 5 выбран 1 час — этот экран пропускается координатором.
final class OnboardingDesiredScreenTimeViewController: OnboardingStepViewController {

    // MARK: - Dependencies

    private let userData: OnboardingUserData

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Сколько времени в телефоне ты хотел бы проводить?"
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
        label.textColor = UIColor(.scrollFitGreen)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let slider: OnboardingHorizontalSlider = {
        let s = OnboardingHorizontalSlider()
        s.fillColor = UIColor(.scrollFitGreen)
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
        stepProgress      = 5.0 / 5.0
        actionButtonTitle = "Продолжить"

        slider.minimumValue = 1
        slider.maximumValue = userData.currentScreenTimeHours

        let clamped = max(1, userData.currentScreenTimeHours - Self.defaultReduction(for: userData.currentScreenTimeHours))
        slider.setValue(clamped, animated: false)
        userData.desiredScreenTimeHours = slider.value
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
        userData.desiredScreenTimeHours = slider.value
    }

    private func updateValueLabel(_ hours: Int) {
        valueLabel.text = "\(hours)ч"
    }

    // MARK: - Default reduction

    private static func defaultReduction(for hours: Int) -> Int {
        switch hours {
        case 2:      return 0
        case 3...5:  return 1
        case 6...7:  return 2
        case 8...10: return 3
        case 11...12: return 4
        case 13...15: return 5
        default:     return 6  // 16
        }
    }
}
