//
//  NSLayoutConstraint+Make.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/4/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal extension NSLayoutConstraint {
    @inline(__always) static func ub_make(_ item: AnyObject, _ attr1: NSLayoutAttribute, _ related: NSLayoutRelation, _ toItem: AnyObject? = nil, _ attr2: NSLayoutAttribute = .notAnAttribute, _ constant: CGFloat = 0, priority: UILayoutPriority = 1000, multiplier: CGFloat = 1) -> Self {
        let c = self.init(item: item, attribute: attr1, relatedBy: related, toItem: toItem, attribute: attr2, multiplier: multiplier, constant: constant)
        c.priority = priority
        return c
    }
}
