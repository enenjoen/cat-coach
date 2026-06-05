import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var eventDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    @State private var heightCm = 165.0
    @State private var currentWeight = 50.0
    @State private var targetWeight = 47.0
    @State private var weeklyGoal = 0.35
    @State private var focusAreas: Set<FocusArea> = [.fullBody]

    var body: some View {
        let palette = store.backgroundTheme.palette
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 14) {
                CatSticker()
                    .scaleEffect(0.72)
                    .frame(width: 64, height: 64)
                VStack(alignment: .leading, spacing: 6) {
                    Text(store.language == .chinese ? "先把小猫教练调成你的版本" : "Make Cat Coach yours")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(palette.berry)
                    Text(store.language == .chinese ? "这些会影响训练计划、热量建议和倒计时。" : "These shape your workouts, calorie guidance, and countdown.")
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 2), spacing: 14) {
                DatePicker(L.text(.countdownDate, store.language), selection: $eventDate, displayedComponents: .date)

                Stepper(value: $heightCm, in: 120...220, step: 0.5) {
                    Text(String(format: "%@：%.1f cm", store.language == .chinese ? "身高" : "Height", heightCm))
                        .font(.headline)
                }

                Stepper(value: $currentWeight, in: 35...120, step: 0.1) {
                    Text(String(format: "%@：%.1f kg", L.text(.currentWeight, store.language), currentWeight))
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

            VStack(alignment: .leading, spacing: 12) {
                Text(store.language == .chinese ? "重点部位" : "Focus Areas")
                    .font(.headline)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                    ForEach(FocusArea.allCases) { area in
                        Button {
                            toggle(area)
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: area.symbol)
                                    .font(.title3)
                                Text(area.title(language: store.language))
                                    .font(.subheadline.weight(.semibold))
                            }
                            .frame(maxWidth: .infinity, minHeight: 76)
                            .foregroundStyle(focusAreas.contains(area) ? Color.white : palette.ink)
                            .background(focusAreas.contains(area) ? palette.rose : palette.softPanel)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            HStack {
                Text(store.language == .chinese ? "之后也可以在「设定」里修改。" : "You can change this later in Settings.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    store.completeOnboarding(
                        eventDate: eventDate,
                        heightCm: heightCm,
                        currentWeightKg: currentWeight,
                        targetWeightKg: targetWeight,
                        weeklyGoalKg: weeklyGoal,
                        focusAreas: focusAreas
                    )
                    dismiss()
                } label: {
                    Label(store.language == .chinese ? "开始使用" : "Start", systemImage: "checkmark.circle.fill")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(minWidth: 760, minHeight: 540)
        .background(AppBackground(theme: store.backgroundTheme))
        .onAppear {
            eventDate = store.profile.eventDate
            heightCm = store.profile.heightCm
            currentWeight = store.profile.currentWeightKg
            targetWeight = store.profile.targetWeightKg
            weeklyGoal = store.profile.weeklyGoalKg
            focusAreas = store.profile.selectedFocusAreas.isEmpty ? [.fullBody] : store.profile.selectedFocusAreas
        }
    }

    private func toggle(_ area: FocusArea) {
        if focusAreas.contains(area) {
            focusAreas.remove(area)
        } else {
            focusAreas.insert(area)
        }
    }
}
