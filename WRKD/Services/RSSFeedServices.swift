//
//  RSSFeed.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/27/25.
//

import Foundation
import SwiftSoup

class RSSParser: NSObject, XMLParserDelegate {
    // Publicly settable context passed in by the caller
    var sourceName: String?
    var sourceLogoURL: URL?

    private var items: [RSSItem] = []
    
    // Temporary state while parsing
    private var currentElement: String = ""
    private var currentTitle: String = ""
    private var currentDescription: String = ""
    private var currentLink: String = ""
    private var currentThumbnailURL: URL?
    private var currentPubDate: Date?
    
    private var completionHandler: (([RSSItem]) -> Void)?
    
    func parse(data: Data, completion: @escaping ([RSSItem]) -> Void) {
        let parser = XMLParser(data: data)
        self.completionHandler = completion
        parser.delegate = self
        parser.parse()
    }
    
    // MARK: - XMLParser Delegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        // Reset when a new <item> begins
        if elementName == "item" {
            currentTitle = ""
            currentDescription = ""
            currentLink = ""
            currentThumbnailURL = nil
            currentPubDate = nil
        }
        
        // Detect feed image tags (for other sites too)
        if elementName == "media:content" ||
            elementName == "media:thumbnail" ||
            elementName == "enclosure" {
            
            if let urlString = attributeDict["url"], let url = URL(string: urlString) {
                currentThumbnailURL = url
                print("📸 Found featured image tag: \(urlString)")
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        switch currentElement {
        case "title":
            currentTitle += trimmed
        case "description", "content:encoded":
            currentDescription += trimmed

            // Detect feed image tags (for other sites too)
            if currentThumbnailURL == nil {
                if let range = trimmed.range(
                    of: #"https?:\/\/[^\s"]+\.(jpg|jpeg|png|gif)"#,
                    options: .regularExpression
                ) {
                    let urlString = String(trimmed[range]).replacingOccurrences(of: "\"", with: "")
                    if let url = URL(string: urlString) {
                        currentThumbnailURL = url
                        print("🖼️ Regex found image:", url.absoluteString)
                    }
                }
            }
        case "link":
            currentLink += trimmed
        case "pubDate":
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            // Tries common RSS date formats
            let formats = [
                "E, dd MMM yyyy HH:mm:ss Z",
                "E, d MMM yyyy HH:mm:ss Z",
                "yyyy=MM-dd'T'HH:mm:ssZ"
            ]
            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: trimmed) {
                    currentPubDate = date
                    break
                }
            }
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        if elementName == "content:encoded", currentThumbnailURL == nil {
//            do {
//                let doc = try SwiftSoup.parse(currentDescription)
//                if let imgSrc = try doc.select("img").first()?.attr("src"), let url = URL(string: imgSrc) {
//                    currentThumbnailURL = url
//                }
//            } catch {
//                print("⚠️ SwiftSoup failed:", error.localizedDescription)
//            }
//        }
        if elementName == "content:encoded" {
            do {
                let doc = try SwiftSoup.parse(currentDescription)

                if let imgSrc = try doc.select("img").first()?.attr("src"),
                   let url = URL(string: imgSrc) {

                    // Always let the article's own image override any generic feed image
                    currentThumbnailURL = url
                    print("📸 Overriding thumbnail from content:encoded: \(imgSrc)")
                }
            } catch {
                print("⚠️ SwiftSoup failed:", error.localizedDescription)
            }
        }
        
        // When an <item> ends, finalize and append
        if elementName == "item" {
            print("🧠 Thumbnail found:", currentThumbnailURL?.absoluteString ?? "none")
            print("📰 Title:", currentTitle)
            print("🔗 Source logo:", self.sourceLogoURL?.absoluteString ?? "none")
            let newItem = RSSItem(
                title: currentTitle,
                description: currentDescription,
                link: currentLink,
                thumbnailURL: currentThumbnailURL,
                sourceName: self.sourceName,
                sourceLogoURL: self.sourceLogoURL,
                pubDate: currentPubDate ?? Date()
            )
            items.append(newItem)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print("✅ Parsed \(items.count) items total")
        completionHandler?(items)
    }
}

func fetchRSSFeed(source: RSSSource, completion: @escaping (Result<[RSSItem], Error>) -> Void) {
    let task = URLSession.shared.dataTask(with: source.feedURL) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let data = data else {
            completion(.failure(NSError(domain: "RSSFeedError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }
        let parser = RSSParser()
        parser.sourceName = source.name
        parser.sourceLogoURL = source.logoURL
        parser.parse(data: data) { items in
            completion(.success(items))
        }
    }
    task.resume()
}

//func enhanceWrestleTalkThumbnails(_ items: [RSSItem], completion: @escaping ([RSSItem]) -> Void) {
//    
//    var updated = items
//    let group = DispatchGroup()
//    
//    for (index, item) in items.enumerated() {
//        guard item.sourceName == "WrestleTalk", let articleURL = URL(string: item.link) else { continue }
//        
//        group.enter()
//        URLSession.shared.dataTask(with: articleURL) { data, _, _ in
//            defer { group.leave() }
//            
//            guard let data = data, let html = String(data: data, encoding: .utf8) else { return }
//            
//            do {
//                let doc = try SwiftSoup.parse(html)
//                
//                // Try meta og:image first (very likely to exist)
//                if let meta = try doc.select("meta[property=og:image]").first(),
//                   let ogImage = try? meta.attr("content"),
//                   let url = URL(string: ogImage) {
//                    
//                    let old = item
//                    let newItem = RSSItem(
//                        title: old.title,
//                        description: old.description,
//                        link: old.link,
//                        thumbnailURL: url,
//                        sourceName: old.sourceName,
//                        sourceLogoURL: old.sourceLogoURL,
//                        pubDate: old.pubDate
//                    )
//                    updated[index] = newItem
//                }
//            } catch {
//                print("⚠️ WrestleTalk HTML parse failed:", error.localizedDescription)
//            }
//        }.resume()
//    }
//    group.notify(queue: .main) {
//        completion(updated)
//    }
//}
