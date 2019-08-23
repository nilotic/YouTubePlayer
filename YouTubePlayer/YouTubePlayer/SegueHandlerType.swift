//
//  SegueHandlerType.swift
//  YouTubePlayer
//
//  Created by Den Jo on 22/08/2019.
//  Copyright © 2019 nilotic. All rights reserved.
//

import UIKit

public protocol SegueHandlerType {
    associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {
    /**
     An overload of `UIViewController`'s `performSegueWithIdentifier(_:sender:)`
     method that takes in a `SegueIdentifier` enum parameter rather than a `String`.
     */
    public func performSegue(with segueIdentifier: SegueIdentifier, sender: Any?) {
        performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
    }
    
    /**
     A convenience method to map a `StoryboardSegue` to the  segue identifier
     enum that it represents.
     */
    
    public func segueIdentifier(with segue: UIStoryboardSegue) -> SegueIdentifier? {
        guard let identifier = segue.identifier, let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            log(.error, "Couldn't handle segue identifier \(String(describing: segue.identifier)) for view controller of type \(type(of: self)).")
            return nil
        }
        return segueIdentifier
    }
}
