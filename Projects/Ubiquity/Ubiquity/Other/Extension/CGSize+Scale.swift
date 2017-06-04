//
//  CGSize+Scale.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/26/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal extension CGSize {
    
    var ub_fitWithScreen: CGSize {
        return .init(width: width * UIScreen.main.scale,
                     height: height * UIScreen.main.scale)
    }
}
