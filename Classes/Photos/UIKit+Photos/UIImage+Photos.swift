//
//  UIImage+Photos.swift
//  SAPhotos
//
//  Created by SAGESSE on 31/10/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit


internal extension UIImage {
    static func sap_init(named: String) -> UIImage? {
        return UIImage(named: named, in: _frameworkMainBundle, compatibleWith: nil)
    }
}

private weak var _frameworkMainBundle: Bundle? = Bundle(identifier: "SA.SAPhotos")
