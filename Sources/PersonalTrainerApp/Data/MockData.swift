import Foundation

enum MockData {
    static let profile = UserProfile(
        name: "Joen",
        eventDate: Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 20)) ?? Date(),
        heightCm: 165,
        currentWeightKg: 50,
        targetWeightKg: 45.5,
        weeklyGoalKg: 0.35,
        selectedFocusAreas: [.back, .arms, .thighs, .face, .fullBody]
    )

    static func workoutPlan(profile: UserProfile, customActivities: [CustomActivity], language: AppLanguage = .chinese) -> [WorkoutDay] {
        let selected = profile.selectedFocusAreas.isEmpty ? Set(FocusArea.allCases) : profile.selectedFocusAreas
        let bmi = profile.currentWeightKg / pow(profile.heightCm / 100, 2)
        let durationDelta = bmi >= 25 ? -4 : (bmi < 19 ? -3 : 0)
        let setHint = language == .chinese
            ? (bmi >= 25 ? "以低冲击和动作标准为优先，必要时减少一组。" : "根据体感保留 1-2 次余力。")
            : (bmi >= 25 ? "Prioritize low impact and clean form; reduce one set if needed." : "Keep 1-2 reps in reserve based on feel.")
        let focusSummary = focusTitle(for: selected, language: language)

        var days = workoutPlan(focusAreas: selected, language: language).map { day in
            var updated = day
            updated.durationMinutes = max(18, day.durationMinutes + durationDelta + selectedDurationBonus(for: selected))
            updated.title = language == .chinese
                ? "\(focusSummary) - \(day.title)"
                : "\(focusSummary) - \(day.title)"
            updated.note = "\(day.note) \(setHint)"
            return updated
        }

        for index in days.indices {
            let extras = focusExtras(for: selected, language: language)
            if let extra = extras[safe: index % extras.count] {
                days[index].exercises.append(extra)
            }
        }

        for activity in customActivities where days.indices.contains(activity.dayIndex) {
            days[activity.dayIndex].exercises.append(exercise(from: activity, language: language))
            days[activity.dayIndex].durationMinutes += activity.minutes
        }

        return keyed(days)
    }

    static func workoutPlan(focusAreas: Set<FocusArea>, language: AppLanguage = .chinese) -> [WorkoutDay] {
        if language == .english {
            return englishWorkoutPlan(focusAreas: focusAreas)
        }

        let strengthNote = "选择能保持动作标准的重量。若出现疼痛、头晕或异常不适，请停止训练。"
        let selected = focusAreas.isEmpty ? Set(FocusArea.allCases) : focusAreas

        return keyed([
            WorkoutDay(
                weekday: "星期一",
                type: .strength,
                title: "背部、手臂与核心紧致",
                durationMinutes: 42,
                exercises: [
                    Exercise(name: "俯身划船", focus: .back, sets: "3 组 x 10 次", instruction: "从髋部折叠，背部保持延展，手肘向肋骨方向拉。", videoURL: "https://www.youtube.com/results?search_query=bent+over+row+proper+form"),
                    Exercise(name: "反向飞鸟", focus: .back, sets: "3 组 x 12 次", instruction: "使用轻重量，手肘微弯，温和夹紧肩胛骨。", videoURL: "https://www.youtube.com/results?search_query=dumbbell+reverse+fly+proper+form"),
                    Exercise(name: "三头肌后伸", focus: .arms, sets: "3 组 x 12 次", instruction: "上臂保持稳定，慢慢伸直手臂，不要锁死手肘。", videoURL: "https://www.youtube.com/results?search_query=triceps+kickback+proper+form"),
                    Exercise(name: "死虫式", focus: .fullBody, sets: "每侧 3 组 x 8 次", instruction: "下背轻贴地面，控制对侧手脚移动。", videoURL: "https://www.youtube.com/results?search_query=dead+bug+exercise+proper+form")
                ].filter { selected.contains($0.focus) || $0.focus == .fullBody },
                note: strengthNote
            ),
            WorkoutDay(
                weekday: "星期二",
                type: .cardio,
                title: "低冲击有氧与体态",
                durationMinutes: 35,
                exercises: [
                    Exercise(name: "坡度走或快走", focus: .fullBody, sets: "25 分钟", instruction: "保持能说短句的速度，不需要冲刺。", videoURL: "https://www.youtube.com/results?search_query=incline+walking+workout+beginner"),
                    Exercise(name: "靠墙天使", focus: .back, sets: "3 组 x 10 次", instruction: "慢慢移动，肋骨放松，脖子向上延展。", videoURL: "https://www.bilibili.com/search?keyword=%E9%9D%A0%E5%A2%99%E5%A4%A9%E4%BD%BF%20%E4%BD%93%E6%80%81"),
                    Exercise(name: "下巴内收", focus: .face, sets: "2 组 x 8 次", instruction: "拉长后颈，帮助拍照时脸部与颈线更自然。")
                ].filter { selected.contains($0.focus) || $0.focus == .fullBody },
                note: "低冲击有氧支持循序渐进的减脂，也能降低压力，不会过度消耗恢复。"
            ),
            WorkoutDay(
                weekday: "星期三",
                type: .strength,
                title: "大腿、臀部与核心",
                durationMinutes: 45,
                exercises: [
                    Exercise(name: "高脚杯深蹲", focus: .thighs, sets: "3 组 x 10 次", instruction: "臀部向后坐，膝盖跟脚尖同方向，站起时身体挺拔。", videoURL: "https://www.youtube.com/results?search_query=goblet+squat+proper+form"),
                    Exercise(name: "反向弓步", focus: .thighs, sets: "每侧 3 组 x 8 次", instruction: "轻轻向后迈步，若平衡不稳可扶墙或椅子。", videoURL: "https://www.youtube.com/results?search_query=reverse+lunge+proper+form"),
                    Exercise(name: "臀桥", focus: .thighs, sets: "3 组 x 12 次", instruction: "脚跟发力，顶端短暂停留。", videoURL: "https://www.youtube.com/results?search_query=glute+bridge+proper+form"),
                    Exercise(name: "侧平板", focus: .fullBody, sets: "每侧 2 组 x 20 秒", instruction: "肩髋叠放；需要时可屈膝降低难度。", videoURL: "https://www.youtube.com/results?search_query=side+plank+proper+form")
                ].filter { selected.contains($0.focus) || $0.focus == .fullBody },
                note: strengthNote
            ),
            WorkoutDay(
                weekday: "星期四",
                type: .stretch,
                title: "恢复、灵活性与减少胀感",
                durationMinutes: 28,
                exercises: [
                    Exercise(name: "轻松散步", focus: .fullBody, sets: "15 分钟", instruction: "保持放松，把它当成舒缓压力的时间。"),
                    Exercise(name: "髋屈肌拉伸", focus: .thighs, sets: "2 组 x 40 秒", instruction: "骨盆微微后收，慢慢呼吸。"),
                    Exercise(name: "胸部打开", focus: .back, sets: "2 组 x 45 秒", instruction: "打开身体前侧，让背部和肩膀在照片中更挺拔。")
                ].filter { selected.contains($0.focus) || $0.focus == .fullBody },
                note: "补水、规律吃饭和温和活动，比临时极端限制更安全。"
            ),
            WorkoutDay(
                weekday: "星期五",
                type: .strength,
                title: "体态全身力量",
                durationMinutes: 44,
                exercises: [
                    Exercise(name: "弹力带下拉", focus: .back, sets: "3 组 x 12 次", instruction: "将弹力带固定在上方，手肘向下拉，肩膀保持放松。", videoURL: "https://www.youtube.com/results?search_query=resistance+band+lat+pulldown"),
                    Exercise(name: "二头弯举接肩推", focus: .arms, sets: "3 组 x 10 次", instruction: "顺畅弯举，推举时不要耸肩，下降时保持控制。", videoURL: "https://www.youtube.com/results?search_query=bicep+curl+to+shoulder+press"),
                    Exercise(name: "侧卧内收抬腿", focus: .thighs, sets: "每侧 3 组 x 12 次", instruction: "髋部叠放，用内侧大腿发力，不靠甩动。", videoURL: "https://www.youtube.com/results?search_query=side+lying+inner+thigh+lift"),
                    Exercise(name: "正平板", focus: .fullBody, sets: "3 组 x 25 秒", instruction: "轻轻收紧核心并保持呼吸；需要时可跪姿完成。", videoURL: "https://www.youtube.com/results?search_query=front+plank+proper+form")
                ].filter { selected.contains($0.focus) || $0.focus == .fullBody },
                note: strengthNote
            ),
            WorkoutDay(
                weekday: "星期六",
                type: .rest,
                title: "休息日",
                durationMinutes: 20,
                exercises: [
                    Exercise(name: "可选轻松散步", focus: .fullBody, sets: "20 分钟", instruction: "保持轻松。今天的重点是恢复。")
                ],
                note: "休息有助于身体线条、食欲稳定、情绪和健康进步。"
            ),
            WorkoutDay(
                weekday: "星期日",
                type: .rest,
                title: "整理与准备",
                durationMinutes: 25,
                exercises: [
                    Exercise(name: "备餐规划", focus: .fullBody, sets: "10 分钟", instruction: "规划本周的蛋白质、彩色蔬菜和让人满足的碳水。"),
                    Exercise(name: "拍照体态练习", focus: .face, sets: "5 分钟", instruction: "放松下颌，拉长颈部，肩膀柔和下沉并呼吸。")
                ].filter { selected.contains($0.focus) || $0.focus == .fullBody },
                note: "用今天让下一周更轻松，而不是惩罚上一周。"
            )
        ])
    }

    static func meals(language: AppLanguage = .chinese) -> [MealSuggestion] {
        if language == .english {
            return [
                MealSuggestion(title: "Greek Yogurt Bowl", mealType: "Breakfast", detail: "Greek yogurt, berries, chia, and a small handful of granola.", proteinHint: "Protein plus fiber keeps the morning steady."),
                MealSuggestion(title: "Chicken Rice Plate", mealType: "Lunch", detail: "Grilled chicken, rice, cucumber, leafy greens, olive oil, and lemon.", proteinHint: "Balanced carbs support training without feeling heavy."),
                MealSuggestion(title: "Salmon and Sweet Potato", mealType: "Dinner", detail: "Salmon, sweet potato, zucchini, and a simple yogurt herb sauce.", proteinHint: "Omega-rich protein with moderate carbs."),
                MealSuggestion(title: "Tofu Stir-Fry", mealType: "Dinner", detail: "Tofu, eggs or edamame, rice noodles, bok choy, carrots, and ginger.", proteinHint: "A lighter dinner option that is still satisfying."),
                MealSuggestion(title: "Cottage Cheese Snack", mealType: "Snack", detail: "Cottage cheese with pineapple or tomatoes and pepper.", proteinHint: "Useful when protein is low later in the day.")
            ]
        }

        return [
            MealSuggestion(title: "希腊酸奶碗", mealType: "早餐", detail: "希腊酸奶、莓果、奇亚籽和少量燕麦脆。", proteinHint: "蛋白质加纤维，让早上更稳定。"),
            MealSuggestion(title: "鸡肉米饭盘", mealType: "午餐", detail: "烤鸡胸、米饭、黄瓜、绿叶菜、橄榄油和柠檬。", proteinHint: "适量碳水支持训练，也不容易太沉重。"),
            MealSuggestion(title: "三文鱼配红薯", mealType: "晚餐", detail: "三文鱼、红薯、西葫芦和简单酸奶香草酱。", proteinHint: "优质蛋白搭配适量碳水。"),
            MealSuggestion(title: "豆腐炒蔬菜", mealType: "晚餐", detail: "豆腐、鸡蛋或毛豆、米粉、小白菜、胡萝卜和姜。", proteinHint: "清爽但仍然有满足感的晚餐选择。"),
            MealSuggestion(title: "茅屋奶酪小食", mealType: "加餐", detail: "茅屋奶酪配菠萝，或配番茄和黑胡椒。", proteinHint: "适合当天蛋白质偏低时补充。")
        ]
    }

    static let calorieLog: [CalorieEntry] = []

    static let foodPhotoEstimates: [FoodPhotoEstimate] = []

    private static func englishWorkoutPlan(focusAreas: Set<FocusArea>) -> [WorkoutDay] {
        let strengthNote = "Use a load that lets you finish with good form. Stop if pain, dizziness, or unusual symptoms appear."
        let selected = focusAreas.isEmpty ? Set(FocusArea.allCases) : focusAreas

        return keyed([
            WorkoutDay(
                weekday: "Monday",
                type: .strength,
                title: "Back, Arms, and Core Tone",
                durationMinutes: 42,
                exercises: [
                    Exercise(name: "Bent-Over Row", focus: .back, sets: "3 x 10", instruction: "Hinge at the hips, keep your spine long, and pull elbows toward your ribs.", videoURL: "https://www.youtube.com/results?search_query=bent+over+row+proper+form"),
                    Exercise(name: "Reverse Fly", focus: .back, sets: "3 x 12", instruction: "Use light weights, soften elbows, and squeeze shoulder blades gently.", videoURL: "https://www.youtube.com/results?search_query=dumbbell+reverse+fly+proper+form"),
                    Exercise(name: "Triceps Kickback", focus: .arms, sets: "3 x 12", instruction: "Keep upper arms still and extend slowly without locking the elbow.", videoURL: "https://www.youtube.com/results?search_query=triceps+kickback+proper+form"),
                    Exercise(name: "Dead Bug", focus: .fullBody, sets: "3 x 8 each side", instruction: "Press low back toward the floor and move opposite arm and leg with control.", videoURL: "https://www.youtube.com/results?search_query=dead+bug+exercise+proper+form")
                ].filter { selected.contains($0.focus) || $0.focus == .fullBody },
                note: strengthNote
            ),
            WorkoutDay(
                weekday: "Tuesday",
                type: .cardio,
                title: "Low-Impact Cardio and Posture",
                durationMinutes: 35,
                exercises: [
                    Exercise(name: "Incline Walk or Brisk Walk", focus: .fullBody, sets: "25 min", instruction: "Keep a pace where you can talk in short sentences.", videoURL: "https://www.youtube.com/results?search_query=incline+walking+workout+beginner"),
                    Exercise(name: "Wall Angels", focus: .back, sets: "3 x 10", instruction: "Move slowly with ribs relaxed and neck tall.", videoURL: "https://www.youtube.com/results?search_query=wall+angels+posture+exercise"),
                    Exercise(name: "Chin Tucks", focus: .face, sets: "2 x 8", instruction: "Lengthen the back of your neck to support a softer photo posture.", videoURL: "https://www.youtube.com/results?search_query=chin+tuck+exercise+proper+form")
                ].filter { selected.contains($0.focus) || $0.focus == .fullBody },
                note: "Cardio supports gradual fat loss and helps reduce stress without exhausting recovery."
            ),
            WorkoutDay(
                weekday: "Wednesday",
                type: .strength,
                title: "Thighs, Glutes, and Core",
                durationMinutes: 45,
                exercises: [
                    Exercise(name: "Goblet Squat", focus: .thighs, sets: "3 x 10", instruction: "Sit hips back, keep knees tracking over toes, and stand tall.", videoURL: "https://www.youtube.com/results?search_query=goblet+squat+proper+form"),
                    Exercise(name: "Reverse Lunge", focus: .thighs, sets: "3 x 8 each side", instruction: "Step back softly and use support if balance feels uncertain.", videoURL: "https://www.youtube.com/results?search_query=reverse+lunge+proper+form"),
                    Exercise(name: "Glute Bridge", focus: .thighs, sets: "3 x 12", instruction: "Drive through heels and pause briefly at the top.", videoURL: "https://www.youtube.com/results?search_query=glute+bridge+proper+form"),
                    Exercise(name: "Side Plank", focus: .fullBody, sets: "2 x 20 sec each side", instruction: "Stack shoulders and hips; lower knees if needed.", videoURL: "https://www.youtube.com/results?search_query=side+plank+proper+form")
                ].filter { selected.contains($0.focus) || $0.focus == .fullBody },
                note: strengthNote
            ),
            WorkoutDay(
                weekday: "Thursday",
                type: .stretch,
                title: "Recovery, Mobility, and Bloating Reset",
                durationMinutes: 28,
                exercises: [
                    Exercise(name: "Easy Walk", focus: .fullBody, sets: "15 min", instruction: "Keep it relaxed and use it to unwind."),
                    Exercise(name: "Hip Flexor Stretch", focus: .thighs, sets: "2 x 40 sec", instruction: "Tuck pelvis slightly and breathe slowly.", videoURL: "https://www.youtube.com/results?search_query=hip+flexor+stretch+proper+form"),
                    Exercise(name: "Chest Opener", focus: .back, sets: "2 x 45 sec", instruction: "Open the front body to help the back and shoulders sit cleaner in photos.", videoURL: "https://www.youtube.com/results?search_query=chest+opener+stretch+posture")
                ].filter { selected.contains($0.focus) || $0.focus == .fullBody },
                note: "Hydration, regular meals, and gentle movement are safer than last-minute restriction."
            ),
            WorkoutDay(
                weekday: "Friday",
                type: .strength,
                title: "Full-Body Personal Photo Strength",
                durationMinutes: 44,
                exercises: [
                    Exercise(name: "Band Pulldown", focus: .back, sets: "3 x 12", instruction: "Anchor a band overhead and pull elbows down while keeping shoulders relaxed.", videoURL: "https://www.youtube.com/results?search_query=resistance+band+lat+pulldown"),
                    Exercise(name: "Biceps Curl to Shoulder Press", focus: .arms, sets: "3 x 10", instruction: "Curl smoothly, press overhead without shrugging, and lower with control.", videoURL: "https://www.youtube.com/results?search_query=bicep+curl+to+shoulder+press"),
                    Exercise(name: "Inner Thigh Side-Lying Lift", focus: .thighs, sets: "3 x 12 each side", instruction: "Keep hips stacked and lift from the inner thigh, not momentum.", videoURL: "https://www.youtube.com/results?search_query=side+lying+inner+thigh+lift"),
                    Exercise(name: "Front Plank", focus: .fullBody, sets: "3 x 25 sec", instruction: "Brace gently and breathe; drop to knees to keep form clean.", videoURL: "https://www.youtube.com/results?search_query=front+plank+proper+form")
                ].filter { selected.contains($0.focus) || $0.focus == .fullBody },
                note: strengthNote
            ),
            WorkoutDay(weekday: "Saturday", type: .rest, title: "Rest Day", durationMinutes: 20, exercises: [
                Exercise(name: "Optional Gentle Walk", focus: .fullBody, sets: "20 min", instruction: "Keep it easy. This day is for recovery.")
            ], note: "Rest supports tone, appetite regulation, mood, and healthy progress."),
            WorkoutDay(weekday: "Sunday", type: .rest, title: "Reset and Prep", durationMinutes: 25, exercises: [
                Exercise(name: "Meal Prep Walkthrough", focus: .fullBody, sets: "10 min", instruction: "Plan protein, colorful vegetables, and satisfying carbohydrates for the week."),
                Exercise(name: "Photo Posture Practice", focus: .face, sets: "5 min", instruction: "Relax jaw, lengthen neck, soften shoulders, and breathe.")
            ].filter { selected.contains($0.focus) || $0.focus == .fullBody }, note: "Use today to set up an easier week, not to punish the last one.")
        ])
    }

    private static func keyed(_ days: [WorkoutDay]) -> [WorkoutDay] {
        days.enumerated().map { dayIndex, day in
            var updatedDay = day
            updatedDay.exercises = day.exercises.enumerated().map { exerciseIndex, exercise in
                var updatedExercise = exercise
                updatedExercise.videoKey = "day-\(dayIndex)-exercise-\(exerciseIndex)"
                return updatedExercise
            }
            return updatedDay
        }
    }

    static let weightLog: [WeightEntry] = []

    static let measurements: [MeasurementEntry] = []

    static let wellness: [WellnessEntry] = []

    static let checklist = DailyChecklist(
        workoutCompleted: false,
        stepsCompleted: false,
        waterCompleted: false,
        proteinCompleted: false,
        sleepCompleted: false
    )

    static let weeklyReview = WeeklyReview(
        summary: "这一周正朝着循序渐进、健康的方向前进。",
        adjustment: "继续执行当前计划，保持餐食均衡；如果精力不错，可以加一次轻松晚间散步。",
        encouragement: "你是在为重要日期建立更从容、更有力量的状态，而不是追求速成结果。"
    )

    private static func focusTitle(for selected: Set<FocusArea>, language: AppLanguage) -> String {
        let order: [FocusArea] = [.back, .arms, .thighs, .face, .fullBody]
        let names = order
            .filter { selected.contains($0) }
            .map { $0.title(language: language) }

        if selected.count == FocusArea.allCases.count || selected.isEmpty {
            return language == .chinese ? "全身定制" : "Personal Full Body"
        }

        return names.prefix(2).joined(separator: language == .chinese ? " + " : " + ")
    }

    private static func selectedDurationBonus(for selected: Set<FocusArea>) -> Int {
        selected.count <= 2 ? -6 : 0
    }

    private static func focusExtras(for selected: Set<FocusArea>, language: AppLanguage) -> [Exercise] {
        var extras: [Exercise] = []
        if selected.contains(.back) {
            extras.append(Exercise(
                name: language == .chinese ? "弹力带面拉" : "Band Face Pull",
                focus: .back,
                sets: language == .chinese ? "2 组 x 12 次" : "2 x 12",
                instruction: language == .chinese ? "手肘略高，向脸侧拉，感受上背发力。" : "Keep elbows slightly high and pull toward the face, feeling upper-back control.",
                videoURL: "https://www.youtube.com/results?search_query=band+face+pull+proper+form"
            ))
        }
        if selected.contains(.arms) {
            extras.append(Exercise(
                name: language == .chinese ? "窄距跪姿俯卧撑" : "Close-Grip Knee Push-Up",
                focus: .arms,
                sets: language == .chinese ? "2 组 x 8 次" : "2 x 8",
                instruction: language == .chinese ? "身体保持直线，手肘靠近身体，动作慢一点。" : "Keep a straight line, elbows close, and move slowly.",
                videoURL: "https://www.youtube.com/results?search_query=close+grip+knee+push+up+form"
            ))
        }
        if selected.contains(.thighs) {
            extras.append(Exercise(
                name: language == .chinese ? "墙坐" : "Wall Sit",
                focus: .thighs,
                sets: language == .chinese ? "2 组 x 30 秒" : "2 x 30 sec",
                instruction: language == .chinese ? "背靠墙，膝盖跟脚尖同方向，保持均匀呼吸。" : "Back against the wall, knees tracking toes, and breathe evenly.",
                videoURL: "https://www.youtube.com/results?search_query=wall+sit+proper+form"
            ))
        }
        if selected.contains(.face) {
            extras.append(Exercise(
                name: language == .chinese ? "颈线放松组合" : "Neckline Reset",
                focus: .face,
                sets: language == .chinese ? "2 轮 x 60 秒" : "2 rounds x 60 sec",
                instruction: language == .chinese ? "下巴微收，肩膀放松，配合鼻吸口呼。" : "Tuck the chin gently, relax shoulders, and breathe slowly.",
                videoURL: "https://www.youtube.com/results?search_query=chin+tuck+neck+posture+exercise"
            ))
        }
        if selected.contains(.fullBody) || extras.isEmpty {
            extras.append(Exercise(
                name: language == .chinese ? "全身活动准备" : "Full-Body Prep",
                focus: .fullBody,
                sets: language == .chinese ? "5 分钟" : "5 min",
                instruction: language == .chinese ? "髋、肩、脚踝轻松活动，让训练更顺。" : "Move hips, shoulders, and ankles gently to make the session smoother."
            ))
        }
        return extras
    }

    private static func exercise(from activity: CustomActivity, language: AppLanguage) -> Exercise {
        Exercise(
            videoKey: "custom-\(activity.id.uuidString)",
            name: activity.kind.title(language: language),
            focus: .fullBody,
            sets: language == .chinese ? "\(activity.minutes) 分钟" : "\(activity.minutes) min",
            instruction: language == .chinese
                ? "自定义活动：\(activity.intensity)。按体感保持可持续强度。"
                : "Custom activity: \(activity.intensity). Keep the effort sustainable."
        )
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
