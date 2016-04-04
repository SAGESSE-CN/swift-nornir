//
//  SIMChatBaseMessage.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import Foundation

///
/// 聊天消息
///
public class SIMChatBaseMessage: SIMChatMessage {
    ///
    /// 初始化
    ///
    /// - parameter content:    消息内容
    /// - parameter sender:     发送者信息
    /// - parameter receiver:   接收者信息
    /// - parameter identifier: 唯一标识符
    ///
    public required init(
        content: SIMChatMessageBody,
        receiver: SIMChatUserProtocol,
        sender: SIMChatUserProtocol,
        identifier: String = NSUUID().UUIDString) {
            self.sender = sender
            self.receiver = receiver
            self.content = content
            self.identifier = identifier
    }
    ///
    /// 消息ID(唯一标识符).
    ///
    public var identifier: String
    ///
    /// 发送者信息
    ///
    public var sender: SIMChatUserProtocol
    ///
    /// 接收者信息
    ///
    public var receiver: SIMChatUserProtocol
    ///
    /// 消息内容
    ///
    public var content: SIMChatMessageBody
    
    ///
    /// 消息发生时间(发送/接收)
    ///
    public lazy var timestamp: NSDate = NSDate()
    ///
    /// 消息是否是自己发送的
    ///
    public lazy var isSelf: Bool = true
    ///
    /// 消息状态(发送/接收)
    ///
    public lazy var status: SIMChatMessageStatus = .Unknow
    ///
    /// 消息的一些选项, 默认None
    ///
    public lazy var option: SIMChatMessageOption = [.None]
    
    ///
    /// 创建一个新的消息
    ///
    /// - parameter content:    消息内容
    /// - parameter identifier: 唯一标识符
    /// - parameter receiver:   接收者信息
    /// - parameter sender:     发送者信息
    /// - returns:  消息
    ///
    public class func messageWithContent(
        content: SIMChatMessageBody,
        receiver: SIMChatUserProtocol,
        sender: SIMChatUserProtocol,
        identifier: String) -> SIMChatMessage {
            return self.init(
                content: content,
                receiver: receiver,
                sender: sender,
                identifier: identifier)
    }
}