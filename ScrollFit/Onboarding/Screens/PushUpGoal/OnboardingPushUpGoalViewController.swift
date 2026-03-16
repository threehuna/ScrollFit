// OnboardingPushUpGoalViewController.swift
// ScrollFit

import UIKit

/// Экран 4: выбор цели по отжиманиям.
/// Барабанный пикер: левая колонка — «повт.», правая — 1…200 (шаг 1, дефолт 25).
final class OnboardingPushUpGoalViewController: OnboardingStepViewController {

    // MARK: - Dependencies

    private let userData: OnboardingUserData

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Выбери цель по отжиманиям"
        label.font = UIFont(name: "Helvetica-Bold", size: 40)
                  ?? UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Сколько в день тебе хотелось бы отжиматься?"
        label.font = UIFont(name: "Helvetica", size: 18)
                  ?? UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor(white: 0.73, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let pickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.backgroundColor = .clear
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()

    private let topSeparator: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let bottomSeparator: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Constants

    private static let rowHeight: CGFloat = 60
    private static let maxReps = 1000

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
        stepProgress      = 3.0 / 5.0
        actionButtonTitle = "Продолжить"

        pickerView.dataSource = self
        pickerView.delegate   = self

        setupContent()

        let initial = max(0, min(userData.pushUpGoal - 1, Self.maxReps - 1))
        pickerView.selectRow(initial, inComponent: 1, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hideDefaultPickerLines()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private func setupContent() {
        [titleLabel, subtitleLabel, pickerView,
         topSeparator, bottomSeparator].forEach { view.addSubview($0) }

        let half = Self.rowHeight / 2

        NSLayoutConstraint.activate([
            // Заголовок
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 63),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 39),
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -39),

            // Подзаголовок
            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 39),
            subtitleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -24),

            // Пикер
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.widthAnchor.constraint(equalToConstant: 280),
            pickerView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor, constant: 60),
            pickerView.heightAnchor.constraint(equalToConstant: 280),

            // Линии-разделители
            topSeparator.leadingAnchor.constraint(equalTo: pickerView.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor),
            topSeparator.centerYAnchor.constraint(
                equalTo: pickerView.centerYAnchor, constant: -half),
            topSeparator.heightAnchor.constraint(equalToConstant: 1),

            bottomSeparator.leadingAnchor.constraint(equalTo: pickerView.leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor),
            bottomSeparator.centerYAnchor.constraint(
                equalTo: pickerView.centerYAnchor, constant: half),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    private func hideDefaultPickerLines() {
        pickerView.subviews.forEach { subview in
            if subview.frame.height <= 1.5 {
                subview.isHidden = true
            }
        }
    }
}

// MARK: - UIPickerViewDataSource

extension OnboardingPushUpGoalViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        component == 0 ? 1 : Self.maxReps
    }
}

// MARK: - UIPickerViewDelegate

extension OnboardingPushUpGoalViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView,
                    rowHeightForComponent component: Int) -> CGFloat {
        Self.rowHeight
    }

    func pickerView(_ pickerView: UIPickerView,
                    widthForComponent component: Int) -> CGFloat {
        120
    }

    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int, forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.textColor     = .white
        label.font          = UIFont(name: "Helvetica-Bold", size: 40)
                           ?? UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textAlignment = component == 0 ? .left : .right
        label.text          = component == 0 ? "повт." : "\(row + 1)"
        return label
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int, inComponent component: Int) {
        guard component == 1 else { return }
        userData.pushUpGoal = row + 1
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
