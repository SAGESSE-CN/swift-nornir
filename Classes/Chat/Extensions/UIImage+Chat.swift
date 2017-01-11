//
//  UIImage+Photos.swift
//  SAIPhotos
//
//  Created by SAGESSE on 31/10/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit


internal extension UIImage {
    static func sac_init(named: String) -> UIImage? {
        return UIImage(named: named, in: SACManager.mainBundle, compatibleWith: nil)
    }
}

