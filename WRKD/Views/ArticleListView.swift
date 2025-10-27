//
//  ArticleListView.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/20/25.
//

import SwiftUI

struct ArticleListView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("tertiaryBG"))
                .frame(height: 126)
                .frame(maxWidth: .infinity)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Image("FightfulLogo")
                        .resizable()
                        .frame(width: 78, height: 12)
                    
                    Text("Jimmy Jacobs: Vince McMahon Would Say, ‘If I Say The Sky Is Green, The Sky Is Green’")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundStyle(Color("primaryText"))

                    
                    Text("1h ago | Jeremy Lambert")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundStyle(Color("secondaryText"))

                }
                Image("VinceMcMahon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .frame(width: 90, height: 90)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ArticleListView()
}
