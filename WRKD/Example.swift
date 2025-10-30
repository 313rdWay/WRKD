//
//  Example.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/27/25.
//

import SwiftUI

struct Example: View {
    @StateObject var vm = RSSFeedViewModel()
    var body: some View {
        List(vm.items) { item in
            HStack(alignment: .top, spacing: 12) {
                if let logoURL = item.sourceLogoURL,
                   !logoURL.absoluteString.isEmpty {
                    UniversalImageView(
                        urlString: logoURL.absoluteString,
                        size: CGSize(width: 24, height: 24)
                    )
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 24, height: 24)
                }
                
                if let url = item.thumbnailURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(8)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                        default:
                            ProgressView()
                                .frame(width: 80, height: 80)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.headline)
                        .lineLimit(2)
                    Text(item.description)
                        .font(.subheadline)
                        .lineLimit(3)
                    Text(item.timeAgo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .onAppear {
            vm.loadFeeds()
//            vm.testLogoFetch(for: "https://www.fightful.com/sites/default/files/fightful-share-logo.png")
        }
    }
}

#Preview {
    Example()
}
