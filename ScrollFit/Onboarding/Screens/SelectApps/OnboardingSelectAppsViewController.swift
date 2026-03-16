// OnboardingSelectAppsViewController.swift
// ScrollFit

import UIKit
import SwiftUI
import FamilyControls

/// Экран 10: выбор приложений для блокировки.
/// Показывает декоративную картинку и кнопку «Выбрать приложения»,
/// которая открывает системный FamilyActivityPicker.
final class OnboardingSelectAppsViewController: OnboardingStepViewController {

    // MARK: - Data

    private let userData: OnboardingUserData

    // MARK: - UI

    private let topLabel: UILabel = {
        let label = UILabel()
        label.text = "Давай настроим ScrollFit!"
        label.font = UIFont(name: "Helvetica", size: 15)
                  ?? UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Выбери приложения, которые больше всего отвлекают тебя"
        label.font = UIFont(name: "Helvetica-Bold", size: 28)
                  ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ты всегда можешь изменить свой выбор\nпотом в настройках приложения"
        label.font = UIFont(name: "Helvetica", size: 15)
                  ?? UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let decorImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "selectAppsImage")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Init

    init(userData: OnboardingUserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        showsBackButton  = false
        showsProgressBar = false
        actionButtonTitle = "Выбрать приложения"
        setupContent()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Activity Picker

    private func openActivityPicker() {
        #if targetEnvironment(simulator)
        onNext?()
        return
        #else
        let pickerView = ActivityPickerWrapper(
            selection: userData.selectedApps,
            onDone: { [weak self] selection in
                guard let self else { return }
                self.userData.selectedApps = selection
                self.dismiss(animated: true) {
                    self.onNext?()
                }
            },
            onCancel: { [weak self] in
                self?.dismiss(animated: true)
            }
        )

        let hostingController = UIHostingController(rootView: pickerView)
        hostingController.modalPresentationStyle = .pageSheet
        present(hostingController, animated: true)
        #endif
    }

    // MARK: - Setup

    private func setupContent() {
        actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(selectAppsTapped), for: .touchUpInside)

        [topLabel, titleLabel, subtitleLabel, decorImageView].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            topLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 63),
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            titleLabel.topAnchor.constraint(
                equalTo: topLabel.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            decorImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            decorImageView.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor, constant: 32),
            decorImageView.widthAnchor.constraint(equalToConstant: 357),
            decorImageView.heightAnchor.constraint(equalToConstant: 357),
        ])
    }

    @objc private func selectAppsTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        openActivityPicker()
    }
}

// MARK: - SwiftUI Wrapper

/// Обёртка FamilyActivityPicker с навигационной панелью (Done / Cancel).
private struct ActivityPickerWrapper: View {
    @State var selection: FamilyActivitySelection
    let onDone: (FamilyActivitySelection) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationView {
            FamilyActivityPicker(selection: $selection)
                .navigationTitle("Приложения")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Отмена") { onCancel() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Готово") { onDone(selection) }
                    }
                }
        }
    }
}
