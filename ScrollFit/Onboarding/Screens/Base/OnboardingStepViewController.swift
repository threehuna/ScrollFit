// OnboardingStepViewController.swift
// ScrollFit

import UIKit

/// Базовый VC для всех шагов онбординга.
///
/// Предоставляет:
/// - градиентный фон
/// - зелёную pill-кнопку действия внизу
///
/// Конфигурационные свойства (читаются контейнером):
/// `showsBackButton`, `showsProgressBar`, `stepProgress`
///
/// Подклассы добавляют свой контент в `view` и при необходимости
/// задают `actionButtonTitle`.
class OnboardingStepViewController: UIViewController {

    // MARK: - Callbacks

    var onNext: (() -> Void)?
    var onBack: (() -> Void)?

    // MARK: - Config (читается OnboardingContainerViewController)

    var showsBackButton: Bool  = false
    var showsProgressBar: Bool = false
    var stepProgress: Float    = 0

    // MARK: - UI

    private let gradientView = GradientBackgroundView()

    private(set) lazy var actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor(.scrollFitGreen)
        btn.setTitleColor(UIColor(.scrollFitBlack), for: .normal)
        btn.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 20)
                            ?? UIFont.systemFont(ofSize: 20, weight: .bold)
        btn.layer.cornerRadius = 31
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        return btn
    }()

    // MARK: - Configuration

    var actionButtonTitle: String = "Продолжить" {
        didSet { actionButton.setTitle(actionButtonTitle, for: .normal) }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupActionButton()
    }

    // MARK: - Setup

    private func setupBackground() {
        gradientView.frame = view.bounds
        view.insertSubview(gradientView, at: 0)
    }

    private func setupActionButton() {
        view.addSubview(actionButton)
        actionButton.setTitle(actionButtonTitle, for: .normal)

        NSLayoutConstraint.activate([
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 375),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            actionButton.heightAnchor.constraint(equalToConstant: 62),
        ])
    }

    // MARK: - Actions

    @objc private func actionTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onNext?()
    }
}
