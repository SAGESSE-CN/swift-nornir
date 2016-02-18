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
    /// 关联的管理器
    ///
    weak var manager: SIMChatManagerProtocol? { get }
    ///
    /// 关联的会话.
    ///
    weak var conversation: SIMChatConversationProtocol? { set get }
    
    ///
    /// 代理
    ///
    weak var delegate: protocol<SIMChatMessageCellDelegate, SIMChatMessageCellMenuDelegate>? { set get }
}

extension SIMChatMessageCellProtocol {
    ///
    /// 关联的管理器
    ///
    public weak var manager: SIMChatManagerProtocol? { return conversation?.manager }
}

///
/// 事件代理
///
public protocol SIMChatMessageCellDelegate: class {
    
    // 点击消息
    func cellEvent(cell: SIMChatMessageCellProtocol, shouldPressMessage message: SIMChatMessageProtocol) -> Bool
    func cellEvent(cell: SIMChatMessageCellProtocol, didPressMessage message: SIMChatMessageProtocol)
    
    // 长按消息
    func cellEvent(cell: SIMChatMessageCellProtocol, shouldLongPressMessage message: SIMChatMessageProtocol) -> Bool
    func cellEvent(cell: SIMChatMessageCellProtocol, didLongPressMessage message: SIMChatMessageProtocol)
    
    // 点击用户
    func cellEvent(cell: SIMChatMessageCellProtocol, shouldPressUser user: SIMChatUserProtocol) -> Bool
    func cellEvent(cell: SIMChatMessageCellProtocol, didPressUser user: SIMChatUserProtocol)
    
    // 长按用户
    func cellEvent(cell: SIMChatMessageCellProtocol, shouldLongPressUser user: SIMChatUserProtocol) -> Bool
    func cellEvent(cell: SIMChatMessageCellProtocol, didLongPressUser user: SIMChatUserProtocol)
}

///
/// 菜单代理
///
public protocol SIMChatMessageCellMenuDelegate: class {
    
    // 复制
    func cellMenu(cell: SIMChatMessageCellProtocol, shouldCopyMessage message: SIMChatMessageProtocol) -> Bool
    func cellMenu(cell: SIMChatMessageCellProtocol, didCopyMessage message: SIMChatMessageProtocol)
    
    // 删除
    func cellMenu(cell: SIMChatMessageCellProtocol, shouldRemoveMessage message: SIMChatMessageProtocol) -> Bool
    func cellMenu(cell: SIMChatMessageCellProtocol, didRemoveMessage message: SIMChatMessageProtocol)
    
    /// 重试(发送/上传/下载)
    func cellMenu(cell: SIMChatMessageCellProtocol, shouldRetryMessage message: SIMChatMessageProtocol) -> Bool
    func cellMenu(cell: SIMChatMessageCellProtocol, didRetryMessage message: SIMChatMessageProtocol)
    
    // 撤销
    func cellMenu(cell: SIMChatMessageCellProtocol, shouldRevokeMessage message: SIMChatMessageProtocol) -> Bool
    func cellMenu(cell: SIMChatMessageCellProtocol, didRevokeMessage message: SIMChatMessageProtocol)
}

