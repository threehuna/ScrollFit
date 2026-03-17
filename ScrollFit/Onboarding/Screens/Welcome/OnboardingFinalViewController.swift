// OnboardingFinalViewController.swift
// ScrollFit

import UIKit

/// Экран 12 (последний): «Добро пожаловать!»
/// Показывает логотип, картинку muscleBody и приветственный текст.
final class OnboardingFinalViewController: OnboardingStepViewController {

    // MARK: - UI

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "scrollFitLogo")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "ScrollFit"
        label.font = UIFont(name: "Helvetica-Bold", size: 35)
                  ?? UIFont.systemFont(ofSize: 35, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let muscleImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "muscleBody")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Добро пожаловать!"
        label.font = UIFont(name: "Helvetica-Bold", size: 30)
                  ?? UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = UIColor(.scrollFitGreen)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Поборем зависимость от думскроллинга вместе"
        label.font = UIFont(name: "Helvetica-Light", size: 30)
                  ?? UIFont.systemFont(ofSize: 30, weight: .light)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        showsBackButton  = false
        showsProgressBar = false
        actionButtonTitle = "Давай!"
        setupContent()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private func setupContent() {
        [logoImageView, logoLabel, muscleImageView,
         welcomeLabel, subtitleLabel].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            // Лого: иконка + текст
            logoImageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 63),
            logoImageView.widthAnchor.constraint(equalToConstant: 46),
            logoImageView.heightAnchor.constraint(equalToConstant: 46),

            logoLabel.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),
            logoLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 8),

            // Центрируем пару лого+текст
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 104),

            // Картинка muscleBody
            muscleImageView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            muscleImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            muscleImageView.widthAnchor.constraint(equalToConstant: 298),
            muscleImageView.heightAnchor.constraint(equalToConstant: 298),

            // "Добро пожаловать!"
            welcomeLabel.topAnchor.constraint(equalTo: muscleImageView.bottomAnchor, constant: 32),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            // Подзаголовок
            subtitleLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
        ])
    }
}
