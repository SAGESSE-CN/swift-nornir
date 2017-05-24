//
//  UIColor+Hex.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/24/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit


internal extension UIColor {
    static func ub_init(hex: UInt) -> UIColor {
        return UIColor(red: .init((hex >> 16) & 0xff) / 256.0,
                       green: .init((hex >> 8) & 0xff) / 256.0,
                       blue: .init((hex >> 0) & 0xff) / 256.0,
                       alpha: 1)
    }
}

