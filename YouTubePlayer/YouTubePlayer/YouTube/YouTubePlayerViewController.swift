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
    @IBOutlet private var playerView: UIView!
    
    
    
    
    // MARK: - Value
    // MARK: Public
    var lastPlaytime: TimeInterval = 0
    
    
    // MARK: Private
    private lazy var webView: WKWebView = {
        // WKWebView equivalent for UIWebView's scalesPageToFit
        // http://stackoverflow.com/questions/26295277/wkwebview-equivalent-for-uiwebviews-scalespagetofit
        let source = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        
        
//        userContentController.add(self, name: "close")
//        userContentController.add(self, name: "share")
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled                     = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController     = userContentController
        configuration.preferences               = preferences
        configuration.allowsInlineMediaPlayback = true
        
        
        let webView = WKWebView(frame: playerView.bounds, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces         = false
        
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.topAnchor.constraint(equalTo: playerView.topAnchor).isActive           = true
        webView.bottomAnchor.constraint(equalTo: playerView.bottomAnchor).isActive     = true
        webView.leadingAnchor.constraint(equalTo: playerView.leadingAnchor).isActive   = true
        webView.trailingAnchor.constraint(equalTo: playerView.trailingAnchor).isActive = true
        
        view.bringSubviewToFront(activityIndicatorView)
        return webView
    }()
    
    private let baseURL = URL(string: "https://www.youtube.com")!
    
    
    
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setWebView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        webView.load(URLRequest(url: URL(string: "https://www.google.com")!))
        
        set(quality: .hd720)
        guard load(id: "jy_UiIQn_d0") == true else { return }
        activityIndicatorView.startAnimating()
    }
    
    
    // MARK: - Function
    // MARK: Public
    private func setWebView() {
        webView.uiDelegate         = self
        webView.navigationDelegate = self
        view.layoutIfNeeded()
    }
    
    func set(quality: YouTubeQuality) {
        webView.evaluateJavaScript(String(format: "player.setPlaybackQuality('%@');", quality.rawValue)) { (response, error) in
            guard error == nil else {
                log(.error, error?.localizedDescription)
                return
            }
        }
    }
    
    func load(id: String) -> Bool {
        var parameters:  [String : Any] {
            return ["videoId"    : id,
                    "width"      : "100%",
                    "height"     : "100%",
                    
                    "playerVars" : ["controls"    : 1,
                                    "playsinline" : 1,
                                    "autohide"    : 1,
                                    "origin"      : "https://www.youtube.com",
                                    "start"       : lastPlaytime],
                    
                    "events" : ["onReady"                 : "onReady",
                                "onStateChange"           : "onStateChange",
                                "onPlaybackQualityChange" : "onPlaybackQualityChange",
                                "onError"                 : "onPlayerError"]
            ]
        }
        
        guard  let data = try? JSONSerialization.data(withJSONObject: parameters, options: []), let jsonString = String(data: data, encoding: .utf8),
            let contentsURL = Bundle.main.url(forResource: "YouTubePlayer", withExtension: "html"), let format = try? String(contentsOf: contentsURL, encoding: .utf8) else { return false }
        
        
        
        webView.loadHTMLString(String(format: format, jsonString), baseURL: baseURL)
        return true
    }
    
    
    // MARK: Private
    private func get(completion: @escaping (_ quality: YouTubeQuality) -> Void) {
        webView.evaluateJavaScript("player.getPlaybackQuality();") { (response, error) in
            completion(YouTubeQuality(rawValue: (response as? String ?? "")) ?? .none)
        }
    }
    
    
    private func handleStatus(url: URL) {
        guard let host = url.host, let status = YouTubeStatus(rawValue: host) else { return }
        
        
        let data   = url.query?.components(separatedBy: "=").last
        
        switch status {
        case .ready:
            break
            
        case .stateChanged:
            
            
            
            
        }
        
    }
    
    private func handleHttpNavigation(url: URL) -> Bool {
        var regularExpression = try? NSRegularExpression(pattern: "^http(s)://(www.)youtube.com/embed/(.*)$", options: .caseInsensitive)
        guard regularExpression?.firstMatch(in: url.absoluteString, options: [], range: NSRange(location: 0, length: url.absoluteString.count)) == nil else { return true }
        
        regularExpression = try? NSRegularExpression(pattern: "^http(s)://pubads.g.doubleclick.net/pagead/conversion/", options: .caseInsensitive)
        guard regularExpression?.firstMatch(in: url.absoluteString, options: [], range: NSRange(location: 0, length: url.absoluteString.count)) == nil else { return true }
        
        regularExpression = try? NSRegularExpression(pattern: "^http(s)://accounts.google.com/o/oauth2/(.*)$", options: .caseInsensitive)
        guard regularExpression?.firstMatch(in: url.absoluteString, options: [], range: NSRange(location: 0, length: url.absoluteString.count)) == nil else { return true }
        
        regularExpression = try? NSRegularExpression(pattern: "^https://content.googleapis.com/static/proxy.html(.*)$", options: .caseInsensitive)
        guard regularExpression?.firstMatch(in: url.absoluteString, options: [], range: NSRange(location: 0, length: url.absoluteString.count)) == nil else { return true }
        
        regularExpression = try? NSRegularExpression(pattern: "^https://tpc.googlesyndication.com/sodar/(.*).html$", options: .caseInsensitive)
        guard regularExpression?.firstMatch(in: url.absoluteString, options: [], range: NSRange(location: 0, length: url.absoluteString.count)) == nil else { return true }
        return false
    }
    
    
    
    private func close() {
        webView.removeFromSuperview()
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "close")
    }
}



// MARK: - WKNavigation Delegate
extension YouTubePlayerViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.host == baseURL.host {
            decisionHandler(.allow)
        
        } else if let url = navigationAction.request.url, url.scheme == "ytplayer" {
            handleStatus(url: url)
            decisionHandler(.cancel)
            
        } else if let url = navigationAction.request.url, url.scheme == "https" {
            guard handleHttpNavigation(url: url) == true else {
                decisionHandler(.cancel)

                guard UIApplication.shared.canOpenURL(url) else { return }
                UIApplication.shared.open(url, options: [:])
                return
            }
            
            decisionHandler(.allow)
            
        } else {
            decisionHandler(.allow)
        }
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
