//
//  ArticleLargeView.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/20/25.
//

import SwiftUI

struct ArticleLargeView: View {
    @StateObject var vm = RSSFeedViewModel()

    var body: some View {
        ZStack {
            Image("GCWLogo")
                .resizable()
                .frame(width: 557, height: 269)
                .mask(
                    RoundedRectangle(cornerRadius: 50)
                        .fill(.blue)
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
                            Text("1d ago | Skylar Russell")
                                .font(.system(size: 12, weight: .regular, design: .default))

                            Spacer()

                            Text("GCW Debuting In Witchita, WWE Raw Highlights, More | Fight Size")
                            .font(.system(size: 18, weight: .regular, design: .default))
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
                            .overlay(alignment: .center) {
                                Image("FightfulLogo")
                                    .resizable()
                                    .frame(width: 78, height: 12)
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
    }
}

#Preview {
    ArticleLargeView()
}
