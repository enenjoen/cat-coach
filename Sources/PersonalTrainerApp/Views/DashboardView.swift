import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        let palette = store.backgroundTheme.palette
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                    MetricCard(title: L.text(.countdown, store.language), value: "\(store.daysRemaining) \(L.text(.days, store.language))", caption: L.text(.dateCaption, store.language), symbol: "calendar")
                    MetricCard(title: L.text(.currentWeight, store.language), value: String(format: "%.1f kg", store.latestWeight), caption: "\(L.text(.starting, store.language))：\(String(format: "%.1f", store.startingWeight)) kg", symbol: "scalemass")
                    MetricCard(title: L.text(.targetRange, store.language), value: String(format: "%.1f kg", store.profile.targetWeightKg), caption: store.language == .chinese ? "循序渐进，不追求速成" : "Gradual, not a crash target", symbol: "target")
                    MetricCard(title: L.text(.weeklyGoal, store.language), value: String(format: "%.2f kg", store.profile.weeklyGoalKg), caption: store.language == .chinese ? "健康、现实的节奏" : "Healthy, realistic pace", symbol: "leaf")
                }

                SectionPanel(title: store.language == .chinese ? "进度" : "Progress", symbol: "chart.bar.fill") {
                    VStack(alignment: .leading, spacing: 10) {
                        ProgressView(value: store.progressFraction)
                            .tint(palette.rose)
                            .scaleEffect(x: 1, y: 1.4, anchor: .center)
                        Text(store.language == .chinese ? "根据记录，已完成目标的 \(Int(store.progressFraction * 100))%" : "\(Int(store.progressFraction * 100))% toward target based on records")
                            .foregroundStyle(.secondary)
                    }
                }

                if store.isPersonalWeek {
                    PersonalWeekBanner()
                }

                SectionPanel(title: store.language == .chinese ? "每日清单" : "Daily Checklist", symbol: "checkmark.seal") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ChecklistToggle(title: store.language == .chinese ? "完成训练" : "Workout completed", symbol: "dumbbell", isOn: store.checklist.workoutCompleted) {
                            store.toggleChecklist(\.workoutCompleted)
                        }
                        ChecklistToggle(title: store.language == .chinese ? "完成步数" : "Steps completed", symbol: "shoeprints.fill", isOn: store.checklist.stepsCompleted) {
                            store.toggleChecklist(\.stepsCompleted)
                        }
                        ChecklistToggle(title: store.language == .chinese ? "完成饮水" : "Water completed", symbol: "drop.fill", isOn: store.checklist.waterCompleted) {
                            store.toggleChecklist(\.waterCompleted)
                        }
                        ChecklistToggle(title: store.language == .chinese ? "完成蛋白质" : "Protein completed", symbol: "takeoutbag.and.cup.and.straw.fill", isOn: store.checklist.proteinCompleted) {
                            store.toggleChecklist(\.proteinCompleted)
                        }
                        ChecklistToggle(title: store.language == .chinese ? "达到睡眠目标" : "Sleep target completed", symbol: "moon.zzz.fill", isOn: store.checklist.sleepCompleted) {
                            store.toggleChecklist(\.sleepCompleted)
                        }
                    }
                }
                Color.clear.frame(height: 10)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(store.language == .chinese ? "健康塑形仪表盘" : "Wellness Dashboard")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(store.backgroundTheme.palette.berry)
                Text(store.language == .chinese ? "用温和的 5 天计划，帮助循序渐进减脂、改善体态、提升状态与日常精力。" : "A calm 5-day plan for gradual fat loss, posture, confidence, and steady energy.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            CatSticker()
        }
    }
}

struct PersonalWeekBanner: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        SectionPanel(title: store.language == .chinese ? "重要日期周模式" : "Event Week Mode", symbol: "sparkles") {
            Text(store.language == .chinese ? "这一周减少高强度训练，重点放在散步、拉伸、补水、睡眠、体态和舒服不胀的食物上。不提供冒险的临时减重建议。" : "This week shifts away from intense training and toward walking, stretching, hydration, sleep, posture, and comfortable foods. No risky last-minute weight-loss advice.")
                .foregroundStyle(Theme.ink)
        }
    }
}
