//
//  SACConversation.swift
//  SAChat
//
//  Created by SAGESSE on 01/11/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

open class SACConversation: NSObject, SACConversationType {
    
    init(receiver: SACUserType, sender: SACUserType) {
        self.sender = sender
        self.receiver = receiver
        super.init()
    }
    
    /// 发送者
    open var sender: SACUserType
    
    /// 接收者
    open var receiver: SACUserType
    
}
