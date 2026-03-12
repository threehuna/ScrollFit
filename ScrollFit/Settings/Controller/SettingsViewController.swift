// SettingsViewController.swift
// ScrollFit

import UIKit

/// Экран настроек. Открывается push'ем из HomeViewController.
/// TODO: реализовать контент
final class SettingsViewController: UIViewController {

    weak var coordinator: HomeCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupAppearance()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Настройки"
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
        // Показываем nav bar для кнопки Back
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = UIColor(.scrollFitGreen)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        title = "Настройки"
    }
}
