//
//  SIMChatMessageCellProtocol.swift
//  SIMChat
//
//  Created by sagesse on 1/17/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation

///
/// 抽象的聊天显示协议.
///
public protocol SIMChatMessageCellProtocol: class {
    ///
    /// 关联的消息
    ///
    var message: SIMChatMessageProtocol? { set get }
    ///
    /// 关联的会话.
    ///
    var conversation: SIMChatConversationProtocol? { set get }
    
    ///
    /// 关联的事件
    ///
    weak var eventDelegate: SIMChatCellEventDelegate? { set get }
}

///
/// 事件代理
///
public protocol SIMChatCellEventDelegate: class {
    
    // TODO: 这设计存在不合理的地方, 需要重新设计
    
    /// 回复用户
    func cellEvent(cell: SIMChatMessageCellProtocol, replyUser user: SIMChatUserProtocol)
    /// 显示用户信息
    func cellEvent(cell: SIMChatMessageCellProtocol, showProfile user: SIMChatUserProtocol)
    
    /// 复制消息
    func cellEvent(cell: SIMChatMessageCellProtocol, copyMessage message: SIMChatMessageProtocol)
    /// 删除消息
    func cellEvent(cell: SIMChatMessageCellProtocol, removeMessage message: SIMChatMessageProtocol)
    /// 撤回消息(未支持)
    //func cellEvent(cell: SIMChatMessageCellProtocol, revocationMessage message: SIMChatMessageProtocol)
    
    /// 点击消息
    func cellEvent(cell: SIMChatMessageCellProtocol, clickMessage message: SIMChatMessageProtocol)
    /// 重试(发送/上传/下载)
    func cellEvent(cell: SIMChatMessageCellProtocol, retryMessage message: SIMChatMessageProtocol)
}