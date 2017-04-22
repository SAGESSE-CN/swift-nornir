//
//  UIImage+Module.swift
//  Ubiquity
//
//  Created by SAGESSE on 31/10/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit


internal extension UIImage {
    
    func ub_withOrientation(_ orientation: UIImageOrientation) -> UIImage? {
        guard imageOrientation != orientation else {
            return self
        }
        if let image = cgImage {
            return UIImage(cgImage: image, scale: scale, orientation: orientation)
        }
        if let image = ciImage {
            return UIImage(ciImage: image, scale: scale, orientation: orientation)
        }
        return nil
    }
    
    static func ub_init(named: String) -> UIImage? {
        return UIImage(named: named, in: _bundle, compatibleWith: nil)
    }
}

private weak var _bundle: Bundle? = Bundle(identifier: "SA.Ubiquity")
