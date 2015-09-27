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
    /// 当前登录的用户
    var user: SIMChatUser?
    
    /// 用户管理
    lazy var userManager = SIMChatUserManager.sharedManager
    /// 所有的会话缓存
    lazy var allConversations = Dictionary<String, SIMChatConversation>()
    
    /// 单例
    static let sharedManager = SIMChatManager()
}

// MARK: - User
extension SIMChatManager {
    ///
    /// 登入
    ///
    func login(user: SIMChatUser, finish: (NSError? -> Void)?) {
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

// MARK: - Conversation
extension SIMChatManager {
    ///
    /// 获取会话, 如果不存在创建
    ///
    /// :param: recver 接收者
    ///
    func conversationWithRecver(recver: SIMChatUser) -> SIMChatConversation {
        // 己经创建
        if let cv = self.allConversations[recver.identifier] {
            return cv
        }
        // 创建
        let cv = SIMChatConversation(recver: recver, sender: user!)
        // 缓存起来
        self.allConversations[recver.identifier] = cv
        // ok
        return cv
    }
    ///
    /// 获取会话, 如果不存在创建
    ///
    /// :param: recver 接收者
    ///
    func conversationWithRecverId(identifier: String) -> SIMChatConversation {
        return self.conversationWithRecver(self.userManager[identifier])
    }
    ///
    /// 删除会话
    ///
    /// :param: recver 删除和接收者相关的会话
    ///
    func conversationOfRemove(recver: SIMChatUser) {
        self.allConversations.removeValueForKey(recver.identifier)
    }
    ///
    /// 会放数量
    ///
    func conversationOfCount() -> Int {
        return self.allConversations.count
    }
}
