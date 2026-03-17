// SoundEffectsRowView.swift
// ScrollFit

import UIKit

/// Pill-shaped row with a bell icon, title, subtitle, and a toggle for disabling sounds.
/// Design: Settings screen, node 807-3.
final class SoundEffectsRowView: UIView {

    // MARK: - State

    private static let userDefaultsKey = "scrollfit.sound.muted"

    var isMuted: Bool {
        get { UserDefaults.standard.bool(forKey: Self.userDefaultsKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.userDefaultsKey)
            muteToggle.setOn(newValue, animated: true)
        }
    }

    // MARK: - Subviews

    private let iconImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .regular)
        let iv = UIImageView(image: UIImage(systemName: "bell.and.waves.left.and.right", withConfiguration: config))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Выключить звук"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Выключить звуковой эффект после каждого засчитанного повторения"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let muteToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = UIColor.scrollFitGreen
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()

    private let textStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .leading
        sv.spacing = 4
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupHierarchy()
        setupLayout()
        muteToggle.isOn = isMuted
        muteToggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupAppearance() {
        backgroundColor = .clear
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 3
        layer.cornerRadius = 40
    }

    private func setupHierarchy() {
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)
        addSubview(iconImageView)
        addSubview(textStack)
        addSubview(muteToggle)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 80),

            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 44),
            iconImageView.heightAnchor.constraint(equalToConstant: 44),

            muteToggle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            muteToggle.centerYAnchor.constraint(equalTo: centerYAnchor),

            textStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            textStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: muteToggle.leadingAnchor, constant: -12),
        ])
    }

    // MARK: - Actions

    @objc private func toggleChanged() {
        UserDefaults.standard.set(muteToggle.isOn, forKey: Self.userDefaultsKey)
    }
}
