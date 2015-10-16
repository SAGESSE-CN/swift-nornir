//
//  SDChatManager.swift
//  SIMChat
//
//  Created by sagesse on 10/4/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// SIM Demo Chat Manager
class SDChatManager: SIMChatManager {
    
}

// MARK: - Conversation
extension SDChatManager {
    ///
    /// 获取会话, 如果不存在创建
    ///
    /// :param: recver 接收者
    ///
    override func conversationWithRecver(recver: SIMChatUser2) -> SDChatConversation {
        return super.conversationWithRecver(recver) as! SDChatConversation
    }
    ///
    /// 获取会话, 如果不存在创建
    ///
    /// :param: recver 接收者
    ///
    override func conversationWithIdentifier(identifier: String) -> SDChatConversation {
        return super.conversationWithIdentifier(identifier) as! SDChatConversation
    }
    ///
    /// 创建会话
    /// :param: recver 接收者
    ///
    override func conversationOfMake(recver: SIMChatUser2) -> SDChatConversation {
        return SDChatConversation(recver: recver, manager: self)
    }
}