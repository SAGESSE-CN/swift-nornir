//
//  SACMessageVideoContent.swift
//  SAChat
//
//  Created by sagesse on 05/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

open class SACMessageVideoContent: NSObject, SACMessageContentType {
    
    open var layoutMargins: UIEdgeInsets = .zero
    
    open class var viewType: SACMessageContentViewType.Type {
        return SACMessageVideoContentView.self
    }
    
    open func sizeThatFits(_ size: CGSize) -> CGSize {
        return .init(width: size.width, height: 80)
    }
}
