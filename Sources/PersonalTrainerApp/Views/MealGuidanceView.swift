import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct MealGuidanceView: View {
    @EnvironmentObject private var store: AppStore
    @State private var calories = 1540
    @State private var calorieNote = ""
    @State private var showingFoodImporter = false

    var body: some View {
        let palette = store.backgroundTheme.palette
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(store.language == .chinese ? "饮食与热量建议" : "Meal and Calorie Guidance")
                    .font(.system(size: 31, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.berry)

                SectionPanel(title: store.language == .chinese ? "健康活动准备原则" : "Healthy Event Prep Principles", symbol: "leaf") {
                    Text(store.language == .chinese ? "以高蛋白、适量碳水、丰富蔬菜、规律补水和足够能量为核心。避免挨饿、排毒餐和极端限制。" : "Aim for high-protein meals, moderate carbohydrates, colorful plants, regular hydration, and enough food to train well. Avoid starvation, detoxes, and extreme restriction.")
                        .foregroundStyle(Theme.ink)
                    Text(store.language == .chinese ? "如果需要个人热量目标、有健康顾虑，或曾有饮食失调经历，请咨询医生或营养师。" : "For personal calorie targets, medical concerns, or a history of disordered eating, consult a doctor or dietitian.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                SectionPanel(title: store.language == .chinese ? "身高体重与每日热量" : "Height, Weight, and Daily Calories", symbol: "flame") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 3), spacing: 14) {
                        MetricCard(title: store.language == .chinese ? "身高" : "Height", value: String(format: "%.1f cm", store.profile.heightCm), caption: store.language == .chinese ? "来自个人记录" : "From your profile", symbol: "ruler")
                        MetricCard(title: store.language == .chinese ? "体重" : "Weight", value: String(format: "%.1f kg", store.latestWeight), caption: store.language == .chinese ? "来自每日体重表" : "From daily log", symbol: "scalemass")
                        MetricCard(title: store.language == .chinese ? "建议热量" : "Calorie Target", value: "\(store.estimatedDailyCalories) kcal", caption: store.language == .chinese ? "按身高体重温和估算" : "Gentle estimate from height and weight", symbol: "gauge.with.dots.needle.50percent")
                    }

                    HStack {
                        Stepper(value: $calories, in: 800...4000, step: 10) {
                            Text("\(calories) kcal")
                                .font(.headline)
                        }
                        TextField(store.language == .chinese ? "备注，例如：含加餐" : "Note, e.g. includes snack", text: $calorieNote)
                            .textFieldStyle(.roundedBorder)
                        Button {
                            store.addCalorieEntry(calories: calories, note: calorieNote)
                            calorieNote = ""
                        } label: {
                            Label(store.language == .chinese ? "记录今日热量" : "Log Today", systemImage: "plus.circle")
                        }
                    }

                    Grid(alignment: .leading, horizontalSpacing: 28, verticalSpacing: 10) {
                        GridRow {
                            Text(store.language == .chinese ? "日期" : "Date").font(.headline)
                            Text(store.language == .chinese ? "热量" : "Calories").font(.headline)
                            Text(store.language == .chinese ? "备注" : "Note").font(.headline)
                            Text("").font(.headline)
                        }
                        ForEach(store.calorieLog.sorted { $0.date > $1.date }) { entry in
                            GridRow {
                                Text(entry.date, style: .date)
                                Text("\(entry.calories) kcal")
                                Text(entry.note.isEmpty ? "-" : entry.note)
                                Button(role: .destructive) {
                                    store.deleteCalorieEntry(entry)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.borderless)
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }

                SectionPanel(title: store.language == .chinese ? "食物照片热量估算" : "Food Photo Calorie Estimate", symbol: "camera.viewfinder") {
                    Text(store.language == .chinese ? "上传食物照片后，可接入视觉 AI 自动估算食物和热量；当前 MVP 会先保存图片名称并生成估算占位。" : "Upload a food photo and a vision AI can estimate food and calories. This MVP stores the image name and creates an estimate placeholder.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button {
                        showingFoodImporter = true
                    } label: {
                        Label(store.language == .chinese ? "上传食物照片" : "Upload Food Photo", systemImage: "photo.badge.plus")
                    }

                    ForEach(store.foodPhotoEstimates.sorted { $0.date > $1.date }) { estimate in
                        HStack(alignment: .top, spacing: 12) {
                            FoodPhotoThumbnail(path: estimate.imagePath)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(estimate.imageName)
                                    .font(.headline)
                                Text(estimate.estimate)
                                    .foregroundStyle(.secondary)
                                Text(estimate.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                store.deleteFoodPhotoEstimate(estimate)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(palette.softPanel)
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                    }
                }

                SectionPanel(title: store.language == .chinese ? "饮水记录" : "Water Tracker", symbol: "drop.fill") {
                    HStack(spacing: 14) {
                        Stepper(value: $store.waterGlasses, in: 0...12) {
                            Text(store.language == .chinese ? "\(store.waterGlasses) / 8 杯" : "\(store.waterGlasses) of 8 glasses")
                                .font(.headline)
                        }
                        ProgressView(value: Double(store.waterGlasses), total: 8)
                            .tint(palette.rose)
                    }
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(store.meals) { meal in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(meal.mealType)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(palette.softGold)
                            Text(meal.title)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(palette.ink)
                            Text(meal.detail)
                                .foregroundStyle(.secondary)
                            Label(meal.proteinHint, systemImage: "checkmark.seal")
                                .font(.footnote)
                                .foregroundStyle(palette.completed)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
                        .background(palette.panel)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cuteRadius))
                        .overlay(RoundedRectangle(cornerRadius: Theme.cuteRadius).stroke(palette.blush.opacity(0.32)))
                        .shadow(color: palette.rose.opacity(0.08), radius: 12, x: 0, y: 7)
                    }
                }
                Color.clear.frame(height: 10)
            }
        }
        .fileImporter(isPresented: $showingFoodImporter, allowedContentTypes: [.image]) { result in
            if case let .success(url) = result {
                store.addFoodPhotoEstimate(from: url)
            }
        }
        .onAppear {
            calories = store.estimatedDailyCalories
        }
    }
}

private struct FoodPhotoThumbnail: View {
    let path: String?

    var body: some View {
        Group {
            if let path, let image = NSImage(contentsOfFile: path) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.5))
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.65)))
    }
}
