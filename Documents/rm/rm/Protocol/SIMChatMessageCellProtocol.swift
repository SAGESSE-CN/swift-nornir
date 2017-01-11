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
    /// 关联的模型
    ///
    var model: SIMChatMessage? { set get }
    
    ///
    /// 关联的管理器
    ///
    weak var manager: SIMChatManager? { get }
    ///
    /// 关联的会话.
    ///
    weak var conversation: SIMChatConversation? { set get }
    
    ///
    /// 代理
    ///
    weak var delegate: (SIMChatMessageCellDelegate & SIMChatMessageCellMenuDelegate)? { set get }
}

extension SIMChatMessageCellProtocol {
    ///
    /// 关联的管理器
    ///
    public weak var manager: SIMChatManager? { return conversation?.manager }
}

///
/// 事件代理
///
public protocol SIMChatMessageCellDelegate: class {
    
    // 点击消息
    func cellEvent(_ cell: SIMChatMessageCellProtocol, shouldPressMessage message: SIMChatMessage) -> Bool
    func cellEvent(_ cell: SIMChatMessageCellProtocol, didPressMessage message: SIMChatMessage)
    
    // 长按消息
    func cellEvent(_ cell: SIMChatMessageCellProtocol, shouldLongPressMessage message: SIMChatMessage) -> Bool
    func cellEvent(_ cell: SIMChatMessageCellProtocol, didLongPressMessage message: SIMChatMessage)
    
    // 点击用户
    func cellEvent(_ cell: SIMChatMessageCellProtocol, shouldPressUser user: SIMChatUserProtocol) -> Bool
    func cellEvent(_ cell: SIMChatMessageCellProtocol, didPressUser user: SIMChatUserProtocol)
    
    // 长按用户
    func cellEvent(_ cell: SIMChatMessageCellProtocol, shouldLongPressUser user: SIMChatUserProtocol) -> Bool
    func cellEvent(_ cell: SIMChatMessageCellProtocol, didLongPressUser user: SIMChatUserProtocol)
}

///
/// 菜单代理
///
public protocol SIMChatMessageCellMenuDelegate: class {
    
    // 复制
    func cellMenu(_ cell: SIMChatMessageCellProtocol, shouldCopyMessage message: SIMChatMessage) -> Bool
    func cellMenu(_ cell: SIMChatMessageCellProtocol, didCopyMessage message: SIMChatMessage)
    
    // 删除
    func cellMenu(_ cell: SIMChatMessageCellProtocol, shouldRemoveMessage message: SIMChatMessage) -> Bool
    func cellMenu(_ cell: SIMChatMessageCellProtocol, didRemoveMessage message: SIMChatMessage)
    
    /// 重试(发送/上传/下载)
    func cellMenu(_ cell: SIMChatMessageCellProtocol, shouldRetryMessage message: SIMChatMessage) -> Bool
    func cellMenu(_ cell: SIMChatMessageCellProtocol, didRetryMessage message: SIMChatMessage)
    
    // 撤销
    func cellMenu(_ cell: SIMChatMessageCellProtocol, shouldRevokeMessage message: SIMChatMessage) -> Bool
    func cellMenu(_ cell: SIMChatMessageCellProtocol, didRevokeMessage message: SIMChatMessage)
}

