//
//  SIMChatMessage+Protocol.swift
//  SIMChat
//
//  Created by sagesse on 10/20/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// Message Interface
@objc protocol SIMChatMessageProtocol {
    /// 标识符
    var identifier: String { get }
    
    /// 发送者(只能是用户.) \
    /// 为nil, 视为广播信息, 自动隐藏名字
    var sender: SIMChatUserProtocol? { get }
    /// 接收者 \
    /// 为nil, 视为广播信息, 自动隐藏名字
    var receiver: SIMChatUserProtocol? { get }
    
    /// 发送时间
    var sentTime: NSDate { get }
    /// 接收时间
    var receiveTime: NSDate { get }
    
    /// 状态
    var status: SIMChatMessageStatus { get }
    /// 内容
    var content: SIMChatMessageContentProtocol { get }
    
    /// 名片选项
    var option: Int { get }
    /// 是否是所有者
    var ownership: Bool { get }
    
    /// 消息的高度 \
    /// 为0表示需要计算
    var height: CGFloat { set get }
}

/// Message Options
struct SIMChatMessageOption {
    /// 无
    static var None: Int { return 0x0000 }
    /// 消息静音
    static var Mute: Int { return 0x0001 }
    /// 消息隐藏(透明的)
    static var Hidden: Int { return 0x0010 }

    /// 名片强制显示
    static var ContactShow: Int { return 0x0100 }
    /// 名片强制隐藏
    static var ContactHidden: Int { return 0x0200 }
    /// 名片根据环境自动显示/隐藏
    static var ContactAutomatic: Int { return 0x0400 }
}

/// Message Status
@objc enum SIMChatMessageStatus : Int {
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

