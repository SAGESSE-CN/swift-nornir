//
//  SIMChatInputAccessory.swift
//  SIMChat
//
//  Created by sagesse on 1/27/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

///
/// 附件协议
///
@objc public protocol SIMChatInputAccessory {
    
    var accessoryName: String? { get }
    var accessoryIdentifier: String { get }
    
    var accessoryImage: UIImage? { get }
    var accessorySelecteImage: UIImage? { get }
}


public class SIMChatInputBaseAccessory: SIMChatInputAccessory {
    
    public init(_ identifier: String, _ image: UIImage?, _ selectImage: UIImage? = nil, _ name: String? = nil) {
        accessoryIdentifier = identifier
        accessoryName = name
        
        accessoryImage = image
        accessorySelecteImage = selectImage
    }
    
    @objc public var accessoryIdentifier: String
    @objc public var accessoryName: String?
    
    @objc public var accessoryImage: UIImage?
    @objc public var accessorySelecteImage: UIImage?
}