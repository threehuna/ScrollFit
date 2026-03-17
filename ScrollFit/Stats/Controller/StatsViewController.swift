// StatsViewController.swift
// ScrollFit

import UIKit

final class StatsViewController: UIViewController {

    weak var coordinator: StatsCoordinator?

    // MARK: - Subviews

    private let gradientView  = GradientBackgroundView()
    private let scrollView    = UIScrollView()
    private let contentView   = UIView()

    private let titleLabel    = UILabel()
    private let sectionLabel  = UILabel()

    private let card1 = StatCardView() // Всего
    private let card2 = StatCardView() // Лучший стрик
    private let card3 = StatCardView() // В среднем
    private let card4 = StatCardView() // На этой неделе

    private let progressView: PushUpProgressView = {
        let v = PushUpProgressView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Lifecycle

    // MARK: - Tooltip state

    private var tooltipOverlay: UIControl?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupAppearance()
        loadData()
        setupInfoActions()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private func setupHierarchy() {
        view.insertSubview(gradientView, at: 0)
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        makeGrid()

        contentView.addSubview(sectionLabel)
        contentView.addSubview(gridStack)
        contentView.addSubview(progressView)
    }

    private func setupLayout() {
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            sectionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            sectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),

            gridStack.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 16),
            gridStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),
            gridStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19),

            progressView.topAnchor.constraint(equalTo: gridStack.bottomAnchor, constant: 28),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19),
            progressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
        ])
    }

    private func setupAppearance() {
        navigationController?.navigationBar.isHidden = true
        scrollView.showsVerticalScrollIndicator = false

        titleLabel.text      = "Статистика"
        titleLabel.font      = .boldSystemFont(ofSize: 35)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        sectionLabel.text      = "Общие сведения"
        sectionLabel.font      = .systemFont(ofSize: 30)
        sectionLabel.textColor = .white
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Grid

    private lazy var gridStack: UIStackView = UIStackView()

    
    private func makeGrid() {
        gridStack.arrangedSubviews.forEach {
            gridStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let topRow = UIStackView(arrangedSubviews: [card1, card2])
        topRow.spacing = 10
        topRow.distribution = .fillEqually
        topRow.heightAnchor.constraint(equalToConstant: 149).isActive = true

        let bottomRow = UIStackView(arrangedSubviews: [card3, card4])
        bottomRow.spacing = 10
        bottomRow.distribution = .fillEqually
        bottomRow.heightAnchor.constraint(equalToConstant: 149).isActive = true

        gridStack.axis = .vertical
        gridStack.spacing = 10
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        gridStack.addArrangedSubview(topRow)
        gridStack.addArrangedSubview(bottomRow)
    }

    // MARK: - Data

    private func loadData() {
        let stats = computeStats()

        let iconCfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)

        card1.configure(with: StatCardViewModel(
            icon: UIImage(named: "pushIconWithArrows"),
            iconTintColor: UIColor(.scrollFitGreen),
            value: "\(stats.totalPushUps)",
            description: "отжиманий за всё время",
            category: "Всего"
        ))

        card2.configure(with: StatCardViewModel(
            icon: UIImage(systemName: "flame.fill", withConfiguration: iconCfg),
            iconTintColor: .systemOrange,
            value: "\(stats.bestStreak)",
            description: "дней подряд",
            category: "Лучший стрик",
            badge: stats.streakBadge
        ))

        card3.configure(with: StatCardViewModel(
            icon: UIImage(named: "muscleArmGreen"),
            iconTintColor: UIColor(.scrollFitBlue),
            value: "\(stats.avgPerDay)",
            description: "отжиманий в день (за посл. 30 дней)",
            category: "В среднем"
        ))

        card4.configure(with: StatCardViewModel(
            icon: UIImage(systemName: "calendar.badge.clock", withConfiguration: iconCfg),
            iconTintColor: UIColor(.scrollFitBlue),
            value: "\(stats.thisWeekTotal)",
            description: "отжимания",
            category: "На этой неделе",
            categoryFontSize: 17,
            badge: stats.weekBadge
        ))

        progressView.reloadData()
    }

    // MARK: - Stats computation

    private struct StatsData {
        let totalPushUps: Int
        let bestStreak: Int
        let currentStreak: Int
        let avgPerDay: Int
        let thisWeekTotal: Int
        let lastWeekTotal: Int

        var streakBadge: String? {
            currentStreak > 0 ? "+\(currentStreak)д" : nil
        }

        var weekBadge: String? {
            guard lastWeekTotal > 0, thisWeekTotal > lastWeekTotal else { return nil }
            let pct = Int((Double(thisWeekTotal - lastWeekTotal) / Double(lastWeekTotal)) * 100)
            return pct > 0 ? "+\(pct)%" : nil
        }
    }

    private func computeStats() -> StatsData {
        let repo     = ActivityRepository.shared
        let calendar = Calendar.current
        let now      = Date()

        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale     = Locale(identifier: "en_US_POSIX")

        // Total
        let total = repo.allRecords().reduce(0) { $0 + $1.pushUpsCount }

        // Average over last 30 days
        let last30 = (0..<30).reduce(0) { sum, i in
            guard let d = calendar.date(byAdding: .day, value: -i, to: now) else { return sum }
            return sum + (repo.record(for: fmt.string(from: d))?.pushUpsCount ?? 0)
        }
        let avg = last30 / 30

        // This week (Mon → today) and previous full week (Mon → Sun)
        // weekday: 1=Sun, 2=Mon … 7=Sat  →  days since Monday = (weekday + 5) % 7
        let daysFromMon = (calendar.component(.weekday, from: now) + 5) % 7

        let thisWeek = (0...daysFromMon).reduce(0) { sum, i in
            guard let d = calendar.date(byAdding: .day, value: -i, to: now) else { return sum }
            return sum + (repo.record(for: fmt.string(from: d))?.pushUpsCount ?? 0)
        }

        let lastWeek = (1...7).reduce(0) { sum, i in
            guard let d = calendar.date(byAdding: .day, value: -(daysFromMon + i), to: now) else { return sum }
            return sum + (repo.record(for: fmt.string(from: d))?.pushUpsCount ?? 0)
        }

        return StatsData(
            totalPushUps:  total,
            bestStreak:    repo.bestStreak,
            currentStreak: repo.currentStreak,
            avgPerDay:     avg,
            thisWeekTotal: thisWeek,
            lastWeekTotal: lastWeek
        )
    }

    // MARK: - Info tooltips

    private let infoTexts: [StatCardView: String] = [:]

    private func setupInfoActions() {
        let texts: [(StatCardView, String)] = [
            (card1, "Суммарное количество отжиманий за всё время использования приложения."),
            (card2, "Рекордное количество дней подряд, когда вы делали хотя бы одно отжимание."),
            (card3, "Среднее количество отжиманий в день за последние 30 дней."),
            (card4, "Суммарное количество отжиманий с начала текущей недели (пн–вс)."),
        ]
        texts.forEach { card, text in
            card.onInfoTapped = { [weak self] button in
                self?.toggleTooltip(text: text, relativeTo: button)
            }
        }
    }

    private func toggleTooltip(text: String, relativeTo button: UIButton) {
        // Если тултип уже открыт — закрываем (нажатие на ту же кнопку снова)
        if tooltipOverlay != nil {
            dismissTooltip()
            return
        }
        showTooltip(text: text, relativeTo: button)
    }

    private func showTooltip(text: String, relativeTo button: UIButton) {
        // Прозрачный overlay перехватывает любой тап — закрывает тултип
        let overlay = UIControl(frame: view.bounds)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.addTarget(self, action: #selector(dismissTooltip), for: .touchUpInside)
        view.addSubview(overlay)
        tooltipOverlay = overlay

        let tooltip = TooltipView(text: text)
        tooltip.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(tooltip)

        // Конвертируем позицию кнопки в координаты view
        let btnRect = view.convert(button.bounds, from: button)

        // Trailing тултипа = правый край кнопки; ширина ≤ 190
        // Для правых карточек trailing = правый край кнопки, для левых — то же
        let trailingConstant = btnRect.maxX
        let topConstant      = btnRect.maxY + 6

        NSLayoutConstraint.activate([
            tooltip.widthAnchor.constraint(lessThanOrEqualToConstant: 190),
            tooltip.leadingAnchor.constraint(greaterThanOrEqualTo: overlay.leadingAnchor, constant: 12),
            tooltip.trailingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: trailingConstant),
            tooltip.topAnchor.constraint(equalTo: overlay.topAnchor, constant: topConstant),
        ])

        // Плавное появление
        overlay.alpha = 0
        UIView.animate(withDuration: 0.15) { overlay.alpha = 1 }
    }

    @objc private func appWillEnterForeground() {
        loadData()
    }

    @objc private func dismissTooltip() {
        UIView.animate(withDuration: 0.1) {
            self.tooltipOverlay?.alpha = 0
        } completion: { _ in
            self.tooltipOverlay?.removeFromSuperview()
            self.tooltipOverlay = nil
        }
    }
}
