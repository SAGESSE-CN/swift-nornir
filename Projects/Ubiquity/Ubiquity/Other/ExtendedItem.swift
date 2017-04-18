//
//  ExtendedItem.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class ExtendedItem: UIBarButtonItem {
    
    init(customView: UIView) {
        self.height = customView.frame.size.height
        super.init()
        self.customView = customView
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 保留高度
    let height: CGFloat
}

