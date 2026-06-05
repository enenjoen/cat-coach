import Foundation

@MainActor
final class AppStore: ObservableObject {
    @Published var profile: UserProfile {
        didSet { saveState() }
    }
    @Published var workoutPlan: [WorkoutDay]
    @Published var meals: [MealSuggestion]
    @Published var calorieLog: [CalorieEntry] {
        didSet { saveState() }
    }
    @Published var foodPhotoEstimates: [FoodPhotoEstimate] {
        didSet { saveState() }
    }
    @Published var customActivities: [CustomActivity] {
        didSet {
            rebuildWorkoutPlan()
            saveState()
        }
    }
    @Published var weightLog: [WeightEntry] {
        didSet { saveState() }
    }
    @Published var measurements: [MeasurementEntry] {
        didSet { saveState() }
    }
    @Published var wellness: [WellnessEntry] {
        didSet { saveState() }
    }
    @Published var checklist: DailyChecklist {
        didSet { saveState() }
    }
    @Published var weeklyReview: WeeklyReview {
        didSet { saveState() }
    }
    @Published var waterGlasses: Int {
        didSet { saveState() }
    }
    @Published var stepProgress: Int {
        didSet { saveState() }
    }
    @Published var language: AppLanguage {
        didSet {
            rebuildWorkoutPlan()
            meals = MockData.meals(language: language)
            updateWeeklyReview()
            saveState()
        }
    }
    @Published var backgroundTheme: BackgroundTheme {
        didSet { saveState() }
    }
    @Published var videoOverrides: [String: String] {
        didSet {
            applyVideoOverrides()
            saveState()
        }
    }
    @Published var hasCompletedOnboarding: Bool {
        didSet { saveState() }
    }

    private let calendar = Calendar.current
    private let dataURL = AppStore.defaultDataURL
    private let foodPhotosDirectory = AppStore.defaultDataURL
        .deletingLastPathComponent()
        .appendingPathComponent("FoodPhotos", isDirectory: true)

    init() {
        let savedState = AppStore.loadSavedState()
        let loadedProfile = savedState?.profile ?? MockData.profile
        let loadedLanguage = savedState?.language ?? .chinese

        profile = loadedProfile
        language = loadedLanguage
        backgroundTheme = savedState?.backgroundTheme ?? .pink
        videoOverrides = savedState?.videoOverrides ?? [:]
        hasCompletedOnboarding = savedState?.hasCompletedOnboarding ?? false
        workoutPlan = []
        meals = MockData.meals(language: loadedLanguage)
        calorieLog = savedState?.calorieLog ?? MockData.calorieLog
        foodPhotoEstimates = savedState?.foodPhotoEstimates ?? MockData.foodPhotoEstimates
        customActivities = savedState?.customActivities ?? []
        weightLog = savedState?.weightLog ?? MockData.weightLog
        measurements = savedState?.measurements ?? MockData.measurements
        wellness = savedState?.wellness ?? MockData.wellness
        checklist = savedState?.checklist ?? MockData.checklist
        weeklyReview = savedState?.weeklyReview ?? MockData.weeklyReview
        waterGlasses = savedState?.waterGlasses ?? 0
        stepProgress = savedState?.stepProgress ?? 0
        rebuildWorkoutPlan()
    }

    var daysRemaining: Int {
        max(calendar.dateComponents([.day], from: Date(), to: profile.eventDate).day ?? 0, 0)
    }

    var totalWeightToLose: Double {
        max(startingWeight - profile.targetWeightKg, 0.1)
    }

    var startingWeight: Double {
        weightLog.sorted { $0.date < $1.date }.first?.weightKg ?? profile.currentWeightKg
    }

    var latestWeight: Double {
        weightLog.sorted { $0.date < $1.date }.last?.weightKg ?? profile.currentWeightKg
    }

    var latestMeasurement: MeasurementEntry? {
        measurements.sorted { $0.date < $1.date }.last
    }

    var progressFraction: Double {
        let lost = startingWeight - latestWeight
        return min(max(lost / totalWeightToLose, 0), 1)
    }

    var isPersonalWeek: Bool {
        daysRemaining <= 7
    }

    var weeklyWeightChange: Double {
        guard let latest = weightLog.sorted(by: { $0.date < $1.date }).last else { return 0 }
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: latest.date) ?? latest.date
        let previous = weightLog
            .filter { $0.date <= sevenDaysAgo }
            .sorted { $0.date < $1.date }
            .last
        return (previous?.weightKg ?? profile.currentWeightKg) - latest.weightKg
    }

    func toggleFocusArea(_ area: FocusArea) {
        if profile.selectedFocusAreas.contains(area) {
            profile.selectedFocusAreas.remove(area)
        } else {
            profile.selectedFocusAreas.insert(area)
        }
        rebuildWorkoutPlan()
        saveState()
    }

    func toggleChecklist(_ keyPath: WritableKeyPath<DailyChecklist, Bool>) {
        checklist[keyPath: keyPath].toggle()
    }

    func addWeight(_ weight: Double) {
        weightLog.append(WeightEntry(date: Date(), weightKg: weight))
        profile.currentWeightKg = weight
    }

    func updateCurrentWeight(_ weight: Double) {
        profile.currentWeightKg = weight
        if let index = weightLog.lastIndex(where: { calendar.isDateInToday($0.date) }) {
            weightLog[index].weightKg = weight
        } else {
            weightLog.append(WeightEntry(date: Date(), weightKg: weight))
        }
        updateWeeklyReview()
        rebuildWorkoutPlan()
    }

    func deleteWeightEntry(_ entry: WeightEntry) {
        weightLog.removeAll { $0.id == entry.id }
        profile.currentWeightKg = latestWeight
        updateWeeklyReview()
        rebuildWorkoutPlan()
    }

    func clearTrackingHistory() {
        weightLog = []
        measurements = []
        calorieLog = []
        foodPhotoEstimates = []
        customActivities = []
        videoOverrides = [:]
        wellness = []
        checklist = DailyChecklist(
            workoutCompleted: false,
            stepsCompleted: false,
            waterCompleted: false,
            proteinCompleted: false,
            sleepCompleted: false
        )
        waterGlasses = 0
        stepProgress = 0
        weeklyReview = MockData.weeklyReview
        rebuildWorkoutPlan()
        saveState()
    }

    func completeOnboarding(
        eventDate: Date,
        heightCm: Double,
        currentWeightKg: Double,
        targetWeightKg: Double,
        weeklyGoalKg: Double,
        focusAreas: Set<FocusArea>
    ) {
        profile.eventDate = eventDate
        profile.heightCm = heightCm
        profile.currentWeightKg = currentWeightKg
        profile.targetWeightKg = targetWeightKg
        profile.weeklyGoalKg = weeklyGoalKg
        profile.selectedFocusAreas = focusAreas.isEmpty ? [.fullBody] : focusAreas
        hasCompletedOnboarding = true
        rebuildWorkoutPlan()
        updateWeeklyReview()
        saveState()
    }

    func showOnboardingAgain() {
        hasCompletedOnboarding = false
    }

    func updateTargetWeight(_ weight: Double) {
        profile.targetWeightKg = weight
        rebuildWorkoutPlan()
    }

    func updateWeeklyGoal(_ weight: Double) {
        profile.weeklyGoalKg = weight
        updateWeeklyReview()
        rebuildWorkoutPlan()
    }

    func updateHeight(_ height: Double) {
        profile.heightCm = height
        rebuildWorkoutPlan()
    }

    func updateCountdownDate(_ date: Date) {
        profile.eventDate = date
    }

    func updateVideoURL(for key: String, url: String) {
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            videoOverrides.removeValue(forKey: key)
        } else {
            videoOverrides[key] = trimmed
        }
    }

    func videoURL(for exercise: Exercise) -> String {
        let key = videoKey(for: exercise)
        return videoOverrides[key] ?? exercise.videoURL ?? ""
    }

    func videoKey(for exercise: Exercise) -> String {
        exercise.videoKey.isEmpty ? exercise.name : exercise.videoKey
    }

    func updateWeeklyMeasurement(chest: Double, arm: Double, thigh: Double, waist: Double, hip: Double) {
        let entry = MeasurementEntry(
            date: Date(),
            chestCm: chest,
            armCm: arm,
            thighCm: thigh,
            waistCm: waist,
            hipCm: hip
        )

        if let index = measurements.lastIndex(where: { calendar.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }) {
            measurements[index] = entry
        } else {
            measurements.append(entry)
        }
    }

    func deleteMeasurementEntry(_ entry: MeasurementEntry) {
        measurements.removeAll { $0.id == entry.id }
        updateWeeklyReview()
    }

    func addCalorieEntry(calories: Int, note: String) {
        let entry = CalorieEntry(date: Date(), calories: calories, note: note)
        if let index = calorieLog.lastIndex(where: { calendar.isDateInToday($0.date) }) {
            calorieLog[index] = entry
        } else {
            calorieLog.append(entry)
        }
    }

    func deleteCalorieEntry(_ entry: CalorieEntry) {
        calorieLog.removeAll { $0.id == entry.id }
    }

    func addFoodPhotoEstimate(imageName: String) {
        addFoodPhotoEstimate(imageName: imageName, imagePath: nil)
    }

    func addFoodPhotoEstimate(from url: URL) {
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            try FileManager.default.createDirectory(at: foodPhotosDirectory, withIntermediateDirectories: true)
            let ext = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
            let fileName = "\(UUID().uuidString).\(ext)"
            let destination = foodPhotosDirectory.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.copyItem(at: url, to: destination)
            addFoodPhotoEstimate(imageName: url.lastPathComponent, imagePath: destination.path)
        } catch {
            addFoodPhotoEstimate(imageName: url.lastPathComponent, imagePath: nil)
        }
    }

    private func addFoodPhotoEstimate(imageName: String, imagePath: String?) {
        let target = estimatedDailyCalories
        let estimate = language == .chinese
            ? "AI 估算占位：请接入视觉模型后识别食物。当前建议用 \(target) kcal/天作参考。"
            : "AI estimate placeholder: connect a vision model to identify food. Current daily reference is \(target) kcal."
        foodPhotoEstimates.append(FoodPhotoEstimate(date: Date(), imageName: imageName, imagePath: imagePath, estimate: estimate))
    }

    func deleteFoodPhotoEstimate(_ estimate: FoodPhotoEstimate) {
        if let imagePath = estimate.imagePath, FileManager.default.fileExists(atPath: imagePath) {
            try? FileManager.default.removeItem(atPath: imagePath)
        }
        foodPhotoEstimates.removeAll { $0.id == estimate.id }
    }

    func addCustomActivity(dayIndex: Int, kind: CustomActivityKind, minutes: Int, intensity: String) {
        customActivities.append(CustomActivity(dayIndex: dayIndex, kind: kind, minutes: minutes, intensity: intensity))
    }

    func deleteCustomActivity(_ activity: CustomActivity) {
        customActivities.removeAll { $0.id == activity.id }
    }

    var estimatedDailyCalories: Int {
        let heightAdjustment = (profile.heightCm - 165) * 4
        let weightAdjustment = (latestWeight - 50) * 12
        let goalAdjustment = min(max(profile.weeklyGoalKg, 0.1), 0.7) * 230
        let raw = 1550 + heightAdjustment + weightAdjustment - goalAdjustment
        return Int((min(max(raw, 1200), 2300) / 10).rounded() * 10)
    }

    func updateWeeklyReview() {
        let change = weeklyWeightChange
        if change < 0.1 {
            weeklyReview = language == .chinese
                ? WeeklyReview(
                    summary: "这一周进展稳定，但变化比较细微。",
                    adjustment: "先保持均衡饮食，在两餐后加 10 分钟轻松散步，并优先保证睡眠，不急着减少食量。",
                    encouragement: "小幅进步也算数。稳定坚持正在悄悄发挥作用。"
                )
                : WeeklyReview(
                    summary: "Progress looks steady but subtle this week.",
                    adjustment: "Keep meals balanced, add a gentle 10-minute walk after two meals, and prioritize sleep before reducing food intake.",
                    encouragement: "Small weeks still count. Consistency is doing the quiet work."
                )
        } else if change > 0.7 {
            weeklyReview = language == .chinese
                ? WeeklyReview(
                    summary: "这一周体重下降速度偏快，超过了通常更健康的活动准备节奏。",
                    adjustment: "稍微降低训练强度，训练前后补充一点碳水。如果这种速度持续，建议咨询医生或营养师。",
                    encouragement: "状态好、有力量、吃得够，比匆忙追体重数字更重要。"
                )
                : WeeklyReview(
                    summary: "Weight moved faster than the usual healthy event-prep range this week.",
                    adjustment: "Ease intensity slightly, add a little more carbohydrate around workouts, and check in with a doctor or dietitian if this pace continues.",
                    encouragement: "Feeling strong and well-fueled matters more than rushing the scale."
                )
        } else {
            weeklyReview = language == .chinese
                ? WeeklyReview(
                    summary: "你的进度处在循序渐进、现实健康的范围内。",
                    adjustment: "计划可以继续照做，保留容易执行的餐食，动作稳定后再慢慢增加阻力。",
                    encouragement: "这种从容的进步，会体现在你的状态、体态和自信上。"
                )
                : WeeklyReview(
                    summary: "You are tracking within a gradual, realistic range.",
                    adjustment: "Keep the plan as-is, repeat meals that feel easy, and increase resistance only when form feels confident.",
                    encouragement: "This calm momentum supports confidence, posture, and everyday energy."
                )
        }
    }

    private func saveState() {
        let state = AppState(
            profile: profile,
            calorieLog: calorieLog,
            foodPhotoEstimates: foodPhotoEstimates,
            customActivities: customActivities,
            weightLog: weightLog,
            measurements: measurements,
            wellness: wellness,
            checklist: checklist,
            weeklyReview: weeklyReview,
            waterGlasses: waterGlasses,
            stepProgress: stepProgress,
            language: language,
            backgroundTheme: backgroundTheme,
            videoOverrides: videoOverrides,
            hasCompletedOnboarding: hasCompletedOnboarding
        )

        do {
            try FileManager.default.createDirectory(
                at: dataURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            try encoder.encode(state).write(to: dataURL, options: .atomic)
        } catch {
            print("保存本地数据失败：\(error.localizedDescription)")
        }
    }

    private static func loadSavedState() -> AppState? {
        do {
            let data = try Data(contentsOf: defaultDataURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(AppState.self, from: data)
        } catch {
            return nil
        }
    }

    private static var defaultDataURL: URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return baseURL
            .appendingPathComponent("PersonalTrainer", isDirectory: true)
            .appendingPathComponent("app-state.json")
    }

    private func applyVideoOverrides() {
        workoutPlan = workoutPlan.map { day in
            var updatedDay = day
            updatedDay.exercises = day.exercises.map { exercise in
                var updatedExercise = exercise
                let key = videoKey(for: exercise)
                if let override = videoOverrides[key] {
                    updatedExercise.videoURL = override
                }
                return updatedExercise
            }
            return updatedDay
        }
    }

    private func rebuildWorkoutPlan() {
        workoutPlan = MockData.workoutPlan(profile: profile, customActivities: customActivities, language: language)
        applyVideoOverrides()
    }
}

private struct AppState: Codable {
    var profile: UserProfile
    var calorieLog: [CalorieEntry]
    var foodPhotoEstimates: [FoodPhotoEstimate]
    var customActivities: [CustomActivity]
    var weightLog: [WeightEntry]
    var measurements: [MeasurementEntry]
    var wellness: [WellnessEntry]
    var checklist: DailyChecklist
    var weeklyReview: WeeklyReview
    var waterGlasses: Int
    var stepProgress: Int
    var language: AppLanguage
    var backgroundTheme: BackgroundTheme
    var videoOverrides: [String: String]
    var hasCompletedOnboarding: Bool

    enum CodingKeys: String, CodingKey {
        case profile
        case calorieLog
        case foodPhotoEstimates
        case customActivities
        case weightLog
        case measurements
        case wellness
        case checklist
        case weeklyReview
        case waterGlasses
        case stepProgress
        case language
        case backgroundTheme
        case videoOverrides
        case hasCompletedOnboarding
    }

    init(
        profile: UserProfile,
        calorieLog: [CalorieEntry],
        foodPhotoEstimates: [FoodPhotoEstimate],
        customActivities: [CustomActivity],
        weightLog: [WeightEntry],
        measurements: [MeasurementEntry],
        wellness: [WellnessEntry],
        checklist: DailyChecklist,
        weeklyReview: WeeklyReview,
        waterGlasses: Int,
        stepProgress: Int,
        language: AppLanguage,
        backgroundTheme: BackgroundTheme,
        videoOverrides: [String: String],
        hasCompletedOnboarding: Bool
    ) {
        self.profile = profile
        self.calorieLog = calorieLog
        self.foodPhotoEstimates = foodPhotoEstimates
        self.customActivities = customActivities
        self.weightLog = weightLog
        self.measurements = measurements
        self.wellness = wellness
        self.checklist = checklist
        self.weeklyReview = weeklyReview
        self.waterGlasses = waterGlasses
        self.stepProgress = stepProgress
        self.language = language
        self.backgroundTheme = backgroundTheme
        self.videoOverrides = videoOverrides
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        profile = try container.decode(UserProfile.self, forKey: .profile)
        calorieLog = try container.decodeIfPresent([CalorieEntry].self, forKey: .calorieLog) ?? MockData.calorieLog
        foodPhotoEstimates = try container.decodeIfPresent([FoodPhotoEstimate].self, forKey: .foodPhotoEstimates) ?? MockData.foodPhotoEstimates
        customActivities = try container.decodeIfPresent([CustomActivity].self, forKey: .customActivities) ?? []
        weightLog = try container.decodeIfPresent([WeightEntry].self, forKey: .weightLog) ?? MockData.weightLog
        measurements = try container.decodeIfPresent([MeasurementEntry].self, forKey: .measurements) ?? MockData.measurements
        wellness = try container.decodeIfPresent([WellnessEntry].self, forKey: .wellness) ?? MockData.wellness
        checklist = try container.decodeIfPresent(DailyChecklist.self, forKey: .checklist) ?? MockData.checklist
        weeklyReview = try container.decode(WeeklyReview.self, forKey: .weeklyReview)
        waterGlasses = try container.decode(Int.self, forKey: .waterGlasses)
        stepProgress = try container.decode(Int.self, forKey: .stepProgress)
        language = try container.decodeIfPresent(AppLanguage.self, forKey: .language) ?? .chinese
        backgroundTheme = try container.decodeIfPresent(BackgroundTheme.self, forKey: .backgroundTheme) ?? .pink
        videoOverrides = try container.decodeIfPresent([String: String].self, forKey: .videoOverrides) ?? [:]
        hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
    }
}
