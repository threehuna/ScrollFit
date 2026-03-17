// OnboardingPhoneInfluenceViewController.swift
// ScrollFit

import UIKit

/// Экран 7: сравнение влияния телефона.
/// Формула: userPercent = 3 × currentScreenTimeHours + 48
/// Правый столбец фиксирован: 33% (конкурент).
final class OnboardingPhoneInfluenceViewController: OnboardingStepViewController {

    // MARK: - Data

    private let userPercent: Int
    private static let averagePercent = 33
    private static let maxBarHeight: CGFloat = 280

    private var difference: Int { abs(userPercent - Self.averagePercent) }
    private var isAboveAverage: Bool { userPercent > Self.averagePercent }

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Плохие новости..."
        label.font = UIFont(name: "Helvetica-Bold", size: 35)
                  ?? UIFont.systemFont(ofSize: 35, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Твой телефон оказывает негативное влияние сильнее, чем у других*"
        label.font = UIFont(name: "Helvetica", size: 20)
                  ?? UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Левый столбец
    private let leftBarView = GradientBarView(
        colors: [UIColor(red: 0, green: 0.765, blue: 1, alpha: 1), .white]
    )
    private let leftPercentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-Bold", size: 20)
                  ?? UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let leftCaptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Твой\nрезультат"
        label.font = UIFont(name: "Helvetica-Bold", size: 15)
                  ?? UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Правый столбец
    private let rightBarView = GradientBarView(
        colors: [UIColor(red: 0.647, green: 0.945, blue: 0.2, alpha: 1), .white]
    )
    private let rightPercentLabel: UILabel = {
        let label = UILabel()
        label.text = "33%"
        label.font = UIFont(name: "Helvetica-Bold", size: 20)
                  ?? UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let rightCaptionLabel: UILabel = {
        let label = UILabel()
        label.text = "В среднем"
        label.font = UIFont(name: "Helvetica-Bold", size: 15)
                  ?? UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let comparisonLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let disclaimerLabel: UILabel = {
        let label = UILabel()
        label.text = "*Не психологический диагноз"
        label.font = UIFont(name: "Helvetica-Bold", size: 15)
                  ?? UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = UIColor(white: 0.73, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Height constraints animated on appear
    private var leftBarHeightConstraint: NSLayoutConstraint!
    private var rightBarHeightConstraint: NSLayoutConstraint!

    // MARK: - Init

    init(userData: OnboardingUserData) {
        userPercent = min(100, 3 * userData.currentScreenTimeHours + 48)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        showsBackButton   = true
        showsProgressBar  = false
        actionButtonTitle = "Продолжить"

        leftPercentLabel.text = "\(userPercent)%"
        setupComparisonLabel()
        setupContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateBars()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private func setupContent() {
        [leftBarView, leftPercentLabel,
         rightBarView, rightPercentLabel,
         leftCaptionLabel, rightCaptionLabel,
         titleLabel, subtitleLabel,
         comparisonLabel, disclaimerLabel].forEach { view.addSubview($0) }

        leftBarView.translatesAutoresizingMaskIntoConstraints = false
        rightBarView.translatesAutoresizingMaskIntoConstraints = false

        let barWidth: CGFloat = 53
        let barSpacing: CGFloat = 69          // gap between bars
        let totalBarsWidth = barWidth * 2 + barSpacing  // 175

        // Height constraints start at 0 for animation
        leftBarHeightConstraint  = leftBarView.heightAnchor.constraint(equalToConstant: 0)
        rightBarHeightConstraint = rightBarView.heightAnchor.constraint(equalToConstant: 0)

        // Horizontal center of bar pair — shift slightly left to match design
        // Left bar center = 157.5, right bar center = 279.5, pair center = 218.5
        let barsCenterX: CGFloat = 218.5

        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 63),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 39),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -39),

            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            // Left bar — bottom aligned with right bar
            leftBarView.widthAnchor.constraint(equalToConstant: barWidth),
            leftBarHeightConstraint,
            leftBarView.centerXAnchor.constraint(
                equalTo: view.leadingAnchor, constant: barsCenterX - barWidth / 2 - barSpacing / 2),
            leftBarView.bottomAnchor.constraint(
                equalTo: view.centerYAnchor, constant: 100),

            // Right bar
            rightBarView.widthAnchor.constraint(equalToConstant: barWidth),
            rightBarHeightConstraint,
            rightBarView.centerXAnchor.constraint(
                equalTo: view.leadingAnchor, constant: barsCenterX + barWidth / 2 + barSpacing / 2),
            rightBarView.bottomAnchor.constraint(equalTo: leftBarView.bottomAnchor),

            // Percent labels (inside top of bars)
            leftPercentLabel.centerXAnchor.constraint(equalTo: leftBarView.centerXAnchor),
            leftPercentLabel.topAnchor.constraint(equalTo: leftBarView.topAnchor, constant: 8),

            rightPercentLabel.centerXAnchor.constraint(equalTo: rightBarView.centerXAnchor),
            rightPercentLabel.topAnchor.constraint(equalTo: rightBarView.topAnchor, constant: 8),

            // Captions below bars
            leftCaptionLabel.centerXAnchor.constraint(equalTo: leftBarView.centerXAnchor),
            leftCaptionLabel.topAnchor.constraint(equalTo: leftBarView.bottomAnchor, constant: 12),

            rightCaptionLabel.centerXAnchor.constraint(equalTo: rightBarView.centerXAnchor),
            rightCaptionLabel.topAnchor.constraint(equalTo: rightBarView.bottomAnchor, constant: 12),

            // Comparison text
            comparisonLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            comparisonLabel.topAnchor.constraint(equalTo: leftCaptionLabel.bottomAnchor, constant: 24),
            comparisonLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            comparisonLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            // Disclaimer
            disclaimerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            disclaimerLabel.bottomAnchor.constraint(
                equalTo: actionButton.topAnchor, constant: -16),
        ])
    }

    private func setupComparisonLabel() {
        let highlightColor = isAboveAverage
            ? UIColor(red: 0, green: 0.765, blue: 1, alpha: 1)  // #00C3FF
            : UIColor(.scrollFitGreen)
        let direction = isAboveAverage ? "выше" : "ниже"
        let highlighted = "\(difference)% \(direction)"
        let full = "На \(highlighted), чем в среднем"

        let attr = NSMutableAttributedString(
            string: full,
            attributes: [
                .font: UIFont(name: "Helvetica-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: UIColor.white,
            ]
        )
        if let range = full.range(of: highlighted) {
            let nsRange = NSRange(range, in: full)
            attr.addAttribute(.foregroundColor, value: highlightColor, range: nsRange)
        }
        comparisonLabel.attributedText = attr
    }

    // MARK: - Animation

    private func animateBars() {
        let leftTarget  = Self.maxBarHeight * CGFloat(userPercent) / 100
        let rightTarget = Self.maxBarHeight * CGFloat(Self.averagePercent) / 100

        UIView.animate(withDuration: 0.8, delay: 0.1, options: .curveEaseInOut) {
            self.leftBarHeightConstraint.constant  = leftTarget
            self.rightBarHeightConstraint.constant = rightTarget
            self.view.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.leftPercentLabel.alpha  = 1
                self.rightPercentLabel.alpha = 1
            }
        }
    }
}

// MARK: - GradientBarView

private final class GradientBarView: UIView {

    private let gradientLayer = CAGradientLayer()

    init(colors: [UIColor]) {
        super.init(frame: .zero)
        layer.cornerRadius = 10
        clipsToBounds = true
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        layer.addSublayer(gradientLayer)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        CATransaction.commit()
    }
}
