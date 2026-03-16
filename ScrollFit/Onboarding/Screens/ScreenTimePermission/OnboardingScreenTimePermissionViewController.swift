// OnboardingScreenTimePermissionViewController.swift
// ScrollFit

import UIKit
import FamilyControls

/// Экран 9: запрос разрешения на доступ к экранному времени.
/// Показывает макет системного алёрта FamilyControls в том месте,
/// где он реально появится. Стрелка указывает на кнопку «Продолжить» в алёрте.
///
/// Логика:
/// - Через 1.5с после появления экрана показывается системный алёрт
/// - Если пользователь нажал «Не разрешать» → через 3с алёрт повторяется
/// - Если разрешил → переход на следующий экран
final class OnboardingScreenTimePermissionViewController: OnboardingStepViewController {

    // MARK: - State

    private var authTask: Task<Void, Never>?

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Разреши доступ к экранному времени"
        label.font = UIFont(name: "Helvetica-Bold", size: 35)
                  ?? UIFont.systemFont(ofSize: 35, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Чтобы анализировать твоё экранное время на этом iPhone.\nScrollFit нужно твоё разрешение"
        label.font = UIFont(name: "Helvetica", size: 20)
                  ?? UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let alertBorderView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor(.scrollFitGreen).cgColor
        v.layer.borderWidth = 4
        v.layer.cornerRadius = 14
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let alertMockupView = AlertMockupView()

    /// Стрелка указывает вверх на кнопку «Продолжить» в алёрте
    private let arrowImageView: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let iv = UIImageView(image: UIImage(systemName: "arrow.up", withConfiguration: cfg))
        iv.tintColor = UIColor(.scrollFitGreen)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let disclaimerLabel: UILabel = {
        let label = UILabel()
        label.text = "Чувствительные данные защищены Apple\nи никогда не покидают твоё устройство"
        label.font = UIFont(name: "Helvetica", size: 18)
                  ?? UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        showsActionButton  = false   // до super, чтобы base class не добавлял кнопку
        super.viewDidLoad()
        showsBackButton    = true
        showsProgressBar   = false
        setupContent()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private var didRequestOnce = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didRequestOnce else { return }
        didRequestOnce = true

        if AuthorizationCenter.shared.authorizationStatus == .approved {
            onNext?()
            return
        }

        NotificationCenter.default.addObserver(
            self, selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification, object: nil)

        scheduleAuthorization(delay: 2.0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        authTask?.cancel()
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func appWillResignActive() {
        authTask?.cancel()
    }

    @objc private func appDidBecomeActive() {
        if AuthorizationCenter.shared.authorizationStatus == .approved {
            onNext?()
        } else {
            scheduleAuthorization(delay: 2.0)
        }
    }

    // MARK: - Authorization

    private func scheduleAuthorization(delay: TimeInterval) {
        authTask?.cancel()
        authTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await requestAuthorization()
        }
    }

    @MainActor
    private func requestAuthorization() async {
        #if targetEnvironment(simulator)
        onNext?()
        return
        #else
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            onNext?()
        } catch {
            guard !(authTask?.isCancelled ?? true) else { return }
            scheduleAuthorization(delay: 2.0)
        }
        #endif
    }

    // MARK: - Setup

    private func setupContent() {
        alertMockupView.translatesAutoresizingMaskIntoConstraints = false
        alertBorderView.addSubview(alertMockupView)

        [titleLabel, subtitleLabel, alertBorderView,
         arrowImageView, disclaimerLabel].forEach { view.addSubview($0) }

        // Ширина алёрта — фиксирована чтобы стрелка попадала точно под левую кнопку
        let alertWidth: CGFloat = 280

        NSLayoutConstraint.activate([
            // Заголовок
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 63),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            // Подзаголовок
            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            // Алёрт: немного ниже центра экрана — там где реально появляется системный алёрт
            alertBorderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertBorderView.widthAnchor.constraint(equalToConstant: alertWidth),
            alertBorderView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor, constant: 23),

            // Макет алёрта внутри рамки
            alertMockupView.topAnchor.constraint(
                equalTo: alertBorderView.topAnchor, constant: 6),
            alertMockupView.bottomAnchor.constraint(
                equalTo: alertBorderView.bottomAnchor, constant: -6),
            alertMockupView.leadingAnchor.constraint(
                equalTo: alertBorderView.leadingAnchor, constant: 6),
            alertMockupView.trailingAnchor.constraint(
                equalTo: alertBorderView.trailingAnchor, constant: -6),

            // Стрелка: X выровнен по центру левой кнопки алёрта
            // Левая кнопка занимает [leading..centerX] → её центр = leading + width/4
            arrowImageView.centerXAnchor.constraint(
                equalTo: alertBorderView.leadingAnchor, constant: alertWidth / 4),
            arrowImageView.topAnchor.constraint(
                equalTo: alertBorderView.bottomAnchor, constant: 10),
            arrowImageView.widthAnchor.constraint(equalToConstant: 36),
            arrowImageView.heightAnchor.constraint(equalToConstant: 52),

            // Дисклеймер внизу
            disclaimerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            disclaimerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            disclaimerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            disclaimerLabel.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
    }
}

// MARK: - AlertMockupView

/// Имитирует системный алёрт FamilyControls с текстами на русском языке.
private final class AlertMockupView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "«ScrollFit» хочет получить доступ к Экранному времени"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.text = "Предоставление «ScrollFit» доступа к Экранному времени позволит ему просматривать данные об активности, ограничивать контент и использование приложений и веб-сайтов."
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let separatorH: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let continueButton: UILabel = {
        let label = UILabel()
        label.text = "Продолжить"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(red: 0.26, green: 0.56, blue: 1, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let separatorV: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let denyButton: UILabel = {
        let label = UILabel()
        label.text = "Не разрешать"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(red: 0.26, green: 0.56, blue: 1, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.18, green: 0.18, blue: 0.20, alpha: 1)
        layer.cornerRadius = 10
        clipsToBounds = true

        [titleLabel, bodyLabel, separatorH,
         continueButton, separatorV, denyButton].forEach { addSubview($0) }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bodyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            bodyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            separatorH.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 14),
            separatorH.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorH.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorH.heightAnchor.constraint(equalToConstant: 0.5),

            continueButton.topAnchor.constraint(equalTo: separatorH.bottomAnchor),
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: centerXAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 44),
            continueButton.bottomAnchor.constraint(equalTo: bottomAnchor),

            separatorV.topAnchor.constraint(equalTo: separatorH.bottomAnchor),
            separatorV.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorV.centerXAnchor.constraint(equalTo: centerXAnchor),
            separatorV.widthAnchor.constraint(equalToConstant: 0.5),

            denyButton.topAnchor.constraint(equalTo: separatorH.bottomAnchor),
            denyButton.leadingAnchor.constraint(equalTo: centerXAnchor),
            denyButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            denyButton.heightAnchor.constraint(equalToConstant: 44),
            denyButton.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}
