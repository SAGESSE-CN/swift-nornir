//
//  NSLayoutConstraint+SA.swift
//  SIMChat
//
//  Created by sagesse on 9/15/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

/// Cretae an `NSLayoutConstraint`
internal func _SALayoutConstraintMake(_ item: AnyObject, _ attr1: NSLayoutAttribute, _ related: NSLayoutRelation, _ toItem: AnyObject? = nil, _ attr2: NSLayoutAttribute = .notAnAttribute, _ constant: CGFloat = 0, priority: UILayoutPriority = 1000, multiplier: CGFloat = 1, output: UnsafeMutablePointer<NSLayoutConstraint?>? = nil) -> NSLayoutConstraint {
    
    let c = NSLayoutConstraint(item:item, attribute:attr1, relatedBy:related, toItem:toItem, attribute:attr2, multiplier:multiplier, constant:constant)
    c.priority = priority
    if output != nil {
        output?.pointee = c
    }
    
    return c
}
