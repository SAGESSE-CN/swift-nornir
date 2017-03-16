//
//  UIColor+Random.swift
//  Example
//
//  Created by SAGESSE on 11/1/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

extension UIColor {
    static var random: UIColor {
        let maxValue: UInt32 = 24
        return UIColor(red: CGFloat(arc4random() % maxValue) / CGFloat(maxValue),
                       green: CGFloat(arc4random() % maxValue) / CGFloat(maxValue) ,
                       blue: CGFloat(arc4random() % maxValue) / CGFloat(maxValue) ,
                       alpha: 1)
    }
}
