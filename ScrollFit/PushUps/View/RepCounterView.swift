// RepCounterView.swift
// ScrollFit

import UIKit

/// Green circle displaying the current repetition count.
/// Pulses with a scale animation each time a rep is counted.
final class RepCounterView: UIView {

    // MARK: - Constants

    private let diameter: CGFloat = 60

    // MARK: - Subviews

    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 26, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    override var intrinsicContentSize: CGSize { CGSize(width: diameter, height: diameter) }

    // MARK: - Setup

    private func setup() {
        backgroundColor = UIColor(.scrollFitGreen) 
        layer.cornerRadius = diameter / 2
        clipsToBounds = false
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(countLabel)
        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: diameter),
            heightAnchor.constraint(equalToConstant: diameter),
        ])
    }

    // MARK: - Public

    func setCount(_ count: Int) {
        countLabel.text = "\(count)"
    }

    /// Brief scale pulse to celebrate a completed rep.
    func animatePulse() {
        UIView.animateKeyframes(withDuration: 0.35, delay: 0, options: []) {
            UIView.addKeyframe(withRelativeStartTime: 0,   relativeDuration: 0.4) {
                self.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6) {
                self.transform = .identity
            }
        }
    }
}
