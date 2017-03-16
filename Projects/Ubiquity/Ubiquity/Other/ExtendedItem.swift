//
//  ExtendedItem.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

public class ExtendedItem: UIBarButtonItem {
    
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
    public let height: CGFloat
}
