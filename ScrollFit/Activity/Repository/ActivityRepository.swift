// ActivityRepository.swift
// ScrollFit

import Foundation

enum ActivityRepositoryError: Error {
    case pastDayEditNotAllowed
}

final class ActivityRepository {

    static let shared = ActivityRepository()

    private var store: ActivityStore
    private let fileURL: URL
    private let calendar = Calendar.current

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    // MARK: - Init

    private init() {
        fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("activity_store.json")

        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(ActivityStore.self, from: data) {
            store = decoded
        } else {
            store = ActivityStore()   // первый запуск
        }

        ensureTodayRecord()
    }

    // MARK: - Public: Read

    var todayKey: String { Self.dateKey(for: Date()) }
    var currentStreak: Int { store.currentStreak }
    var bestStreak: Int { store.bestStreak }
    var bestSingleSessionPushUps: Int { store.bestSingleSessionPushUps }
    var longestSessionMinutes: Int { store.longestSessionMinutes }
    var scrollMinutesPerPushUp: Int { store.scrollMinutesPerPushUp }

    /// Запись текущего дня. Гарантированно не nil.
    func todayRecord() -> DayRecord {
        ensureTodayRecord()   // защита от смены дня без перезапуска
        return store.records[todayKey]!
    }

    func record(for dateKey: String) -> DayRecord? {
        store.records[dateKey]
    }

    /// Все записи, от новой к старой.
    func allRecords() -> [DayRecord] {
        store.records.values.sorted { $0.date > $1.date }
    }

    /// Суммарный баланс доступных минут (заработано - потрачено за все дни).
    var availableMinutes: Int {
        let total = store.records.values.reduce(0) {
            $0 + $1.earnedScrollMinutes - $1.spentScrollMinutes
        }
        return max(0, total)
    }

    /// Можно ли редактировать запись с данным ключом?
    func canEdit(dateKey: String) -> Bool {
        dateKey == todayKey
    }

    // MARK: - Public: Write (только сегодня)

    /// Обновить поля текущего дня. Передавай только те значения, которые изменились.
    @discardableResult
    func updateToday(
        pushUpsCount: Int? = nil,
        earnedScrollMinutes: Int? = nil,
        spentScrollMinutes: Int? = nil
    ) -> DayRecord {
        ensureTodayRecord()
        let key = todayKey

        if let v = pushUpsCount        { store.records[key]!.pushUpsCount        = max(0, v) }
        if let v = earnedScrollMinutes { store.records[key]!.earnedScrollMinutes = max(0, v) }
        if let v = spentScrollMinutes  { store.records[key]!.spentScrollMinutes  = max(0, v) }

        recalculateStreaks()
        persist()
        return store.records[key]!
    }

    /// Зафиксировать завершённую сессию отжиманий. Прибавляет к сегодняшнему счётчику,
    /// обновляет рекорд за одну сессию если побит.
    func recordSession(pushUps: Int) {
        ensureTodayRecord()
        let key = todayKey
        let clampedPushUps = max(0, pushUps)

        store.records[key]!.pushUpsCount += clampedPushUps
        store.records[key]!.earnedScrollMinutes += clampedPushUps * store.scrollMinutesPerPushUp

        if clampedPushUps > store.bestSingleSessionPushUps {
            store.bestSingleSessionPushUps = clampedPushUps
        }

        recalculateStreaks()
        persist()
    }

    /// Обновить рекорд самой долгой сессии в приложении. Вызывать при уходе в фон.
    func updateLongestSessionIfNeeded(minutes: Int) {
        let clamped = max(0, minutes)
        guard clamped > store.longestSessionMinutes else { return }
        store.longestSessionMinutes = clamped
        persist()
    }

    /// Изменить множитель: сколько минут скролла даёт одно отжимание. Минимум 1.
    func setScrollMultiplier(_ value: Int) {
        store.scrollMinutesPerPushUp = max(1, value)
        persist()
    }

    /// Явная попытка редактировать произвольную дату — бросает для прошлых дней.
    func update(dateKey: String, pushUpsCount: Int) throws {
        guard dateKey == todayKey else {
            throw ActivityRepositoryError.pastDayEditNotAllowed
        }
        updateToday(pushUpsCount: pushUpsCount)
    }

    // MARK: - App lifecycle

    /// Вызывать в sceneWillEnterForeground — создаёт запись нового дня, если её ещё нет.
    func refreshIfNeeded() {
        ensureTodayRecord()
    }

    // MARK: - Private

    private func ensureTodayRecord() {
        let key = todayKey
        guard store.records[key] == nil else { return }
        store.records[key] = makeEmptyRecord(for: Date())
        persist()
    }

    private func makeEmptyRecord(for date: Date) -> DayRecord {
        DayRecord(
            date: Self.dateKey(for: date),
            weekday: calendar.component(.weekday, from: date),
            pushUpsCount: 0,
            earnedScrollMinutes: 0,
            spentScrollMinutes: 0
        )
    }

    // MARK: - Streak

    private func recalculateStreaks() {
        var count = 0
        var cursor = Date()

        // Если сегодня отжиманий ещё не было — стрик считаем со вчера,
        // чтобы не обнулять прошлую серию в течение дня.
        let todayPushUps = store.records[todayKey]?.pushUpsCount ?? 0
        if todayPushUps == 0 {
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor)!
        }

        while true {
            let key = Self.dateKey(for: cursor)
            guard let rec = store.records[key], rec.pushUpsCount >= 1 else { break }
            count += 1
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor)!
        }

        store.currentStreak = count
        if count > store.bestStreak {
            store.bestStreak = count
        }
    }

    // MARK: - Persistence

    private func persist() {
        guard let data = try? JSONEncoder().encode(store) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func dateKey(for date: Date) -> String {
        dateFormatter.string(from: date)
    }
}
