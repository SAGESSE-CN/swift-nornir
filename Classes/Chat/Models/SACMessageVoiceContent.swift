//
//  SACMessageVoiceContent.swift
//  SAChat
//
//  Created by sagesse on 05/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

open class SACMessageVoiceContent: NSObject, SACMessageContentType {
    
    open var layoutMargins: UIEdgeInsets = .init(top: 5, left: 10, bottom: 5, right: 10)
    
    open class var viewType: SACMessageContentViewType.Type {
        return SACMessageVoiceContentView.self
    }
    
    open var data: Data?
    open var duration: TimeInterval = 9999
    
    open var attributedText: NSAttributedString?
    
    open func sizeThatFits(_ size: CGSize) -> CGSize {
        // +---------------+
        // |  ))) 99'59''  |
        // +---------------+
        
        attributedText = NSAttributedString(string: "99'59''", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
        
        let w1 = attributedText?.size().width ?? 0
        return .init(width: 20 + 8 + w1, height: 20)
    }
}
