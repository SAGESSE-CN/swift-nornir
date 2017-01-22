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

