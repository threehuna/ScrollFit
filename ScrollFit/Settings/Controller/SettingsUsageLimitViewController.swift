// SettingsUsageLimitViewController.swift
// ScrollFit

import UIKit

/// Экран изменения лимита по использованию (минуты скролла в день) из Настроек.
final class SettingsUsageLimitViewController: UIViewController {

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
        label.text = "Лимит по использованию"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Сколько минут в день ты хочешь тратить на скролл?"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
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

    // MARK: - State

    private static let rowHeight: CGFloat = 60
    private static let maxMinutes = 1440
    private static let step = 5

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        pickerView.dataSource = self
        pickerView.delegate = self
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        let current = UserGoalsRepository.shared.goals.scrollMinutesGoal
        let initial = max(0, min(current / Self.step, Self.maxMinutes / Self.step))
        pickerView.selectRow(initial, inComponent: 1, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hideDefaultPickerLines()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        mainTabBarController?.setCustomTabBarHidden(true)
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
        view.addSubview(subtitleLabel)
        view.addSubview(pickerView)
        view.addSubview(topSeparator)
        view.addSubview(bottomSeparator)
    }

    private func setupLayout() {
        gradientView.frame = view.bounds
        let half = Self.rowHeight / 2

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.widthAnchor.constraint(equalToConstant: 280),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60),
            pickerView.heightAnchor.constraint(equalToConstant: 280),

            topSeparator.leadingAnchor.constraint(equalTo: pickerView.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor),
            topSeparator.centerYAnchor.constraint(equalTo: pickerView.centerYAnchor, constant: -half),
            topSeparator.heightAnchor.constraint(equalToConstant: 1),

            bottomSeparator.leadingAnchor.constraint(equalTo: pickerView.leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor),
            bottomSeparator.centerYAnchor.constraint(equalTo: pickerView.centerYAnchor, constant: half),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    private func hideDefaultPickerLines() {
        pickerView.subviews.forEach { subview in
            if subview.frame.height <= 1.5 { subview.isHidden = true }
        }
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UIPickerViewDataSource

extension SettingsUsageLimitViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        component == 0 ? 1 : Self.maxMinutes / Self.step + 1
    }
}

// MARK: - UIPickerViewDelegate

extension SettingsUsageLimitViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView,
                    rowHeightForComponent component: Int) -> CGFloat { Self.rowHeight }

    func pickerView(_ pickerView: UIPickerView,
                    widthForComponent component: Int) -> CGFloat { 120 }

    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int, forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Helvetica-Bold", size: 40)
                  ?? UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textAlignment = component == 0 ? .left : .right
        label.text = component == 0 ? "мин" : "\(row * Self.step)"
        return label
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int, inComponent component: Int) {
        guard component == 1 else { return }
        UserGoalsRepository.shared.update(scrollMinutesGoal: row * Self.step)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
