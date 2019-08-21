//
//  YouTubeQuality.swift
//  YouTubePlayer
//
//  Created by Den Jo on 21/08/2019.
//  Copyright © 2019 nilotic. All rights reserved.
//

import Foundation


enum YouTubeQuality: String, Codable {
    case none           = "unknown"
    case small          = "small"
    case medium         = "medium"
    case large          = "large"
    case hd720          = "hd720"
    case hd1080         = "hd1080"
    case highResolution = "highres"
    case auto           = "auto"
    case `default`      = "default"
}

extension YouTubeQuality {
    
//    init(any: Any?) {
//        guard let string = rawValue as? String else {
//            self = .none
//            return
//        }
//        switch string {
//        case YouTubeQuality.none.rawValue:
//            
//        default:
//            self = .none
//        }
//        
//    }
}
