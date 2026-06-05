import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case chinese
    case english

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chinese: return "中文"
        case .english: return "English"
        }
    }
}

enum BackgroundTheme: String, CaseIterable, Identifiable, Codable {
    case pink
    case cream
    case lavender
    case mint

    var id: String { rawValue }

    func title(language: AppLanguage) -> String {
        switch (self, language) {
        case (.pink, .chinese): return "温柔粉"
        case (.cream, .chinese): return "奶油杏"
        case (.lavender, .chinese): return "淡紫梦"
        case (.mint, .chinese): return "薄荷绿"
        case (.pink, .english): return "Soft Pink"
        case (.cream, .english): return "Cream"
        case (.lavender, .english): return "Lavender"
        case (.mint, .english): return "Mint"
        }
    }
}

enum FocusArea: String, CaseIterable, Identifiable, Codable {
    case back = "背部"
    case arms = "手臂"
    case thighs = "大腿"
    case face = "脸部"
    case fullBody = "全身"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .back: return "figure.strengthtraining.traditional"
        case .arms: return "dumbbell"
        case .thighs: return "figure.walk"
        case .face: return "sparkles"
        case .fullBody: return "figure.mixed.cardio"
        }
    }

    func title(language: AppLanguage) -> String {
        switch (self, language) {
        case (.back, .chinese): return "背部"
        case (.arms, .chinese): return "手臂"
        case (.thighs, .chinese): return "大腿"
        case (.face, .chinese): return "脸部"
        case (.fullBody, .chinese): return "全身"
        case (.back, .english): return "Back"
        case (.arms, .english): return "Arms"
        case (.thighs, .english): return "Thighs"
        case (.face, .english): return "Face"
        case (.fullBody, .english): return "Full Body"
        }
    }
}

enum PlanDayType: String, Codable {
    case strength = "力量训练"
    case cardio = "低冲击有氧"
    case posture = "体态训练"
    case stretch = "拉伸放松"
    case rest = "休息"

    func title(language: AppLanguage) -> String {
        switch (self, language) {
        case (.strength, .chinese): return "力量训练"
        case (.cardio, .chinese): return "低冲击有氧"
        case (.posture, .chinese): return "体态训练"
        case (.stretch, .chinese): return "拉伸放松"
        case (.rest, .chinese): return "休息"
        case (.strength, .english): return "Strength"
        case (.cardio, .english): return "Low-Impact Cardio"
        case (.posture, .english): return "Posture"
        case (.stretch, .english): return "Stretch"
        case (.rest, .english): return "Rest"
        }
    }
}

struct UserProfile: Codable {
    var name: String
    var eventDate: Date
    var heightCm: Double
    var currentWeightKg: Double
    var targetWeightKg: Double
    var weeklyGoalKg: Double
    var selectedFocusAreas: Set<FocusArea>

    enum CodingKeys: String, CodingKey {
        case name
        case eventDate
        case heightCm
        case currentWeightKg
        case targetWeightKg
        case weeklyGoalKg
        case selectedFocusAreas
    }

    init(
        name: String,
        eventDate: Date,
        heightCm: Double = 165,
        currentWeightKg: Double,
        targetWeightKg: Double,
        weeklyGoalKg: Double,
        selectedFocusAreas: Set<FocusArea>
    ) {
        self.name = name
        self.eventDate = eventDate
        self.heightCm = heightCm
        self.currentWeightKg = currentWeightKg
        self.targetWeightKg = targetWeightKg
        self.weeklyGoalKg = weeklyGoalKg
        self.selectedFocusAreas = selectedFocusAreas
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        eventDate = try container.decode(Date.self, forKey: .eventDate)
        heightCm = try container.decodeIfPresent(Double.self, forKey: .heightCm) ?? 165
        currentWeightKg = try container.decode(Double.self, forKey: .currentWeightKg)
        targetWeightKg = try container.decode(Double.self, forKey: .targetWeightKg)
        weeklyGoalKg = try container.decode(Double.self, forKey: .weeklyGoalKg)
        selectedFocusAreas = try container.decode(Set<FocusArea>.self, forKey: .selectedFocusAreas)
    }
}

struct Exercise: Identifiable, Codable {
    var id = UUID()
    var videoKey: String = ""
    var name: String
    var focus: FocusArea
    var sets: String
    var instruction: String
    var videoURL: String? = nil
}

struct WorkoutDay: Identifiable, Codable {
    var id = UUID()
    var weekday: String
    var type: PlanDayType
    var title: String
    var durationMinutes: Int
    var exercises: [Exercise]
    var note: String
}

struct MealSuggestion: Identifiable, Codable {
    var id = UUID()
    var title: String
    var mealType: String
    var detail: String
    var proteinHint: String
}

struct WeightEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var weightKg: Double
}

struct CalorieEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var calories: Int
    var note: String
}

struct FoodPhotoEstimate: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var imageName: String
    var imagePath: String? = nil
    var estimate: String

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case imageName
        case imagePath
        case estimate
    }

    init(id: UUID = UUID(), date: Date, imageName: String, imagePath: String? = nil, estimate: String) {
        self.id = id
        self.date = date
        self.imageName = imageName
        self.imagePath = imagePath
        self.estimate = estimate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        date = try container.decode(Date.self, forKey: .date)
        imageName = try container.decode(String.self, forKey: .imageName)
        imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath)
        estimate = try container.decode(String.self, forKey: .estimate)
    }
}

enum CustomActivityKind: String, CaseIterable, Identifiable, Codable {
    case walk
    case pilates
    case yoga
    case cycling
    case swimming
    case mobility

    var id: String { rawValue }

    func title(language: AppLanguage) -> String {
        switch (self, language) {
        case (.walk, .chinese): return "快走"
        case (.pilates, .chinese): return "普拉提"
        case (.yoga, .chinese): return "瑜伽"
        case (.cycling, .chinese): return "骑车"
        case (.swimming, .chinese): return "游泳"
        case (.mobility, .chinese): return "灵活性"
        case (.walk, .english): return "Brisk Walk"
        case (.pilates, .english): return "Pilates"
        case (.yoga, .english): return "Yoga"
        case (.cycling, .english): return "Cycling"
        case (.swimming, .english): return "Swimming"
        case (.mobility, .english): return "Mobility"
        }
    }

    var symbol: String {
        switch self {
        case .walk: return "figure.walk"
        case .pilates: return "figure.core.training"
        case .yoga: return "figure.mind.and.body"
        case .cycling: return "bicycle"
        case .swimming: return "figure.pool.swim"
        case .mobility: return "figure.flexibility"
        }
    }
}

struct CustomActivity: Identifiable, Codable {
    var id = UUID()
    var dayIndex: Int
    var kind: CustomActivityKind
    var minutes: Int
    var intensity: String
}

struct MeasurementEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var chestCm: Double
    var armCm: Double
    var thighCm: Double
    var waistCm: Double
    var hipCm: Double

    init(id: UUID = UUID(), date: Date, chestCm: Double = 82.0, armCm: Double, thighCm: Double, waistCm: Double, hipCm: Double) {
        self.id = id
        self.date = date
        self.chestCm = chestCm
        self.armCm = armCm
        self.thighCm = thighCm
        self.waistCm = waistCm
        self.hipCm = hipCm
    }

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case chestCm
        case armCm
        case thighCm
        case waistCm
        case hipCm
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        date = try container.decode(Date.self, forKey: .date)
        chestCm = try container.decodeIfPresent(Double.self, forKey: .chestCm) ?? 82.0
        armCm = try container.decode(Double.self, forKey: .armCm)
        thighCm = try container.decode(Double.self, forKey: .thighCm)
        waistCm = try container.decode(Double.self, forKey: .waistCm)
        hipCm = try container.decode(Double.self, forKey: .hipCm)
    }
}

struct WellnessEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var mood: Int
    var sleepHours: Double
    var energy: Int
}

struct DailyChecklist: Codable {
    var workoutCompleted: Bool
    var stepsCompleted: Bool
    var waterCompleted: Bool
    var proteinCompleted: Bool
    var sleepCompleted: Bool
}

struct WeeklyReview: Codable {
    var summary: String
    var adjustment: String
    var encouragement: String
}
