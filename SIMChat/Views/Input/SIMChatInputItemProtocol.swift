//
//  SIMChatInputItemProtocol.swift
//  SIMChat
//
//  Created by sagesse on 1/27/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

///
/// 输入选项
///
@objc public protocol SIMChatInputItemProtocol {
    
    var itemName: String? { get }
    var itemIdentifier: String { get }
    
    var itemImage: UIImage? { get }
    var itemSelectImage: UIImage? { get }
}

///
/// 输入选项代理
///
public protocol SIMChatInputItemProtocolDelegate: class {
    func itemShouldSelect(item: SIMChatInputItemProtocol) -> Bool
    func itemDidSelect(item: SIMChatInputItemProtocol)
}
