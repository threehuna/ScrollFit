// HomeViewController.swift
// ScrollFit

import UIKit
import SwiftUI
import FamilyControls

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

    // Screen time badge
    private let screenTimeBadgeView: ScreenTimeBadgeView = {
        let v = ScreenTimeBadgeView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

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

    // Blocked apps button
    private let blockedAppsButton: UIView = {
        let container = UIView()
        container.layer.borderColor = UIColor.white.cgColor
        container.layer.borderWidth = 3
        container.layer.cornerRadius = 40
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false

        // Левая часть: заголовок + подзаголовок
        let headerLabel = UILabel()
        headerLabel.text = "БЛОКИРОВКА"
        headerLabel.font = UIFont(name: "Helvetica", size: 11)
                        ?? UIFont.systemFont(ofSize: 11, weight: .regular)
        headerLabel.textColor = .white
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(headerLabel)

        let selectLabel = UILabel()
        selectLabel.text = "Выбрать"
        selectLabel.font = UIFont(name: "Helvetica-Bold", size: 20)
                        ?? UIFont.systemFont(ofSize: 20, weight: .bold)
        selectLabel.textColor = .white
        selectLabel.translatesAutoresizingMaskIntoConstraints = false
        selectLabel.tag = 101
        container.addSubview(selectLabel)

        // Контейнер для иконок приложений (будет заполнен SwiftUI)
        let iconsContainer = UIView()
        iconsContainer.translatesAutoresizingMaskIntoConstraints = false
        iconsContainer.tag = 102
        container.addSubview(iconsContainer)

        // Бадж статуса справа
        let statusBadge = UIView()
        statusBadge.layer.cornerRadius = 14
        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        statusBadge.tag = 103
        container.addSubview(statusBadge)

        let statusDot = UIView()
        statusDot.layer.cornerRadius = 4
        statusDot.translatesAutoresizingMaskIntoConstraints = false
        statusDot.tag = 104
        statusBadge.addSubview(statusDot)

        let statusLabel = UILabel()
        statusLabel.font = UIFont(name: "Helvetica-Bold", size: 11)
                        ?? UIFont.systemFont(ofSize: 11, weight: .bold)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.tag = 105
        statusBadge.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            headerLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),

            selectLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            selectLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 2),

            iconsContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconsContainer.leadingAnchor.constraint(equalTo: selectLabel.trailingAnchor, constant: 12),
            iconsContainer.heightAnchor.constraint(equalToConstant: 32),
            iconsContainer.widthAnchor.constraint(equalToConstant: 140),

            statusBadge.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            statusBadge.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            statusBadge.heightAnchor.constraint(equalToConstant: 28),

            statusDot.leadingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: 10),
            statusDot.centerYAnchor.constraint(equalTo: statusBadge.centerYAnchor),
            statusDot.widthAnchor.constraint(equalToConstant: 8),
            statusDot.heightAnchor.constraint(equalToConstant: 8),

            statusLabel.leadingAnchor.constraint(equalTo: statusDot.trailingAnchor, constant: 6),
            statusLabel.trailingAnchor.constraint(equalTo: statusBadge.trailingAnchor, constant: -10),
            statusLabel.centerYAnchor.constraint(equalTo: statusBadge.centerYAnchor),
        ])

        return container
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
        view.addSubview(screenTimeBadgeView)
        view.addSubview(blockedAppsButton)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            // Лого
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
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

            // Бадж экранного времени — под диаграммами
            screenTimeBadgeView.topAnchor.constraint(equalTo: pushUpsCard.bottomAnchor, constant: 20),
            screenTimeBadgeView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            screenTimeBadgeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            screenTimeBadgeView.heightAnchor.constraint(equalToConstant: 100),

            // Кнопка блокировки
            blockedAppsButton.topAnchor.constraint(equalTo: screenTimeBadgeView.bottomAnchor, constant: 16),
            blockedAppsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            blockedAppsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            blockedAppsButton.heightAnchor.constraint(equalToConstant: 80),
        ])
    }

    private func setupAppearance() {
        navigationController?.navigationBar.isHidden = true
    }

    private func setupActions() {
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        blockedAppsButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(blockedAppsTapped))
        )
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
        let repo = ActivityRepository.shared
        streakBadgeView.configure(streak: repo.currentStreak)
        reloadCalendar()
        reloadCharts(for: selectedDate)

        let available = repo.allRecords().reduce(0) {
            $0 + $1.earnedScrollMinutes - $1.spentScrollMinutes
        }
        screenTimeBadgeView.configure(availableMinutes: max(0, available))
        updateBlockedAppsLabel()
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

    @objc private func blockedAppsTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        #if targetEnvironment(simulator)
        return
        #else
        var selection = BlockedAppsRepository.shared.load()

        let picker = FamilyActivityPicker(selection: Binding(
            get: { selection },
            set: { selection = $0 }
        ))

        let wrapped = picker
            .navigationTitle("Приложения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { [weak self] in
                        self?.dismiss(animated: true)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { [weak self] in
                        BlockedAppsRepository.shared.save(selection)
                        AppBlockingManager.shared.applyBlocking(for: selection)
                        self?.dismiss(animated: true) {
                            self?.updateBlockedAppsLabel()
                        }
                    }
                }
            }

        let hosting = UIHostingController(rootView: NavigationView { wrapped })
        hosting.modalPresentationStyle = .pageSheet
        present(hosting, animated: true)
        #endif
    }

    private var iconsHostingController: UIHostingController<BlockedAppsIconsView>?

    private func updateBlockedAppsLabel() {
        let selection = BlockedAppsRepository.shared.load()
        let count = selection.applicationTokens.count + selection.categoryTokens.count
        let hasBlocking = count > 0

        // Обновить текст «Выбрать» / «N прил.»
        let selectLabel = blockedAppsButton.viewWithTag(101) as? UILabel
        selectLabel?.text = hasBlocking ? "\(count) прил." : "Выбрать"

        // Обновить статус-бадж
        let statusBadge = blockedAppsButton.viewWithTag(103)
        let statusDot   = blockedAppsButton.viewWithTag(104)
        let statusLabel = blockedAppsButton.viewWithTag(105) as? UILabel

        let activeColor = UIColor(red: 0.196, green: 0.78, blue: 0.35, alpha: 1)
        let inactiveColor = UIColor(white: 0.45, alpha: 1)

        if hasBlocking {
            statusBadge?.backgroundColor = activeColor.withAlphaComponent(0.15)
            statusDot?.backgroundColor = activeColor
            statusLabel?.text = "АКТИВНО"
            statusLabel?.textColor = activeColor
        } else {
            statusBadge?.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            statusDot?.backgroundColor = inactiveColor
            statusLabel?.text = "НЕАКТИВНО"
            statusLabel?.textColor = inactiveColor
        }

        // Обновить иконки приложений
        updateAppIcons(selection: selection)
    }

    private func updateAppIcons(selection: FamilyActivitySelection) {
        guard let iconsContainer = blockedAppsButton.viewWithTag(102) else { return }

        let hasIcons = !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty

        if let existing = iconsHostingController {
            existing.rootView = BlockedAppsIconsView(selection: selection)
            existing.view.invalidateIntrinsicContentSize()
        } else if hasIcons {
            let hosting = UIHostingController(rootView: BlockedAppsIconsView(selection: selection))
            hosting.view.translatesAutoresizingMaskIntoConstraints = false
            hosting.view.backgroundColor = .clear
            addChild(hosting)
            iconsContainer.addSubview(hosting.view)
            NSLayoutConstraint.activate([
                hosting.view.topAnchor.constraint(equalTo: iconsContainer.topAnchor),
                hosting.view.bottomAnchor.constraint(equalTo: iconsContainer.bottomAnchor),
                hosting.view.leadingAnchor.constraint(equalTo: iconsContainer.leadingAnchor),
                hosting.view.trailingAnchor.constraint(equalTo: iconsContainer.trailingAnchor),
            ])
            hosting.didMove(toParent: self)
            iconsHostingController = hosting
        }
    }
}
