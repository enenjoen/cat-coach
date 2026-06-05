import SwiftUI
import WebKit

struct VideoPreviewView: View {
    @EnvironmentObject private var store: AppStore
    let url: URL
    let title: String

    var body: some View {
        let palette = store.backgroundTheme.palette
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(palette.berry)
                .padding(.horizontal)
                .padding(.top)
            WebVideoView(url: url)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cuteRadius))
                .padding([.horizontal, .bottom])
        }
        .frame(minWidth: 860, minHeight: 620)
        .background(AppBackground(theme: store.backgroundTheme))
    }
}

private struct WebVideoView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
}
