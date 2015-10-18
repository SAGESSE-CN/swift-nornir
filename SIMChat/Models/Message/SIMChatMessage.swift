//
//  SIMChatMessage.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// Message Module
class SIMChatMessage: NSObject {
    /// 初始化
    convenience init(_ content: AnyObject) {
        self.init()
        self.content = content
    }
    /// 消息
    lazy var identifier = NSUUID().UUIDString
    
    /// 发送者, 如果发送者为空, 视为广播信息 \
    /// 为nil自动隐藏名字
    var sender: SIMChatUserProtocol?
    var sentTime: NSDate = .zero
    
    /// 接收者, 如果接收者为空, 视为广播信息
    var receiver: SIMChatUserProtocol?
    var receiveTime: NSDate = .zero
    
    /// 内容
    var extra: AnyObject?
    var status: SIMChatMessageStatus = .Unknow
    var content: AnyObject?
    
    /// 其他配置
    var mute = false            // 静音
    var hidden = false          // 透明消息
    
    /// 这是自己发送的消息?
    var owns: Bool = false
    /// 是否需要隐藏名片服务? \
    /// 为nil则自动根据环境选择
    var hiddenContact: Bool?
    
    /// 消息的高度 \
    /// 为0表示需要计算
    var height = CGFloat(0)
}

/// Message Status
enum SIMChatMessageStatus {
    /// SR: 未知
    case Unknow
    /// S: 正在发送中 \
    /// R: 对方正在发送中(错误)
    case Sending
    /// S: 己发送 \
    /// R: 错误
    case Sent
    /// S: 对方未读 \
    /// R: 消息未读
    case Unread
    /// S: 对方正在接收中, 包含未读, (图片/音频/视频) \
    /// R: 消息接收中, 包含未读, (图片/音频/视频)
    case Receiving
    /// S: 对方己接收, 包含未读 \
    /// R: 消息己接收, 包含未读
    case Received
    /// S: 对方己读 \
    /// R: 消息己读
    case Read
    /// S: 对方己播放(音频消息), 包含己读 \
    /// R: 消息己播放(音频消息), 包含己读
    case Played
    /// S: 对方己销毁, 包含己读/己播放 \
    /// R: 消息己销毁, 包含己读/己播放
    case Destroyed
    /// S: 发送错误(图片/音频/视频) \
    /// R: 接收错误(图片/音频/视频)
    case Error
}

// MARK: - Time
extension SIMChatMessage {
    
    /// 生成时间
    func makeDateWithMessage(m: SIMChatMessage) {
        
        self.sender = nil
        self.sentTime = m.sentTime
        
        self.receiver = nil
        self.receiveTime = m.receiveTime
        
        self.status = .Read
        
        self.extra = nil
        self.content = SIMChatMessageContentDate(date: self.receiveTime)
        
        self.mute = true
        self.hidden = false
        self.hiddenContact = nil
        self.height = 0
    }
}

// MARK: - Events
extension SIMChatMessage {
    /// 消息状态改变
    func statusChanged() {
        SIMChatNotificationCenter.postNotificationName(SIMChatMessageStatusChangedNotification, object: self)
    }
}

///
/// 操作符重载
///
func ==(lhs: SIMChatMessage?, rhs: SIMChatMessage?) -> Bool {
    return lhs === rhs || lhs?.identifier == rhs?.identifier
}

/// 消息状态改变通告
let SIMChatMessageStatusChangedNotification = "SIMChatMessageStatusChangedNotification"
