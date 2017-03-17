//
//  ExtendedItem.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class ExtendedItem: UIBarButtonItem {
    
    internal init(customView: UIView) {
        self.height = customView.frame.size.height
        super.init()
        self.customView = customView
    }
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 保留高度
    internal let height: CGFloat
}
