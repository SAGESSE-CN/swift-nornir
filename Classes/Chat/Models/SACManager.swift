//
//  SACManager.swift
//  SAChat
//
//  Created by SAGESSE on 01/11/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

open class SACManager: NSObject {
    
    public init(user: SACUserType) {
        self.user = user
        super.init()
    }
    deinit {
    }
   
    open var user: SACUserType
    
    
    ///
    /// 获取一个会话/创建一个会话
    ///
    /// - parameter receiver: 接收者信息
    /// - returns: 会话信息
    ///
    open func conversation(with receiver: SACUserType) -> SACConversationType {
        return SACConversation(receiver: receiver, sender: user)
    }
    
    
    internal static var mainBundle: Bundle? {
        return _frameworkMainBundle
    }
}

private weak var _frameworkMainBundle: Bundle? = Bundle(identifier: "SA.SAChat")
