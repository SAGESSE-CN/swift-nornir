//
//  SIMChatTimeLineMessage.swift
//  SIMChat
//
//  Created by sagesse on 3/17/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

///
/// 时间线
///
internal class SIMChatTimeLineMessage: SIMChatMessage {
    /// 创建.
    init(beforeMessage: SIMChatMessage? = nil, afterMessage: SIMChatMessage? = nil) {
        if beforeMessage == nil && afterMessage == nil {
            fatalError("can't create empty time line")
        }
        self.beforeMessage = beforeMessage
        self.afterMessage = afterMessage
    }
    
    /// 之前
    var beforeMessage: SIMChatMessage?
    /// 之后
    var afterMessage: SIMChatMessage?
    
    /// 唯一标识符
    private lazy var _identifier: String =  UUID().uuidString
    /// 有效的消息
    private var _valid: SIMChatMessage {
        if let m = beforeMessage { return m }
        if let m = afterMessage { return m }
        fatalError("is a empty time line")
    }
//}
//
///// 提供转换操作
//extension SIMChatTimeLineMessage: SIMChatMessage {
    /// 消息ID(唯一标识符).
    var identifier: String {
        return _identifier
    }
    /// 发送者信息
    var sender: SIMChatUserProtocol {
        return _valid.sender
    }
    /// 接收者信息
    var receiver: SIMChatUserProtocol {
        return _valid.receiver
    }
    /// 消息内容
    var content: SIMChatMessageBody {
        return NSNull()
    }
    /// 消息发生时间(发送/接收)
    var timestamp: Date {
        return _valid.timestamp as Date
    }
    /// 消息是否是自己发送的
    var isSelf: Bool {
        return false
    }
    /// 消息状态(发送/接收)
    var status: SIMChatMessageStatus {
        set {                }
        get { return .unknow }
    }
    /// 消息的一些选项, 默认None
    var option: SIMChatMessageOption {
        return .None
    }
}
