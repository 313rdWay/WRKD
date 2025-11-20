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
            category: .news,
            thumbnailStrategy: .ogImage
        ),
        RSSSource(
            name: "Fightful",
            logoURL: URL(string: "https://d1fcaprh3kb5t7.cloudfront.net/wp-content/uploads/2025/06/26001949/footer-logo.svg"),
            feedURL: URL(string: "https://www.fightful.com/rss.xml")!,
            category: .news,
            thumbnailStrategy: .ogImage
        ),
        RSSSource(
            name: "Wrestling Inc",
            logoURL: URL(string: "https://www.wrestlinginc.com/img/winc-logo-color-borderless.svg"),
            feedURL: URL(string: "https://www.wrestlinginc.com/feed/")!,
            category: .news,
            thumbnailStrategy: .ogImage
        )
    ]
    
    var groupedBySource: [String: [RSSItem]] {
        Dictionary(grouping: items) { $0.sourceName ?? "Unknown" }
    }
        
    func enhanceThumbnails() {
        // Work on the current items already published
        var updatedItems = self.items

        // Map source name -> strategy for quick lookup
        let strategyBySourceName: [String: ThumbnailStrategy] = Dictionary(
            uniqueKeysWithValues: sources.map { ($0.name, $0.thumbnailStrategy) }
        )

        let group = DispatchGroup()

        for (index, item) in updatedItems.enumerated() {
            guard
                let name = item.sourceName,
                let strategy = strategyBySourceName[name],
                let articleURL = URL(string: item.link)
            else {
                continue
            }

            switch strategy {
            case .rssOnly:
                // Do nothing – keep whatever RSS gave us
                continue
                
            case .contentFirstImage:
                if let newURL = firstImageURL(in: item.description) {
                    let old = item
                    let newItem = RSSItem(
                        title: old.title,
                        description: old.description,
                        link: old.link,
                        thumbnailURL: newURL,
                        sourceName: old.sourceName,
                        sourceLogoURL: old.sourceLogoURL,
                        pubDate: old.pubDate,
                        author: old.author
                    )
                    updatedItems[index] = newItem
                }
                

            case .ogImage:
                guard let articleURL = URL(string: item.link) else { continue }

                group.enter()
                URLSession.shared.dataTask(with: articleURL) { data, _, _ in
                    defer { group.leave() }

                    guard let data = data,
                          let html = String(data: data, encoding: .utf8) else { return }

                    do {
                        let doc = try SwiftSoup.parse(html)

                        var finalURL: URL?

                        // 1) Try og:image
                        if let meta = try doc.select("meta[property=og:image]").first() {
                            let ogImage = try meta.attr("content")
                            finalURL = URL(string: ogImage)
                        }

                        // 2) If no og:image, fall back to first <img> or YouTube iframe
                        if finalURL == nil {
                            finalURL = self.firstImageURL(in: html)
                        }

                        if let url = finalURL {
                            let old = item
                            let newItem = RSSItem(
                                title: old.title,
                                description: old.description,
                                link: old.link,
                                thumbnailURL: url,   // 🔁 override with best guess
                                sourceName: old.sourceName,
                                sourceLogoURL: old.sourceLogoURL,
                                pubDate: old.pubDate,
                                author: old.author
                            )
                            updatedItems[index] = newItem
                        }
                    } catch {
                        print("⚠️ HTML parse failed for \(name):", error.localizedDescription)
                    }
                }.resume()
            }
        }

        group.notify(queue: .main) {
            self.items = updatedItems
        }
    }
    
    private func youtubeThumbnailURL(from src: String) -> URL? {
        guard let url = URL(string: src),
              let host = url.host,
              host.contains("youtu") else {
            return nil
        }

        var videoID: String?

        // 1) youtu.be/{id}
        if host.contains("youtu.be") {
            videoID = url.pathComponents.dropFirst().first
        }
        // 2) youtube.com/embed/{id}
        else if url.path.contains("/embed/") {
            videoID = url.pathComponents.last
        }
        // 3) youtube.com/watch?v={id}
        else if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            videoID = components.queryItems?.first(where: { $0.name == "v" })?.value
        }

        guard let id = videoID else { return nil }

        // Standard YouTube thumbnail URL
        return URL(string: "https://img.youtube.com/vi/\(id)/hqdefault.jpg")
    }
    
    private func firstImageURL(in html: String) -> URL? {
        do {
            let doc = try SwiftSoup.parse(html)
            
            // Tries normal <img> first
            if let imgSrc = try doc.select("img").first()?.attr("src"),
               let url = URL(string: imgSrc) {
                return url
            }
            
            // If no <img>, look for a Youtube iframe
            if let iframeSrc = try doc
                .select("iframe[src*=\"youtube.com\"], iframe[src*=\"youtu.be\"]")
                .first()?
                .attr("src"),
               let thumbURL = youtubeThumbnailURL(from: iframeSrc) {
                return thumbURL
            }
            
        } catch {
            print("⚠️ firstImageURL HTML parse failed:", error.localizedDescription)
        }
        return nil
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
                            self.enhanceThumbnails()
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


