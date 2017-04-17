//
//  UIImageOrientation+Angle.swift
//  Ubiquity
//
//  Created by SAGESSE on 3/29/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal extension UIImageOrientation {
    
    internal var ub_angle: CGFloat {
        switch self {
        case .up, .upMirrored:
            return 0 * CGFloat.pi / 2
            
        case .right, .rightMirrored:
            return 1 * CGFloat.pi / 2
            
        case .down, .downMirrored:
            return 2 * CGFloat.pi / 2
            
        case .left, .leftMirrored:
            return 3 * CGFloat.pi / 2
        }
    }
    internal var ub_isLandscape: Bool {
        switch self {
        case .left, .leftMirrored: return true
        case .right, .rightMirrored: return true
        case .up, .upMirrored: return false
        case .down, .downMirrored: return false
        }
    }
}
