// OnboardingWelcomeViewController.swift
// ScrollFit

import UIKit

/// Первый экран онбординга — "Твоя энергия - твоя сила!"
/// Статичный экран без прогресс-бара и кнопки "назад".
final class OnboardingWelcomeViewController: OnboardingStepViewController {

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Твоя энергия -\nтвоя сила!"
        label.font = UIFont(name: "Helvetica-Bold", size: 40)
                  ?? UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Считай отжимания и превращай усилие в результат."
        label.font = UIFont(name: "Helvetica-Bold", size: 18)
                  ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(white: 0.73, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let pushUpImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "pushGuy"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let rewardLabel: UILabel = {
        let label = UILabel()
        label.text = "+5 мин"
        label.font = UIFont(name: "Helvetica-Bold", size: 20)
                  ?? UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor(.scrollFitGreen)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = OnboardingWelcomeViewController.makeBodyText()
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        actionButtonTitle = "Начнём!"
        setupContent()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private func setupContent() {
        [titleLabel, subtitleLabel, pushUpImageView, rewardLabel, bodyLabel]
            .forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            // Заголовок: ~59pt ниже safe area (совпадает с Figma: 118pt от верха экрана)
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 59),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 33),
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -33),

            // Подзаголовок
            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 39),
            subtitleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -33),

            // Иллюстрация
            pushUpImageView.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor, constant: 10),
            pushUpImageView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 40),
            pushUpImageView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -30),
            pushUpImageView.heightAnchor.constraint(equalToConstant: 216),

            // "+5 мин"
            rewardLabel.topAnchor.constraint(
                equalTo: pushUpImageView.bottomAnchor, constant: 8),
            rewardLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Текст внизу: прикреплён к кнопке снизу
            bodyLabel.bottomAnchor.constraint(
                equalTo: actionButton.topAnchor, constant: -24),
            bodyLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 39),
            bodyLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -33),
        ])
    }

    // MARK: - Helpers

    private static func makeBodyText() -> NSAttributedString {
        let fullText = "Получи персональную программу, чтобы дать твоему потенциалу раскрыться"
        let grayFont  = UIFont(name: "Helvetica-Bold", size: 15)
                     ?? UIFont.systemFont(ofSize: 15, weight: .bold)
        let gray  = UIColor(white: 0.73, alpha: 1)
        let green = UIColor(.scrollFitGreen)

        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [.font: grayFont, .foregroundColor: gray]
        )

        for highlight in ["персональную", "твоему потенциалу"] {
            if let range = fullText.range(of: highlight) {
                attributed.addAttribute(
                    .foregroundColor, value: green,
                    range: NSRange(range, in: fullText)
                )
            }
        }
        return attributed
    }
}
