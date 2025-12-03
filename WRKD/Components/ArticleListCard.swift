//
//  ArticleListView.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/20/25.
//

import SwiftUI

struct ArticleListCard: View {
    let article: RSSItem
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color("tertiaryBG"))
                .frame(height: 135)
                .frame(maxWidth: .infinity)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    if let assetName = article.localLogoAssetName {
                        Image(assetName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 12)
                    } else if let logoURL = article.sourceLogoURL {
                        UniversalImageView(urlString: logoURL.absoluteString,
                                           size: CGSize(width: 78, height: 12)
                        )
                    }
                    
                    Text(article.title)
                        .font(ArticleStyleConstants.titleFontCompact)
                        .lineLimit(ArticleStyleConstants.linelimit)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(ArticleStyleConstants.titleForeground)
                    
                    
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
                    
                }
                if let thumbnailURL = article.thumbnailURL {
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 90, height: 90)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .frame(width: 90, height: 90)
                        case .failure(_):
                            Color.gray
                                .frame(width: 90, height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .frame(width: 90, height: 90)
                        @unknown default:
                            Color.gray
                                .frame(width: 90, height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .frame(width: 90, height: 90)
                        }
                    }
                } else {
                    Color.gray
                        .frame(width: 90, height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(width: 90, height: 90)
                }
            }
            .padding(.horizontal)
        }
        .articleContainer()
    }
}

#Preview {
    let sampleArticle = RSSItem(
        title: "GCW Debuting In Witchita, WWE Raw Highlights, More | Fight Size",
        description: "This is a sample descripton for the article used in the preview.",
        link: "https://www.fightful.com/wrestling/gcw-wwe-raw-260178",
        thumbnailURL: URL(string: "https://d1fcaprh3kb5t7.cloudfront.net/wp-content/uploads/2025/10/07172006/G2nvYqcW0AAFR37-e1759872037909.jpg"),
        sourceName: "FIghtful",
        sourceLogoURL: URL(string: "https://d1fcaprh3kb5t7.cloudfront.net/wp-content/uploads/2025/06/26001949/footer-logo.svg"),
        pubDate: Date(),
        author: "Jeremy Lambert")
    
    ArticleListCard(article: sampleArticle)
}
