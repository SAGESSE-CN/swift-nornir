//
//  SACMessageOptions.swift
//  SAChat
//
//  Created by sagesse on 04/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

/// 消息类型
@objc public enum SACMessageStyle: Int {
    case notice
    case bubble
}

/// 消息对齐方式
@objc public enum SACMessageAlignment: Int {
    case left
    case right
    case center
}

/// 消息选项
@objc open class SACMessageOptions: NSObject {
    
    public override init() {
        super.init()
    }
    
    public convenience init(with content: SACMessageContentType) {
        self.init()
        
        switch content {
        case is SACMessageNoticeContent:
            self.style = .notice
            self.alignment = .center
            self.showsCard = false
            self.showsAvatar = false
            self.showsBubble = true
            self.isUserInteractionEnabled = false
            
        case is SACMessageTimeLineContent:
            self.style = .notice
            self.alignment = .center
            self.showsCard = false
            self.showsAvatar = false
            self.showsBubble = false
            self.isUserInteractionEnabled = false
            
        default:
            break
        }
    }
    
    open var style: SACMessageStyle = .bubble
    open var alignment: SACMessageAlignment = .left
    
    open var isUserInteractionEnabled: Bool = true
    
    open var showsCard: Bool = true
    open var showsAvatar: Bool =  true
    open var showsBubble: Bool = true
    
    internal func fix(with content: SACMessageContentType)  {
    }
}
