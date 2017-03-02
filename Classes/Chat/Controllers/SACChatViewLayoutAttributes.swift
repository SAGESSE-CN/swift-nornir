//
//  SACChatViewLayoutAttributes.swift
//  SAChat
//
//  Created by SAGESSE on 26/12/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

@objc public enum SACChatViewLayoutItem: Int {
    case all
    case card
    case avatar
    case bubble
    case content
}

@objc open class SACChatViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    public override init() {
        super.init()
    }
    
    open override func copy(with zone: NSZone? = nil) -> Any {
        let new = super.copy(with: zone)
        if let new = new as? SACChatViewLayoutAttributes {
            new.info = info
        }
        return new
    }
    
    open var message: SACMessageType? {
        return info?.message
    }
    
    open var info: SACChatViewLayoutAttributesInfo?
}

@objc internal class SACChatViewLayoutAnimationAttributes: SACChatViewLayoutAttributes {
    
    internal override init() {
        super.init()
    }
    internal static func animation(with layoutAttributes: UICollectionViewLayoutAttributes, updateItem: UICollectionViewUpdateItem) -> SACChatViewLayoutAnimationAttributes? {
        // layoutAttributes must is SACChatViewLayoutAttributes
        guard layoutAttributes is SACChatViewLayoutAttributes else {
            return nil
        }
        // copy from SACChatViewLayoutAttributes
        object_setClass(layoutAttributes, SACChatViewLayoutAnimationAttributes.self)
        let ob = layoutAttributes.copy()
        object_setClass(layoutAttributes, SACChatViewLayoutAttributes.self)
        // checkout type
        guard let newLayoutAttributes = ob as? SACChatViewLayoutAnimationAttributes else {
            return nil
        }
        newLayoutAttributes.updateItem = updateItem
        return newLayoutAttributes
    }
    
    internal override func copy(with zone: NSZone? = nil) -> Any {
        let new = super.copy(with: zone)
        return new
    }
    
    var delay: TimeInterval = 0
    var options: UIViewAnimationOptions = .curveEaseInOut
    var duration: TimeInterval = 5
    
    var updateItem: UICollectionViewUpdateItem?
}
