import SwiftUI

struct WorkoutPlanView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedDayIndex = 0
    @State private var videoDrafts: [String: String] = [:]
    @State private var previewURL: URL?
    @State private var previewTitle = ""
    @State private var customActivityKind: CustomActivityKind = .walk
    @State private var customActivityMinutes = 20
    @State private var customActivityIntensity = "轻松到中等"

    var body: some View {
        let palette = store.backgroundTheme.palette
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(L.text(.workoutPlan, store.language))
                    .font(.system(size: 31, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.berry)

                PersonalWeekBanner()

                if !store.workoutPlan.isEmpty {
                    carouselControls(palette: palette)
                    customActivityPanel(palette: palette)
                    dayCard(store.workoutPlan[safe: selectedDayIndex] ?? store.workoutPlan[0], palette: palette)
                }
                Color.clear.frame(height: 10)
            }
        }
        .onAppear {
            syncVideoDrafts()
        }
        .onChange(of: store.workoutPlan.count) { _ in
            selectedDayIndex = min(selectedDayIndex, max(store.workoutPlan.count - 1, 0))
            syncVideoDrafts()
        }
        .sheet(item: previewBinding) { item in
            VideoPreviewView(url: item.url, title: item.title)
                .environmentObject(store)
        }
    }

    private func carouselControls(palette: ThemePalette) -> some View {
        HStack(spacing: 14) {
            Button {
                selectedDayIndex = max(selectedDayIndex - 1, 0)
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title)
            }
            .buttonStyle(.plain)
            .foregroundStyle(palette.rose)
            .disabled(selectedDayIndex == 0)

            HStack(spacing: 7) {
                ForEach(store.workoutPlan.indices, id: \.self) { index in
                    Circle()
                        .fill(index == selectedDayIndex ? palette.rose : palette.blush.opacity(0.36))
                        .frame(width: index == selectedDayIndex ? 12 : 8, height: index == selectedDayIndex ? 12 : 8)
                }
            }

            Button {
                selectedDayIndex = min(selectedDayIndex + 1, store.workoutPlan.count - 1)
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title)
            }
            .buttonStyle(.plain)
            .foregroundStyle(palette.rose)
            .disabled(selectedDayIndex >= store.workoutPlan.count - 1)

            Spacer()

            Text(store.language == .chinese ? "左右切换训练日" : "Switch workout days")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }

    private func dayCard(_ day: WorkoutDay, palette: ThemePalette) -> some View {
        SectionPanel(title: "\(day.weekday): \(day.title)", symbol: icon(for: day.type)) {
            HStack {
                Text(day.type.title(language: store.language))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.rose)
                Spacer()
                Label(store.language == .chinese ? "\(day.durationMinutes) 分钟" : "\(day.durationMinutes) min", systemImage: "clock")
                    .foregroundStyle(.secondary)
            }

            ForEach(day.exercises) { exercise in
                exerciseCard(exercise, palette: palette)
            }

            Text(day.note)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func customActivityPanel(palette: ThemePalette) -> some View {
        SectionPanel(title: store.language == .chinese ? "插入自选活动" : "Insert Activity", symbol: "plus.rectangle.on.rectangle") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 3), spacing: 14) {
                Picker(store.language == .chinese ? "活动类型" : "Activity", selection: $customActivityKind) {
                    ForEach(CustomActivityKind.allCases) { kind in
                        Label(kind.title(language: store.language), systemImage: kind.symbol).tag(kind)
                    }
                }

                Stepper(value: $customActivityMinutes, in: 5...90, step: 5) {
                    Text(store.language == .chinese ? "\(customActivityMinutes) 分钟" : "\(customActivityMinutes) min")
                        .font(.headline)
                }

                TextField(store.language == .chinese ? "强度，例如：轻松到中等" : "Intensity, e.g. easy to moderate", text: $customActivityIntensity)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Label(customActivityKind.title(language: store.language), systemImage: customActivityKind.symbol)
                    .foregroundStyle(palette.rose)
                Text(store.language == .chinese ? "会加入当前选中的训练日" : "Adds to the selected workout day")
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    store.addCustomActivity(
                        dayIndex: selectedDayIndex,
                        kind: customActivityKind,
                        minutes: customActivityMinutes,
                        intensity: customActivityIntensity
                    )
                } label: {
                    Label(store.language == .chinese ? "加入计划" : "Add to Plan", systemImage: "plus.circle.fill")
                }
            }

            let activities = customActivitiesForSelectedDay
            if !activities.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 10) {
                    Text(store.language == .chinese ? "当前训练日的自选活动" : "Custom activities for this day")
                        .font(.headline)
                    ForEach(activities) { activity in
                        HStack(spacing: 10) {
                            Image(systemName: activity.kind.symbol)
                                .foregroundStyle(palette.rose)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(activity.kind.title(language: store.language))
                                    .font(.subheadline.weight(.semibold))
                                Text(store.language == .chinese ? "\(activity.minutes) 分钟 - \(activity.intensity)" : "\(activity.minutes) min - \(activity.intensity)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                store.deleteCustomActivity(activity)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(10)
                        .background(palette.softPanel)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }

    private func exerciseCard(_ exercise: Exercise, palette: ThemePalette) -> some View {
        let key = store.videoKey(for: exercise)
        let draft = Binding<String>(
            get: { videoDrafts[key] ?? store.videoURL(for: exercise) },
            set: { videoDrafts[key] = $0 }
        )

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(exercise.name)
                    .font(.headline)
                Spacer()
                Text(exercise.sets)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.softGold)
            }
            Text(exercise.instruction)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                TextField(store.language == .chinese ? "粘贴 YouTube 或 B站链接" : "Paste YouTube or Bilibili link", text: draft)
                    .textFieldStyle(.roundedBorder)

                Button {
                    store.updateVideoURL(for: key, url: draft.wrappedValue)
                } label: {
                    Label(store.language == .chinese ? "保存" : "Save", systemImage: "checkmark.circle")
                }

                Button {
                    if let url = URL(string: draft.wrappedValue), !draft.wrappedValue.isEmpty {
                        previewTitle = exercise.name
                        previewURL = url
                    }
                } label: {
                    Label(store.language == .chinese ? "预览" : "Preview", systemImage: "play.rectangle.fill")
                }
                .disabled(URL(string: draft.wrappedValue) == nil)
            }
        }
        .padding(12)
        .background(palette.softPanel)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(palette.blush.opacity(0.28)))
    }

    private var previewBinding: Binding<VideoPreviewItem?> {
        Binding(
            get: {
                guard let previewURL else { return nil }
                return VideoPreviewItem(url: previewURL, title: previewTitle)
            },
            set: { item in
                previewURL = item?.url
                previewTitle = item?.title ?? ""
            }
        )
    }

    private func syncVideoDrafts() {
        var drafts = videoDrafts
        for day in store.workoutPlan {
            for exercise in day.exercises {
                let key = store.videoKey(for: exercise)
                drafts[key] = drafts[key] ?? store.videoURL(for: exercise)
            }
        }
        videoDrafts = drafts
    }

    private var customActivitiesForSelectedDay: [CustomActivity] {
        store.customActivities.filter { $0.dayIndex == selectedDayIndex }
    }

    private func icon(for type: PlanDayType) -> String {
        switch type {
        case .strength: return "dumbbell"
        case .cardio: return "heart"
        case .posture: return "figure.stand"
        case .stretch: return "figure.cooldown"
        case .rest: return "bed.double"
        }
    }
}

private struct VideoPreviewItem: Identifiable {
    var id: String { url.absoluteString }
    let url: URL
    let title: String
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
