//
//  YouTubeStatus.swift
//  YouTubePlayer
//
//  Created by Den Jo on 21/08/2019.
//  Copyright © 2019 nilotic. All rights reserved.
//

import Foundation

enum YouTubeStatus: String {
    case ready                        = "onReady"
    case stateChanged                 = "onStateChange"
    case playbackQualityChange        = "onPlaybackQualityChange"
    case error                        = "onError"
    case playTime                     = "onPlayTime"
    case youTubeIframeAPIReady        = "onYouTubeIframeAPIReady"
    case youTubeIframeAPIFailedToLoad = "onYouTubeIframeAPIFailedToLoad"
}
