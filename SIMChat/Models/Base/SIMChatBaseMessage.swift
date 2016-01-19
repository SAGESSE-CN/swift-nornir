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
public class SIMChatBaseMessage: SIMChatMessageProtocol {
    ///
    /// 初始化
    ///
    /// - parameter content:    消息内容
    /// - parameter sender:     发送者信息
    /// - parameter receiver:   接收者信息
    /// - parameter identifier: 唯一标识符
    ///
    public required init(
        content: SIMChatContentProtocol,
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
    public var content: SIMChatContentProtocol
    
    ///
    /// 消息发生时间(发送/接收)
    ///
    public lazy var date: NSDate = NSDate()
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
        content: SIMChatContentProtocol,
        receiver: SIMChatUserProtocol,
        sender: SIMChatUserProtocol,
        identifier: String) -> SIMChatMessageProtocol {
            return self.init(
                content: content,
                receiver: receiver,
                sender: sender,
                identifier: identifier)
    }
}
//
////    convenience init(_ content: AnyObject) {
////        self.init()
////        self.content = content
////    }
////    /// 消息
////    lazy var identifier = NSUUID().UUIDString
////    
////    /// 发送者, 如果发送者为空, 视为广播信息 \
////    /// 为nil自动隐藏名字
////    var sender: SIMChatUserProtocol?
////    var sentTime: NSDate = .zero
////    
////    /// 接收者, 如果接收者为空, 视为广播信息
////    var receiver: SIMChatUserProtocol?
////    var receiveTime: NSDate = .zero
////    
////    /// 内容
////    var extra: AnyObject?
////    var status: SIMChatMessageStatus = .Unknow
////    var content: AnyObject?
////    
////    /// 其他配置
////    var mute = false            // 静音
////    var hidden = false          // 透明消息
////    
////    /// 这是自己发送的消息?
////    var owns: Bool = false
////    /// 是否需要隐藏名片服务? \
////    /// 为nil则自动根据环境选择
////    var hiddenContact: Bool?
////    
////    /// 消息的高度 \
////    /// 为0表示需要计算
////    var height = CGFloat(0)
////    
//    /// 标识符
//    var identifier: String = NSUUID().UUIDString
//    
//    /// 发送者 \
//    /// 为nil, 视为广播信息, 自动隐藏名字
//    var sender: SIMChatUserProtocol?
//    /// 接收者 \
//    /// 为nil, 视为广播信息, 自动隐藏名字
//    var receiver: SIMChatUserProtocol?
//    
//    /// 发送时间
//    var sentTime: NSDate = .zero
//    /// 接收时间
//    var receiveTime: NSDate = .zero
//    
//    /// 状态
//    var status: SIMChatMessageStatus = .Unknow
//    /// 内容
//    var content: SIMChatMessageContentProtocol
//    
//    /// 名片选项
//    var option: Int = 0
//    /// 是否是所有者
//    var ownership: Bool = false
//    
//    /// 消息的高度 \
//    /// 为0表示需要计算
//    var height: CGFloat = 0
//}
//
//// MARK: - Time
//extension SIMChatMessage {
//    
//    /// 生成时间
//    func makeDateWithMessage(m: SIMChatMessage) {
//        
//        // TODO: no imp
////        self.sender = nil
////        self.sentTime = m.sentTime
////        
////        self.receiver = nil
////        self.receiveTime = m.receiveTime
////        
////        self.status = .Read
////        
////        self.extra = nil
////        self.content = SIMChatMessageContentDate(date: self.receiveTime)
////        
////        self.mute = true
////        self.hidden = false
////        self.hiddenContact = nil
////        self.height = 0
//    }
//}
//
//// MARK: - Events
//extension SIMChatMessage {
//    /// 消息状态改变
//    func statusChanged() {
//        SIMChatNotificationCenter.postNotificationName(SIMChatMessageStatusChangedNotification, object: self)
//    }
//}
//
/////
///// 操作符重载
/////
//func ==(lhs: SIMChatMessage?, rhs: SIMChatMessage?) -> Bool {
//    return lhs === rhs || lhs?.identifier == rhs?.identifier
//}
//
///// 消息状态改变通告
//let SIMChatMessageStatusChangedNotification = "SIMChatMessageStatusChangedNotification"
