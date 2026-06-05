import SwiftUI

enum AppScreen: String, CaseIterable, Identifiable {
    case dashboard = "仪表盘"
    case goals = "身体目标"
    case workouts = "训练计划"
    case meals = "饮食建议"
    case progress = "进度记录"
    case review = "每周复盘"
    case coach = "AI 教练"
    case settings = "设定"

    var id: String { rawValue }

    func title(language: AppLanguage) -> String {
        switch self {
        case .dashboard: return L.text(.dashboard, language)
        case .goals: return L.text(.bodyGoals, language)
        case .workouts: return L.text(.workoutPlan, language)
        case .meals: return L.text(.meals, language)
        case .progress: return L.text(.progress, language)
        case .review: return L.text(.weeklyReview, language)
        case .coach: return L.text(.coach, language)
        case .settings: return L.text(.settings, language)
        }
    }

    var symbol: String {
        switch self {
        case .dashboard: return "calendar.badge.clock"
        case .goals: return "target"
        case .workouts: return "figure.strengthtraining.functional"
        case .meals: return "fork.knife"
        case .progress: return "chart.line.uptrend.xyaxis"
        case .review: return "checklist"
        case .coach: return "message.and.waveform"
        case .settings: return "gearshape"
        }
    }
}

struct MainView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedScreen: AppScreen? = .dashboard

    var body: some View {
        let palette = store.backgroundTheme.palette
        NavigationSplitView {
            Sidebar(selectedScreen: $selectedScreen)
        } detail: {
            ZStack {
                AppBackground(theme: store.backgroundTheme)
                VStack {
                    HStack {
                        Spacer()
                        CatSticker()
                            .scaleEffect(0.72)
                            .opacity(0.55)
                            .padding(.top, 16)
                            .padding(.trailing, 18)
                    }
                    Spacer()
                }
                .allowsHitTesting(false)
                screen
                    .padding(22)
            }
        }
        .tint(palette.rose)
        .sheet(isPresented: onboardingBinding) {
            OnboardingView()
                .environmentObject(store)
                .interactiveDismissDisabled()
        }
    }

    private var onboardingBinding: Binding<Bool> {
        Binding(
            get: { !store.hasCompletedOnboarding },
            set: { isPresented in
                if !isPresented {
                    store.hasCompletedOnboarding = true
                }
            }
        )
    }

    @ViewBuilder
    private var screen: some View {
        switch selectedScreen ?? .dashboard {
        case .dashboard:
            DashboardView()
        case .goals:
            BodyGoalPlannerView()
        case .workouts:
            WorkoutPlanView()
        case .meals:
            MealGuidanceView()
        case .progress:
            ProgressTrackingView()
        case .review:
            WeeklyReviewView()
        case .coach:
            CoachView()
        case .settings:
            SettingsView()
        }
    }
}

private struct Sidebar: View {
    @EnvironmentObject private var store: AppStore
    @Binding var selectedScreen: AppScreen?

    var body: some View {
        let palette = store.backgroundTheme.palette
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                CatSticker()
                    .scaleEffect(0.42)
                    .frame(width: 42, height: 42)
                Text(L.text(.appName, store.language))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(palette.berry)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)

            List(AppScreen.allCases, selection: $selectedScreen) { screen in
                Label(screen.title(language: store.language), systemImage: screen.symbol)
                    .tag(screen)
                    .padding(.vertical, 3)
            }
            .scrollContentBackground(.hidden)
        }
        .background(palette.petal)
    }
}
