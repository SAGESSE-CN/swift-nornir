//
//  SIMChatConversationProtocol.swift
//  SIMChat
//
//  Created by sagesse on 10/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 会话接口
@objc protocol SIMChatConversationProtocol {
    ///
    /// 查询消息
    ///
    func queryMessages(total: Int, last: SIMChatMessage?, _ finish: ([SIMChatMessage] -> Void)?, _ fail: SIMChatFailBlock?)
    ///
    /// 发送消息
    ///
    func sendMessage(m: SIMChatMessage, isResend: Bool, _ finish: SIMChatFinishBlock?, _ fail: SIMChatFailBlock?)
    ///
    /// 删除消息
    ///
    func removeMessage(m: SIMChatMessage, _ finish: SIMChatFinishBlock?, _ fail: SIMChatFailBlock?)
    ///
    /// 标记消息为己读
    ///
    func readMessage(m: SIMChatMessage, _ finish: SIMChatFinishBlock?, _ fail: SIMChatFailBlock?)
    ///
    /// 远端获取到了一条消息
    ///
    func reciveMessageForRemote(m: SIMChatMessage)
    ///
    /// 远端要求删除一条消息
    ///
    func removeMessageForRemote(m: SIMChatMessage)
    ///
    /// 远端要求更新一条消息
    ///
    func updateMessageForRemote(m: SIMChatMessage)
    
    /// 发送者
    var sender: SIMChatUserProtocol { get }
    /// 接收者
    var receiver: SIMChatUserProtocol { get }
    
    /// 代理
    weak var delegate: SIMChatConversationDelegate? { set get }
}

/// 代理
@objc protocol SIMChatConversationDelegate : NSObjectProtocol {
    ///
    /// 新消息通知
    ///
    optional func chatConversation(conversation: SIMChatConversationProtocol, didReciveMessage message: SIMChatMessage)
    ///
    /// 删除消息通知
    ///
    optional func chatConversation(conversation: SIMChatConversationProtocol, didRemoveMessage message: SIMChatMessage)
    ///
    /// 更新消息通知
    ///
    optional func chatConversation(conversation: SIMChatConversationProtocol, didUpdateMessage message: SIMChatMessage)
}

@objc enum SIMChatConversationType : Int {
    case C2C
}
