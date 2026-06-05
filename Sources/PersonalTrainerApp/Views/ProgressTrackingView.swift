import SwiftUI

struct ProgressTrackingView: View {
    @EnvironmentObject private var store: AppStore
    @State private var currentWeight = 50.0
    @State private var chestMeasurement = 82.6
    @State private var armMeasurement = 27.4
    @State private var thighMeasurement = 52.0
    @State private var waistMeasurement = 66.2
    @State private var hipMeasurement = 90.6

    var body: some View {
        let palette = store.backgroundTheme.palette
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(L.text(.progress, store.language))
                    .font(.system(size: 31, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.berry)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    MetricCard(title: store.language == .chinese ? "最新体重" : "Latest Weight", value: String(format: "%.1f kg", store.latestWeight), caption: store.language == .chinese ? "尽量参考每周平均值" : "Use weekly averages when possible", symbol: "scalemass")
                    MetricCard(title: store.language == .chinese ? "今日步数" : "Steps Today", value: "\(store.stepProgress)", caption: store.language == .chinese ? "低冲击活动也很有价值" : "Low-impact movement counts", symbol: "shoeprints.fill")
                    MetricCard(title: store.language == .chinese ? "睡眠" : "Sleep", value: store.language == .chinese ? String(format: "%.1f 小时", store.wellness.first?.sleepHours ?? 0) : String(format: "%.1f h", store.wellness.first?.sleepHours ?? 0), caption: store.language == .chinese ? "恢复有助于线条和食欲稳定" : "Recovery supports tone and appetite", symbol: "moon.zzz.fill")
                }

                SectionPanel(title: store.language == .chinese ? "记录今日体重" : "Log Today's Weight", symbol: "scalemass") {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Stepper(value: $currentWeight, in: 35...80, step: 0.1) {
                                Text(String(format: "%@：%.1f kg", L.text(.currentWeight, store.language), currentWeight))
                                    .font(.headline)
                            }
                            Button {
                                store.updateCurrentWeight(currentWeight)
                            } label: {
                                Label(store.language == .chinese ? "更新当前体重" : "Update Current Weight", systemImage: "checkmark.circle")
                            }
                        }

                        Text(store.language == .chinese ? "只会记录你保存过的日期；没有记录的日期不会自动补出来。" : "Only saved dates appear here; missing days are not auto-filled.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                SectionPanel(title: store.language == .chinese ? "每日体重列表" : "Daily Weight Table", symbol: "tablecells") {
                    if sortedWeightEntries.isEmpty {
                        EmptyStateLabel(
                            title: store.language == .chinese ? "还没有体重记录" : "No weight records yet",
                            message: store.language == .chinese ? "保存今日体重后，这里会按真实记录日期显示。" : "Save today's weight and this table will show real recorded dates."
                        )
                    } else {
                        Grid(alignment: .leading, horizontalSpacing: 28, verticalSpacing: 12) {
                            GridRow {
                                Text(store.language == .chinese ? "日期" : "Date").font(.headline)
                                Text(store.language == .chinese ? "体重" : "Weight").font(.headline)
                                Text(store.language == .chinese ? "变化" : "Change").font(.headline)
                                Text("").font(.headline)
                            }
                            ForEach(sortedWeightEntries) { entry in
                                GridRow {
                                    Text(entry.date, style: .date)
                                    Text(String(format: "%.1f kg", entry.weightKg))
                                    Text(weightDeltaText(for: entry))
                                        .foregroundStyle(weightDelta(for: entry) <= 0 ? palette.completed : palette.rose)
                                    Button(role: .destructive) {
                                        store.deleteWeightEntry(entry)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .buttonStyle(.borderless)
                                }
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                SectionPanel(title: L.text(.measurement, store.language), symbol: "ruler") {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(store.language == .chinese ? "建议每周固定同一天、相似时间测量一次。这里可以手动调整本周围度。\(store.measurements.isEmpty ? L.text(.firstWeekHint, store.language) : "")" : "Measure once a week on the same day and similar time. You can manually adjust this week's measurements here. \(store.measurements.isEmpty ? L.text(.firstWeekHint, store.language) : "")")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 2), spacing: 12) {
                            MeasurementStepper(title: L.text(.chest, store.language), value: $chestMeasurement)
                            MeasurementStepper(title: L.text(.arm, store.language), value: $armMeasurement)
                            MeasurementStepper(title: L.text(.thigh, store.language), value: $thighMeasurement)
                            MeasurementStepper(title: L.text(.waist, store.language), value: $waistMeasurement)
                            MeasurementStepper(title: L.text(.hip, store.language), value: $hipMeasurement)
                        }

                        Button {
                            store.updateWeeklyMeasurement(
                                chest: chestMeasurement,
                                arm: armMeasurement,
                                thigh: thighMeasurement,
                                waist: waistMeasurement,
                                hip: hipMeasurement
                            )
                        } label: {
                            Label(L.text(.saveWeeklyMeasurement, store.language), systemImage: "checkmark.circle")
                        }
                    }

                    Divider()

                    if store.measurements.isEmpty {
                        EmptyStateLabel(
                            title: store.language == .chinese ? "还没有围度记录" : "No measurement records yet",
                            message: store.language == .chinese ? "保存第一次记录后，这里会按真实日期显示每周列表。" : "Save your first entry and this table will show real weekly records by date."
                        )
                    } else {
                        Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 12) {
                            GridRow {
                                Text(store.language == .chinese ? "日期" : "Date").font(.headline)
                                Text(L.text(.chest, store.language)).font(.headline)
                                Text(L.text(.arm, store.language)).font(.headline)
                                Text(L.text(.thigh, store.language)).font(.headline)
                                Text(L.text(.waist, store.language)).font(.headline)
                                Text(L.text(.hip, store.language)).font(.headline)
                                Text("").font(.headline)
                            }
                            ForEach(store.measurements.sorted { $0.date > $1.date }) { entry in
                                GridRow {
                                    Text(entry.date, style: .date)
                                    Text(String(format: "%.1f cm", entry.chestCm))
                                    Text(String(format: "%.1f cm", entry.armCm))
                                    Text(String(format: "%.1f cm", entry.thighCm))
                                    Text(String(format: "%.1f cm", entry.waistCm))
                                    Text(String(format: "%.1f cm", entry.hipCm))
                                    Button(role: .destructive) {
                                        store.deleteMeasurementEntry(entry)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .buttonStyle(.borderless)
                                }
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                SectionPanel(title: store.language == .chinese ? "照片与状态提醒" : "Photos and Wellness Reminder", symbol: "camera") {
                    Text(store.language == .chinese ? "每周在相似光线和体态下拍进度照。记录心情、睡眠和精力，让进步不只由体重数字决定。" : "Take weekly progress photos in similar lighting and posture. Track mood, sleep, and energy so progress is not only about the scale.")
                        .foregroundStyle(Theme.ink)
                }
                Color.clear.frame(height: 10)
            }
        }
        .onAppear {
            currentWeight = store.latestWeight
            if let measurement = store.latestMeasurement {
                chestMeasurement = measurement.chestCm
                armMeasurement = measurement.armCm
                thighMeasurement = measurement.thighCm
                waistMeasurement = measurement.waistCm
                hipMeasurement = measurement.hipCm
            }
        }
    }

    private var sortedWeightEntries: [WeightEntry] {
        store.weightLog.sorted { $0.date > $1.date }
    }

    private func weightDelta(for entry: WeightEntry) -> Double {
        let sorted = store.weightLog.sorted { $0.date < $1.date }
        guard let index = sorted.firstIndex(where: { $0.id == entry.id }), index > 0 else { return 0 }
        return entry.weightKg - sorted[index - 1].weightKg
    }

    private func weightDeltaText(for entry: WeightEntry) -> String {
        let delta = weightDelta(for: entry)
        if abs(delta) < 0.05 { return "0.0 kg" }
        return String(format: "%+.1f kg", delta)
    }
}

private struct EmptyStateLabel: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: "tray")
                .font(.headline)
            Text(message)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

private struct MeasurementStepper: View {
    @EnvironmentObject private var store: AppStore
    let title: String
    @Binding var value: Double

    var body: some View {
        Stepper(value: $value, in: 20...140, step: 0.1) {
            Text(String(format: "%@：%.1f cm", title, value))
                .font(.headline)
        }
        .padding(12)
        .background(store.backgroundTheme.palette.softPanel)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(store.backgroundTheme.palette.blush.opacity(0.28)))
    }
}
