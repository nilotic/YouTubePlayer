//
//  YouTubePlayerViewController.swift
//  YouTubePlayer
//
//  Created by Den Jo on 21/08/2019.
//  Copyright © 2019 nilotic. All rights reserved.
//

import UIKit
import WebKit

final class YouTubePlayerViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var containerView: UIView!
    
    
    
    
    // MARK: - Value
    // MARK: Public
    var lastPlaytime: TimeInterval = 0
    
    
    // MARK: Private
    private lazy var webView: WKWebView = {
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "close")
        userContentController.add(self, name: "share")
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled                     = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.preferences = preferences
        
        
        let webView = WKWebView(frame: view.bounds, configuration: configuration)
        
        containerView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive                          = true
        webView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        webView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive                   = true
        webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive                 = true
        
        view.bringSubviewToFront(activityIndicatorView)
        return webView
    }()
    
    
    
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    // MARK: - Function
    // MARK: Public
    func set(quality: YouTubeQuality) {
        webView.evaluateJavaScript(String(format: "player.setPlaybackQuality('%@');", quality.rawValue)) { (response, error) in
            guard error == nil else {
                log(.error, error?.localizedDescription)
                return
            }
        }
    }
    
    func load(id: String) {
        
        var parameters:  [String : Any] {
            return ["videoId"    : id,
                    "width"      : "100%",
                    "height"     : "100%",
                    
                    "playerVars" : ["controls"    : 1,
                                    "playsinline" : 1,
                                    "autohide"    : 1,
                                    "autohide"    : 1,
                                    "origin"      : "https://www.youtube.com",
                                    "start"       : lastPlaytime],
                    
                    "events" : ["onReady"                 : "onReady",
                                "onStateChange"           : "onStateChange",
                                "onPlaybackQualityChange" : "onPlaybackQualityChange",
                                "onError"                 : "onPlayerError"]
                ]
        }

    
            
    }
    
    
    // MARK: Private
    private func get(completion: @escaping (_ quality: YouTubeQuality) -> Void) {
        webView.evaluateJavaScript("player.getPlaybackQuality();") { (response, error) in
            completion(YouTubeQuality(rawValue: (response as? String ?? "")) ?? .none)
        }
    }
    
    
    
    private func close() {
        webView.removeFromSuperview()
    }
}



// MARK: - WKNavigation Delegate
extension YouTubePlayerViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicatorView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicatorView.stopAnimating()
    }
}


// MARK: - WKUI Delegate
extension YouTubePlayerViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let absoluteURLString = navigationAction.request.url?.absoluteString, absoluteURLString.hasPrefix("http"), let url = URL(string: absoluteURLString) {
            UIApplication.shared.open(url)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { action in
                completionHandler()
            }
            
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}


// MARK: - WKScriptMessageHandler
extension YouTubePlayerViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "share":
            guard let string = message.body as? String, let url = URL(string: string) else { return }
            
            DispatchQueue.main.async {
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                self.present(activityViewController, animated: true)
            }
            
        case "close":
            break
        default:            break
        }
    }
}
