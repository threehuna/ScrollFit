// PushUpProgressView.swift
// ScrollFit

import UIKit

// MARK: - BarChartView

private final class BarChartView: UIView {

    struct Entry {
        let label: String
        let value: Int
    }

    var entries: [Entry] = [] {
        didSet { setNeedsDisplay() }
    }

    private let yLabelWidth:  CGFloat = 40
    private let xLabelHeight: CGFloat = 22
    private let topPadding:   CGFloat = 16

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ rect: CGRect) {
        guard !entries.isEmpty, let ctx = UIGraphicsGetCurrentContext() else { return }

        let chartX      = yLabelWidth
        let chartBottom = rect.height - xLabelHeight
        let chartW      = rect.width - chartX
        let chartH      = chartBottom - topPadding

        let rawMax = entries.map(\.value).max() ?? 0
        let yMax   = niceMax(rawMax)
        let ySteps = 5

        let axisColor  = UIColor(.scrollFitGray).withAlphaComponent(0.5)
        let labelColor = UIColor(.scrollFitGray)
        let labelFont  = UIFont(name: "Helvetica", size: 12) ?? UIFont.systemFont(ofSize: 12)
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: labelFont,
            .foregroundColor: labelColor
        ]

        // Y grid lines and labels
        for i in 0...ySteps {
            let val = yMax * i / ySteps
            let y   = chartBottom - chartH * CGFloat(val) / CGFloat(yMax)

            ctx.setStrokeColor(axisColor.cgColor)
            ctx.setLineWidth(0.5)
            ctx.move(to: CGPoint(x: chartX, y: y))
            ctx.addLine(to: CGPoint(x: rect.width, y: y))
            ctx.strokePath()

            guard i > 0 else { continue }
            let s  = "\(val)" as NSString
            let sz = s.size(withAttributes: labelAttrs)
            s.draw(at: CGPoint(x: chartX - sz.width - 6, y: y - sz.height / 2),
                   withAttributes: labelAttrs)
        }

        // Axes
        let axisStroke = UIColor(.scrollFitGray).withAlphaComponent(0.6)
        ctx.setStrokeColor(axisStroke.cgColor)
        ctx.setLineWidth(1)
        ctx.move(to: CGPoint(x: chartX, y: topPadding))
        ctx.addLine(to: CGPoint(x: chartX, y: chartBottom))
        ctx.move(to: CGPoint(x: chartX, y: chartBottom))
        ctx.addLine(to: CGPoint(x: rect.width, y: chartBottom))
        ctx.strokePath()

        // Bars + X labels
        let slotW = chartW / CGFloat(entries.count)
        let barW  = max(slotW * 0.45, 6)

        for (i, entry) in entries.enumerated() {
            let cx = chartX + (CGFloat(i) + 0.5) * slotW

            // Tick mark
            ctx.setStrokeColor(axisColor.cgColor)
            ctx.setLineWidth(1)
            ctx.move(to: CGPoint(x: cx, y: chartBottom))
            ctx.addLine(to: CGPoint(x: cx, y: chartBottom + 4))
            ctx.strokePath()

            // X label
            let lbl = entry.label as NSString
            let sz  = lbl.size(withAttributes: labelAttrs)
            lbl.draw(at: CGPoint(x: cx - sz.width / 2, y: chartBottom + 5),
                     withAttributes: labelAttrs)

            // Bar
            guard entry.value > 0, yMax > 0 else { continue }
            let barH    = chartH * CGFloat(entry.value) / CGFloat(yMax)
            let barRect = CGRect(x: cx - barW / 2, y: chartBottom - barH, width: barW, height: barH)
            let path    = UIBezierPath(roundedRect: barRect,
                                       byRoundingCorners: [.topLeft, .topRight],
                                       cornerRadii: CGSize(width: 3, height: 3))
            ctx.setFillColor(UIColor(.scrollFitGreen).cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
        }
    }

    private func niceMax(_ raw: Int) -> Int {
        switch raw {
        case ..<1:   return 5
        case ..<6:   return 5
        case ..<11:  return 10
        case ..<21:  return 20
        case ..<26:  return 25
        case ..<51:  return 50
        case ..<101: return 100
        default:     return ((raw + 24) / 25) * 25
        }
    }
}

// MARK: - PushUpProgressView

final class PushUpProgressView: UIView {

    enum Period: CaseIterable {
        case day, week, month

        var title: String {
            switch self {
            case .day:   return "день"
            case .week:  return "неделя"
            case .month: return "месяц"
            }
        }
    }

    private var period: Period = .week

    // MARK: Subviews

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Прогресс за период"
        l.textColor = UIColor(.scrollFitWhite)
        l.font = .systemFont(ofSize: 30)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let periodButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = UIColor(.scrollFitWhite)
        btn.setTitleColor(UIColor(.scrollFitWhite), for: .normal)
        btn.titleLabel?.font = UIFont(name: "Helvetica", size: 18) ?? UIFont.systemFont(ofSize: 18)
        btn.layer.borderWidth = 2.5
        btn.layer.borderColor = UIColor(.scrollFitWhite).cgColor
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let chartView: BarChartView = {
        let v = BarChartView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: Public

    func reloadData() {
        chartView.entries = makeEntries(for: period)
    }

    // MARK: Private

    private func setup() {
        addSubview(titleLabel)
        addSubview(periodButton)
        addSubview(chartView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            periodButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            periodButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            periodButton.heightAnchor.constraint(equalToConstant: 40),
            periodButton.widthAnchor.constraint(equalToConstant: 120),

            chartView.topAnchor.constraint(equalTo: periodButton.bottomAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: trailingAnchor),
            chartView.heightAnchor.constraint(equalToConstant: 220),
            chartView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        updateButton()
    }

    private func updateButton() {
        let chevron = UIImage(
            systemName: "chevron.down",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .regular)
        )
        periodButton.setTitle("  " + period.title + "  ", for: .normal)
        periodButton.setImage(chevron, for: .normal)
        periodButton.semanticContentAttribute = .forceRightToLeft

        let actions = Period.allCases.map { [weak self] p in
            UIAction(title: p.title, state: p == self?.period ? .on : .off) { [weak self] _ in
                self?.period = p
                self?.updateButton()
                self?.reloadData()
            }
        }
        periodButton.menu = UIMenu(title: "", children: actions)
        periodButton.showsMenuAsPrimaryAction = true
    }

    // MARK: - Data

    private func makeEntries(for period: Period) -> [BarChartView.Entry] {
        switch period {
        case .day:   return makeDayEntries()
        case .week:  return makeWeekEntries()
        case .month: return makeMonthEntries()
        }
    }

    /// Последние 7 дней, единица = 1 день, метки = Пн/Вт/...
    private func makeDayEntries() -> [BarChartView.Entry] {
        let cal   = Calendar.current
        let repo  = ActivityRepository.shared
        let abbrs = ["", "Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]  // 1-based weekday
        var result = [BarChartView.Entry]()
        for offset in stride(from: 6, through: 0, by: -1) {
            let date    = cal.date(byAdding: .day, value: -offset, to: Date())!
            let key     = ActivityRepository.dateKey(for: date)
            let count   = repo.record(for: key)?.pushUpsCount ?? 0
            let weekday = cal.component(.weekday, from: date)
            result.append(.init(label: abbrs[weekday], value: count))
        }
        return result
    }

    /// Последние 4 недели, единица = 1 неделя, метки = дата понедельника (d.MM)
    private func makeWeekEntries() -> [BarChartView.Entry] {
        let cal   = Calendar.current
        let repo  = ActivityRepository.shared
        let fmt   = DateFormatter()
        fmt.locale     = Locale(identifier: "ru_RU")
        fmt.dateFormat = "d.MM"
        var result = [BarChartView.Entry]()
        for offset in stride(from: 3, through: 0, by: -1) {
            let ref   = cal.date(byAdding: .weekOfYear, value: -offset, to: Date())!
            let start = mondayOf(date: ref, calendar: cal)
            var total = 0
            for day in 0..<7 {
                let d = cal.date(byAdding: .day, value: day, to: start)!
                if d > Date() { break }
                total += repo.record(for: ActivityRepository.dateKey(for: d))?.pushUpsCount ?? 0
            }
            result.append(.init(label: fmt.string(from: start), value: total))
        }
        return result
    }

    /// Последние 6 месяцев, единица = 1 месяц, метки = Янв/Фев/...
    private func makeMonthEntries() -> [BarChartView.Entry] {
        let cal     = Calendar.current
        let allRecs = ActivityRepository.shared.allRecords()
        let names   = ["", "Янв", "Фев", "Мар", "Апр", "Май", "Июн",
                       "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"]
        var result  = [BarChartView.Entry]()
        for offset in stride(from: 5, through: 0, by: -1) {
            let ref    = cal.date(byAdding: .month, value: -offset, to: Date())!
            let year   = cal.component(.year, from: ref)
            let month  = cal.component(.month, from: ref)
            let prefix = String(format: "%04d-%02d-", year, month)
            let total  = allRecs
                .filter { $0.date.hasPrefix(prefix) }
                .reduce(0) { $0 + $1.pushUpsCount }
            result.append(.init(label: names[month], value: total))
        }
        return result
    }

    private func mondayOf(date: Date, calendar: Calendar) -> Date {
        var cal          = calendar
        cal.firstWeekday = 2   // Monday
        let comps        = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return cal.date(from: comps) ?? date
    }
}
