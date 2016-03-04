//
//  SIMChatConversationProtocol.swift
//  SIMChat
//
//  Created by sagesse on 10/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import Foundation

/// 消息处理者
public typealias SIMChatMessageHandler = SIMChatResult<SIMChatMessageProtocol, NSError> -> Void
public typealias SIMChatMessagesHandler = SIMChatResult<Array<SIMChatMessageProtocol>, NSError> -> Void

///
/// 抽象的聊天会话协议.
///
public protocol SIMChatConversationProtocol: class {
    
    // MARK: User Info
    
    ///
    /// 接收者信息
    ///
    var receiver: SIMChatUserProtocol { get }
    ///
    /// 发送都信息
    ///
    var sender: SIMChatUserProtocol { get }
    
    // MARK: Util
    
    ///
    /// 最新的一条消息, 如果为nil则没有
    ///
    var latest: SIMChatMessageProtocol? { get }
    ///
    /// 未读消息数量, 为0则没有
    ///
    var unreadCount: Int { get }
    ///
    /// 所有消息都己经加载
    ///
    var allMessagesIsLoaded: Bool { get }
    
    // MARK: Other
    
    ///
    /// 管理器
    ///
    weak var manager: SIMChatManagerProtocol? { get }
    ///
    /// 远程消息代理
    ///
    weak var delegate: SIMChatConversationDelegate? { set get }
    
    // MARK: Message
    
    ///
    /// 加载(历史)消息
    ///
    /// - parameter last: 最后一条消息, 如果为nil则没有
    /// - parameter count: 容量
    /// - parameter closure: 执行结果
    ///
    func loadHistoryMessages(last: SIMChatMessageProtocol?, count: Int, closure: SIMChatMessagesHandler?)
    ///
    /// 更新消息状态
    ///
    /// - parameter message: 需要发送的消息
    /// - parameter status:  新的状态, 一般检查该状态来决定是否需要访问网络
    /// - parameter closure: 执行结果
    ///
    func updateMessage(message: SIMChatMessageProtocol, status: SIMChatMessageStatus, closure: SIMChatMessageHandler?)
    ///
    /// 发送消息
    ///
    /// - parameter message: 需要发送的消息
    /// - parameter isResend: 是否是重发消息
    /// - parameter closure: 执行结果
    ///
    func sendMessage(message: SIMChatMessageProtocol, isResend: Bool, closure: SIMChatMessageHandler?)
    ///
    /// 删除消息
    ///
    /// - parameter message: 需要删除的消息
    /// - parameter closure: 执行结果
    ///
    func removeMessage(message: SIMChatMessageProtocol, closure: SIMChatMessageHandler?)
    
    // MARK: Message Of Remote
    
    ///
    /// 服务端要求更新消息(被动)
    ///
    /// - parameter message: 被操作的消息
    ///
    func updateMessageFromRemote(message: SIMChatMessageProtocol)
    ///
    /// 接收到来自服务端的消息(被动)
    ///
    /// - parameter message: 被操作的消息
    ///
    func receiveMessageFromRemote(message: SIMChatMessageProtocol)
    ///
    /// 服务端要求更删除消息(被动)
    ///
    /// - parameter message: 被操作的消息
    ///
    func removeMessageFromRemote(message: SIMChatMessageProtocol)
    
    // MARK: Generate
    
    ///
    /// 创建一个新的会话
    ///
    /// - parameter receiver: 会话的接收者
    ///
    static func conversation(receiver: SIMChatUserProtocol, manager: SIMChatManagerProtocol) -> SIMChatConversationProtocol
}

// MARK: - Convenience

extension SIMChatConversationProtocol {
    ///
    /// 会话类型, 默认值由receiver指定
    ///
    public var type: SIMChatConversationType {
        switch receiver.type {
        case .User:     return .C2C
        case .System:   return .C2C
        case .Group:    return .Group
        }
    }
    ///
    /// 加载(历史)消息
    ///
    /// - parameter last: 最后一条消息, 如果为nil则没有
    /// - parameter count: 容量
    /// - parameter closure: 执行结果
    ///
    public func loadHistoryMessages(count: Int, closure: SIMChatMessagesHandler?) {
        loadHistoryMessages(nil, count: count, closure: closure)
    }
    ///
    /// 发送消息
    ///
    /// - parameter message: 需要发送的消息
    /// - parameter closure: 执行结果
    ///
    public func sendMessage(message: SIMChatMessageProtocol, closure: SIMChatMessageHandler?) {
        sendMessage(message, isResend: false, closure: closure)
    }
}

/// 代理
public protocol SIMChatConversationDelegate: class {
    ///
    /// 新消息通知
    ///
    /// - parameter conversation: 发生事件的会话
    /// - parameter message: 接收到的消息
    ///
    func conversation(conversation: SIMChatConversationProtocol, didReciveMessage message: SIMChatMessageProtocol)
    ///
    /// 删除消息通知
    ///
    /// - parameter conversation: 发生事件的会话
    /// - parameter message: 接收到的消息
    ///
    func conversation(conversation: SIMChatConversationProtocol, didRemoveMessage message: SIMChatMessageProtocol)
    ///
    /// 更新消息通知
    ///
    /// - parameter conversation: 发生事件的会话
    /// - parameter message: 接收到的消息
    ///
    func conversation(conversation: SIMChatConversationProtocol, didUpdateMessage message: SIMChatMessageProtocol)
}

///
/// 会话类型
///
public enum SIMChatConversationType: Int {
    case C2C
    case Group
}

// MARK: - User compare

public func !=(lhs: SIMChatConversationProtocol, rhs: SIMChatConversationProtocol?) -> Bool {
    return !(lhs == rhs)
}
public func ==(lhs: SIMChatConversationProtocol, rhs: SIMChatConversationProtocol?) -> Bool {
    return lhs.receiver == rhs?.receiver
}
