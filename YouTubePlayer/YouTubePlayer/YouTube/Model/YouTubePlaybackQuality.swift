//
//  YouTubePlaybackQuality.swift
//  YouTubePlayer
//
//  Created by Den Jo on 21/08/2019.
//  Copyright © 2019 nilotic. All rights reserved.
//

import Foundation


enum YouTubePlaybackQuality: String, Codable {
    case unknown        = "unknown"
    case small          = "small"
    case medium         = "medium"
    case large          = "large"
    case hd720          = "hd720"
    case hd1080         = "hd1080"
    case highResolution = "highres"
    case auto           = "auto"
    case `default`      = "default"
}
