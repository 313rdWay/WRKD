//
//  ArticlesStyleConstants.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/30/25.
//

import SwiftUI

struct ArticleStyleConstants {
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 12
    static let spacing: CGFloat = 8
    
    static let titleFontLarge = Font.system(size: 18, weight: .regular, design: .default)
    static let titleFontCompact = Font.system(size: 16, weight: .regular, design: .default)
    static let titleFontSmall = Font.system(size: 12, weight: .regular, design: .default)
    static let subtitleFont = Font.system(size: 12, weight: .regular, design: .default)
    static let subtitleFontSmall = Font.system(size: 9, weight: .regular, design: .default)
    static let linelimit = 3
    
    static let titleForeground = Color("primaryText")
    static let subtitleForeground = Color("secondaryText")
}

struct ArticleContainerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(ArticleStyleConstants.padding)
            .background(Color(.systemBackground))
            .cornerRadius(ArticleStyleConstants.cornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

extension View {
    func articleContainer() -> some View {
        modifier(ArticleContainerModifier())
    }
}
