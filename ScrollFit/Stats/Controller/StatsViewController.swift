// StatsViewController.swift
// ScrollFit

import UIKit

/// Экран статистики.
final class StatsViewController: UIViewController {

    weak var coordinator: StatsCoordinator?

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
        label.text = "Статистика"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    private let gradientView = GradientBackgroundView()

    private func setupHierarchy() {
        view.insertSubview(gradientView, at: 0)
        view.addSubview(titleLabel)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupAppearance() {
        gradientView.frame = view.bounds
        navigationController?.navigationBar.isHidden = true
    }

    private func setupActions() {
       
    }

    @objc private func startWorkoutTapped() {
        coordinator?.requestWorkout()
    }
}
