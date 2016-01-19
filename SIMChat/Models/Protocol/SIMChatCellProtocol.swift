//
//  SIMChatCellProtocol.swift
//  SIMChat
//
//  Created by sagesse on 1/17/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation

///
/// 抽象的聊天显示协议.
///
public protocol SIMChatCellProtocol: class {
    ///
    /// 关联的消息
    ///
    var message: SIMChatMessageProtocol? { set get }
    ///
    /// 关联的会话.
    ///
    var conversation: SIMChatConversationProtocol? { set get }
}