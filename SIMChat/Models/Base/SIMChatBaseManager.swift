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
public class SIMChatBaseManager: SIMChatManagerProtocol {
    
    /// 当前登录的用户.
    public var user: SIMChatUserProtocol?
    
    /// 用户信息提供者
    public lazy var userProvider: SIMChatUserProvider =  SIMChatUserProvider(self)
    
    /// 文件提供者
    public lazy var fileProvider: SIMChatFileProvider = SIMChatFileProvider()
    /// 类提供者, 用户可以在这里修改所有使用的实际类型
    public lazy var classProvider: SIMChatClassProvider = SIMChatClassProvider()
    
    /// 所有的会话.
    private lazy var conversations: Dictionary<String, SIMChatConversationProtocol> = [:]
}

// MARK: - User Login & Logout

extension SIMChatBaseManager {
    ///
    /// 登录用户
    ///
    /// - parameter user: 用户信息
    /// - return: 请求
    ///
    public func login(user: SIMChatUserProtocol) -> SIMChatRequest<Void> {
        SIMLog.trace()
        
        return SIMChatRequest.request {
            self.user = user
            $0.success()
        }
    }
    ///
    /// 登录用户
    ///
    /// - parameter user: 用户信息
    /// - return: 请求
    ///
    public func logout() -> SIMChatRequest<Void> {
        SIMLog.trace()
        
        return SIMChatRequest.request {
            self.user = nil
            $0.success()
        }
    }
}

// MARK: - Conversation Method

extension SIMChatBaseManager {
    ///
    /// 所有的会话
    ///
    public func allConversations() -> Array<SIMChatConversationProtocol> {
        SIMLog.trace()
        
        return Array(conversations.values)
    }
    ///
    /// 获取一个会话/创建一个会话
    ///
    /// - parameter receiver: 接收者信息
    /// - returns: 会话信息
    ///
    public func conversation(receiver: SIMChatUserProtocol) -> SIMChatConversationProtocol {
        SIMLog.trace()
        
        return conversations[receiver.identifier] ?? {
            let conversation = classProvider.conversation.conversation(receiver, manager: self)
            conversations[receiver.identifier] = conversation
            return conversation
        }()
    }
    ///
    /// 删除会话
    ///
    /// - parameter receiver: 被删除会放的接收者信息
    ///
    public func removeConversationWithReceiver(receiver: SIMChatUserProtocol) {
        SIMLog.trace()
        
        if let index = conversations.indexOf({ receiver == $1.receiver }) {
            conversations.removeAtIndex(index)
        }
    }
}

