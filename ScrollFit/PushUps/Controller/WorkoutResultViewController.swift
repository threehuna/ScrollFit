// WorkoutResultViewController.swift
// ScrollFit

import UIKit

/// Экран результата тренировки. Показывается после завершения сессии с >0 отжиманий.
/// Анимирует счётчик заработанных минут от 0 до earnedMinutes.
final class WorkoutResultViewController: UIViewController {

    // MARK: - Input

    let earnedMinutes: Int

    // MARK: - Callbacks

    var onClaim: (() -> Void)?

    // MARK: - Animation state

    private var displayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0
    private static let animationDuration: CFTimeInterval = 1.5

    // MARK: - Subviews

    private let gradientView = GradientBackgroundView()

    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let congratsLabel: UILabel = {
        let label = UILabel()
        label.text = "Поздравляем!"
        label.textColor = .white
        label.font = UIFont(name: "Helvetica-Bold", size: 35)
                  ?? UIFont.systemFont(ofSize: 35, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let rewardLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let phoneImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "phoneInHand"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let minutesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Helvetica-Bold", size: 35)
                  ?? UIFont.systemFont(ofSize: 35, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let rewardRow: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let claimButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Получить награду", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 25)
                            ?? UIFont.boldSystemFont(ofSize: 25)
        btn.backgroundColor = UIColor(.scrollFitGreen)
        btn.layer.cornerRadius = 31
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init

    init(earnedMinutes: Int) {
        self.earnedMinutes = earnedMinutes
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupRewardText()
        minutesLabel.text = "0 мин."
        backButton.addTarget(self, action: #selector(claimTapped), for: .touchUpInside)
        claimButton.addTarget(self, action: #selector(claimTapped), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCounterAnimation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        displayLink?.invalidate()
        displayLink = nil
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private func setupHierarchy() {
        view.insertSubview(gradientView, at: 0)
        view.addSubview(backButton)
        view.addSubview(congratsLabel)
        view.addSubview(rewardLabel)
        rewardRow.addArrangedSubview(phoneImageView)
        rewardRow.addArrangedSubview(minutesLabel)
        view.addSubview(rewardRow)
        view.addSubview(claimButton)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            congratsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            congratsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            rewardLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rewardLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            rewardLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            rewardLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            phoneImageView.widthAnchor.constraint(equalToConstant: 115),
            phoneImageView.heightAnchor.constraint(equalToConstant: 115),

            rewardRow.topAnchor.constraint(equalTo: rewardLabel.bottomAnchor, constant: 32),
            rewardRow.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            claimButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 39),
            claimButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -39),
            claimButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            claimButton.heightAnchor.constraint(equalToConstant: 62),
        ])
    }

    private func setupRewardText() {
        let font = UIFont(name: "Helvetica-Bold", size: 35)
                ?? UIFont.systemFont(ofSize: 35, weight: .bold)
        let fullText = "Ты можешь забрать свою награду"
        let greenWord = "награду"

        let attrs = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: font,
                .foregroundColor: UIColor.white,
            ]
        )
        if let range = fullText.range(of: greenWord) {
            attrs.addAttribute(
                .foregroundColor,
                value: UIColor(.scrollFitGreen),
                range: NSRange(range, in: fullText)
            )
        }
        rewardLabel.attributedText = attrs
    }

    // MARK: - Counter animation

    private func startCounterAnimation() {
        guard earnedMinutes > 0 else {
            minutesLabel.text = "0 мин."
            return
        }
        animationStartTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(updateCounter))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateCounter() {
        let elapsed = CACurrentMediaTime() - animationStartTime
        let progress = min(elapsed / Self.animationDuration, 1.0)
        // ease-out
        let eased = 1 - pow(1 - progress, 3)
        let current = Int(Double(earnedMinutes) * eased)
        minutesLabel.text = "\(current) мин."

        if progress >= 1.0 {
            minutesLabel.text = "\(earnedMinutes) мин."
            displayLink?.invalidate()
            displayLink = nil
        }
    }

    // MARK: - Actions

    @objc private func claimTapped() {
        onClaim?()
    }
}
