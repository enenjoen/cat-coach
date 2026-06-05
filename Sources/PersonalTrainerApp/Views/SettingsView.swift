import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var countdownDate = Date()
    @State private var heightCm = 165.0
    @State private var targetWeight = 45.5
    @State private var weeklyGoal = 0.35
    @State private var showingResetConfirmation = false

    var body: some View {
        let palette = store.backgroundTheme.palette
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header(palette: palette)

                SectionPanel(title: store.language == .chinese ? "个人目标" : "Personal Goals", symbol: "person.crop.circle.badge.checkmark") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 2), spacing: 14) {
                        DatePicker(L.text(.countdownDate, store.language), selection: $countdownDate, displayedComponents: .date)

                        Stepper(value: $heightCm, in: 120...220, step: 0.5) {
                            Text(String(format: "%@：%.1f cm", store.language == .chinese ? "身高" : "Height", heightCm))
                                .font(.headline)
                        }

                        Stepper(value: $targetWeight, in: 35...120, step: 0.1) {
                            Text(String(format: "%@：%.1f kg", store.language == .chinese ? "目标体重" : "Target Weight", targetWeight))
                                .font(.headline)
                        }

                        Stepper(value: $weeklyGoal, in: 0.1...0.8, step: 0.05) {
                            Text(String(format: "%@：%.2f kg", L.text(.weeklyGoal, store.language), weeklyGoal))
                                .font(.headline)
                        }
                    }

                    HStack {
                        Text(store.language == .chinese ? "身高和目标会影响训练计划与热量建议。" : "Height and goals affect workout planning and calorie guidance.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button {
                            saveProfileSettings()
                        } label: {
                            Label(L.text(.saveSettings, store.language), systemImage: "checkmark.circle")
                        }
                    }
                }

                SectionPanel(title: store.language == .chinese ? "首次设置" : "First-Time Setup", symbol: "wand.and.stars") {
                    HStack {
                        Text(store.language == .chinese ? "想重新走一遍快速设置，可以从这里打开。" : "Open the quick setup again whenever you want.")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button {
                            store.showOnboardingAgain()
                        } label: {
                            Label(store.language == .chinese ? "重新打开引导" : "Open Setup", systemImage: "sparkles")
                        }
                    }
                }

                SectionPanel(title: store.language == .chinese ? "外观与语言" : "Appearance and Language", symbol: "paintpalette") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 2), spacing: 14) {
                        Picker(L.text(.language, store.language), selection: $store.language) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(language.title).tag(language)
                            }
                        }
                        .pickerStyle(.segmented)

                        Picker(L.text(.background, store.language), selection: $store.backgroundTheme) {
                            ForEach(BackgroundTheme.allCases) { theme in
                                Text(theme.title(language: store.language)).tag(theme)
                            }
                        }
                    }
                }

                SectionPanel(title: store.language == .chinese ? "数据重置" : "Data Reset", symbol: "arrow.counterclockwise.circle") {
                    Text(store.language == .chinese ? "清空每日体重列表、围度记录、热量记录、食物照片估算、自选活动、视频链接和每日清单。个人目标和外观设定会保留。" : "Clear daily weights, measurements, calories, food-photo estimates, custom activities, video links, and checklist state. Personal goals and appearance settings stay.")
                        .foregroundStyle(.secondary)

                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        Label(store.language == .chinese ? "一键清空记录历史" : "Clear Tracking History", systemImage: "trash")
                    }
                }

                Color.clear.frame(height: 10)
            }
        }
        .onAppear(perform: syncDrafts)
        .confirmationDialog(
            store.language == .chinese ? "确定清空记录历史？" : "Clear tracking history?",
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(store.language == .chinese ? "清空记录历史" : "Clear History", role: .destructive) {
                store.clearTrackingHistory()
                syncDrafts()
            }
            Button(store.language == .chinese ? "取消" : "Cancel", role: .cancel) {}
        } message: {
            Text(store.language == .chinese ? "这个操作会删除历史记录，但不会改变你的目标和主题。" : "This removes history but keeps your goals and theme.")
        }
    }

    private func header(palette: ThemePalette) -> some View {
        HStack(spacing: 14) {
            CatSticker()
                .scaleEffect(0.72)
                .frame(width: 64, height: 64)
            VStack(alignment: .leading, spacing: 6) {
                Text(L.text(.settings, store.language))
                    .font(.system(size: 31, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.berry)
                Text(store.language == .chinese ? "所有长期设定集中在这里。" : "All long-term settings live here.")
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private func syncDrafts() {
        countdownDate = store.profile.eventDate
        heightCm = store.profile.heightCm
        targetWeight = store.profile.targetWeightKg
        weeklyGoal = store.profile.weeklyGoalKg
    }

    private func saveProfileSettings() {
        store.updateCountdownDate(countdownDate)
        store.updateHeight(heightCm)
        store.updateTargetWeight(targetWeight)
        store.updateWeeklyGoal(weeklyGoal)
    }
}
