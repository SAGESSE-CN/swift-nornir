//
//  UIColor+Hex.swift
//  SIMChat
//
//  Created by sagesse on 9/20/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(rgb: UInt) {
        let a = 0xFF
        let r = (rgb >> 16) & 0xFF
        let g = (rgb >> 8) & 0xFF
        let b = (rgb >> 0) & 0xFF
        
        self.init(red: CGFloat(r) / 0xFF,  green: CGFloat(g) / 0xFF, blue: CGFloat(b) / 0xFF, alpha: CGFloat(a) / 0xFF)
    }
    
    convenience init(argb: UInt) {
        let a = (argb >> 24) & 0xFF
        let r = (argb >> 16) & 0xFF
        let g = (argb >> 8) & 0xFF
        let b = (argb >> 0) & 0xFF
        
        self.init(red: CGFloat(r) / 0xFF,  green: CGFloat(g) / 0xFF, blue: CGFloat(b) / 0xFF, alpha: CGFloat(a) / 0xFF)
    }
}