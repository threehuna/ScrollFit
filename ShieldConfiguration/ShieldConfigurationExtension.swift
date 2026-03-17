//
//  ShieldConfigurationExtension.swift
//  ShieldConfiguration
//
//  Created by Трофим Чекмарев on 17.03.2026.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        makeConfiguration(for: application.localizedDisplayName)
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration(for: application.localizedDisplayName)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        makeConfiguration(for: webDomain.domain)
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration(for: webDomain.domain)
    }

    // MARK: - Private

    private func makeConfiguration(for name: String?) -> ShieldConfiguration {
        let appName = name ?? "Приложение"

        let icon = UIImage(named: "muscleBody", in: Bundle.main, compatibleWith: nil)

        return ShieldConfiguration(
            backgroundBlurStyle: nil,
            backgroundColor: UIColor(red: 0.125, green: 0.122, blue: 0.129, alpha: 1),
            icon: icon,
            title: .init(
                text: "\(appName) заблокирован ScrollFit",
                color: .white
            ),
            subtitle: .init(
                text: "Сделай отжимания, чтобы разблокировать",
                color: UIColor(white: 0.7, alpha: 1)
            ),
            primaryButtonLabel: .init(
                text: "Закрыть",
                color: UIColor(red: 0.196, green: 0.192, blue: 0.196, alpha: 1)
            ),
            primaryButtonBackgroundColor: UIColor(
                red: 0.647, green: 0.945, blue: 0.2, alpha: 1
            )
        )
    }
}
