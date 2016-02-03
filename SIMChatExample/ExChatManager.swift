//
//  ExChatManager.swift
//  SIMChatExample
//
//  Created by sagesse on 2/3/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import SIMChat

class ExChatManager: SIMChatBaseManager {
    override init() {
        super.init()
        
        classProvider.conversation = ExChatConversation.self
    }
}

//// MARK: - Conversation
//extension SDChatManager {
//    ///
//    /// 获取会话, 如果不存在创建
//    ///
//    /// :param: recver 接收者
//    ///
//    override func conversationWithRecver(recver: SIMChatUserProtocol) -> SDChatConversation {
//        return super.conversationWithRecver(recver) as! SDChatConversation
//    }
//    ///
//    /// 创建会话
//    /// :param: recver 接收者
//    ///
//    override func conversationOfMake(recver: SIMChatUserProtocol) -> SDChatConversation {
//        return SDChatConversation(receiver: recver, sender: self.currentUser)
//    }
//}