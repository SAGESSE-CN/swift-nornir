//
//  SAPWKObject.swift
//  SAC
//
//  Created by SAGESSE on 18/10/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

internal struct SAPWKObject<T: AnyObject>: Equatable {
    weak var object: T?
}

/// Returns a Boolean value indicating whether two values are equal.
///
/// Equality is the inverse of inequality. For any values `a` and `b`,
/// `a == b` implies that `a != b` is `false`.
///
/// - Parameters:
///   - lhs: A value to compare.
///   - rhs: Another value to compare.
func ==<T: AnyObject>(lhs: SAPWKObject<T>, rhs: SAPWKObject<T>) -> Bool {
    return lhs.object === rhs.object
}

func ==<T: AnyObject>(lhs: SAPWKObject<T>, rhs: T) -> Bool {
    return lhs.object === rhs
}
