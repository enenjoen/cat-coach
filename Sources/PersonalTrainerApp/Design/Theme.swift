import SwiftUI

enum Theme {
    static let ivory = Color(red: 1.00, green: 0.96, blue: 0.97)
    static let petal = Color(red: 1.00, green: 0.88, blue: 0.91)
    static let blush = Color(red: 0.98, green: 0.70, blue: 0.78)
    static let rose = Color(red: 0.86, green: 0.30, blue: 0.48)
    static let berry = Color(red: 0.56, green: 0.18, blue: 0.33)
    static let sage = Color(red: 0.55, green: 0.68, blue: 0.55)
    static let ink = Color(red: 0.26, green: 0.17, blue: 0.22)
    static let linen = Color(red: 0.98, green: 0.80, blue: 0.85)
    static let softGold = Color(red: 0.86, green: 0.62, blue: 0.36)
    static let lavender = Color(red: 0.78, green: 0.68, blue: 0.90)
    static let panel = Color.white.opacity(0.82)
    static let softPanel = Color(red: 1.00, green: 0.93, blue: 0.95).opacity(0.84)
    static let cuteRadius: CGFloat = 16
}

struct ThemePalette {
    let background: [Color]
    let panel: Color
    let softPanel: Color
    let petal: Color
    let blush: Color
    let rose: Color
    let berry: Color
    let ink: Color
    let softGold: Color
    let completed: Color
}

extension BackgroundTheme {
    var palette: ThemePalette {
        switch self {
        case .pink:
            return ThemePalette(
                background: [Theme.ivory, Theme.petal, Color.white],
                panel: Color.white.opacity(0.84),
                softPanel: Color(red: 1.00, green: 0.93, blue: 0.95).opacity(0.88),
                petal: Theme.petal,
                blush: Theme.blush,
                rose: Theme.rose,
                berry: Theme.berry,
                ink: Theme.ink,
                softGold: Theme.softGold,
                completed: Theme.rose
            )
        case .cream:
            return ThemePalette(
                background: [Color(red: 1.0, green: 0.97, blue: 0.90), Color(red: 1.0, green: 0.91, blue: 0.84), Color.white],
                panel: Color.white.opacity(0.86),
                softPanel: Color(red: 1.0, green: 0.94, blue: 0.84).opacity(0.88),
                petal: Color(red: 1.0, green: 0.90, blue: 0.78),
                blush: Color(red: 0.95, green: 0.70, blue: 0.43),
                rose: Color(red: 0.82, green: 0.48, blue: 0.22),
                berry: Color(red: 0.44, green: 0.25, blue: 0.15),
                ink: Color(red: 0.27, green: 0.20, blue: 0.16),
                softGold: Color(red: 0.78, green: 0.56, blue: 0.28),
                completed: Color(red: 0.82, green: 0.48, blue: 0.22)
            )
        case .lavender:
            return ThemePalette(
                background: [Color(red: 0.98, green: 0.94, blue: 1.0), Theme.lavender.opacity(0.48), Color.white],
                panel: Color.white.opacity(0.84),
                softPanel: Color(red: 0.94, green: 0.90, blue: 1.0).opacity(0.88),
                petal: Color(red: 0.91, green: 0.84, blue: 1.0),
                blush: Color(red: 0.72, green: 0.60, blue: 0.92),
                rose: Color(red: 0.55, green: 0.38, blue: 0.78),
                berry: Color(red: 0.32, green: 0.20, blue: 0.48),
                ink: Color(red: 0.22, green: 0.18, blue: 0.30),
                softGold: Color(red: 0.70, green: 0.56, blue: 0.86),
                completed: Color(red: 0.55, green: 0.38, blue: 0.78)
            )
        case .mint:
            return ThemePalette(
                background: [Color(red: 0.94, green: 1.0, blue: 0.96), Color(red: 0.82, green: 0.95, blue: 0.88), Color.white],
                panel: Color.white.opacity(0.84),
                softPanel: Color(red: 0.88, green: 0.98, blue: 0.92).opacity(0.88),
                petal: Color(red: 0.80, green: 0.95, blue: 0.86),
                blush: Color(red: 0.46, green: 0.76, blue: 0.58),
                rose: Color(red: 0.26, green: 0.58, blue: 0.42),
                berry: Color(red: 0.16, green: 0.34, blue: 0.28),
                ink: Color(red: 0.15, green: 0.25, blue: 0.22),
                softGold: Color(red: 0.45, green: 0.68, blue: 0.52),
                completed: Color(red: 0.26, green: 0.58, blue: 0.42)
            )
        }
    }
}

struct AppBackground: View {
    let theme: BackgroundTheme

    var body: some View {
        LinearGradient(
            colors: theme.palette.background,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct CatSticker: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        let palette = store.backgroundTheme.palette
        ZStack {
            Circle()
                .fill(palette.panel)
                .frame(width: 77, height: 77)
                .shadow(color: palette.rose.opacity(0.12), radius: 12, x: 0, y: 7)

            VStack(spacing: 0) {
                HStack(spacing: 20) {
                    Triangle()
                        .fill(palette.blush.opacity(0.9))
                        .frame(width: 16, height: 16)
                    Triangle()
                        .fill(palette.blush.opacity(0.9))
                        .frame(width: 16, height: 16)
                }
                .padding(.bottom, -2)

                ZStack {
                    Circle()
                        .fill(palette.petal)
                        .frame(width: 52, height: 43)
                    HStack(spacing: 14) {
                        Circle().fill(palette.berry).frame(width: 4.5, height: 4.5)
                        Circle().fill(palette.berry).frame(width: 4.5, height: 4.5)
                    }
                    .offset(y: -3)
                    Text("w")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(palette.berry)
                        .offset(y: 8)
                }
            }
        }
        .accessibilityLabel("cute cat sticker")
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct MetricCard: View {
    @EnvironmentObject private var store: AppStore
    let title: String
    let value: String
    let caption: String
    let symbol: String

    var body: some View {
        let palette = store.backgroundTheme.palette
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(palette.petal)
                        .frame(width: 34, height: 34)
                    Image(systemName: symbol)
                        .foregroundStyle(palette.rose)
                }
                Spacer()
            }
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(palette.berry)
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(palette.ink)
            Text(caption)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 135, alignment: .topLeading)
        .background(palette.panel)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cuteRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cuteRadius)
                .stroke(palette.blush.opacity(0.38), lineWidth: 1)
        )
        .shadow(color: palette.rose.opacity(0.10), radius: 13, x: 0, y: 7)
    }
}

struct SectionPanel<Content: View>: View {
    @EnvironmentObject private var store: AppStore
    let title: String
    let symbol: String
    @ViewBuilder var content: Content

    var body: some View {
        let palette = store.backgroundTheme.palette
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(palette.petal)
                        .frame(width: 29, height: 29)
                    Image(systemName: symbol)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(palette.rose)
                }
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(palette.berry)
            }
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(palette.panel)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cuteRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cuteRadius)
                .stroke(palette.blush.opacity(0.34), lineWidth: 1)
        )
        .shadow(color: palette.rose.opacity(0.09), radius: 14, x: 0, y: 8)
    }
}

struct ChecklistToggle: View {
    @EnvironmentObject private var store: AppStore
    let title: String
    let symbol: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        let palette = store.backgroundTheme.palette
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isOn ? palette.completed : palette.blush.opacity(0.55))
                    .font(.title3)
                Image(systemName: symbol)
                    .foregroundStyle(palette.rose)
                    .frame(width: 20)
                Text(title)
                    .foregroundStyle(palette.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(isOn ? palette.petal.opacity(0.86) : Color.white.opacity(0.66))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isOn ? palette.blush.opacity(0.5) : palette.blush.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
