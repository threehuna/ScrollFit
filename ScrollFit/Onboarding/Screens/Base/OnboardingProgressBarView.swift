// OnboardingProgressBarView.swift
// ScrollFit

import UIKit

/// Прогресс-бар для шагов онбординга.
/// Заливка — scrollFitGreen, трек — белый с прозрачностью.
/// Анимация через CABasicAnimation; anchorPoint = (0, 0.5) — растёт только вправо.
final class OnboardingProgressBarView: UIView {

    // MARK: - Layers

    private let trackLayer = CALayer()
    private let fillLayer  = CALayer()

    // MARK: - State

    private var currentProgress: Float = 0

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 4
        clipsToBounds = true

        trackLayer.backgroundColor = UIColor.white.withAlphaComponent(0.25).cgColor
        trackLayer.cornerRadius    = 4
        layer.addSublayer(trackLayer)

        fillLayer.backgroundColor = UIColor(.scrollFitGreen).cgColor
        fillLayer.cornerRadius    = 4
        // Растём от левого края
        fillLayer.anchorPoint     = CGPoint(x: 0, y: 0.5)
        layer.addSublayer(fillLayer)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        trackLayer.frame = bounds

        // Обновляем без анимации — позиция управляется через setProgress
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let w = bounds.width * CGFloat(currentProgress)
        fillLayer.bounds   = CGRect(x: 0, y: 0, width: w, height: bounds.height)
        fillLayer.position = CGPoint(x: 0, y: bounds.height / 2)
        CATransaction.commit()
    }

    // MARK: - Public

    func setProgress(_ progress: Float, animated: Bool) {
        let toWidth = bounds.width * CGFloat(progress)

        if animated {
            let fromWidth: CGFloat
            if let presentation = fillLayer.presentation() {
                fromWidth = presentation.bounds.width
            } else {
                fromWidth = fillLayer.bounds.width
            }

            // Обновляем model layer до старта анимации
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            fillLayer.bounds   = CGRect(x: 0, y: 0, width: toWidth, height: bounds.height)
            fillLayer.position = CGPoint(x: 0, y: bounds.height / 2)
            CATransaction.commit()

            let anim                    = CABasicAnimation(keyPath: "bounds.size.width")
            anim.fromValue              = fromWidth
            anim.toValue                = toWidth
            anim.duration               = 0.45
            anim.timingFunction         = CAMediaTimingFunction(name: .easeInEaseOut)
            fillLayer.add(anim, forKey: "progressWidth")
        } else {
            fillLayer.removeAnimation(forKey: "progressWidth")
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            fillLayer.bounds   = CGRect(x: 0, y: 0, width: toWidth, height: bounds.height)
            fillLayer.position = CGPoint(x: 0, y: bounds.height / 2)
            CATransaction.commit()
        }

        currentProgress = progress
    }
}
