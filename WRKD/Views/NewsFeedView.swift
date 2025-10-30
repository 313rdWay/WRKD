//
//  NewsFeedView.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/20/25.
//

import SwiftUI

struct NewsFeedView: View {
    @StateObject private var vm = RSSFeedViewModel()
    
    let promotions: [String] = ["ALL", "WWE", "AEW", "NJPW"]
    
    @State private var selection = 0
    let stories = Array(0..<3)
    
    @State var selectedTab: Int = 0
    @State private var selectedPromotion: String? = "ALL"
    
    var featuredArticles: [RSSItem] {
        Array(vm.items.prefix(3)) // first 3 items
    }
    
    var regularArticles: [RSSItem] {
        Array(vm.items.dropFirst(3)) // everything after the first 3
    }
        
    var body: some View {
        ZStack {
            // background layer
            Color("primaryBG")
                .ignoresSafeArea(.all)
            
            VStack {
                header
                
                filterOptions
                
                articlesScrollView
                
                
            }
        

        }
        .onAppear {
            vm.loadFeeds()
        }
    }
}

#Preview {
    NewsFeedView()
}

extension NewsFeedView {
    private var header: some View {
        HStack(spacing: 23) {
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
    
    private var filterOptions: some View {
        HStack(spacing: 10) {
            ForEach(promotions, id: \.self) { promotion in
                
                Button {
                    if selectedPromotion == promotion {
                        selectedPromotion = nil
                    } else {
                        selectedPromotion = promotion
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedPromotion == promotion ? Color("primaryColor") : Color("tertiaryBG"))
                        .frame(width: 80, height: 44)
                        .overlay{
                            Text(promotion)
                                .foregroundStyle(Color("primaryText"))
                                .font(.system(size: 17.5, weight: .semibold, design: .default))
                        }
                }
            }
        }
    }
    
    private var articlesScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Featured Stories")
                    .font(.system(size: 21, weight: .semibold, design: .default))
                    .padding(.bottom, -50)
                    .padding(.leading, 20)
                
                VStack {
                    TabView(selection: $selection) {
                        ForEach(featuredArticles) { article in
                            ArticleLargeView(article: article)
                                .padding(.bottom, 0)
//                                .tag(article)
                        }
                    }
                    .tabViewStyle(.page)
                }
                .frame(height: 340)
            }
            .padding(.top)
            
            
            VStack(alignment: .leading) {
                Text("Latest News")
                    .font(.system(size: 21, weight: .semibold, design: .default))
                    .padding(.leading, 20)
                
                ForEach(regularArticles) { article in
                    ArticleListView(article: article)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

