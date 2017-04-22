//
//  TilingViewLayoutAttributes.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class TilingViewLayoutAttributes: NSObject {
    
    init(forCellWith indexPath: IndexPath) {
        self.indexPath = indexPath
        super.init()
    }
    
    var indexPath: IndexPath
    var version: Int = 0
    
    var frame: CGRect = .zero
    var fromFrame: CGRect = .zero
}
