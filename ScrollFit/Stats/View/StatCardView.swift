// StatCardView.swift
// ScrollFit

import UIKit

struct StatCardViewModel {
    let icon: UIImage?
    let iconTintColor: UIColor
    let value: String
    let description: String
    let category: String
    let categoryFontSize: CGFloat
    let badge: String?

    init(
        icon: UIImage?,
        iconTintColor: UIColor = UIColor(.scrollFitGreen),
        value: String,
        description: String,
        category: String,
        categoryFontSize: CGFloat = 20,
        badge: String? = nil
    ) {
        self.icon = icon
        self.iconTintColor = iconTintColor
        self.value = value
        self.description = description
        self.category = category
        self.categoryFontSize = categoryFontSize
        self.badge = badge
    }
}

final class StatCardView: UIView {

    // MARK: - Layer structure
   

    private let shadowView  = UIView()
    private let borderView  = UIView()

    // MARK: - Content subviews (живут внутри borderView)

    private let iconView         = UIImageView()
    private let infoButton       = UIButton(type: .system)
    private let badgeContainer   = UIView()
    private let badgeLabel       = UILabel()
    private let valueLabel       = UILabel()
    private let descriptionLabel = UILabel()
    private let categoryLabel    = UILabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupShadowView()
        setupBorderView()
        setupHierarchy()
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        shadowView.frame = bounds
        borderView.frame = bounds
        // Явный shadowPath — тень строго по форме карточки
        shadowView.layer.shadowPath = UIBezierPath(
            roundedRect: shadowView.bounds,
            cornerRadius: shadowView.layer.cornerRadius
        ).cgPath
    }

    // MARK: - Public

    var onInfoTapped: ((UIButton) -> Void)?

    func configure(with vm: StatCardViewModel) {
        iconView.image        = vm.icon
        iconView.tintColor    = vm.iconTintColor
        valueLabel.text       = vm.value
        descriptionLabel.text = vm.description
        categoryLabel.text    = vm.category
        categoryLabel.font    = .boldSystemFont(ofSize: vm.categoryFontSize)

        if let badge = vm.badge {
            badgeLabel.text         = badge
            badgeContainer.isHidden = false
        } else {
            badgeContainer.isHidden = true
        }
    }

    // MARK: - Private setup

    private func setupShadowView() {
        // Тёмный фон нужен, чтобы тень не просачивалась сквозь прозрачную карточку.
        // alpha = 0.75 — достаточно тёмный, но немного просвечивает градиент фона.
        shadowView.backgroundColor = UIColor(.scrollFitBlack).withAlphaComponent(0.85)
        shadowView.layer.cornerRadius = 30
        shadowView.layer.shadowColor   = UIColor(.scrollFitGreen).cgColor
        shadowView.layer.shadowOffset  = .zero
        shadowView.layer.shadowRadius  = 10
        shadowView.layer.shadowOpacity = 0.6
        addSubview(shadowView)
    }

    private func setupBorderView() {
        borderView.backgroundColor = .clear
        borderView.layer.cornerRadius = 30
        borderView.layer.borderWidth  = 2
        borderView.layer.borderColor  = UIColor(.scrollFitGreen).cgColor
        borderView.clipsToBounds      = true
        addSubview(borderView)
    }

    private func setupHierarchy() {
        // Icon
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        borderView.addSubview(iconView)

        // Info button
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        infoButton.setImage(UIImage(systemName: "info.circle", withConfiguration: cfg), for: .normal)
        infoButton.tintColor = UIColor.white.withAlphaComponent(0.6)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        borderView.addSubview(infoButton)

        // Badge
        badgeContainer.backgroundColor = UIColor(red: 60/255, green: 255/255, blue: 125/255, alpha: 0.29)
        badgeContainer.layer.cornerRadius = 10
        badgeContainer.translatesAutoresizingMaskIntoConstraints = false
        borderView.addSubview(badgeContainer)

        badgeLabel.font      = .systemFont(ofSize: 10)
        badgeLabel.textColor = UIColor(red: 60/255, green: 255/255, blue: 125/255, alpha: 1)
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeContainer.addSubview(badgeLabel)

        // Value — 30pt bold, белый glow только на цифре
        valueLabel.font             = .boldSystemFont(ofSize: 30)
        valueLabel.textColor        = .white
        valueLabel.layer.shadowColor   = UIColor.white.withAlphaComponent(0.5).cgColor
        valueLabel.layer.shadowOffset  = .zero
        valueLabel.layer.shadowRadius  = 14
        valueLabel.layer.shadowOpacity = 0.9
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        borderView.addSubview(valueLabel)

        // Description
        descriptionLabel.font          = .systemFont(ofSize: 15)
        descriptionLabel.textColor     = UIColor.white.withAlphaComponent(0.7)
        descriptionLabel.numberOfLines = 3
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        borderView.addSubview(descriptionLabel)

        // Category
        categoryLabel.textColor = .white
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        borderView.addSubview(categoryLabel)
    }

    // MARK: - Actions

    @objc private func infoButtonTapped() {
        onInfoTapped?(infoButton)
    }

    private func setupLayout() {
        // Все constraint'ы — относительно borderView (= bounds карточки)
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 20),
            iconView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 9),
            iconView.widthAnchor.constraint(equalToConstant: 26),
            iconView.heightAnchor.constraint(equalToConstant: 26),

            infoButton.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -13),
            infoButton.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 11),
            infoButton.widthAnchor.constraint(equalToConstant: 20),
            infoButton.heightAnchor.constraint(equalToConstant: 20),

            badgeContainer.trailingAnchor.constraint(equalTo: infoButton.leadingAnchor, constant: -4),
            badgeContainer.centerYAnchor.constraint(equalTo: infoButton.centerYAnchor),
            badgeContainer.heightAnchor.constraint(equalToConstant: 20),

            badgeLabel.centerYAnchor.constraint(equalTo: badgeContainer.centerYAnchor),
            badgeLabel.leadingAnchor.constraint(equalTo: badgeContainer.leadingAnchor, constant: 6),
            badgeLabel.trailingAnchor.constraint(equalTo: badgeContainer.trailingAnchor, constant: -6),

            valueLabel.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 20),
            valueLabel.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 40),

            descriptionLabel.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -12),
            descriptionLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 3),

            categoryLabel.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 20),
            categoryLabel.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -10),
        ])
    }
}
