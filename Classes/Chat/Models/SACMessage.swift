//
//  SACMessage.swift
//  SAChat
//
//  Created by sagesse on 03/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

open class SACMessage: NSObject, SACMessageType {
    
    init(content: SACMessageContentType) {
        self.content = content
        self.options = SACMessageOptions(with: content)
        super.init()
    }
    
    convenience init(forTimeline after: SACMessageType, before: SACMessageType? = nil) {
        let content = SACMessageTimeLineContent(date: after.date)
        content.before = before
        content.after = after
        self.init(content: content)
        self.date = after.date
    }
    
    open var name: String = "Unknow"
    
    // 发送/接收时间
    open var date: Date = .init()
    
    // 发送者和接收者
    open var sender: SACUserType {
        fatalError()
    }
    open var receiver: SACUserType {
        fatalError()
    }
    
    open let content: SACMessageContentType
    
    open let options: SACMessageOptions
}

