// BlockedAppsIconsView.swift
// ScrollFit

import SwiftUI
import FamilyControls

/// Горизонтальный ряд иконок заблокированных приложений и категорий.
struct BlockedAppsIconsView: View {

    let selection: FamilyActivitySelection

    private let maxVisible = 5

    var body: some View {
        HStack(spacing: -6) {
            let appTokens = Array(selection.applicationTokens)
            let catTokens = Array(selection.categoryTokens)

            // Сначала иконки приложений
            let visibleApps = Array(appTokens.prefix(maxVisible))
            ForEach(visibleApps, id: \.self) { token in
                Label(token)
                    .labelStyle(.iconOnly)
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            }

            // Затем иконки категорий (если осталось место)
            let slotsLeft = max(0, maxVisible - visibleApps.count)
            let visibleCats = Array(catTokens.prefix(slotsLeft))
            ForEach(visibleCats, id: \.self) { token in
                Label(token)
                    .labelStyle(.iconOnly)
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            }

            // Бадж "+N" для оставшихся
            let totalShown = visibleApps.count + visibleCats.count
            let totalAll = appTokens.count + catTokens.count
            let remaining = totalAll - totalShown
            if remaining > 0 {
                Text("+\(remaining)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            }
        }
    }
}
