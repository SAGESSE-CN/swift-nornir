//
//  SIMChatMessage.swift
//  SIMChat
//
//  Created by sagesse on 10/20/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import Foundation

///
/// 抽象的消息协议.
///
public protocol SIMChatMessage: class {
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
    var content: SIMChatMessageBody { get }
    
    ///
    /// 消息发生时间(发送/接收)
    ///
    var timestamp: Date { get }
    ///
    /// 消息是否是自己发送的
    ///
    var isSelf: Bool { get }
    ///
    /// 消息状态(发送/接收)
    ///
    var status: SIMChatMessageStatus { set get }
    ///
    /// 消息的一些选项, 默认None
    ///
    var option: SIMChatMessageOption { get }
}

// MARK: - Convenience

extension SIMChatMessage {
    ///
    /// 显示时间线
    ///
    public var showsTimeLine: Bool {
        // 撤回的消息不显示timeline
        if status == .revoked || status == .destroyed {
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
public struct SIMChatMessageOption: OptionSet {
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
    case unknow
    /// S: 正在发送中<br>
    /// R: 对方正在发送中(错误)
    case sending
    /// S: 己发送<br>
    /// R: 错误
    case sent
    /// S: 对方未读<br>
    /// R: 消息未读
    case unread
    /// S: 对方正在接收中, 包含未读, (图片/音频/视频)<br>
    /// R: 消息接收中, 包含未读, (图片/音频/视频)
    case receiving
    /// S: 对方己接收, 包含未读<br>
    /// R: 消息己接收, 包含未读
    case received
    /// S: 对方己读<br>
    /// R: 消息己读
    case read
    /// S: 对方己播放(音频消息), 包含己读<br>
    /// R: 消息己播放(音频消息), 包含己读
    case played
    /// S: 对方己销毁, 包含己读/己播放<br>
    /// R: 消息己销毁, 包含己读/己播放
    case destroyed
    /// S: 对方己撤回, 包含己读/己播放<br>
    /// R: 消息己撤回, 包含己读/己播放
    case revoked
    /// S: 发送错误(图片/音频/视频)<br>
    /// R: 接收错误(图片/音频/视频)
    case error
    
    public func isUnknow()     -> Bool { return self == .unknow }
    public func isSending()    -> Bool { return self == .sending  }
    public func isSent()       -> Bool { return self == .sent  }
    public func isUnread()     -> Bool { return self == .unread  }
    public func isReceiving()  -> Bool { return self == .receiving  }
    public func isReceived()   -> Bool { return self == .received  }
    public func isRead()       -> Bool { return self == .read  }
    public func isPlayed()     -> Bool { return self == .played  }
    public func isDestroyed()  -> Bool { return self == .destroyed  }
    public func isRevoked()    -> Bool { return self == .revoked  }
    public func isError()      -> Bool { return self == .error  }
}

// MARK: - Message compare

public func !=(lhs: SIMChatMessage, rhs: SIMChatMessage?) -> Bool {
    return !(lhs == rhs)
}
public func ==(lhs: SIMChatMessage, rhs: SIMChatMessage?) -> Bool {
    return lhs === rhs || lhs.identifier == rhs?.identifier
}

/// 消息改变通知
public let SIMChatMessageStatusChangedNotification = "SIMChatMessageStatusChangedNotification"
