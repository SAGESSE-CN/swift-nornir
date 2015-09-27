//
//  UIColor+Hex.swift
//  SIMChat
//
//  Created by sagesse on 9/20/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hex: Int) {
        
        let r = (hex >> 16) & 0xFF
        let g = (hex >> 8) & 0xFF
        let b = (hex >> 0) & 0xFF
        let a = 0xFF
        
        self.init(red: CGFloat(r) / 0xFF,  green: CGFloat(g) / 0xFF, blue: CGFloat(b) / 0xFF, alpha: CGFloat(a) / 0xFF)
    }
    
}