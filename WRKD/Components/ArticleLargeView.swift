//
//  ArticleLargeView.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/20/25.
//

import SwiftUI

struct ArticleLargeView: View {
    @Environment(\.openURL) private var openURL
    
    let article: RSSItem

    var body: some View {
        ZStack {
            ZStack {
                // Thumbnail
                if let thumbnailURL = article.thumbnailURL {
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .padding(40)
                                .foregroundColor(.gray.opacity(0.4))
                        default:
                            ProgressView()
                        }
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .padding(40)
                        .foregroundColor(.gray.opacity(0.4))
                }
            }
            .frame(width: 557, height: 269)
            .mask(
                RoundedRectangle(cornerRadius: 50)
                    .frame(width: 350, height: 252)
            )
            .overlay(alignment: .bottom) {
                CustomRoundedRectangle(
                    topLeft: 0,
                    topRight: 0,
                    bottomLeft: 50,
                    bottomRight: 50
                )
                .fill((Color("tertiaryBG")))
                .glassEffect()
                .frame(width: 350, height: 99)
                
                .overlay(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(article.timeAgo)
                                .font(ArticleStyleConstants.subtitleFont)
                                .foregroundStyle(ArticleStyleConstants.subtitleForeground)
                            
                            Divider()
                                .frame(height: 10)
                            
                            if let byline = article.displayAuthor {
                                Text(byline)
                                    .font(ArticleStyleConstants.subtitleFont)
                                    .foregroundStyle(ArticleStyleConstants.subtitleForeground)
                            }
                        }
                        
                        Spacer()
                        
                        Text(article.title)
                            .font(ArticleStyleConstants.titleFontLarge)
                            .lineLimit(ArticleStyleConstants.linelimit)
                            .foregroundStyle(ArticleStyleConstants.titleForeground)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                }
            }
            .overlay(alignment: .top) {
                HStack(spacing: 180) {
                    Capsule()
                        .fill(Color("tertiaryBG"))
                        .glassEffect()
                        .frame(width: 85, height: 22)
                        .overlay {
                            if let assetName = article.localLogoAssetName {
                                Image(assetName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 78, height: 12)
                            }
                            if let logoURL = article.sourceLogoURL {
                                UniversalImageView(
                                    urlString: logoURL.absoluteString,
                                    size: CGSize(width: 78, height: 12)
                                )
                            }
                        }
                    
                    Circle()
                        .fill(Color("tertiaryBG"))
                        .glassEffect()
                        .frame(width: 29, height: 29)
                        .overlay(alignment: .center) {
                            Image("meatballsMenu")
                                .resizable()
                                .frame(width: 29, height: 29)
                        }
                }
                .offset(y: 20)
            }
        }
        .articleContainer()

    }
}



#Preview {
    let sampleArticle = RSSItem(title: "GCW Debuting In Witchita, WWE Raw Highlights, More | Fight Size", description: "This is a sample descripton for the article used in the preview.", link: "https://www.fightful.com/wrestling/gcw-wwe-raw-260178", thumbnailURL: URL(string: "https://d1fcaprh3kb5t7.cloudfront.net/wp-content/uploads/2025/10/07172006/G2nvYqcW0AAFR37-e1759872037909.jpg"), sourceName: "FIghtful", sourceLogoURL: URL(string: "https://d1fcaprh3kb5t7.cloudfront.net/wp-content/uploads/2025/06/26001949/footer-logo.svg"), pubDate: Date(), author: "Jeremy Lambert")

    ArticleLargeView(article: sampleArticle)
}
