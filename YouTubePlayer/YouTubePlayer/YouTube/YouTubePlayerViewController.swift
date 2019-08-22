//
//  YouTubePlayerViewController.swift
//  YouTubePlayer
//
//  Created by Den Jo on 21/08/2019.
//  Copyright © 2019 nilotic. All rights reserved.
//

import UIKit
import WebKit

// MARK: - Define
protocol YouTubePlayerViewControllerDelegate: class {
    func didUpdate(state: YouTubePlayerState, error: YouTubePlayerError?)
    func didUpdate(quality: YouTubePlaybackQuality)
    func didUpdate(playtime: TimeInterval)
}

final class YouTubePlayerViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet private var playerView: UIView!
    
    
    
    
    // MARK: - Value
    // MARK: Public
    var lastPlaytime: TimeInterval = 0
    weak var delegate: YouTubePlayerViewControllerDelegate? = nil
    
    
    // MARK: Private
    private lazy var webView: WKWebView = {
        // WKWebView equivalent for UIWebView's scalesPageToFit
        // http://stackoverflow.com/questions/26295277/wkwebview-equivalent-for-uiwebviews-scalespagetofit
        let source = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)

        let preferences = WKPreferences()
        preferences.javaScriptEnabled                     = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController     = userContentController
        configuration.preferences               = preferences
        configuration.allowsInlineMediaPlayback = true
        
        
        let webView = WKWebView(frame: playerView.bounds, configuration: configuration)
        webView.backgroundColor            = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces         = false
        
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.topAnchor.constraint(equalTo: playerView.topAnchor).isActive           = true
        webView.bottomAnchor.constraint(equalTo: playerView.bottomAnchor).isActive     = true
        webView.leadingAnchor.constraint(equalTo: playerView.leadingAnchor).isActive   = true
        webView.trailingAnchor.constraint(equalTo: playerView.trailingAnchor).isActive = true
        return webView
    }()
    
    private let baseURL = URL(string: "https://www.youtube.com")!
    
    
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setWebView()
    }
    
    
    
    // MARK: - Function
    // MARK: Public
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
                                "onFullscreen"            : "onFullscreen",
                                "onError"                 : "onPlayerError"]
            ]
        }
        
        guard  let data = try? JSONSerialization.data(withJSONObject: parameters, options: []), let jsonString = String(data: data, encoding: .utf8),
            let contentsURL = Bundle.main.url(forResource: "YouTubePlayer", withExtension: "html"), let format = try? String(contentsOf: contentsURL, encoding: .utf8) else { return false }
        
        webView.loadHTMLString(String(format: format, jsonString), baseURL: baseURL)
        return true
    }
    
    
    // MARK: Player
    func play() {
        webView.evaluateJavaScript("player.playVideo();") { (response, error) in
            self.delegate?.didUpdate(state: .playing, error: nil)
        }
    }
    
    func stop() {
        webView.evaluateJavaScript("player.stopVideo();")
    }
    
    func pause() {
        webView.evaluateJavaScript("player.pauseVideo();") { (response, error) in
            self.delegate?.didUpdate(state: .paused, error: nil)
        }
    }
    
    
    // MARK: Settings
    func set(quality: YouTubePlaybackQuality) {
        webView.evaluateJavaScript(String(format: "player.setPlaybackQuality('%@');", quality.rawValue))
    }
    
    private func get(completion: @escaping (_ quality: YouTubePlaybackQuality) -> Void) {
        webView.evaluateJavaScript("player.getPlaybackQuality();") { (response, error) in
            completion(YouTubePlaybackQuality(rawValue: (response as? String ?? "")) ?? .unknown)
        }
    }
    
    
    // MARK: Private
    private func setWebView() {
        webView.uiDelegate         = self
        webView.navigationDelegate = self
        view.layoutIfNeeded()
    }
    
    private func handleStatus(url: URL) {
        guard let component = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = component.host, let status = YouTubeStatus(rawValue: host) else { return }
        switch status {
        case .ready:
            delegate?.didUpdate(state: .ready, error: nil)
            
        case .stateChanged:
            let state = YouTubePlayerState(rawValue: component.queryItems?.first?.value ?? "") ?? .unknown
            delegate?.didUpdate(state: state, error: nil)
            
        case .playbackQualityChange:
            delegate?.didUpdate(quality: YouTubePlaybackQuality(rawValue: component.queryItems?.first?.value ?? "") ?? .unknown)
            
        case .error:
            let error = YouTubePlayerError(rawValue: component.queryItems?.first?.value ?? "") ?? .unknown
            delegate?.didUpdate(state: .unknown, error: error)
            
        case .playTime:
            let time = TimeInterval(component.queryItems?.first?.value ?? "") ?? 0
            delegate?.didUpdate(playtime: time)
            
        case .youTubeIframeAPIReady:
            break
            
        case .youTubeIframeAPIFailedToLoad:
            break
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
        webView.uiDelegate         = nil
        webView.navigationDelegate = nil
        webView.removeFromSuperview()
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
