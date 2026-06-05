import SwiftUI

struct CoachView: View {
    @EnvironmentObject private var store: AppStore
    @State private var prompt = ""
    @State private var messages: [CoachMessage] = []

    private var quickPrompts: [String] {
        store.language == .chinese
            ? ["今天我应该做什么训练？", "我今天有点累，帮我调整计划", "晚餐应该吃什么？", "怎样让手臂看起来更紧致？"]
            : ["What workout should I do today?", "I feel tired, adjust today’s plan", "What should I eat for dinner?", "How can I make my arms slimmer?"]
    }

    var body: some View {
        let palette = store.backgroundTheme.palette
        VStack(alignment: .leading, spacing: 16) {
            Text(L.text(.coach, store.language))
                .font(.system(size: 31, weight: .bold, design: .rounded))
                .foregroundStyle(palette.berry)

            SectionPanel(title: store.language == .chinese ? "安全教练" : "Safe Coach", symbol: "message.and.waveform") {
                Text(store.language == .chinese ? "离线 MVP 教练，内置安全边界：不提供医疗断言、挨饿建议或极端临时减重方法。" : "Offline MVP coach with safety guardrails. It avoids medical claims, starvation advice, and extreme last-minute weight-loss tactics.")
                    .foregroundStyle(.secondary)

                HStack {
                    ForEach(quickPrompts, id: \.self) { item in
                        Button(item) {
                            ask(item)
                        }
                    }
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(message.role)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(message.role == userRole ? palette.softGold : palette.rose)
                            Text(message.text)
                                .foregroundStyle(Theme.ink)
                                .textSelection(.enabled)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(message.role == userRole ? palette.softPanel : palette.panel)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(palette.blush.opacity(0.28)))
                    }
                }
            }

            HStack {
                TextField(store.language == .chinese ? "问问你的教练" : "Ask your coach", text: $prompt)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { ask(prompt) }
                Button {
                    ask(prompt)
                } label: {
                    Label(store.language == .chinese ? "发送" : "Send", systemImage: "paperplane.fill")
                }
                .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            Color.clear.frame(height: 10)
        }
        .onAppear {
            if messages.isEmpty {
                messages = [CoachMessage(role: coachRole, text: introText)]
            }
        }
    }

    private var userRole: String { store.language == .chinese ? "你" : "You" }
    private var coachRole: String { store.language == .chinese ? "教练" : "Coach" }
    private var introText: String {
        store.language == .chinese
            ? "你可以问我今天做什么训练、累的时候怎么调整、晚餐吃什么，或如何安全处理手臂、背部、大腿、脸部、体态和重要日期周准备。"
            : "Ask me what workout to do today, how to adjust when tired, what to eat for dinner, or how to approach arms, back, thighs, face, posture, and event-week prep safely."
    }

    private func ask(_ text: String) {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        messages.append(CoachMessage(role: userRole, text: clean))
        messages.append(CoachMessage(role: coachRole, text: SafeCoach.answer(question: clean, store: store, language: store.language)))
        prompt = ""
    }
}
