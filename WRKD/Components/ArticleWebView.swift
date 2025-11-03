//
//  ArticleWebView.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/30/25.
//

import SwiftUI
import WebKit

struct ArticleWebView: View {
//    let url: URL
    let urlString: String
    
    var body: some View {
//        WebView(url: url)
//            .navigationTitle(url.host ?? "Article") // shows domain name, e.g., fightful.com
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .bottomBar) {
//                    Button {
//                        UIApplication.shared.open(url)
//                    } label: {
//                        Image(systemName: "safari")
//                    }
//                    .accessibilityLabel("Open in Browser")
//                }
//            }
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

struct WebView: UIViewRepresentable {
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

//#Preview {
//    NavigationStack {
//        ArticleWebView(url: URL(string: "http://www.fightful.com")!)
//    }
//}
