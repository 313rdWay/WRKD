//
//  ArticleViewModel.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/27/25.
//

import SwiftUI
import Combine
import SVGKit
import SwiftSoup

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
            let ogImageEnhancedSources = ["WrestleTalk", "Fightful", "Wrestling Inc"]
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
                            self.enhanceThumbnailsUsingOGImage(for: ogImageEnhancedSources)
                            self.hasLoadedOnce = true
                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }
    }
    
    func enhanceThumbnailsUsingOGImage(for sourceName: [String]) {
        // Work on the current items already published
        var updatedItems = self.items

        let group = DispatchGroup()

        for (index, item) in updatedItems.enumerated() {
            // Only care about specific sources (e.g. WrestleTalk, Fightful, Wrestling Inc)
            guard let name = item.sourceName, sourceName.contains(name),
                  let articleURL = URL(string: item.link)
            else { continue }

            group.enter()
            URLSession.shared.dataTask(with: articleURL) { data, _, _ in
                defer { group.leave() }

                guard let data = data,
                      let html = String(data: data, encoding: .utf8) else { return }

                do {
                    let doc = try SwiftSoup.parse(html)

                    if let meta = try doc.select("meta[property=og:image]").first() {
                        let ogImage = try meta.attr("content")

                        if let url = URL(string: ogImage) {
                            let old = item
                            let newItem = RSSItem(
                                title: old.title,
                                description: old.description,
                                link: old.link,
                                thumbnailURL: url, // 🔁 overwrite thumbnail
                                sourceName: old.sourceName,
                                sourceLogoURL: old.sourceLogoURL,
                                pubDate: old.pubDate
                            )
                            updatedItems[index] = newItem
                        }
                    }
                } catch {
                    print("⚠️ HTML parse failed for \(name):", error.localizedDescription)
                }
            }.resume()
        }

        group.notify(queue: .main) {
            // 🔁 When all WrestleTalk pages are checked, publish the enhanced list
            self.items = updatedItems
        }
    }
}
