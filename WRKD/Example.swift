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
                if let url = item.thumbnailURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } placeholder: {
                        ProgressView()
                            .frame(width: 80, height: 80)
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
            vm.loadFeed(from: "https://www.fightful.com/rss.xml")
        }
    }
}

#Preview {
    Example()
}
