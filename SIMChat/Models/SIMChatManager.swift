//
//  SIMChatManager.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SIMChatManager: NSObject {
    
    /// 当前用户
    var user: SIMChatUser?
    
    /// 所有的用户信息缓存
    var users = [String : SIMChatUser]()
    var groups = [String : SIMChatGroup]()
    
    /// 所有的会话缓存
    var conversations = [String : SIMChatConversation]()
}

/// MARK: - /// User
extension SIMChatManager {
    
    ///
    /// 登入
    ///
    func login(user: SIMChatUser, finish: (NSError? -> Void)?) {
        // 成功
        self.user = user
        self.users[user.identifier] = user
        // 回调
        finish?(nil)
    }
    
    ///
    /// 登出
    ///
    func logout(finish: (NSError? -> Void)?) {
        // 成功
        self.user = nil
        self.users.removeAll(keepCapacity: false)
        self.groups.removeAll(keepCapacity: false)
        self.conversations.removeAll(keepCapacity: false)
        // 回调
        finish?(nil)
    }
    
    ///
    /// 用户
    ///
    func user(userId identifier: String) -> SIMChatUser {
        
        if let u = self.users[identifier] {
            return u
        }
        
        let u = SIMChatUser(identifier: identifier)
        
        self.users[identifier] = u
        
        self.query(userInfo: u) { [weak self](nu, e) in
            if let nu = nu {
                // 更新。。
                self?.updateUserInfo(nu)
            } else {
                // 失败删除 
                self?.users.removeValueForKey(identifier)
            }
        }
        
        return u
    }
    
    ///
    /// 群组
    ///
    func group(groupId id: String) -> SIMChatGroup {
        
        if let u = self.groups[id] {
            return u
        }
        
        let u = SIMChatGroup(identifier: id)
        
        self.groups[id] = u
        
        return u
    }
    
    ///
    /// 查询用户信息
    ///
    func query(userInfo user: SIMChatUser, finish: ((SIMChatUser?, NSError?) -> Void)?) {
        // nothing
    }
    
    ///
    /// 更新用户信息
    ///
    func updateUserInfo(user: SIMChatUser) {
        
        let u = self.users[user.identifier]
        
        // 成功， 更新
        u?.identifier = user.identifier
        u?.name = user.name
        u?.portrait = user.portrait
        u?.extra = user.extra
        
        self.users[user.identifier] = user
        
//        // 生成全局通知
//        NSNotificationCenter.simInternalCenter().postNotificationName(SIMChatUserInfoDidUpdateNotification, object: user)
    }
}

/// MARK: - /// Conversation
extension SIMChatManager {
    
    ///
    /// 获取会话, 如果不存在创建
    ///
    /// :param: recver 接收者
    ///
    func conversationWithRecver(recver: SIMChatUser) -> SIMChatConversation? {
        return self.conversations[recver.identifier]
    }
    
    ///
    /// 获取会话
    ///
    func conversationAtIndex(index: Int) -> SIMChatConversation? {
        return nil
    }
    
    ///
    /// 删除会话
    ///
    /// :param: recver 删除和接收者相关的会话
    ///
    func conversationOfRemove(recver: SIMChatUser) {
        self.conversations.removeValueForKey(recver.identifier)
    }
    
    ///
    /// 会放数量
    ///
    func conversationOfCount() -> Int {
        return 0
    }
}
