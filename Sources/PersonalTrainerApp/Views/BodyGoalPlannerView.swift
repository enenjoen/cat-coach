import SwiftUI

struct BodyGoalPlannerView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        let palette = store.backgroundTheme.palette
        VStack(alignment: .leading, spacing: 20) {
            Text(store.language == .chinese ? "身体目标规划" : "Body Goal Planner")
                .font(.system(size: 31, weight: .bold, design: .rounded))
                .foregroundStyle(palette.berry)

            SectionPanel(title: store.language == .chinese ? "重点部位" : "Focus Areas", symbol: "target") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                    ForEach(FocusArea.allCases) { area in
                        Button {
                            store.toggleFocusArea(area)
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: area.symbol)
                                    .font(.title2)
                                Text(area.title(language: store.language))
                                    .font(.headline)
                            }
                            .foregroundStyle(store.profile.selectedFocusAreas.contains(area) ? Color.white : Theme.ink)
                            .frame(maxWidth: .infinity, minHeight: 83)
                            .background(store.profile.selectedFocusAreas.contains(area) ? palette.rose : palette.softPanel)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(palette.blush.opacity(0.36), lineWidth: 1)
                            )
                            .shadow(color: palette.rose.opacity(0.08), radius: 10, x: 0, y: 6)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            SectionPanel(title: store.language == .chinese ? "生成的每周计划" : "Generated Weekly Plan", symbol: "calendar") {
                ForEach(store.workoutPlan) { day in
                    HStack(alignment: .top, spacing: 14) {
                        Text(day.weekday.prefix(3).uppercased())
                            .font(.caption.weight(.bold))
                            .foregroundStyle(palette.softGold)
                            .frame(width: 42, alignment: .leading)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(day.title)
                                .font(.headline)
                            Text(store.language == .chinese ? "\(day.type.title(language: store.language)) - \(day.durationMinutes) 分钟" : "\(day.type.title(language: store.language)) - \(day.durationMinutes) min")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    Divider()
                }
            }

            Spacer()
            Color.clear.frame(height: 10)
        }
    }
}
