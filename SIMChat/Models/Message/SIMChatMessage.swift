//
//  SIMChatMessage.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// Message Module
class SIMChatMessage: NSObject, SIMChatMessageProtocol {
    /// 初始化
    override init() {
        self.content = SIMChatMessageContentUnknow()
        super.init()
    }
    /// 初始化
    init(_ content: SIMChatMessageContentProtocol) {
        self.content = content
        super.init()
    }
//    convenience init(_ content: AnyObject) {
//        self.init()
//        self.content = content
//    }
//    /// 消息
//    lazy var identifier = NSUUID().UUIDString
//    
//    /// 发送者, 如果发送者为空, 视为广播信息 \
//    /// 为nil自动隐藏名字
//    var sender: SIMChatUserProtocol?
//    var sentTime: NSDate = .zero
//    
//    /// 接收者, 如果接收者为空, 视为广播信息
//    var receiver: SIMChatUserProtocol?
//    var receiveTime: NSDate = .zero
//    
//    /// 内容
//    var extra: AnyObject?
//    var status: SIMChatMessageStatus = .Unknow
//    var content: AnyObject?
//    
//    /// 其他配置
//    var mute = false            // 静音
//    var hidden = false          // 透明消息
//    
//    /// 这是自己发送的消息?
//    var owns: Bool = false
//    /// 是否需要隐藏名片服务? \
//    /// 为nil则自动根据环境选择
//    var hiddenContact: Bool?
//    
//    /// 消息的高度 \
//    /// 为0表示需要计算
//    var height = CGFloat(0)
//    
    /// 标识符
    var identifier: String = NSUUID().UUIDString
    
    /// 发送者 \
    /// 为nil, 视为广播信息, 自动隐藏名字
    var sender: SIMChatUserProtocol?
    /// 接收者 \
    /// 为nil, 视为广播信息, 自动隐藏名字
    var receiver: SIMChatUserProtocol?
    
    /// 发送时间
    var sentTime: NSDate = .zero
    /// 接收时间
    var receiveTime: NSDate = .zero
    
    /// 状态
    var status: SIMChatMessageStatus = .Unknow
    /// 内容
    var content: SIMChatMessageContentProtocol
    
    /// 名片选项
    var option: Int = 0
    /// 是否是所有者
    var ownership: Bool = false
    
    /// 消息的高度 \
    /// 为0表示需要计算
    var height: CGFloat = 0
}

// MARK: - Time
extension SIMChatMessage {
    
    /// 生成时间
    func makeDateWithMessage(m: SIMChatMessage) {
        
        // TODO: no imp
//        self.sender = nil
//        self.sentTime = m.sentTime
//        
//        self.receiver = nil
//        self.receiveTime = m.receiveTime
//        
//        self.status = .Read
//        
//        self.extra = nil
//        self.content = SIMChatMessageContentDate(date: self.receiveTime)
//        
//        self.mute = true
//        self.hidden = false
//        self.hiddenContact = nil
//        self.height = 0
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
