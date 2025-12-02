//
//  CardSwipeView.swift
//  WRKD
//
//  Created by Davaughn Williams on 11/24/25.
//

import SwiftUI
import Combine

struct CardSwipeView: View {
//    @StateObject private var vm = RSSFeedViewModel()
    let articles: [RSSItem]
    var onArticleTapped: ((RSSItem) -> Void)? = nil
    
    @State private var currentIndex = 0
    @State private var showPreviousCard = false
    let stories = Array(0..<3)
    
//    @State var article: RSSItem
    
//    var featuredArticles: [RSSItem] {
//        Array(vm.items.prefix(3)) // first 3 items
//    }
    
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    private var currentArticle: RSSItem? {
        guard !articles.isEmpty else { return nil }
        let safeIndex = currentIndex % articles.count
        return articles[safeIndex]
    }
    
    var body: some View {
        ZStack {
            if let article = currentArticle {
                ArticleLargeViewRD(article: article)
                    .contentShape(Rectangle())        // make whole card tappable
                    .onTapGesture {
                        onArticleTapped?(article)     // tell parent which article was tapped
                    }
                    .transition(.asymmetric(insertion: .move(edge: showPreviousCard ? .leading : .trailing), removal: .move(edge: showPreviousCard ? .trailing : .leading)))
                    } else {
                        Text("No featured stories")
                            .foregroundStyle(Color("secondaryText"))
                    }
                }
//        ZStack {
//            if let article = currentArticle {
//                if ArticleWebView.makeURL(from: article.link) != nil {
//                    NavigationLink {
//                        ArticleWebView(urlString: article.link)
//                            .toolbar(.hidden, for: .tabBar)
//                    } label: {
//                        ArticleLargeViewRD(article: article)
//                    }
//                    .buttonStyle(.plain)
//                    .transition(.asymmetric(insertion: .move(edge: showPreviousCard ? .leading : .trailing), removal: .move(edge: showPreviousCard ? .trailing : .leading)))
//                } else {
//                    // Fallback if the URL is bad
//                    ArticleLargeView(article: article)
//                        .onTapGesture {
//                            print("⚠️ Invalid or missing URL for \(article.title)")
//                        }
//                }
//            } else {
//                Text("No featured stories")
//                    .foregroundStyle(Color("secondaryText"))
//            }
//            ForEach(stories, id: \.self) { index in
//                if index == currentIndex {
//                    ArticleLargeViewRD(article: article)
//                        .transition(.asymmetric(
//                            insertion: .move(edge: showPreviousCard ? .leading : .trailing),
//                            removal: .move(edge: showPreviousCard ? .trailing : .leading)))
//                }
//            }
//        }
        .onReceive(timer) { _ in
            guard !articles.isEmpty else { return }
            showPreviousCard = false
            withAnimation(.snappy) {
                currentIndex = (currentIndex + 1) % 3
            }
        }
        .gesture(
            DragGesture()
                .onEnded({ value in
                    guard !articles.isEmpty else { return }
                    
                    let threshold: CGFloat = 100
                    if value.translation.width < -threshold {
                        // left swipe -> next
                        showPreviousCard = false
                        
                        withAnimation(.snappy) {
                            currentIndex = (currentIndex + 1) % 3
                        }
                        
                    } else if value.translation.width > threshold {
                        // right swipe -> previous
                        showPreviousCard = true
                        
                        withAnimation {
                            currentIndex = (currentIndex - 1 + 3) % 3
                        }
                    }
                })
        )
    }
}

#Preview {
    let sampleArticles = [
        RSSItem(title: "GCW Debuting In Witchita, WWE Raw Highlights, More | Fight Size",
                description: "Sample Description 1",
                link: "https://www.fightful.com/wrestling/gcw-wwe-raw-260178",
                thumbnailURL: URL(string: "https://d1fcaprh3kb5t7.cloudfront.net/wp-content/uploads/2025/10/07172006/G2nvYqcW0AAFR37-e1759872037909.jpg"),
                sourceName: "Fightful",
                sourceLogoURL: URL(string: "https://d1fcaprh3kb5t7.cloudfront.net/wp-content/uploads/2025/06/26001949/footer-logo.svg"),
                pubDate: Date(),
                author: "Jeremy Lambert"),
        
        RSSItem(title: "Triple H: WWE Raw Is Going To Be Epic",
                description: "Sample Description 2",
                link:"https://www.fightful.com/wrestling/triple-h-wwe-raw-is-going-to-be-epic/",
                thumbnailURL: URL(string: "https://d1fcaprh3kb5t7.cloudfront.net/wp-content/uploads/2025/11/29225722/Screenshot-2369.png"),
                sourceName: "Fightful",
                sourceLogoURL: URL(string: "https://d1fcaprh3kb5t7.cloudfront.net/wp-content/uploads/2025/06/26001949/footer-logo.svg"),
                pubDate: Date(),
                author: "Jeremy Lambert"),
        
        RSSItem(title: "Bayley On Being A WWE Locker Room Leader: It’s Not Something That I Asked For, These Idiots Need Guidance",
                description: "Sample Description 3",
                link:"https://www.fightful.com/wrestling/bayley-on-being-a-wwe-locker-room-leader-its-not-something-that-i-asked-for-these-idiots-need-guidance/",
                thumbnailURL: URL(string: "https://d1fcaprh3kb5t7.cloudfront.net/wp-content/uploads/2025/10/29165411/sddefault-8_1.jpg"),
                sourceName: "Fightful",
                sourceLogoURL: URL(string: "https://d1fcaprh3kb5t7.cloudfront.net/wp-content/uploads/2025/06/26001949/footer-logo.svg"),
                pubDate: Date(),
                author: "Corey Brennan")
        
    ]
    
    CardSwipeView(articles: sampleArticles)
}
