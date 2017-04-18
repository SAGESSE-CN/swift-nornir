//
//  UIImage+Module.swift
//  Ubiquity
//
//  Created by SAGESSE on 31/10/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit


internal extension UIImage {
    static func ub_init(named: String) -> UIImage? {
        return UIImage(named: named, in: _bundle, compatibleWith: nil)
    }
}

private weak var _bundle: Bundle? = Bundle(identifier: "SA.Ubiquity")
