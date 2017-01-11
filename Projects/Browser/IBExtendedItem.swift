//
//  IBExtendedItem.swift
//  Browser
//
//  Created by sagesse on 12/17/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

open class IBExtendedItem: UIBarButtonItem {
    
    public init(height: CGFloat, view: UIView) {
        self.height = height
        super.init()
        self.customView = view
    }
    public required init?(coder aDecoder: NSCoder) {
        self.height = CGFloat(aDecoder.decodeDouble(forKey: "height"))
        super.init(coder: aDecoder)
    }
    
    /// 保留高度
    open let height: CGFloat
}

