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
        ),
        
        RSSSource(
            name: "Wrestling Observer",
            logoURL: URL(string: "https://www.f4wonline.com/wp-content/themes/f4wonline/dist/images/logo-f4w-default.svg"),
            feedURL: URL(string: "https://f4wonline.com/feed/")!,
            category: .news,
            thumbnailStrategy: .ogImage
        ),
        
        RSSSource(
            name: "PW Torch",
            logoURL: URL(string: "https://www.pwtorch.com/site/wp-content/uploads/2022/09/cropped-PWTorch_WebLogoFreeSite-2022-300.png"),
            feedURL: URL(string: "https://www.pwtorch.com/site/feed/")!,
            category: .news,
            thumbnailStrategy: .ogImage
        ),
        
        RSSSource(
            name: "ESPN",
            logoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/ESPN_wordmark.svg/1108px-ESPN_wordmark.svg.png?20180702212649"),
            feedURL: URL(string: "https://www.espn.com/espn/rss/wwe/news")!,
            category: .news,
            thumbnailStrategy: .ogImage
        ),
        
        RSSSource(
            name: "Voices of Wrestling",
            logoURL: URL(string: "https://b493361.smushcdn.com/493361/wp-content/uploads/2016/04/cropped-cropped-VOWTransLogo-1-1.png?lossy=2&strip=1&webp=1"),
            feedURL: URL(string: "https://www.voicesofwrestling.com/feed")!,
            category: .news,
            thumbnailStrategy: .ogImage
        ),
        
        RSSSource(
            name: "No DQ",
            logoURL: URL(string: "https://nodq.com/wp-content/uploads/2021/03/nodq-theme.png"),
            feedURL: URL(string: "https://nodq.com/feed/")!,
            category: .news,
            thumbnailStrategy: .ogImage
        ),
        
        RSSSource(
            name: "Ringside News",
            logoURL: URL(string: "https://b1671682.smushcdn.com/1671682/wp-content/uploads/2023/01/ringsidenews-header.png?lossy=2&strip=1&avif=1"),
            feedURL: URL(string: "https://www.ringsidenews.com/feed")!,
            category: .news,
            thumbnailStrategy: .ogImage
        ),
        
        RSSSource(
            name: "BodySlam.net",
            logoURL: URL(string: "https://www.bodyslam.net/wp-content/uploads/2024/09/295083346_765880221226131_2119036521563380360_n-min.png"),
            feedURL: URL(string: "https://www.bodyslam.net/feed/")!,
            category: .news,
            thumbnailStrategy: .ogImage
        ),
        
        RSSSource(
            name: "WrestlingNews.co",
            logoURL: URL(string: "https://wrestlingnews.co/wp-content/uploads/2024/06/logo@2x.png"),
            feedURL: URL(string: "https://wrestlingnews.co/feed/")!,
            category: .news,
            thumbnailStrategy: .ogImage
        ),
        
        RSSSource(
            name: "Sportskeeda Wrestling",
            logoURL: URL(string: "https://staticg.sportskeeda.com/logo/brand_logos/full-vector.svg"),
            feedURL: URL(string: "https://www.sportskeeda.com/wwe/feed")!,
            category: .news,
            thumbnailStrategy: .ogImage
        ),
        
        RSSSource(
            name: "Cageside Seats",
            logoURL: nil,
            feedURL: URL(string: "https://www.cagesideseats.com/rss/index.xml")!,
            category: .news,
            thumbnailStrategy: .ogImage
        ),
        
        RSSSource(
            name: "ITR Wrestling",
            logoURL: nil,
            feedURL: URL(string: "https://itrwrestling.com/feed/")!,
            category: .news,
            thumbnailStrategy: .ogImage
        ),
        
        RSSSource(
            name: "Daily DDT",
            logoURL: nil,
            feedURL: URL(string: "https://dailyddt.com/feed")!,
            category: .news,
            thumbnailStrategy: .ogImage
        ),
        
        RSSSource(
            name: "411 Mania",
            logoURL: URL(string: "https://411mania.com/wp-content/themes/411mania/img/logo-small.svg"),
            feedURL: URL(string: "https://411mania.com/wrestling/feed/")!,
            category: .news,
            thumbnailStrategy: .ogImage
        ),
        
        RSSSource(
            name: "Diva Dirt",
            logoURL: URL(string: "https://www.diva-dirt.com/wp-content/uploads/2017/04/cropped-cropped-divadirtlogo2017.png"),
            feedURL: URL(string: "https://www.diva-dirt.com/feed/")!,
            category: .news,
            thumbnailStrategy: .ogImage
        )
    ]
    
    var groupedBySource: [String: [RSSItem]] {
        Dictionary(grouping: items) { $0.sourceName ?? "Unknown" }
    }
        
    func enhanceThumbnails() {
        // Sources where we WANT to override the RSS-provided thumbnail
        let overrideRSSThumbnailSources: Set<String> = ["WrestleTalk"]
        
        // Work on the current items already published
        var updatedItems = self.items
        
        let currentItems = self.items

        // Map source name -> strategy for quick lookup
        let strategyBySourceName: [String: ThumbnailStrategy] = Dictionary(
            uniqueKeysWithValues: sources.map { ($0.name, $0.thumbnailStrategy) }
        )

//        let group = DispatchGroup()
        
        // Protects writes to updatedItems from multiple background threads
        let mutationQueue = DispatchQueue(label: "RSSFeedViewModel.thumbnailMutaion")
        
        // Limit how many "heavy" enhancements we do per source
        var enhancedCountBySource: [String: Int] = [:]
        let maxEnhancedPerSourc = 5

        for (index, item) in updatedItems.enumerated() {
            guard
                let name = item.sourceName,
                let strategy = strategyBySourceName[name]
//                let articleURL = URL(string: item.link)
            else {
                continue
            }
            let shouldOverride = overrideRSSThumbnailSources.contains(name)
            
            // Uf RSS already gave a thumbnail, this makes sure it doesn't waste time scraping
            if item.thumbnailURL != nil && !shouldOverride {
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
                    // Upadate the published items on the main actor
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        // Make sure the index still exists and refers to the same article
                        if index < self.items.count, self.items[index].link == old.link {
                            self.items[index] = newItem
                        }
                    }
                }
                

            case .ogImage:
                var allowLimit = true
                
                // Only Voices of Wrestling overrides the limit
                if name == "Voices of Wrestling" || name == "WrestleTalk" {
                    allowLimit = false
                    
                }
                // Only enhance the first N items per source to avoid hammering
                if allowLimit {
                    let count = enhancedCountBySource[name, default: 0]
                    guard count < maxEnhancedPerSourc else { continue }
                    enhancedCountBySource[name] = count + 1
                }

                guard let articleURL = URL(string: item.link) else { continue }

//                URLSession.shared.dataTask(with: articleURL) { data, _, _ in
                URLSession.shared.dataTask(with: articleURL) { [weak self] data, _, _ in
                    guard let self else { return }
//                    defer { group.leave() }
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

//                        if let url = finalURL {
                        guard let url = finalURL else { return }
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
                        // Update the published items on the main actor, one by one
                        DispatchQueue.main.async {
                            // Make sure the index is still valid and still same article
                            if index < self.items.count, self.items[index].link == old.link {
                                self.items[index] = newItem
                            }
                        }
//                        }
                    } catch {
                        print("⚠️ HTML parse failed for \(name):", error.localizedDescription)
                    }
                }.resume()
            }
        }

//        group.notify(queue: .main) {
//            self.items = updatedItems
//        }
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
                            print("✅ \(source.name) returned \(items.count) items")
                            allItems.append(contentsOf : items)
                            self.items = allItems.sorted {
                                ($0.pubDate ?? .distantPast) > ($1.pubDate ?? .distantPast)
                            }
                            self.enhanceThumbnails()
                            self.hasLoadedOnce = true
                        case .failure(let error):
                            print("❌ \(source.name) failed:", error.localizedDescription)
                            self.errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }
    }
}

