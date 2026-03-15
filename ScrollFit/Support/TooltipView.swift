// TooltipView.swift
// ScrollFit

import UIKit

/// Маленькая пояснительная плашка, прикреплённая к info-кнопке.
final class TooltipView: UIView {

    private let label = UILabel()

    init(text: String) {
        super.init(frame: .zero)

        backgroundColor      = UIColor(.scrollFitBlack).withAlphaComponent(0.95)
        layer.cornerRadius   = 10
        layer.borderWidth    = 1
        layer.borderColor    = UIColor(.scrollFitGreen).withAlphaComponent(0.5).cgColor
        layer.shadowColor    = UIColor.black.cgColor
        layer.shadowOffset   = CGSize(width: 0, height: 2)
        layer.shadowRadius   = 8
        layer.shadowOpacity  = 0.35

        label.text          = text
        label.font          = .systemFont(ofSize: 12)
        label.textColor     = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}
