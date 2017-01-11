//
//  SACMessageContentType.swift
//  SAChat
//
//  Created by sagesse on 05/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

@objc public protocol SACMessageContentType: class  {
    
    var layoutMargins: UIEdgeInsets { get }
    
    func sizeThatFits(_ size: CGSize) -> CGSize
    
    static var viewType: SACMessageContentViewType.Type { get }
}

@objc public protocol SACMessageContentViewType: class {
    
    init()
    
    func apply(_ message: SACMessageType)
}

