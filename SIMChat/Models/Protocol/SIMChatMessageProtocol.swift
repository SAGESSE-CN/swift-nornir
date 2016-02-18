//
//  SIMChatMessage+Protocol.swift
//  SIMChat
//
//  Created by sagesse on 10/20/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import Foundation

///
/// 抽象的消息协议.
///
public protocol SIMChatMessageProtocol: class {
    ///
    /// 消息ID(唯一标识符).
    ///
    var identifier: String { get }
    ///
    /// 发送者信息
    ///
    var sender: SIMChatUserProtocol { get }
    ///
    /// 接收者信息
    ///
    var receiver: SIMChatUserProtocol { get }
    ///
    /// 消息内容
    ///
    var content: SIMChatMessageContentProtocol { get }
    
    ///
    /// 消息发生时间(发送/接收)
    ///
    var date: NSDate { set get }
    ///
    /// 消息是否是自己发送的
    ///
    var isSelf: Bool { set get }
    ///
    /// 消息状态(发送/接收)
    ///
    var status: SIMChatMessageStatus { set get }
    ///
    /// 消息的一些选项, 默认None
    ///
    var option: SIMChatMessageOption { set get }
    
    ///
    /// 创建一个新的消息
    ///
    /// - parameter content:    消息内容
    /// - parameter identifier: 唯一标识符
    /// - parameter receiver:   接收者信息
    /// - parameter sender:     发送者信息
    /// - returns:  消息
    ///
    static func messageWithContent(content: SIMChatMessageContentProtocol, receiver: SIMChatUserProtocol, sender: SIMChatUserProtocol, identifier: String) -> SIMChatMessageProtocol
}

// MARK: - Convenience

extension SIMChatMessageProtocol {
    
    ///
    /// 创建一个新的消息
    ///
    /// - parameter content:    消息内容
    /// - parameter receiver:   接收者信息
    /// - parameter sender:     发送者信息
    /// - returns:  消息
    ///
    public static func messageWithContent(content: SIMChatMessageContentProtocol, receiver: SIMChatUserProtocol, sender: SIMChatUserProtocol) -> SIMChatMessageProtocol {
        return messageWithContent(content, receiver: receiver, sender: sender, identifier: NSUUID().UUIDString)
    }
    
    ///
    /// 显示时间线
    ///
    public var showsTimeLine: Bool {
        // 撤回的消息不显示timeline
        if status == .Revoked || status == .Destroyed {
            return false
        }
        // 检查选项
        return !option.contains(.TimeLineHidden)
    }
}

// MARK: - Message Other Type

///
/// 消息选项
///
public struct SIMChatMessageOption: OptionSetType {
    public var rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// 无
    public static var None: SIMChatMessageOption {
        return SIMChatMessageOption(rawValue: 0x0000)
    }
    /// 静音, 收到消息后不发出提示
    public static var Mute: SIMChatMessageOption {
        return SIMChatMessageOption(rawValue: 0x0001)
    }
    /// 消息隐藏(透明的)
    public static var Hidden: SIMChatMessageOption {
        return SIMChatMessageOption(rawValue: 0x0002)
    }
    
    /// 名片强制显示, 默认是自动选项
    public static var ContactShow: SIMChatMessageOption {
        return SIMChatMessageOption(rawValue: 0x0100)
    }
    /// 名片强制隐藏, 默认是自动选项
    public static var ContactHidden: SIMChatMessageOption {
        return SIMChatMessageOption(rawValue: 0x0200)
    }
    /// 隐藏时间线
    public static var TimeLineHidden: SIMChatMessageOption {
        return SIMChatMessageOption(rawValue: 0x0400)
    }
}

///
/// 消息状态
///
public enum SIMChatMessageStatus: Int {
    /// SR: 未知
    case Unknow
    /// S: 正在发送中<br>
    /// R: 对方正在发送中(错误)
    case Sending
    /// S: 己发送<br>
    /// R: 错误
    case Sent
    /// S: 对方未读<br>
    /// R: 消息未读
    case Unread
    /// S: 对方正在接收中, 包含未读, (图片/音频/视频)<br>
    /// R: 消息接收中, 包含未读, (图片/音频/视频)
    case Receiving
    /// S: 对方己接收, 包含未读<br>
    /// R: 消息己接收, 包含未读
    case Received
    /// S: 对方己读<br>
    /// R: 消息己读
    case Read
    /// S: 对方己播放(音频消息), 包含己读<br>
    /// R: 消息己播放(音频消息), 包含己读
    case Played
    /// S: 对方己销毁, 包含己读/己播放<br>
    /// R: 消息己销毁, 包含己读/己播放
    case Destroyed
    /// S: 对方己撤回, 包含己读/己播放<br>
    /// R: 消息己撤回, 包含己读/己播放
    case Revoked
    /// S: 发送错误(图片/音频/视频)<br>
    /// R: 接收错误(图片/音频/视频)
    case Error
    
    public func isUnknow()     -> Bool { return self == .Unknow }
    public func isSending()    -> Bool { return self == .Sending  }
    public func isSent()       -> Bool { return self == .Sent  }
    public func isUnread()     -> Bool { return self == .Unread  }
    public func isReceiving()  -> Bool { return self == .Receiving  }
    public func isReceived()   -> Bool { return self == .Received  }
    public func isRead()       -> Bool { return self == .Read  }
    public func isPlayed()     -> Bool { return self == .Played  }
    public func isDestroyed()  -> Bool { return self == .Destroyed  }
    public func isRevoked()    -> Bool { return self == .Revoked  }
    public func isError()      -> Bool { return self == .Error  }
}

// MARK: - Message compare

public func !=(lhs: SIMChatMessageProtocol, rhs: SIMChatMessageProtocol?) -> Bool {
    return !(lhs == rhs)
}
public func ==(lhs: SIMChatMessageProtocol, rhs: SIMChatMessageProtocol?) -> Bool {
    return lhs.identifier == rhs?.identifier
}


/// 消息改变通知
public let SIMChatMessageStatusChangedNotification = "SIMChatMessageStatusChangedNotification"