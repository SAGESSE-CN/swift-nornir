//
//  SACChatViewLayoutAttributesInfo.swift
//  SAChat
//
//  Created by sagesse on 04/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

@objc open class SACChatViewLayoutAttributesInfo: NSObject {
    
    public init(message: SACMessageType, size: CGSize, rects: [SACChatViewLayoutItem: CGRect], boxRects: [SACChatViewLayoutItem: CGRect]) {
        _message = message
        _cacheSize = size
        _allLayoutedRects = rects
        _allLayoutedBoxRects = boxRects
        super.init()
    }
    
    open var message: SACMessageType {
        return _message
    }
    
    open func layoutedRect(with item: SACChatViewLayoutItem) -> CGRect {
        return _allLayoutedRects[item] ?? .zero
    }
    open func layoutedBoxRect(with item: SACChatViewLayoutItem) -> CGRect {
        return _allLayoutedBoxRects[item] ?? .zero
    }
    
    private var _message: SACMessageType
    private var _cacheSize: CGSize
    
    private var _allLayoutedRects: [SACChatViewLayoutItem: CGRect]
    private var _allLayoutedBoxRects: [SACChatViewLayoutItem: CGRect]
    
}
