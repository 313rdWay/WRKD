//
//  RSSItem.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/27/25.
//

import Foundation
import SwiftUI


struct RSSItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let link: String
    let thumbnailURL: URL?
    let logoURL: URL?
    let pubDate: Date?
    
    var timeAgo: String {
        guard let pubDate = pubDate else { return "Unknown" }
        let secondsAgo = Int(Date().timeIntervalSince(pubDate))
        
        switch secondsAgo {
        case 0..<60:
            return "\(secondsAgo)s ago"
        case 60..<3600:
            return "\(secondsAgo / 60)m ago"
        case 3600..<86400:
            return "\(secondsAgo / 3600)h ago"
        case 86400..<2592000:
            return "\(secondsAgo / 86400)d ago"
        case 2592000..<31536000:
            return "\(secondsAgo / 2592000)mo ago"
        default:
            return "\(secondsAgo / 31536000)y ago"
        }
    }
}
