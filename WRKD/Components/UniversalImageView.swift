//
//  UniversalImageView.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/29/25.
//

import SwiftUI
import SVGKit
import Combine
import CryptoKit

@MainActor
class UniversalImageLoader: ObservableObject {
    @Published var image: UIImage?

//    static var cache = [String: UIImage]()
    // Mark: - Caches
    
    // In memory cache (fast temporary)
    private static let memoryCache = NSCache<NSString, UIImage>()
    
    // Directory on disk where we'll store images
    private static let diskCacheDirectory: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let dir = urls[0].appendingPathComponent("ImageCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()
    
    // Generate a safe file URL for this image based on its URL string
    private static func cacheFileURL(for urlString: String) -> URL {
        // Use SHA256 so filenames are short & safe
        let digest = SHA256.hash(data: Data(urlString.utf8))
        let filename = digest.map { String(format: "%02x", $0) }.joined()
        return diskCacheDirectory.appendingPathComponent(filename).appendingPathExtension("img")
    }
    
    // Try to load from memory, the fall back to disk
    private static func imageFromCache(for urlString: String) -> UIImage? {
        // 1) Memory cache
        if let image = memoryCache.object(forKey: urlString as NSString) {
            return image
        }
        
        // 2) Disk cache
        let fileURL = cacheFileURL(for: urlString)
        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            // Promote to memory cache for faster next access
            memoryCache.setObject(image, forKey: urlString as NSString)
            return image
        }
        return nil
    }
    
    /// Store in memory and on disk
    private static func store(_ image: UIImage, for urlString: String) {
        // Memory
        memoryCache.setObject(image, forKey: urlString as NSString)
        
        // Disk
        let fileURL = cacheFileURL(for: urlString)
        if let data = image.pngData() {
            try? data.write(to: fileURL)
        }
    }

       func load(from urlString: String) {
           guard let url = URL(string: urlString), !urlString.isEmpty else { return }
           
#if DEBUG
if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
    self.image = UIImage(systemName: "photo")
    return
}
#endif

           // Trys to load from memory or disk cache
           if let cached = Self.imageFromCache(for: urlString) {
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
                
                // Stores in cache if we actually got an image
                if let loadedImage {
                    Self.store(loadedImage, for: urlString)
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


