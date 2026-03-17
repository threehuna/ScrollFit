// ScreenTimeBadgeView.swift
// ScrollFit

import UIKit

final class ScreenTimeBadgeView: UIView {

    // MARK: - Subviews

    private let minutesLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont(name: "Helvetica-Bold", size: 25) ?? UIFont.boldSystemFont(ofSize: 25)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.text = "экранного времени осталось, чтобы потратить"
        l.textColor = .white
        l.font = UIFont(name: "Helvetica", size: 15) ?? UIFont.systemFont(ofSize: 15)
        l.textAlignment = .center
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    func configure(availableMinutes: Int) {
        minutesLabel.text = "\(availableMinutes) мин."
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    // MARK: - Private

    private func setup() {
        backgroundColor = .clear
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 3

        addSubview(minutesLabel)
        addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            minutesLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            minutesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            minutesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: minutesLabel.bottomAnchor, constant:0),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
        ])
    }
}
