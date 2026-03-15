// RingProgressView.swift
// ScrollFit

import UIKit

/// Кольцевая диаграмма прогресса.
/// progress = 0.0 (пусто) … 1.0 (заполнено).
/// Кольцо всегда стартует с верхней точки (12 часов) и идёт по часовой стрелке.
final class RingProgressView: UIView {

    var progress: CGFloat = 0 {
        didSet { progressLayer.strokeEnd = progress.clamped(to: 0...1) }
    }

    private let lineWidth: CGFloat = 9

    private let trackLayer    = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let decoLayer     = CAShapeLayer()  // тонкая внешняя окружность

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.addSublayer(decoLayer)
        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        rebuildPaths()
    }

    private func rebuildPaths() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let r      = (min(bounds.width, bounds.height) - lineWidth) / 2

        let circle = UIBezierPath(arcCenter: center,
                                  radius: r,
                                  startAngle: -.pi / 2,
                                  endAngle:    .pi * 1.5,
                                  clockwise:   true)

        // Декоративная внешняя окружность
        let decoR    = r + lineWidth * 0.6
        let decoPart = UIBezierPath(arcCenter: center,
                                    radius: decoR,
                                    startAngle: -.pi / 2,
                                    endAngle:    .pi * 1.5,
                                    clockwise:   true)
        decoLayer.path        = decoPart.cgPath
        decoLayer.fillColor   = UIColor.clear.cgColor
        decoLayer.strokeColor = UIColor.white.withAlphaComponent(0.12).cgColor
        decoLayer.lineWidth   = 1

        // Трек (фон кольца)
        trackLayer.path        = circle.cgPath
        trackLayer.fillColor   = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.white.withAlphaComponent(0.25).cgColor
        trackLayer.lineWidth   = lineWidth
        trackLayer.lineCap     = .round
        trackLayer.strokeEnd   = 1

        // Прогресс
        progressLayer.path        = circle.cgPath
        progressLayer.fillColor   = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.lineWidth   = lineWidth
        progressLayer.lineCap     = .round
        progressLayer.strokeEnd   = progress.clamped(to: 0...1)
    }
}

// MARK: - Helpers

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.max(range.lowerBound, Swift.min(range.upperBound, self))
    }
}
