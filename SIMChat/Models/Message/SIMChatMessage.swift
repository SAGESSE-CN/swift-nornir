//
//  SIMChatMessage.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 消息模型
class SIMChatMessage: NSObject {
    
    convenience init(_ content: AnyObject) {
        self.init()
        self.content = content
    }
    
    /// 消息
    lazy var identifier = NSUUID().UUIDString
    
    /// 发送者, 如果发送者为空, 视为系统消息
    var sender: SIMChatUser?                              // 为nil, 自动隐藏名字
    var sentTime: NSDate = .zero                          // 为0
    /// 消息发送状态. Warning: 尽量不要去修改他
    var sentStatus: SIMChatMessageSentStatus = .Unknow
    
    /// 接收者, 如果接收者为空, 视为广播信息
    var recver: SIMChatUser?
    var recvTime: NSDate = .zero
    /// 消息接收状态. Warning: 尽量不要去修改他
    var recvStatus: SIMChatMessageRecvStatus = .Unknow
    
    /// 内容
    var extra: AnyObject?
    var content: AnyObject?
    
    /// 其他配置
    var mute = false            // 静音
    var hidden = false          // 透明消息
    var hiddenName = false      // 隐藏名字
    
    /// 辅助信息
    var height = CGFloat(0)     // 为0表示需要计算
}

// MARK: - Sent Status
enum SIMChatMessageSentStatus {
    case Unknow     /// 未知
    case Sending    /// 发送中
    case Failed     /// 发送失败
    case Sent       /// 己发送
    case Received   /// 对方己接收
    case Read       /// 对方己读
    case Destroyed  /// 对方己销毁
}

// MARK: - Reveice Status
enum SIMChatMessageRecvStatus {
    case Unknow      /// 未知
    case Unread      /// 未读
    case Downloading /// 接收中
    case Downloaded  /// 己下载
    case Failed      /// 接收失败
    case Read        /// 己读
    case Listened    /// 未读
}

// MARK: - Time
extension SIMChatMessage {
    
    /// 生成时间
    func makeDateWithMessage(m: SIMChatMessage) {
        
        self.sender = nil
        self.sentTime = m.sentTime
        self.sentStatus = .Unknow
        
        self.recver = nil
        self.recvTime = m.recvTime
        self.recvStatus = .Unknow
        
        self.extra = nil
        self.content = SIMChatMessageContentDate(date: self.recvTime)
        
        self.mute = true
        self.hidden = false
        self.hiddenName = true
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
