//
//  SIMChatBaseInputItem.swift
//  SIMChat
//
//  Created by sagesse on 2/10/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

public class SIMChatBaseInputItem: SIMChatInputItemProtocol {
    
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
