import Foundation

struct CoachMessage: Identifiable {
    let id = UUID()
    let role: String
    let text: String
}

enum SafeCoach {
    @MainActor
    static func answer(question: String, store: AppStore, language: AppLanguage) -> String {
        let text = question.lowercased()

        if text.contains("tired") || text.contains("exhausted") || text.contains("adjust") || text.contains("累") || text.contains("疲惫") || text.contains("调整") {
            if language == .english {
                return "Let’s make today recovery-friendly: do a 20-30 minute easy walk, 8 minutes of stretching, and one posture circuit with wall angels and chin tucks. Keep protein steady, drink water, and sleep earlier if you can. Skip intense training if you feel unwell."
            }
            return """
            今天改成恢复友好版：20-30 分钟轻松散步、8 分钟拉伸，再做一轮靠墙天使和下巴内收。蛋白质照常吃，记得喝水，今晚尽量早点睡。如果身体不舒服，就跳过高强度训练。
            """
        }

        if text.contains("dinner") || text.contains("eat") || text.contains("meal") || text.contains("晚餐") || text.contains("吃") || text.contains("饮食") {
            if language == .english {
                return "Choose a balanced dinner: protein, a comfortable carb, cooked vegetables, and fluids. A good option is salmon or tofu with sweet potato, zucchini, and yogurt herb sauce. Keep it satisfying and low-bloat by avoiding huge portions of unfamiliar salty or very high-fiber foods close to the event."
            }
            return """
            晚餐选一个均衡组合：蛋白质、舒服的碳水、熟蔬菜和水分。可以吃三文鱼或豆腐，搭配红薯、西葫芦和简单酸奶香草酱。重要日期临近时，避免突然吃大量陌生、很咸或高纤维的食物，减少胀感。
            """
        }

        if text.contains("arms") || text.contains("slimmer") || text.contains("smaller") || text.contains("手臂") || text.contains("瘦") || text.contains("变小") {
            if language == .english {
                return "Arms usually look slimmer through overall gradual fat loss plus shoulder, triceps, biceps, and posture work. Try reverse flys, triceps kickbacks, biceps curls, and wall angels 2-3 times weekly. You cannot spot-reduce fat, so keep meals balanced and avoid crash dieting."
            }
            return """
            手臂看起来更紧致，通常来自整体循序渐进减脂，加上肩部、三头肌、二头肌和体态训练。每周 2-3 次做反向飞鸟、三头肌后伸、二头弯举和靠墙天使。不能局部减脂，所以饮食要均衡，避免速成节食。
            """
        }

        if text.contains("today") || text.contains("workout") || text.contains("今天") || text.contains("训练") || text.contains("运动") {
            let dayName = weekday(language: language)
            let plan = store.workoutPlan.first { $0.weekday == dayName } ?? store.workoutPlan.first
            guard let plan else {
                return language == .chinese ? "今天可以快走、轻柔拉伸、补水，并安排下一次力量训练。" : "Take a brisk walk, stretch gently, hydrate, and plan your next strength session."
            }
            let exercises = plan.exercises.prefix(4).map { "- \($0.name): \($0.sets)" }.joined(separator: "\n")
            if language == .english {
                return """
                Today’s plan: \(plan.title) for about \(plan.durationMinutes) minutes.
                \(exercises)

                Keep the effort moderate and form-focused. If your body feels run down, switch to walking and mobility.
                """
            }
            return """
            今天的计划：\(plan.title)，大约 \(plan.durationMinutes) 分钟。
            \(exercises)

            强度保持中等，优先动作质量。如果身体很疲惫，就改成散步和灵活性练习。
            """
        }

        if text.contains("face") || text.contains("bloat") || text.contains("puffy") || text.contains("脸") || text.contains("水肿") || text.contains("胀") {
            if language == .english {
                return "A smaller-looking face comes from gradual overall fat loss, sleep, hydration, posture, and less bloating. Keep meals regular, reduce very salty unfamiliar foods near the event, walk daily, relax your jaw, and lengthen your neck in posture practice. Avoid dehydration tricks."
            }
            return """
            脸看起来更小，主要来自整体循序渐进减脂、睡眠、补水、体态和减少胀感。保持规律吃饭，重要日期前少吃很咸或不熟悉的食物，每天散步，练习放松下颌、拉长颈部。不要用脱水方法冒险。
            """
        }

        if language == .english {
            return "I can help with today’s workout, tired-day adjustments, dinner ideas, arms/back/thighs, or event-week prep. I’ll keep advice practical and safe: steady training, balanced meals, hydration, sleep, and no extreme restriction. For personal medical or nutrition needs, check with a doctor or dietitian."
        }
        return """
        我可以帮你安排今天的训练、调整疲惫日计划、推荐晚餐、处理手臂/背部/大腿/脸部和重要日期周准备。建议会保持实际和安全：稳定训练、均衡饮食、补水、睡眠，不做极端限制。若涉及个人健康或营养问题，请咨询医生或营养师。
        """
    }

    private static func weekday(language: AppLanguage) -> String {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let names = language == .chinese
            ? ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
            : ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return names[max(0, min(weekday - 1, names.count - 1))]
    }
}
