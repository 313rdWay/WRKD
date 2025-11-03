//
//  UniversalImageView.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/29/25.
//

import SwiftUI
import SVGKit
import Combine

@MainActor
class UniversalImageLoader: ObservableObject {
    @Published var image: UIImage?

    static var cache = [String: UIImage]()

       func load(from urlString: String) {
           guard let url = URL(string: urlString), !urlString.isEmpty else { return }
           
#if DEBUG
if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
    self.image = UIImage(systemName: "photo")
    return
}
#endif

           // Checks if image is already cached
           if let cached = Self.cache[urlString] {
               self.image = cached
               return
           }
        
        
        let isSVG = url.pathExtension.lowercased() == "svg"

        Task {
            do {
                var request = URLRequest(url: url)
                request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")
                let (data, _) = try await URLSession.shared.data(for: request)

                let loadedImage: UIImage?
                if isSVG {
                    if let svgImage = SVGKImage(data: data)?.uiImage {
                        loadedImage = svgImage
                    } else {
                        print("⚠️ Invalid SVG data for URL: \(urlString)")
                        loadedImage = UIImage(systemName: "photo")
                    }
                } else {
                    loadedImage = UIImage(data: data)
                }

                await MainActor.run {
                    self.image = loadedImage
                }

            } catch {
                print("❌ Failed to load image:", error.localizedDescription)
            }
        }
    }
}

struct UniversalImageView: View {
    @StateObject private var loader = UniversalImageLoader()
    let urlString: String
    let size: CGSize

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ProgressView()
                    .frame(width: size.width, height: size.height)
            }
        }
        .onAppear {
            loader.load(from: urlString)
        }
    }
}

//#Preview {
//    UniversalImageView(urlString: "https://d1fcaprh3kb5t7.cloudfront.net/wp-content/uploads/2025/10/28113130/irs-mike-rotunda-irwin-3.jpg?v=20251029182105", size: CGSize(width: 350, height: 252))
//}


