//
//  SIMChatInputItem.swift
//  SIMChat
//
//  Created by sagesse on 1/27/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

///
/// 输入选项
///
@objc public protocol SIMChatInputItem {
    
    var itemName: String? { get }
    var itemIdentifier: String { get }
    
    var itemImage: UIImage? { get }
    var itemSelectImage: UIImage? { get }
}

///
/// 输入选项代理
///
public protocol SIMChatInputItemDelegate: class {
    func itemShouldSelect(item: SIMChatInputItem) -> Bool
    func itemDidSelect(item: SIMChatInputItem)
}

public class SIMChatInputBaseItem: SIMChatInputItem {
    
    public init(_ identifier: String, _ image: UIImage?, _ selectImage: UIImage? = nil, _ name: String? = nil) {
        itemIdentifier = identifier
        itemName = name
        
        itemImage = image
        itemSelectImage = selectImage
    }
    
    @objc public var itemIdentifier: String
    @objc public var itemName: String?
    
    @objc public var itemImage: UIImage?
    @objc public var itemSelectImage: UIImage?
}
