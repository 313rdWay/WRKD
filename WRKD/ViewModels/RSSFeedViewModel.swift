//
//  ArticleViewModel.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/27/25.
//

import SwiftUI
import Combine
import SVGKit

@MainActor
class RSSFeedViewModel: ObservableObject {
    @Published var items: [RSSItem] = []
    @Published var errorMessage: String?
    
    @Published var hasLoadedOnce = false
    
    let sources: [RSSSource] = [
        RSSSource(
            name: "WrestleTalk",
            logoURL: URL(string: "https://wrestletalk.com/wp-content/uploads/2021/12/logo.svg"),
            feedURL: URL(string: "https://wrestletalk.com/feed/")!,
            category: .news
        ),
        RSSSource(
            name: "Fightful",
            logoURL: URL(string: "https://d1fcaprh3kb5t7.cloudfront.net/wp-content/uploads/2025/06/26001949/footer-logo.svg"),
            feedURL: URL(string: "https://www.fightful.com/rss.xml")!,
            category: .news
        ),
        RSSSource(
            name: "Wrestling Inc",
            logoURL: URL(string: "https://www.wrestlinginc.com/img/winc-logo-color-borderless.svg"),
            feedURL: URL(string: "https://www.wrestlinginc.com/feed/")!,
            category: .news
        )
    ]
    
    var groupedBySource: [String: [RSSItem]] {
        Dictionary(grouping: items) { $0.sourceName ?? "Unknown" }
    }
    
    func loadFeedIfNeeded() {
        guard !hasLoadedOnce else { return }
        loadFeeds()
    }
    
    func loadFeeds() {
        Task {
            var allItems: [RSSItem] = []
            
            for source in sources {
                fetchRSSFeed(source: source) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let items):
                            allItems.append(contentsOf : items)
                            self.items = allItems.sorted {
                                ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast)
                            }
                            self.hasLoadedOnce = true
                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }
    }
}
