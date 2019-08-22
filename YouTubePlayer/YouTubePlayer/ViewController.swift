//
//  ViewController.swift
//  YouTubePlayer
//
//  Created by Den Jo on 21/08/2019.
//  Copyright © 2019 nilotic. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    
    
    
    // MARK: - Valvue
    // MARK: Private
    private weak var youTubePlayer: YouTubePlayerViewController? = nil
    
    
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard youTubePlayer?.load(id: "jy_UiIQn_d0") == true else { return }
        activityIndicatorView.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.youTubePlayer?.pause()
        }
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.youTubePlayer?.play()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
            self.youTubePlayer?.stop()
        }
    }
}


// MARK: - YouTubePlayerViewController Delegate
extension ViewController: YouTubePlayerViewControllerDelegate {
    
    func didUpdate(state: YouTubePlayerState, error: YouTubePlayerError?) {
        switch state {
        case .ready:
            DispatchQueue.main.async { self.activityIndicatorView.stopAnimating() }
            
            
        case .unstarted:
            log(.info, state)
            
        case .ended:
            log(.info, state)
            
        case .playing:
            log(.info, state)
            
        case .paused:
            log(.info, state)
            
        case .buffering:
            log(.info, state)
            
        case .cued:
            log(.info, state)
            
        case .unknown:
            log(.info, state)
        }
    }
    
    func didUpdate(quality: YouTubePlaybackQuality) {
        log(.info, quality)
    }
    
    func didUpdate(playtime: TimeInterval) {
        log(.info, playtime)
    }
}



// MARK: - Segue
extension ViewController: SegueHandlerType {
    
    // MARK: Enum
    enum SegueIdentifier: String {
        case youTubePlayer = "YouTubePlayerSegue"
    }
    
    
    // MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segueIdentifier(with: segue) else {
            log(.error, "Failed to get a segueIdentifier.")
            return
        }
        
        switch segueIdentifier {
        case .youTubePlayer:
            guard let viewController = segue.destination as? YouTubePlayerViewController else {
                log(.error, "Failed to get a YouTubePlayerViewController.")
                return
            }
            
            youTubePlayer = viewController
            viewController.delegate = self
        }
    }
}
