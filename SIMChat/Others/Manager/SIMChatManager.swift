//
//  SIMChatManager.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 消息管理
///
class SIMChatManager: NSObject {
    
    /// 用户管理
    lazy var userManager = SIMChatUser2Manager.sharedManager
    /// 所有的会话缓存
    lazy var allConversations = Dictionary<String, SIMChatConversation>()
    
    /// 当前登录的用户
    var user: SIMChatUser2!
    
    /// 单例
    static let sharedManager = SIMChatManager()
}

// MARK: - User
extension SIMChatManager {
    ///
    /// 登入
    ///
    func login(user: SIMChatUser2, finish: (NSError? -> Void)?) {
        // 成功
        self.user = user
        self.userManager[user.identifier] = user
        // 回调
        finish?(nil)
    }
    ///
    /// 登出
    ///
    func logout(finish: (NSError? -> Void)?) {
        // 成功
        self.user = nil
        
        self.allConversations.removeAll()
        
        // 回调
        finish?(nil)
    }
}

// MARK: - Message
extension SIMChatManager {
    /// 发送消息
    func sendMessage(message: SIMChatMessage, finish: (Void -> Void)?, fail: (NSError -> Void)?) {
        // 发送成功
        // 发送失败
        SIMLog.debug()
    }
    /// 删除消息
    func removeMessage(message: SIMChatMessage,  finish: (Void -> Void)?, fail: (NSError -> Void)?) {
        SIMLog.debug()
    }
    /// 更新消息
    func updateMessage(message: SIMChatMessage,  finish: (Void -> Void)?, fail: (NSError -> Void)?) {
        SIMLog.debug()
    }
    /// 查询消息
    func queryMessages(count: Int, last: SIMChatMessage?, finish: ([SIMChatMessage] -> Void)?, fail: (NSError -> Void)?) {
        SIMLog.debug()
    }
}

// MARK: - Conversation
extension SIMChatManager {
    ///
    /// 获取会话, 如果不存在创建
    /// :param: recver 接收者
    ///
    func conversationWithRecver(recver: SIMChatUser2) -> SIMChatConversation {
        // 己经创建
        if let cv = self.allConversations[recver.identifier] {
            return cv
        }
        // 创建, 可能需要由子类创建
        let cv = self.conversationOfMake(recver)
        // 配置
        cv.manager = self
        // 缓存起来
        self.allConversations[recver.identifier] = cv
        // ok
        return cv
    }
    ///
    /// 获取会话, 如果不存在创建
    ///
    /// :param: identifier 接收者标识符
    ///
    func conversationWithIdentifier(identifier: String) -> SIMChatConversation {
        return self.conversationWithRecver(self.userManager[identifier])
    }
    ///
    /// 删除会话
    ///
    /// :param: recver 删除和接收者相关的会话
    ///
    func conversationOfRemove(recver: SIMChatUser2) {
        self.allConversations.removeValueForKey(recver.identifier)
    }
    ///
    /// 会放数量
    ///
    func conversationOfCount() -> Int {
        return self.allConversations.count
    }
    ///
    /// 创建会话
    /// :param: recver 接收者
    ///
    func conversationOfMake(recver: SIMChatUser2) -> SIMChatConversation {
        return SIMChatConversation(recver: recver, manager: self)
    }
}
