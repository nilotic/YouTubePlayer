//
//  YouTubePlayerState.swift
//  YouTubePlayer
//
//  Created by Den Jo on 22/08/2019.
//  Copyright © 2019 nilotic. All rights reserved.
//

import Foundation

enum YouTubePlayerState: String {
    case ready     = "ready"
    case unstarted = "-1"
    case ended     = "0"
    case playing   = "1"
    case paused    = "2"
    case buffering = "3"
    case cued      = "5"
    case unknown   = "unknown"
}
