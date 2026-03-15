// HomeViewController.swift
// ScrollFit

import UIKit

final class HomeViewController: UIViewController {

    weak var coordinator: HomeCoordinator?

    // MARK: - Constants

    /// Количество недель, загружаемых в календарь (листаем назад).
    private let weekCount = 26
    /// Высота строки: число(28) + отступ(6) + круг(36) + отступ(6) + день(20)
    private let calendarRowHeight: CGFloat = 96

    // MARK: - Data

    private var selectedDate: Date = Date()
    private var goals: UserGoals { UserGoalsRepository.shared.goals }

    // MARK: - Subviews

    private let gradientView = GradientBackgroundView()

    // Header
    private let logoImageView: UIImageView = {
        let img = UIImage(named: "scrollFitLogo")
        let iv  = UIImageView(image: img)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "ScrollFit"
        l.textColor = UIColor(.scrollFitWhite)
        l.font = UIFont(name: "Helvetica-Bold", size: 35) ?? UIFont.boldSystemFont(ofSize: 35)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let settingsButton: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 26, weight: .regular)
        btn.setImage(UIImage(systemName: "gearshape", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor(.scrollFitWhite)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // Streak badge
    private let streakBadgeView: StreakBadgeView = {
        let v = StreakBadgeView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // Calendar
    private let calendarScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled                = true
        sv.showsHorizontalScrollIndicator = false
        sv.bounces                        = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let calendarContentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private var weekViews: [WeekCalendarView] = []

    // Charts
    private let pushUpsCard: ProgressChartCardView = {
        let v = ProgressChartCardView(type: .pushUps)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let screenTimeCard: ProgressChartCardView = {
        let v = ProgressChartCardView(type: .screenTime)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupAppearance()
        setupActions()
        loadData()
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientView.frame = view.bounds
        scrollToCurrentWeek(animated: false)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private func setupHierarchy() {
        view.insertSubview(gradientView, at: 0)
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(settingsButton)
        view.addSubview(streakBadgeView)
        view.addSubview(calendarScrollView)
        calendarScrollView.addSubview(calendarContentView)
        buildWeekViews()
        view.addSubview(screenTimeCard)
        view.addSubview(pushUpsCard)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            // Лого
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 96),
            logoImageView.widthAnchor.constraint(equalToConstant: 42),
            logoImageView.heightAnchor.constraint(equalToConstant: 42),

            // Название
            titleLabel.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 8),

            // Кнопка настроек
            settingsButton.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            settingsButton.widthAnchor.constraint(equalToConstant: 32),
            settingsButton.heightAnchor.constraint(equalToConstant: 32),

            // Стрик-бадж
            streakBadgeView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 14),
            streakBadgeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            streakBadgeView.heightAnchor.constraint(equalToConstant: 47),

            // Скролл-вью календаря
            calendarScrollView.topAnchor.constraint(equalTo: streakBadgeView.bottomAnchor, constant: 16),
            calendarScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarScrollView.heightAnchor.constraint(equalToConstant: calendarRowHeight),

            // Контент скролл-вью
            calendarContentView.topAnchor.constraint(equalTo: calendarScrollView.topAnchor),
            calendarContentView.bottomAnchor.constraint(equalTo: calendarScrollView.bottomAnchor),
            calendarContentView.leadingAnchor.constraint(equalTo: calendarScrollView.leadingAnchor),
            calendarContentView.trailingAnchor.constraint(equalTo: calendarScrollView.trailingAnchor),
            calendarContentView.heightAnchor.constraint(equalTo: calendarScrollView.heightAnchor),
            calendarContentView.widthAnchor.constraint(
                equalTo: calendarScrollView.widthAnchor,
                multiplier: CGFloat(weekCount)
            ),

            // Карточки диаграмм — под календарём, по две в ряд
            screenTimeCard.topAnchor.constraint(equalTo: calendarScrollView.bottomAnchor, constant: 24),
            screenTimeCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            screenTimeCard.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.44),
            screenTimeCard.heightAnchor.constraint(equalToConstant: 216),

            pushUpsCard.topAnchor.constraint(equalTo: calendarScrollView.bottomAnchor, constant: 24),
            pushUpsCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            pushUpsCard.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.44),
            pushUpsCard.heightAnchor.constraint(equalToConstant: 216),
        ])
    }

    private func setupAppearance() {
        navigationController?.navigationBar.isHidden = true
    }

    private func setupActions() {
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
    }

    // MARK: - Calendar construction

    private func buildWeekViews() {
        let cal   = Calendar.current
        let today = Date()

        for i in 0..<weekCount {
            // i=0 — самая старая неделя, i=weekCount-1 — текущая
            let daysBack  = (weekCount - 1 - i) * 7
            let startDate = cal.date(byAdding: .day, value: -(daysBack + 6), to: today)!

            let weekView = WeekCalendarView()
            weekView.translatesAutoresizingMaskIntoConstraints = false
            weekView.onDaySelected = { [weak self] date in
                self?.handleDaySelected(date)
            }
            calendarContentView.addSubview(weekView)
            weekViews.append(weekView)
        }
    }

    // Констрейнты недельных вью выставляем в viewDidLayoutSubviews,
    // чтобы знать точную ширину экрана.
    private var weekViewsLaidOut = false

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard !weekViewsLaidOut, view.bounds.width > 0 else { return }
        weekViewsLaidOut = true
        let pageWidth = view.bounds.width

        for (i, weekView) in weekViews.enumerated() {
            NSLayoutConstraint.activate([
                weekView.topAnchor.constraint(equalTo: calendarContentView.topAnchor),
                weekView.bottomAnchor.constraint(equalTo: calendarContentView.bottomAnchor),
                weekView.widthAnchor.constraint(equalToConstant: pageWidth),
                weekView.leadingAnchor.constraint(
                    equalTo: calendarContentView.leadingAnchor,
                    constant: CGFloat(i) * pageWidth
                ),
            ])
        }
    }

    // MARK: - Data

    private func loadData() {
        streakBadgeView.configure(streak: ActivityRepository.shared.currentStreak)
        reloadCalendar()
        reloadCharts(for: selectedDate)
    }

    private func reloadCharts(for date: Date) {
        let key    = ActivityRepository.dateKey(for: date)
        let record = ActivityRepository.shared.record(for: key)
        pushUpsCard.configure(
            current: record?.pushUpsCount ?? 0,
            goal:    goals.pushUpsGoal
        )
        screenTimeCard.configure(
            current: record?.spentScrollMinutes ?? 0,
            goal:    goals.scrollMinutesGoal
        )
    }

    private func reloadCalendar() {
        let cal   = Calendar.current
        let today = Date()

        for (i, weekView) in weekViews.enumerated() {
            let daysBack  = (weekCount - 1 - i) * 7
            let startDate = cal.date(byAdding: .day, value: -(daysBack + 6), to: today)!
            weekView.configure(startDate: startDate, selectedDate: selectedDate, goals: goals)
        }
    }

    private func scrollToCurrentWeek(animated: Bool) {
        let pageWidth = calendarScrollView.bounds.width
        guard pageWidth > 0 else { return }
        let lastPageX = CGFloat(weekCount - 1) * pageWidth
        guard calendarScrollView.contentOffset.x != lastPageX else { return }
        calendarScrollView.setContentOffset(CGPoint(x: lastPageX, y: 0), animated: animated)
    }

    // MARK: - Actions

    private func handleDaySelected(_ date: Date) {
        selectedDate = date
        reloadCalendar()
        reloadCharts(for: date)
    }

    @objc private func appWillEnterForeground() {
        loadData()
    }

    @objc private func settingsTapped() {
        coordinator?.showSettings()
    }
}
