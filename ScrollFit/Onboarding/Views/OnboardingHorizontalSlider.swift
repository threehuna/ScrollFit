// OnboardingHorizontalSlider.swift
// ScrollFit

import UIKit

/// Кастомный горизонтальный слайдер для онбординга.
/// Трек: тёмный (#27272A), высота 31pt.
/// Заливка: задаётся через `fillColor`, высота 25pt.
/// Thumb: белый pill 53×25pt, повёрнутый на 90° — визуально 25×53pt.
final class OnboardingHorizontalSlider: UIControl {

    // MARK: - Public

    var minimumValue: Int = 1
    var maximumValue: Int = 16

    private(set) var value: Int = 8

    var fillColor: UIColor = UIColor(red: 0, green: 0.765, blue: 1, alpha: 1) {
        didSet { fillView.backgroundColor = fillColor }
    }

    func setValue(_ newValue: Int, animated: Bool) {
        let clamped = max(minimumValue, min(maximumValue, newValue))
        guard clamped != value || !animated else {
            value = clamped
            updateUI(animated: animated)
            return
        }
        value = clamped
        updateUI(animated: animated)
    }

    // MARK: - UI

    private let trackView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.153, green: 0.153, blue: 0.165, alpha: 1)
        v.layer.cornerRadius = 15.5
        v.isUserInteractionEnabled = false
        return v
    }()

    private let fillView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0, green: 0.765, blue: 1, alpha: 1) // default #00C3FF, overridable via fillColor
        v.layer.cornerRadius = 12.5
        v.isUserInteractionEnabled = false
        v.clipsToBounds = true
        return v
    }()

    private let thumbView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 12.5
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - Constants

    private let trackHeight: CGFloat = 31
    private let fillHeight:  CGFloat = 25
    // Thumb pre-rotation: 53×25 → after 90° rotation: visually 25×53
    private let thumbPreW:   CGFloat = 53
    private let thumbPreH:   CGFloat = 25
    private var thumbVisualW: CGFloat { thumbPreH }  // 25
    private var thumbVisualH: CGFloat { thumbPreW }  // 53

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(trackView)
        addSubview(fillView)
        addSubview(thumbView)
        thumbView.transform = CGAffineTransform(rotationAngle: .pi / 2)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        let trackY = (bounds.height - trackHeight) / 2
        trackView.frame = CGRect(x: 0, y: trackY, width: bounds.width, height: trackHeight)
        updateUI(animated: false)
    }

    // MARK: - Private

    private func updateUI(animated: Bool) {
        let fraction  = CGFloat(value - minimumValue) / CGFloat(maximumValue - minimumValue)
        let minCX     = thumbVisualW / 2
        let maxCX     = bounds.width - thumbVisualW / 2
        let centerX   = minCX + fraction * (maxCX - minCX)
        let trackY    = (bounds.height - trackHeight) / 2
        let fillY     = trackY + (trackHeight - fillHeight) / 2
        let centerY   = bounds.height / 2

        let applyFrames = {
            self.fillView.frame = CGRect(x: 3, y: fillY, width: centerX, height: self.fillHeight)
            self.thumbView.bounds = CGRect(x: 0, y: 0, width: self.thumbPreW, height: self.thumbPreH)
            self.thumbView.center = CGPoint(x: centerX, y: centerY)
        }

        if animated {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: applyFrames)
        } else {
            applyFrames()
        }
    }

    // MARK: - Gesture

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let locX  = gesture.location(in: self).x
        let minCX = thumbVisualW / 2
        let maxCX = bounds.width - thumbVisualW / 2
        let fraction = max(0, min(1, (locX - minCX) / (maxCX - minCX)))
        let newValue = minimumValue + Int(round(fraction * CGFloat(maximumValue - minimumValue)))

        if newValue != value {
            value = newValue
            updateUI(animated: false)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            sendActions(for: .valueChanged)
        }
    }
}
