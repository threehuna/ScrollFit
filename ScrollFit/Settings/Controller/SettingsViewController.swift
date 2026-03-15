// SettingsViewController.swift
// ScrollFit

import UIKit

/// Экран настроек. Открывается push'ем из HomeViewController.
final class SettingsViewController: UIViewController {

    weak var coordinator: HomeCoordinator?

    // MARK: - Subviews

    private let gradientView = GradientBackgroundView()

    private let multiplierRow = MultiplierRowView()

    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Соотношение"
        label.textColor = .scrollFitGray
        label.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupHierarchy()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        multiplierRow.reload()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private func setupAppearance() {
        gradientView.frame = view.bounds
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = UIColor(.scrollFitGreen)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        title = "Настройки"
    }

    private func setupHierarchy() {
        view.insertSubview(gradientView, at: 0)
        view.addSubview(sectionTitleLabel)

        multiplierRow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(multiplierRow)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            sectionTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            multiplierRow.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor, constant: 20),
            multiplierRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            multiplierRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
    }
}
