// StreakBadgeView.swift
// ScrollFit

import UIKit

final class StreakBadgeView: UIView {

    // MARK: - Subviews

    private let flameImageView: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let img = UIImage(systemName: "flame.fill", withConfiguration: cfg)
        let iv  = UIImageView(image: img)
        iv.tintColor = UIColor(.scrollFitOrange)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let countLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor(.scrollFitOrange)
        l.font = UIFont(name: "Helvetica-Bold", size: 34) ?? UIFont.boldSystemFont(ofSize: 34)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor(.scrollFitWhite)
        l.font = UIFont(name: "Helvetica", size: 25) ?? UIFont.systemFont(ofSize: 25)
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

    func configure(streak: Int) {
        countLabel.text = "\(streak)"
        titleLabel.text = dayTextForBadge(streak)
    }

    // MARK: - Private
    
    private func dayTextForBadge(_ streak: Int) -> String {
        switch streak{
            case 1:
            return "день"
            case 2..<5:
            return "дня"
        default:
            return "дней"
        }
    }

    private func setup() {
        
        layer.shadowOffset  = .zero
        layer.shadowRadius  = 19
        layer.shadowOpacity = 0.85
        layer.masksToBounds = true
        layer.shadowColor        = UIColor(.scrollFitGreen).cgColor
        backgroundColor = UIColor(.scrollFitBlack).withAlphaComponent(0.77)
        layer.borderColor = UIColor(.scrollFitGreen).cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 23.5
        clipsToBounds = true
        

        addSubview(flameImageView)
        addSubview(countLabel)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            flameImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            flameImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            flameImageView.widthAnchor.constraint(equalToConstant: 22),
            flameImageView.heightAnchor.constraint(equalToConstant: 28),

            countLabel.leadingAnchor.constraint(equalTo: flameImageView.trailingAnchor, constant: 8),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: countLabel.trailingAnchor, constant: 6),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
        ])
    }
}
