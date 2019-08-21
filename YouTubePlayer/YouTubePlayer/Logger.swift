//
//  Logger.swift
//  YouTubePlayer
//
//  Created by Den Jo on 21/08/2019.
//  Copyright © 2019 nilotic. All rights reserved.
//

import Foundation

enum LogType: String {
    case info    = "[💬]"
    case warning = "[⚠️]"
    case error   = "[‼️]"
}

#if DEBUG
var dateFormatter: DateFormatter = {
    let dateFormatter        = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return dateFormatter
}()
#endif

func log(_ type: LogType = .error, _ message: Any?, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    #if DEBUG
    var logMessage = ""
    
    // Add file, function name
    if let fileName = file.split(separator: "/").map(String.init).last?.split(separator: ".").map(String.init).first{
        logMessage = "\(dateFormatter.string(from: Date())) \(type.rawValue) [\(fileName)  \(function)]\((type == .info) ? "" : " ✓\(line)")"
    }
    
    print("\(logMessage)  ➜  \(message ?? "")")
    #endif
}
