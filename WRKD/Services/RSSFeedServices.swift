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
    private var currentAuthor: String = ""
    
    private var completionHandler: (([RSSItem]) -> Void)?
    
    private var insideAuthor = false
    private var isAtomFeed = false
    
    func parse(data: Data, completion: @escaping ([RSSItem]) -> Void) {
        let parser = XMLParser(data: data)
        self.completionHandler = completion
        parser.delegate = self
        parser.parse()
    }
    
    // MARK: - XMLParser Delegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
//        currentElement = elementName
//        let name = elementName.components(separatedBy: ":").last ?? elementName
        let raw = elementName
        let name = raw.components(separatedBy: ":").last ?? raw
        currentElement = name
        
        // Reset when a new <item> begins
        if name == "item" || name == "entry" {
            currentTitle = ""
            currentDescription = ""
            currentLink = ""
            currentThumbnailURL = nil
            currentPubDate = nil
            currentAuthor = ""
        }
        
        if name == "feed" && namespaceURI == "http://www.w3.org/2005/Atom" {
            isAtomFeed = true
        }
        
        // Atom: <link rel="alternate" href="https://..."/>
        if name == "link", let href = attributeDict["href"] {
            // Prefer the "alternate" link (the actual article)
            let rel = attributeDict["rel"] ?? "alternate"
            if rel == "alternate" {
                currentLink = href
            }
        }
        
        // Detect feed image tags (for other sites too)
        if raw == "media:content" ||
            raw == "media:thumbnail" ||
            name == "enclosure" {
            
            if let urlString = attributeDict["url"], let url = URL(string: urlString) {
                currentThumbnailURL = url
                print("📸 Found featured image tag: \(urlString)")
            }
        }
        
        if name == "author" { insideAuthor = true }

    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        switch currentElement {
        case "title":
            currentTitle += trimmed
        case "description", "content:encoded", "summary", "content":
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
        case "pubDate", "updated", "published":
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            // Tries common RSS date formats
            let formats = [
                "EEE, dd MMM yyyy HH:mm:ss Z", // Standard RFC822 with numeric offset
                
                "E, d MMM yyyy HH:mm:ss Z", // Single-digit day variant
                
                "EEE, dd MMM yyyy HH:mm:ss z", // Time xone abbreviation (e.g. EST/EDT)
                
                "E, d MMM yyyy HH:mm:ss z", // Single digit day + abbrev
                
                "yyyy-MM-dd'T'HH:mm:ssZ", // ISO8601 without fractional seconds
                
                "yyyy-MM-dd'T'HH:mm:ss.SSSZ", // ISO8601 with fractional seconds
                
                "yyyy=MM-dd'T'HH:mm:ssZ"
            ]
            
            var parsedDate: Date? = nil
            
            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: trimmed) {
                    parsedDate = date
                    break
                }
            }
            
            if let date = parsedDate {
                currentPubDate = date
                
                if sourceName == "Wrestling Observer" {
                    print("📅 Wrestling Observer raw pubDate: \(trimmed)")
                    print("👉 Parsed as: \(date)")
                    print("👉 Now: \(Date())")
                    print("👉 secondsAgo: \(Int(Date().timeIntervalSince(date)))")
                }
            } else {
                print("⚠️ Could not parse pubDate: \(trimmed)")
            }
            
        case "author", "dc:creator":
            currentAuthor += trimmed
            
        case "name":
            if insideAuthor {
                currentAuthor += trimmed
            }
        
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let name = elementName.components(separatedBy: ":").last ?? elementName
        
        if name == "content:encoded" {
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
        if name == "item" || name == "entry" {
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
                pubDate: currentPubDate ?? Date(),
                author: currentAuthor.isEmpty ? nil : currentAuthor
            )
            items.append(newItem)
        }
        
        if name == "author" { insideAuthor = false }

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
            print("❌ \(source.name) network error:", error.localizedDescription)
            completion(.failure(error))
            return
        }
        
        // ✅ DEBUG: HTTP status + content type
        if let http = response as? HTTPURLResponse {
            print("📡 \(source.name) status:", http.statusCode,
                  "content-type:", http.value(forHTTPHeaderField: "Content-Type") ?? "nil")
        }
        
        guard let data = data else {
            completion(.failure(NSError(
                domain: "RSSFeedError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "No data received"]
            )))
            return
        }
        
        // ✅ DEBUG: show what you actually downloaded
        let preview = String(data: data, encoding: .utf8) ?? ""
        print("🧾 \(source.name) first 200 chars:\n\(preview.prefix(200))")
        
        
        let parser = RSSParser()
        parser.sourceName = source.name
        parser.sourceLogoURL = source.logoURL
        
        parser.parse(data: data) { items in
            completion(.success(items))
        }
    }
    task.resume()
}
