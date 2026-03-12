// InstructionBarView.swift
// ScrollFit

import UIKit

/// Dark pill shown at the top of the camera area with an info icon and dynamic instruction text.
final class InstructionBarView: UIView {

    // MARK: - Subviews

    private let infoIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "info.circle", withConfiguration: config)
        let view = UIImageView(image: image)
        view.tintColor = .white
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    // MARK: - Setup

    private func setup() {
        backgroundColor = UIColor(red: 0.196, green: 0.192, blue: 0.196, alpha: 1) // #323132
        layer.cornerRadius = 30
        layer.borderWidth = 3
        layer.borderColor = UIColor.white.cgColor
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(infoIcon)
        addSubview(label)

        NSLayoutConstraint.activate([
            infoIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            infoIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            infoIcon.widthAnchor.constraint(equalToConstant: 24),
            infoIcon.heightAnchor.constraint(equalToConstant: 24),

            label.leadingAnchor.constraint(equalTo: infoIcon.trailingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    // MARK: - Public

    func setText(_ text: String) {
        label.text = text
    }
}
