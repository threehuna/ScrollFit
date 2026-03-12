// MainTabBarController.swift
// ScrollFit

import UIKit

/// UITabBarController со скрытым стандартным таббаром и кастомным плавающим pill'ом.
final class MainTabBarController: UITabBarController {

    var onWorkoutRequested: (() -> Void)?

    private let customTabBar = CustomTabBarView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        // Reserve space for the floating bar (62pt height + 12pt gap above safe area)
        additionalSafeAreaInsets.bottom = 74
        setupCustomTabBar()
    }

    // MARK: - Setup

    private func setupCustomTabBar() {
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customTabBar)

        NSLayoutConstraint.activate([
            customTabBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35),
            customTabBar.widthAnchor.constraint(equalToConstant: 240),
            customTabBar.heightAnchor.constraint(equalToConstant: 72),
        ])

        customTabBar.onTabSelected = { [weak self] index in
            self?.selectedIndex = index
        }

        customTabBar.onWorkoutTapped = { [weak self] in
            self?.onWorkoutRequested?()
        }
    }

    // MARK: - Tab switching

    override var selectedIndex: Int {
        didSet { customTabBar.selectTab(selectedIndex) }
    }
}
