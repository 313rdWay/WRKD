//
//  ArticleWebView.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/30/25.
//

import SwiftUI
import WebKit

struct ArticleWebViewOG: View {
    let urlString: String
    
    var body: some View {
        if let url = Self.makeURL(from: urlString) {
            WebView(url: url)
                .navigationTitle(url.host ?? "Article")
        } else {
            ContentUnavailableView("Invalid link", systemImage: "exclamationmark.triangle")
        }
    }
    static func makeURL(from s: String) -> URL? {
        guard var comps = URLComponents(string: s.trimmingCharacters(in: .whitespacesAndNewlines)) else { return nil }
        if comps.scheme == nil { comps.scheme = "https" }
        return comps.url
    }
}

struct WebViewOG: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        DispatchQueue.main.async {
            uiView.load(URLRequest(url: url))
        }
    }
}

#Preview {
    NavigationStack {
        ArticleWebView(urlString: "http://www.fightful.com")
    }
}
