// OnboardingContainerViewController.swift
// ScrollFit

import UIKit

/// Контейнер онбординга. Управляет стеком экранов и кастомными переходами.
/// - Вперёд: fade easeInOut (0.3s)
/// - Назад:  fade easeInOut (0.25s)
///
/// Прогресс-бар и кнопка «назад» живут здесь как постоянный overlay —
/// это устраняет моргание и позволяет прогресс-бару плавно продолжать
/// анимацию от текущей позиции.
final class OnboardingContainerViewController: UIViewController {

    // MARK: - State

    private var stack: [UIViewController] = []

    // MARK: - Overlay UI (создаются в viewDidLoad)

    private var backButton: UIButton!
    private var progressBarView: OnboardingProgressBarView!

    // MARK: - Status bar

    override var childForStatusBarStyle: UIViewController? { stack.last }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupOverlay()
    }

    // MARK: - Setup

    private func setupBackground() {
        let gradient = GradientBackgroundView()
        gradient.frame = view.bounds
        gradient.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradient)
    }

    private func setupOverlay() {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.isHidden  = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton = btn

        let bar = OnboardingProgressBarView()
        bar.isHidden = true
        bar.translatesAutoresizingMaskIntoConstraints = false
        progressBarView = bar

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

    // MARK: - Navigation

    func pushViewController(_ incoming: UIViewController, animated: Bool) {
        // Загружаем view (и overlay) если ещё не загружен
        loadViewIfNeeded()

        let outgoing = stack.last
        stack.append(incoming)

        addChild(incoming)
        incoming.view.frame = view.bounds
        incoming.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Вставляем под overlay
        view.insertSubview(incoming.view, belowSubview: backButton)
        incoming.didMove(toParent: self)

        if animated, let outgoing {
            incoming.view.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                incoming.view.alpha = 1
                outgoing.view.alpha = 0
            } completion: { _ in
                self.detach(outgoing, resetAlpha: true)
            }
        } else {
            outgoing.map { detach($0, resetAlpha: false) }
        }

        updateTopBar(for: incoming, animated: animated)
    }

    func popViewController(animated: Bool) {
        guard stack.count > 1 else { return }
        let outgoing = stack.removeLast()
        let incoming = stack.last!

        addChild(incoming)
        incoming.view.frame = view.bounds
        incoming.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.insertSubview(incoming.view, belowSubview: backButton)
        incoming.didMove(toParent: self)

        if animated {
            incoming.view.alpha = 0
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                incoming.view.alpha = 1
                outgoing.view.alpha = 0
            } completion: { _ in
                self.detach(outgoing, resetAlpha: true)
            }
        } else {
            detach(outgoing, resetAlpha: false)
        }

        updateTopBar(for: incoming, animated: animated)
    }

    // MARK: - Top Bar Update

    private func updateTopBar(for vc: UIViewController, animated: Bool) {
        guard let step = vc as? OnboardingStepViewController else {
            backButton.isHidden    = true
            progressBarView.isHidden = true
            return
        }

        // Загружаем view шага, чтобы viewDidLoad успел выставить конфиг-свойства
        step.loadViewIfNeeded()

        backButton.isHidden      = !step.showsBackButton
        progressBarView.isHidden = !step.showsProgressBar

        if step.showsProgressBar {
            progressBarView.setProgress(step.stepProgress, animated: animated)
        }
    }

    // MARK: - Actions

    @objc private func backTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        (stack.last as? OnboardingStepViewController)?.onBack?()
    }

    // MARK: - Private

    private func detach(_ vc: UIViewController, resetAlpha: Bool) {
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
        if resetAlpha { vc.view.alpha = 1 }
    }
}
