//
//  UIResponder+Fullscreen.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/12/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit


/// add a full screen support
internal extension UIResponder {
    
    /// the current fullscreen state
    /// default is false, must override return true
    var ub_isFullscreen: Bool {
        return next?.ub_isFullscreen ?? false
    }

    ///
    /// enter fullscreen mode
    ///
    /// - Parameter animated: the change need animation?
    /// - Returns: true is enter success, false is fail
    ///
    @discardableResult
    func ub_enterFullscreen(animated: Bool) -> Bool {
        return next?.ub_enterFullscreen(animated: animated) ?? false
    }
    
    ///
    /// exit fullscreen mode
    ///
    /// - Parameter animated: the change need animation?
    /// - Returns: true is exit success, false is fail
    ///
    @discardableResult
    func ub_exitFullscreen(animated: Bool) -> Bool {
        return next?.ub_exitFullscreen(animated: animated) ?? false
    }
}

