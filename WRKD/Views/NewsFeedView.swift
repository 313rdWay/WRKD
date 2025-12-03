//
//  NewsFeedView.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/20/25.
//

import SwiftUI

struct NewsFeedView: View {
    @StateObject private var vm = RSSFeedViewModel()
    let stories = Array(0..<3)
    
    @State private var activeArticleURL: String? = nil
        
    var featuredArticles: [RSSItem] {
        Array(vm.items.prefix(2)) // first 2 items
    }
    
    var regularArticles: [RSSItem] {
        Array(vm.items.dropFirst(2)) // everything after the first 2
    }
        
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: Background Layer
                Color("primaryBG")
                    .ignoresSafeArea(.all)
                // MARK: Content
                VStack {
                    header
                    
                    articlesScrollView
                    
                }
            }
            .fullScreenCover(
                isPresented: Binding(
                    get: { activeArticleURL != nil },
                    set: { isPresented in
                        if !isPresented {
                            activeArticleURL = nil
                        }
                    }
                )
            ) {
                if let urlString = activeArticleURL {
                    ArticleWebView(urlString: urlString)
                        .ignoresSafeArea()
                }
                    }
        }
        .onAppear {
            vm.loadFeedIfNeeded()
        }
    }
}

#Preview {
    NavigationStack {
        NewsFeedView()
    }
}

extension NewsFeedView {
    private var header: some View {
        HStack(spacing: 32) {
            VStack(alignment: .leading) {
                Text("WRKD")
                    .font(.custom("RushDriver-Italic", size: 48))
                    .foregroundStyle(Color("primaryText"))
                
                Text(Date.now.formatted(date: .long, time: .omitted))
                    .font(.system(size: 21, weight: .medium, design: .default))
                    .foregroundStyle(Color("secondaryText"))
            }
            
            VStack {
                Text("On Tonight")
                    .font(.system(size: 16, weight: .light, design: .default))
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("secondaryColor"))
                    .frame(width: 159, height: 29)
                    .overlay(alignment: .center) {
                        Text("WWE Raw | Netflix")
                            .font(.system(size: 18, weight: .medium, design: .default))
                            .foregroundStyle(Color("primaryText"))
                    }
            }
        }
    }

    private var articlesScrollView: some View {
        ScrollView(.vertical) {
            
            // Featured Stories
            LazyVStack(alignment: .leading, spacing: 0) {
                Text("Featured Stories")
                    .font(.system(size: 21, weight: .semibold, design: .default))
                    .padding(.bottom)
                    .padding(.leading)
                
                HStack(alignment: .center, spacing: 8) {
                    ForEach(featuredArticles) { article in
                        Button {
                            activeArticleURL = article.link
                        } label: {
                            ArticlePreviewCard(article: article)
                        }
                        .buttonStyle(.plain)
                    }
                }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
            .padding(.top)
            
            
            // Regular Stories
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(regularArticles) { article in
                    Button {
                        activeArticleURL = article.link
                    } label: {
                        ArticleListCard(article: article)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .scrollIndicators(.hidden)
        .refreshable {
            vm.hasLoadedOnce = false
            vm.loadFeeds()
        }
    }
}

