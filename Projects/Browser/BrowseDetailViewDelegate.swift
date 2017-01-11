//
//  BrowseDetailViewDelegate.swift
//  Browser
//
//  Created by sagesse on 11/17/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc protocol BrowseDetailViewDelegate {
    
    @objc optional func browseDetailView(_ browseDetailView: Any, _ containterView: IBContainterView, shouldBeginRotationing view: UIView?) -> Bool
    @objc optional func browseDetailView(_ browseDetailView: Any, _ containterView: IBContainterView, didEndRotationing view: UIView?, atOrientation orientation: UIImageOrientation) // scale between minimum and maximum. called after any 'bounce' animations
}
