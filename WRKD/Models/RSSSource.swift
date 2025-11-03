//
//  RSSSource.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/29/25.
//

import Foundation
import SwiftUI

enum FeedCategory: String, Codable, CaseIterable {
    case news
    case podcast
    case video
}

struct RSSSource: Identifiable {
    let id = UUID()
    let name: String
    let logoURL: URL?
    let feedURL: URL
    let category: FeedCategory
}
