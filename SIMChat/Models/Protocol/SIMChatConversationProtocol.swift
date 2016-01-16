//
//  SIMChatConversationProtocol.swift
//  SIMChat
//
//  Created by sagesse on 10/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import Foundation

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
    var sender: SIMChatUserProtocol? { get }
    
    // MARK: Util
    
    ///
    /// 最新的一条消息, 如果为nil则没有
    ///
    var latest: SIMChatMessageProtocol? { get }
    ///
    /// 未读消息数量, 为0则没有
    ///
    var unreadCount: Int { get }
    
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
    /// - returns: 返回结果是Array<SIMChatMessageProtocol>
    ///
    func loadHistoryMessages(last: SIMChatMessageProtocol?, count: Int) -> SIMChatRequest<Array<SIMChatMessageProtocol>>
    ///
    /// 发送消息
    ///
    /// - parameter message: 需要发送的消息
    /// - parameter isResend: 是否是重发消息
    /// - returns: 返回结果是SIMChatMessageProtocol
    ///
    func sendMessage(message: SIMChatMessageProtocol, isResend: Bool) -> SIMChatRequest<SIMChatMessageProtocol>
    ///
    /// 发送消息状态
    ///
    /// - parameter message: 需要发送的消息(包含己修改的信息)
    /// - returns: 返回结果是SIMChatMessageProtocol
    ///
    func sendMessageState(message: SIMChatMessageProtocol) -> SIMChatRequest<SIMChatMessageProtocol>
    ///
    /// 删除消息
    ///
    /// - parameter message: 需要删除的消息
    /// - returns: 返回结果是Void
    ///
    func removeMessage(message: SIMChatMessageProtocol) -> SIMChatRequest<Void>
    
    // MARK: Message Of Remote
    
    ///
    /// 服务端要求更新消息(被动)
    ///
    /// - parameter message: 被操作的消息
    ///
    func updateMessageFromRemote(messsage: SIMChatMessageProtocol)
    ///
    /// 接收到来自服务端的消息(被动)
    ///
    /// - parameter message: 被操作的消息
    ///
    func receiveMessageFromRemote(messsage: SIMChatMessageProtocol)
    ///
    /// 服务端要求更删除消息(被动)
    ///
    /// - parameter message: 被操作的消息
    ///
    func removeMessageFromRemote(messsage: SIMChatMessageProtocol)
    
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
    /// - returns: 返回结果是Array<SIMChatMessageProtocol>
    ///
    public func loadHistoryMessages(count: Int) -> SIMChatRequest<Array<SIMChatMessageProtocol>> {
        return loadHistoryMessages(nil, count: count)
    }
    ///
    /// 发送消息
    ///
    /// - parameter message: 需要发送的消息
    /// - returns: 返回结果是SIMChatMessageProtocol
    ///
    public func sendMessage(message: SIMChatMessageProtocol) -> SIMChatRequest<SIMChatMessageProtocol> {
        return sendMessage(message, isResend: false)
    }
}

/// 代理
public protocol SIMChatConversationDelegate: class {
}

extension SIMChatConversationDelegate {
    ///
    /// 新消息通知
    ///
    /// - parameter conversation: 发生事件的会话
    /// - parameter message: 接收到的消息
    ///
    public func conversation(
        conversation: SIMChatConversationProtocol,
        didReciveMessage message: SIMChatMessageProtocol) {
            // not implemented
    }
    ///
    /// 删除消息通知
    ///
    /// - parameter conversation: 发生事件的会话
    /// - parameter message: 接收到的消息
    ///
    public func conversation(
        conversation: SIMChatConversationProtocol,
        didRemoveMessage message: SIMChatMessageProtocol) {
            // not implemented
    }
    ///
    /// 更新消息通知
    ///
    /// - parameter conversation: 发生事件的会话
    /// - parameter message: 接收到的消息
    ///
    public func conversation(
        conversation: SIMChatConversationProtocol,
        didUpdateMessage message: SIMChatMessageProtocol) {
            // not implemented
    }
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
