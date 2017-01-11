//
//  UIView+Animation.swift
//  Browser
//
//  Created by sagesse on 19/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal extension UIView {
    
    internal static func ib_animate(withDuration duration: TimeInterval, animated: Bool, animations: @escaping () -> Swift.Void, completion: ((Bool) -> Swift.Void)? = nil) {
        guard animated else {
            animations()
            completion?(true)
            return
        }
        UIView.animate(withDuration: duration, animations: animations, completion: completion)
    }
}
