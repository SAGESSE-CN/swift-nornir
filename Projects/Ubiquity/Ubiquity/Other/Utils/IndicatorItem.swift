//
//  IndicatorItem.swift
//  Ubiquity
//
//  Created by SAGESSE on 3/17/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class IndicatorItem: ExtendedItem {
    internal init() {
        _indicatorView = IndicatorView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        super.init(customView: _indicatorView)
    }
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal var indicatorView: IndicatorView {
        return _indicatorView
    }
    
    private var _indicatorView: IndicatorView
}
