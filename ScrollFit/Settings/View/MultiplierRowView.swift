// MultiplierRowView.swift
// ScrollFit

import UIKit

/// Pill-shaped row for selecting how many scroll minutes one push-up earns.
/// Design: Settings screen, nodes 624-2 / 644-3.
final class MultiplierRowView: UIView {

    // MARK: - Callback

    var onMultiplierChanged: ((Int) -> Void)?

    // MARK: - State

    private var currentMultiplier: Int = ActivityRepository.shared.scrollMinutesPerPushUp {
        didSet { updatePill() }
    }

    // MARK: - Subviews

    private let iconImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "pushIconWithArrows"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Отжимания"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// Green pill button: "N мин × повт." + chevron.down — shows UIMenu on tap.
    private lazy var pillButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 10)

        let chevron = UIImage(
            systemName: "chevron.down",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        )
        config.image = chevron

        let btn = UIButton(configuration: config)
        btn.tintColor = .white
        btn.layer.backgroundColor = UIColor.scrollFitGreen.withAlphaComponent(0.6).cgColor
        btn.layer.borderColor = UIColor.scrollFitGreen.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 12
        btn.showsMenuAsPrimaryAction = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let textStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .leading
        sv.spacing = 6
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupHierarchy()
        setupLayout()
        updatePill()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupAppearance() {
        backgroundColor = .clear
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 3
        layer.cornerRadius = 38
    }

    private func setupHierarchy() {
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(pillButton)

        addSubview(iconImageView)
        addSubview(textStack)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            // Icon
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),

            // Text stack (title + pill) — vertically centred, right of icon
            textStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            textStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            // Pill: fixed height, natural width (131 matches Figma)
            pillButton.heightAnchor.constraint(equalToConstant: 25),
            pillButton.widthAnchor.constraint(equalToConstant: 131),

            // Self height
            heightAnchor.constraint(equalToConstant: 76),
        ])
    }

    // MARK: - Private helpers

    private func updatePill() {
        var config = pillButton.configuration ?? UIButton.Configuration.plain()

        var attr = AttributedString("\(currentMultiplier) мин × повт.")
        attr.font = UIFont.systemFont(ofSize: 12, weight: .light)
        attr.foregroundColor = UIColor.white
        config.attributedTitle = attr

        pillButton.configuration = config
        pillButton.menu = makeMenu()
    }

    private func makeMenu() -> UIMenu {
        let actions = (1...5).map { value -> UIAction in
            UIAction(
                title: "\(value) мин",
                state: value == currentMultiplier ? .on : .off
            ) { [weak self] _ in
                self?.selectMultiplier(value)
            }
        }
        return UIMenu(title: "Минут за отжимание", children: actions)
    }

    private func selectMultiplier(_ value: Int) {
        currentMultiplier = value
        ActivityRepository.shared.setScrollMultiplier(value)
        onMultiplierChanged?(value)
    }

    // MARK: - Public

    func reload() {
        currentMultiplier = ActivityRepository.shared.scrollMinutesPerPushUp
    }
}
