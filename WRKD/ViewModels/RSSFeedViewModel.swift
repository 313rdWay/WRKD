//
//  ArticleViewModel.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/27/25.
//

import SwiftUI
import Combine

@MainActor
class RSSFeedViewModel: ObservableObject {
    @Published var items: [RSSItem] = []
    @Published var errorMessage: String?

    func loadFeed(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        fetchRSSFeed(url: url) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.items = items
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
