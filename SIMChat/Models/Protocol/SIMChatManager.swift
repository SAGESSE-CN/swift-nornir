//
//  SIMChatManager.swift
//  SIMChat
//
//  Created by sagesse on 1/15/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation

///
/// 抽象的聊天管理协议.
/// - note: 必须保证使用时的生命周期
///
public protocol SIMChatManager: class {
    
    // MARK: User Info
    
    ///
    /// 登录用户
    ///
    /// - parameter user: 用户信息
    /// - parameter closure: 执行结果
    ///
    func login(user: SIMChatUserProtocol, closure: SIMChatResult<Void, NSError> -> Void)
    ///
    /// 登出用户
    ///
    /// - parameter closure: 执行结果
    ///
    func logout(closure: SIMChatResult<Void, NSError> -> Void)
    
    ///
    /// 获取当前登录的用户
    ///
    var currentUser: SIMChatUserProtocol? { get }
    
    // MARK: Conversation Method
    
    ///
    /// 获取一个会话/创建一个会话
    ///
    /// - parameter receiver: 接收者信息
    /// - returns: 会话信息
    ///
    func conversation(receiver: SIMChatUserProtocol) -> SIMChatConversation
    ///
    /// 获取所有的会话
    ///
    /// - returns: 所有的会话列表
    ///
    func allConversations() -> Array<SIMChatConversation>
    ///
    /// 删除会话
    ///
    /// - parameter receiver: 被删除会放的接收者信息
    ///
    func removeConversation(receiver: SIMChatUserProtocol)
}

///
/// 提供一些默认值
///
extension SIMChatManager {
    ///
    /// 登录用户
    ///
    /// - parameter user: 用户信息
    ///
    public func login(user: SIMChatUserProtocol) {
        return login(user) { _ in }
    }
    ///
    /// 登出用户
    ///
    public func logout() {
        return logout() { _ in }
    }
}