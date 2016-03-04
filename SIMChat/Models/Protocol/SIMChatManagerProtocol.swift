//
//  SIMChatManagerProtocol.swift
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
public protocol SIMChatManagerProtocol: class {
    
    // MARK: User Info
    
    ///
    /// 当前登录的用户.
    ///
    var user: SIMChatUserProtocol? { get }
    
    // MARK: Provider
    
    ///
    /// 用户信息提供者
    ///
    var userProvider: SIMChatUserProvider { get }
    ///
    /// 类提供者, 用户可以在这里修改所有使用的实际类型
    ///
    var classProvider: SIMChatClassProvider { get }
    
    ///
    /// 媒体播放提供者
    ///
    var mediaProvider: SIMChatMediaProvider { get }
    
    // MARK: User Method
    
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
    
    // MARK: Conversation Method
    
    ///
    /// 所有的会话
    ///
    func allConversations() -> Array<SIMChatConversationProtocol>
    ///
    /// 获取一个会话/创建一个会话
    ///
    /// - parameter receiver: 接收者信息
    /// - returns: 会话信息
    ///
    func conversation(receiver: SIMChatUserProtocol) -> SIMChatConversationProtocol
    ///
    /// 删除会话
    ///
    /// - parameter receiver: 被删除会放的接收者信息
    ///
    func removeConversationWithReceiver(receiver: SIMChatUserProtocol)
}
