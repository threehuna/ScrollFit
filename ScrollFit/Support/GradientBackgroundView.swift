// GradientBackgroundView.swift
// ScrollFit

import UIKit

/// Вертикальный градиент приложения: #323132 → #989598.
/// Добавляй в setupHierarchy() через view.insertSubview(gradientView, at: 0).
final class GradientBackgroundView: UIView {

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.colors = [
            UIColor(.scrollFitBlack).cgColor,
            UIColor(.scrollFitGray).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.2)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    required init?(coder: NSCoder) { fatalError() }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        superview?.backgroundColor = UIColor(.scrollFitBlack)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
