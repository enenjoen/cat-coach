import SwiftUI

struct WeeklyReviewView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        let palette = store.backgroundTheme.palette
        VStack(alignment: .leading, spacing: 20) {
            Text(L.text(.weeklyReview, store.language))
                .font(.system(size: 31, weight: .bold, design: .rounded))
                .foregroundStyle(palette.berry)

            SectionPanel(title: store.language == .chinese ? "进度" : "Progress", symbol: "chart.line.uptrend.xyaxis") {
                Text(store.weeklyReview.summary)
                    .font(.title3)
                    .foregroundStyle(Theme.ink)
                Text(store.language == .chinese ? String(format: "预计本周变化：%.1f kg", store.weeklyWeightChange) : String(format: "Estimated weekly change: %.1f kg", store.weeklyWeightChange))
                    .foregroundStyle(.secondary)
            }

            SectionPanel(title: store.language == .chinese ? "计划调整" : "Plan Adjustment", symbol: "slider.horizontal.3") {
                Text(store.weeklyReview.adjustment)
                    .foregroundStyle(Theme.ink)
                Button {
                    store.updateWeeklyReview()
                } label: {
                    Label(store.language == .chinese ? "刷新复盘" : "Refresh Review", systemImage: "arrow.clockwise")
                }
            }

            SectionPanel(title: store.language == .chinese ? "鼓励" : "Encouragement", symbol: "heart") {
                Text(store.weeklyReview.encouragement)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(palette.rose)
            }

            Spacer()
            Color.clear.frame(height: 10)
        }
    }
}
