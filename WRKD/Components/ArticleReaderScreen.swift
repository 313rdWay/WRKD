//
//  ArticleReaderScreen.swift
//  WRKD
//
//  Created by Davaughn Williams on 12/2/25.
//


import SwiftUI

struct ArticleReaderScreen: View {
    let urlString: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ArticleWebView(urlString: urlString)
            .ignoresSafeArea()
            .toolbar(.hidden, for: .tabBar)
            .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        ArticleReaderScreen(urlString: "https://www.fightful.com")
    }
}
