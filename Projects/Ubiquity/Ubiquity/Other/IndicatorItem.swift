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
    
    internal weak var dataSource: IndicatorViewDataSource? {
        set { return _indicatorView.dataSource = newValue }
        get { return _indicatorView.dataSource }
    }
    internal weak var delegate: IndicatorViewDelegate? {
        set { return _indicatorView.delegate = newValue }
        get { return _indicatorView.delegate }
    }
    
    internal func beginInteractiveMovement() {
        _indicatorView.beginInteractiveMovement()
    }
    internal func updateIndexPath(from indexPath1: IndexPath?, to indexPath2: IndexPath?, percent: CGFloat) {
        _indicatorView.updateIndexPath(from: indexPath1, to: indexPath2, percent: percent)
    }
    internal func endInteractiveMovement() {
        _indicatorView.endInteractiveMovement()
    }
    
    internal func scrollToItem(at indexPath: IndexPath, animated: Bool) {
        _indicatorView.scrollToItem(at: indexPath, animated: animated)
    }
    
    private var _indicatorView: IndicatorView
}
