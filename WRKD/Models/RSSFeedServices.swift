//
//  RSSFeed.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/27/25.
//

import Foundation

func fetchRSSFeed(url: URL, completion: @escaping (Result<[RSSItem], Error>) -> Void) {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let data = data else {
            completion(.failure(NSError(domain: "RSSFeedError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }
        let parser = RSSParser()
        parser.parse(data: data) { items in
            completion(.success(items))
        }
    }
    task.resume()
}

class RSSParser: NSObject, XMLParserDelegate {
    private var items: [RSSItem] = []
    
    private var currentElement: String = ""
    private var currentTitle: String = ""
    private var currentDescription: String = ""
    private var currentLink: String = ""
    private var currentThumbnailURL: URL?
    private var currentLogoURL: URL?
    private var currentPubDate: Date?
    
    private var completionHandler: (([RSSItem]) -> Void)?
    
    func parse(data: Data, completion: @escaping ([RSSItem]) -> Void) {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        completion(items)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "item" {
            currentTitle = ""
            currentDescription = ""
            currentLink = ""
            currentThumbnailURL = nil
            currentLogoURL = nil
            currentPubDate = nil
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        switch currentElement {
        case "title":
            currentTitle += trimmed
        case "description":
            currentDescription += trimmed
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
        if elementName == "item" {
            let newItem = RSSItem(
                title: currentTitle,
                description: currentDescription,
                link: currentLink,
                thumbnailURL: currentThumbnailURL,
                logoURL: currentLogoURL,
                pubDate: currentPubDate ?? Date()
            )
            items.append(newItem)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        completionHandler?(items)
    }
}
