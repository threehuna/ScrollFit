// OnboardingStepViewController.swift
// ScrollFit

import UIKit

/// Базовый VC для всех шагов онбординга.
///
/// Предоставляет:
/// - градиентный фон
/// - кнопку «назад» (скрыта по умолчанию)
/// - прогресс-бар справа от кнопки «назад» (скрыт по умолчанию)
/// - зелёную pill-кнопку действия внизу
///
/// Подклассы добавляют свой контент в `view` и при необходимости
/// конфигурируют `showsBackButton`, `showsProgressBar`, `stepProgress`,
/// `actionButtonTitle`.
class OnboardingStepViewController: UIViewController {

    // MARK: - Callbacks

    var onNext: (() -> Void)?
    var onBack: (() -> Void)?

    // MARK: - UI

    private let gradientView = GradientBackgroundView()

    private(set) lazy var backButton: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.isHidden  = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return btn
    }()

    private(set) lazy var progressBarView: OnboardingProgressBarView = {
        let v = OnboardingProgressBarView()
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

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

    var showsBackButton: Bool = false {
        didSet { backButton.isHidden = !showsBackButton }
    }

    var showsProgressBar: Bool = false {
        didSet { progressBarView.isHidden = !showsProgressBar }
    }

    var stepProgress: Float = 0 {
        didSet { progressBarView.progress = stepProgress }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupTopBar()
        setupActionButton()
    }

    // MARK: - Setup

    private func setupBackground() {
        gradientView.frame = view.bounds
        view.insertSubview(gradientView, at: 0)
    }

    private func setupTopBar() {
        view.addSubview(backButton)
        view.addSubview(progressBarView)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            progressBarView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            progressBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            progressBarView.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            progressBarView.heightAnchor.constraint(equalToConstant: 8),
        ])
    }

    private func setupActionButton() {
        view.addSubview(actionButton)
        actionButton.setTitle(actionButtonTitle, for: .normal)

        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            actionButton.heightAnchor.constraint(equalToConstant: 62),
        ])
    }

    // MARK: - Actions

    @objc private func actionTapped() { onNext?() }
    @objc private func backTapped()   { onBack?() }
}
