import Foundation

enum L {
    static func text(_ key: Key, _ language: AppLanguage) -> String {
        switch (key, language) {
        case (.dashboard, .chinese): return "仪表盘"
        case (.dashboard, .english): return "Dashboard"
        case (.bodyGoals, .chinese): return "身体目标"
        case (.bodyGoals, .english): return "Body Goals"
        case (.workoutPlan, .chinese): return "训练计划"
        case (.workoutPlan, .english): return "Workout Plan"
        case (.meals, .chinese): return "饮食建议"
        case (.meals, .english): return "Meals"
        case (.progress, .chinese): return "进度记录"
        case (.progress, .english): return "Progress"
        case (.weeklyReview, .chinese): return "每周复盘"
        case (.weeklyReview, .english): return "Weekly Review"
        case (.coach, .chinese): return "AI 教练"
        case (.coach, .english): return "AI Coach"
        case (.appName, .chinese): return "小猫私教"
        case (.appName, .english): return "Cat Coach"
        case (.countdown, .chinese): return "倒计时"
        case (.countdown, .english): return "Countdown"
        case (.days, .chinese): return "天"
        case (.days, .english): return "days"
        case (.dateCaption, .chinese): return "距离设定日期"
        case (.dateCaption, .english): return "Until your selected date"
        case (.currentWeight, .chinese): return "当前体重"
        case (.currentWeight, .english): return "Current Weight"
        case (.starting, .chinese): return "起始"
        case (.starting, .english): return "Starting"
        case (.targetRange, .chinese): return "目标范围"
        case (.targetRange, .english): return "Target Range"
        case (.weeklyGoal, .chinese): return "每周目标"
        case (.weeklyGoal, .english): return "Weekly Goal"
        case (.settings, .chinese): return "设定"
        case (.settings, .english): return "Settings"
        case (.countdownDate, .chinese): return "倒计时日期"
        case (.countdownDate, .english): return "Countdown Date"
        case (.language, .chinese): return "语言"
        case (.language, .english): return "Language"
        case (.background, .chinese): return "背景颜色"
        case (.background, .english): return "Background"
        case (.saveSettings, .chinese): return "保存设置"
        case (.saveSettings, .english): return "Save Settings"
        case (.measurement, .chinese): return "围度记录"
        case (.measurement, .english): return "Measurements"
        case (.chest, .chinese): return "胸围"
        case (.chest, .english): return "Chest"
        case (.arm, .chinese): return "手臂"
        case (.arm, .english): return "Arm"
        case (.thigh, .chinese): return "大腿"
        case (.thigh, .english): return "Thigh"
        case (.waist, .chinese): return "腰围"
        case (.waist, .english): return "Waist"
        case (.hip, .chinese): return "臀围"
        case (.hip, .english): return "Hip"
        case (.saveWeeklyMeasurement, .chinese): return "保存本周围度"
        case (.saveWeeklyMeasurement, .english): return "Save Weekly Measurements"
        case (.videoReference, .chinese): return "视频参考"
        case (.videoReference, .english): return "Video Reference"
        case (.openVideo, .chinese): return "打开视频"
        case (.openVideo, .english): return "Open Video"
        case (.firstWeekHint, .chinese): return "如果还没有之前的每周记录，就会从第一周开始。"
        case (.firstWeekHint, .english): return "If there is no previous weekly record, this starts as week one."
        }
    }

    enum Key {
        case dashboard, bodyGoals, workoutPlan, meals, progress, weeklyReview, coach, appName
        case countdown, days, dateCaption, currentWeight, starting, targetRange, weeklyGoal
        case settings, countdownDate, language, background, saveSettings
        case measurement, chest, arm, thigh, waist, hip, saveWeeklyMeasurement
        case videoReference, openVideo, firstWeekHint
    }
}
