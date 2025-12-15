//
//  RSSItem.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/27/25.
//

import Foundation
import SwiftUI

struct RSSItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let link: String
    let thumbnailURL: URL?
    let sourceName: String?
    let sourceLogoURL: URL?
    let pubDate: Date?
    let author: String?
    
    // TODO: Future use
    //    let mediaURL: URL? // For podcast audio or video files
    //    let duration: TimeInterval? // For podcast length
    
    var localLogoAssetName: String? {
        switch sourceName {
        case "WrestleTalk":
            return "wrestletalkLogo"
        case "Fightful":
            return "fightfulLogo"
        case "Wrestling Inc":
            return "wrestlingIncLogo"
        case "Wrestling Observer":
            return "wrestlingObserverLogo"
        case "Cageside Seats":
            return "cagesideSeatsLogo"
        case "ITR Wrestling":
            return "itrWrestlingLogo"
        case "Daily DDT":
            return "dailyDDTLogo"
        default:
            return nil
        }
    }
    
    var timeAgo: String {
        guard let pubDate = pubDate else { return "Unknown" }
        
        let rawSeconds = Int(Date().timeIntervalSince(pubDate))
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
    
    var displayAuthor: String? {
        guard var raw = author?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return sourceName
        }
        
        if sourceName == "Wrestling Inc" {
            if let open = raw.firstIndex(of: "("),
               let close = raw.firstIndex(of: ")"),
               open < close {
                let nameRange = raw.index(after: open)..<close
                let name = raw[nameRange].trimmingCharacters(in: .whitespacesAndNewlines)
                if !name.isEmpty {
                    raw = name
                }
            }
            
            if let emailRange = raw.range(
                of: #"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}"#,
                options: [.regularExpression, .caseInsensitive]
            ) {
                raw.removeSubrange(emailRange)
                raw = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        if raw.isEmpty {
            return sourceName
        }
        
        return raw
    }
}
