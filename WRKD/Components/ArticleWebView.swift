//
//  ArticleWebView.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/30/25.
//

import SwiftUI
import SafariServices

struct ArticleWebView: UIViewControllerRepresentable {

    let urlString: String
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        // Safely build the URL
        let url = URL(string: urlString) ?? URL(string: "https://google.com")!
        
        // Configure Safari so it auto-enters the Reader when possible
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        
        let safariVC = SFSafariViewController(url: url, configuration: config)
        
//        safariVC.preferredBarTintColor = UIColor(named: "secondaryBG")
//        safariVC.preferredControlTintColor = UIColor(named: "primaryColor")
        
        safariVC.dismissButtonStyle = .close
        
        return safariVC
    }
    
    // SFSafariViewController doesn’t support changing the URL after creation, so this stays empty.
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) { }
}


#Preview {
    NavigationStack {
        ArticleWebView(urlString: "https://www.fightful.com/wrestling/bayley-on-being-a-wwe-locker-room-leader-its-not-something-that-i-asked-for-these-idiots-need-guidance/")
    }
}
