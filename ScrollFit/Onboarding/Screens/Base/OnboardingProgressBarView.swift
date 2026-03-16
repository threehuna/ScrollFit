// OnboardingProgressBarView.swift
// ScrollFit

import UIKit

/// Кастомный прогресс-бар для шагов онбординга.
/// Заливка — scrollFitGreen, трек — белый с прозрачностью.
final class OnboardingProgressBarView: UIView {

    var progress: Float = 0 { didSet { setNeedsLayout() } }

    private let trackLayer = CALayer()
    private let fillLayer  = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        trackLayer.backgroundColor = UIColor.white.withAlphaComponent(0.25).cgColor
        fillLayer.backgroundColor  = UIColor(.scrollFitGreen).cgColor
        layer.addSublayer(trackLayer)
        layer.addSublayer(fillLayer)
        clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        let r = bounds.height / 2
        trackLayer.frame        = bounds
        trackLayer.cornerRadius = r
        let fillWidth           = bounds.width * CGFloat(progress)
        fillLayer.frame         = CGRect(x: 0, y: 0, width: fillWidth, height: bounds.height)
        fillLayer.cornerRadius  = r
    }
}
