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

    private func setupHierarchy() {
        view.addSubview(titleLabel)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupAppearance() {
        view.backgroundColor = UIColor(red: 0.196, green: 0.192, blue: 0.196, alpha: 1)
        // Показываем nav bar для кнопки Back
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = UIColor(red: 0.647, green: 0.945, blue: 0.200, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        title = "Настройки"
    }
}
