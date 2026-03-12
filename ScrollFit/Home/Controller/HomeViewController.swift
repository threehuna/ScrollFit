// HomeViewController.swift
// ScrollFit

import UIKit

/// Главный экран: диаграммы, прогресс, календарь.
/// TODO: реализовать контент
final class HomeViewController: UIViewController {

    weak var coordinator: HomeCoordinator?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupAppearance()
        setupActions()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Главный экран"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    private let settingsButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        btn.setImage(UIImage(systemName: "gearshape", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private func setupHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(settingsButton)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

        ])
    }

    private func setupAppearance() {
        view.backgroundColor = UIColor(red: 0.196, green: 0.192, blue: 0.196, alpha: 1)
        navigationController?.navigationBar.isHidden = true
    }

    private func setupActions() {
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func startWorkoutTapped() {
        coordinator?.requestWorkout()
    }

    @objc private func settingsTapped() {
        coordinator?.showSettings()
    }
}
