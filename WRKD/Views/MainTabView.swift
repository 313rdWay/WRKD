//
//  MainTabView.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/23/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView {
            
            Tab("Home", systemImage: "newspaper.fill") {
                NewsFeedView()
            }

            Tab("Videos", systemImage: "video.fill") {
                VideoFeedView()
            }
            
            Tab("Podcasts", systemImage: "waveform.circle.fill") {
                PodcastFeedView()
            }
            
            Tab(role: .search) {
//                DetailedSearchView()
            }
        }
        .accentColor(Color("primaryColor"))
    }
}

#Preview {
    MainTabView()
}
