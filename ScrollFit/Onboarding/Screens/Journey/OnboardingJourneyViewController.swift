// OnboardingJourneyViewController.swift
// ScrollFit

import UIKit

/// Экран 11: «Твой путь к лучшей версии себя начинается прямо сейчас».
/// Скроллируемый экран с графиком сравнения методов, датой достижения цели
/// и соотношением отжиманий к минутам.
final class OnboardingJourneyViewController: OnboardingStepViewController {

    // MARK: - Data

    private let currentHours: Int
    private let desiredHours: Int
    private let targetDateString: String

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Твой путь к лучшей версии себя начинается прямо сейчас:"
        label.font = UIFont(name: "Helvetica-Bold", size: 28)
                  ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // График — готовый ассет
    private let chartImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "scrollDiagram")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // Лейблы часов поверх графика
    private lazy var topHoursLabel: UILabel = {
        let label = UILabel()
        label.text = "\(currentHours)ч"
        label.font = UIFont(name: "Helvetica", size: 15)
                  ?? UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(white: 0.73, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var bottomHoursLabel: UILabel = {
        let label = UILabel()
        label.text = "\(desiredHours)ч"
        label.font = UIFont(name: "Helvetica", size: 15)
                  ?? UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(white: 0.73, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let differenceLabel: UILabel = {
        let label = UILabel()
        label.text = "Ты почувствуешь разницу:"
        label.font = UIFont(name: "Helvetica", size: 20)
                  ?? UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var datePillView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor(.scrollFitGreen).cgColor
        v.layer.borderWidth = 4
        v.layer.cornerRadius = 31
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = targetDateString
        label.font = UIFont(name: "Helvetica-Bold", size: 23)
                  ?? UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let pushUpDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Отжимайся, чтобы пользоваться приложениями, к которым ты ограничил доступ:"
        label.font = UIFont(name: "Helvetica", size: 17)
                  ?? UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let pushUpIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "pushIconWithArrows")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let equalsLabel: UILabel = {
        let label = UILabel()
        label.text = "=  1 мин"
        label.font = UIFont(name: "Helvetica-Bold", size: 28)
                  ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let ratioDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Такое соотношение повторений к минутам идеально подойдет для тебя"
        label.font = UIFont(name: "Helvetica", size: 17)
                  ?? UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    init(userData: OnboardingUserData) {
        currentHours = userData.currentScreenTimeHours
        desiredHours = userData.desiredScreenTimeHours

        let targetDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM, yyyy"
        targetDateString = formatter.string(from: targetDate)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        showsBackButton  = false
        showsProgressBar = false
        actionButtonTitle = "Приступим!"
        setupContent()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private func setupContent() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleLabel, chartImageView, topHoursLabel, bottomHoursLabel,
         differenceLabel, datePillView, pushUpDescriptionLabel,
         pushUpIconView, equalsLabel,
         ratioDescriptionLabel].forEach { contentView.addSubview($0) }

        datePillView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            // ScrollView — от верха до кнопки
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -16),

            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 31),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -31),

            // График (ассет)
            chartImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            chartImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            chartImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            chartImageView.heightAnchor.constraint(equalTo: chartImageView.widthAnchor, multiplier: 0.8),

            // Лейблы часов — слева от графика, выровнены по вертикали
            // Верхний (currentHours) — ~18% от верха графика
            topHoursLabel.trailingAnchor.constraint(equalTo: chartImageView.leadingAnchor, constant: 78),
            topHoursLabel.topAnchor.constraint(equalTo: chartImageView.topAnchor, constant: 58),

            // Нижний (desiredHours) — ~65% от верха графика
            bottomHoursLabel.trailingAnchor.constraint(equalTo: chartImageView.leadingAnchor, constant: 78),
            bottomHoursLabel.bottomAnchor.constraint(equalTo: chartImageView.bottomAnchor, constant: -70),

            // "Ты почувствуешь разницу:"
            differenceLabel.topAnchor.constraint(equalTo: chartImageView.bottomAnchor, constant: 16),
            differenceLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Дата в обводке
            datePillView.topAnchor.constraint(equalTo: differenceLabel.bottomAnchor, constant: 16),
            datePillView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            datePillView.widthAnchor.constraint(equalToConstant: 326),
            datePillView.heightAnchor.constraint(equalToConstant: 62),

            dateLabel.centerXAnchor.constraint(equalTo: datePillView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: datePillView.centerYAnchor),

            // Описание отжиманий
            pushUpDescriptionLabel.topAnchor.constraint(equalTo: datePillView.bottomAnchor, constant: 24),
            pushUpDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            pushUpDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),

            // Иконка отжимания + "= 1 мин"
            pushUpIconView.topAnchor.constraint(equalTo: pushUpDescriptionLabel.bottomAnchor, constant: 20),
            pushUpIconView.widthAnchor.constraint(equalToConstant: 68),
            pushUpIconView.heightAnchor.constraint(equalToConstant: 68),
            pushUpIconView.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -8),

            equalsLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -8),
            equalsLabel.centerYAnchor.constraint(equalTo: pushUpIconView.centerYAnchor),

            // Пояснение
            ratioDescriptionLabel.topAnchor.constraint(equalTo: pushUpIconView.bottomAnchor, constant: 20),
            ratioDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            ratioDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            ratioDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
        ])
    }
}
