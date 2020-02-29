//
//  NSLayoutConstraint+Photos.swift
//  SAIPhotos
//
//  Created by SAGESSE on 31/10/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

@inline(__always)
internal func _SAILayoutConstraintMake(_ item: AnyObject, _ attr1: NSLayoutConstraint.Attribute, _ related: NSLayoutConstraint.Relation, _ toItem: AnyObject? = nil, _ attr2: NSLayoutConstraint.Attribute = .notAnAttribute, _ constant: CGFloat = 0, priority: UILayoutPriority = .required, multiplier: CGFloat = 1, output: UnsafeMutablePointer<NSLayoutConstraint?>? = nil) -> NSLayoutConstraint {
    
    let c = NSLayoutConstraint(item:item, attribute:attr1, relatedBy:related, toItem:toItem, attribute:attr2, multiplier:multiplier, constant:constant)
    c.priority = priority
    if output != nil {
        output?.pointee = c
    }
    
    return c
}
