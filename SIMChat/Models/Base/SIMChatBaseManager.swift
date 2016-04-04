//
//  SIMChatBaseManager.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import Foundation

///
/// 管理器
///
public class SIMChatBaseManager: SIMChatManager {
    public init() {}
    
    
    /// 当前登录的用户.
    public var user: SIMChatUserProtocol?
    
    /// 用户信息提供者
    public lazy var userProvider: SIMChatUserProvider =  SIMChatUserProvider(manager: self)
    /// 媒体播放提供者
    public lazy var mediaProvider: SIMChatMediaProvider = SIMChatMediaProvider()
    
    /// 类提供者, 用户可以在这里修改所有使用的实际类型
//    public lazy var classProvider: SIMChatClassProvider = SIMChatClassProvider()
    
    /// 所有的会话.
    public lazy var conversations: Dictionary<String, SIMChatConversation> = [:]
    
    ///
    /// 获取当前登录的用户
    ///
    public var currentUser: SIMChatUserProtocol? {
        return user
    }
    
    // MARK: User Login & Logout
    
    ///
    /// 登录用户
    ///
    /// - parameter user: 用户信息
    /// - parameter closure: 执行结果
    ///
    public func login(user: SIMChatUserProtocol, closure: SIMChatResult<Void, NSError> -> Void) {
        SIMLog.trace()
        
        self.user = user
        closure(.Success())
    }
    ///
    /// 登出用户
    ///
    /// - parameter closure: 执行结果
    ///
    public func logout(closure: SIMChatResult<Void, NSError> -> Void) {
        SIMLog.trace()
        
        self.user = nil
        closure(.Success())
    }
    
    // MARK: - Conversation Method
    
    ///
    /// 所有的会话
    ///
    public func allConversations() -> Array<SIMChatConversation> {
        SIMLog.trace()
        return Array(conversations.values)
    }
    ///
    /// 获取一个会话/创建一个会话
    ///
    /// - parameter receiver: 接收者信息
    /// - returns: 会话信息
    ///
    public func conversation(receiver: SIMChatUserProtocol) -> SIMChatConversation {
        SIMLog.trace()
        return conversations[receiver.identifier] ?? {
            let conversation = SIMChatBaseConversation(receiver: receiver, manager: self)
            conversations[receiver.identifier] = conversation
            return conversation
        }()
    }
    ///
    /// 删除会话
    ///
    /// - parameter receiver: 被删除会放的接收者信息
    ///
    public func removeConversation(receiver: SIMChatUserProtocol) {
        SIMLog.trace()
        if let index = conversations.indexOf({ receiver == $1.receiver }) {
            conversations.removeAtIndex(index)
        }
    }
}

