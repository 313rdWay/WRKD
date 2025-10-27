//
//  XMLParser.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/23/25.
//

//import Foundation
//
//struct RSSItem {
//    var title: String
//    var description: String
//    var pubDate: String
//}
//
//
//// TODO: download XML from a server
//// TODO: parse xml to foundation objects
//// TODO: call back
//
//extension FeedParser {
//    func fetchXML(from urlString: String) async throws -> Data {
//        guard let url = URL(string: urlString) else {
//            throw URLError(.badURL)
//        }
//        
//        let (data, response) = try await URLSession.shared.data(from: url)
//        
//        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
//            throw URLError(.badServerResponse)
//        }
//        
//        if let mime = http.value(forHTTPHeaderField: "Content-Type"), !mime.contains("xml") {
//            throw URLError(.cannotDecodeContentData)
//        }
//        return data
//    }
//}
//
//final class FeedParser: NSObject {
//    private var items: [RSSItem] = []
//    private var currentElement: String = ""
//    private var currentTitle: String = ""
//    private var currentDescription: String = ""
//    private var currentPubDate: String = ""
//    private var accumulatingString: String = ""
//
//    // Public entry point: fetch + parse
//    func loadRSS(from urlString: String) async throws -> [RSSItem] {
//        let data = try await fetchXML(from: urlString)
//        return try parseRSS(data: data)
//    }
//}
