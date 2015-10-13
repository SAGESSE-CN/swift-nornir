//
//  SIMChatConversation.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 聊天会话
///
class SIMChatConversation: NSObject {
    /// 初始化
    init(recver: SIMChatUser, sender: SIMChatUser) {
        
        self.sender = sender
        self.recver = recver
        
        super.init()
    }
    
    /// 管理器(保留联系)
    weak var manager: SIMChatManager!
    
    /// 发送者
    private(set) var sender: SIMChatUser
    /// 接收者
    private(set) var recver: SIMChatUser
    
    /// 消息
    internal lazy var messages = Array<SIMChatMessage>()
}

/// MAKR: - Message
extension SIMChatConversation {
    
    ///
    func sendMessage(message: SIMChatMessage) {
    }
    
    func sendMessageWithContent(content: AnyObject) {
    }
}

// MARK: - Public Method
extension SIMChatConversation {
    ///
    /// 发送一条消息
    ///
    func send(content: AnyObject) {
        SIMLog.trace()
        // 生成
        let m = SIMChatMessage(content)
        // 填写发送信息
        m.sender = sender
        m.sentTime = .now
        m.sentStatus = .Sending
        // 填写接收者信息
        m.recver = recver
        m.recvTime = .now
        m.recvStatus = .Unknow
        // 保存
        messages.insert(m, atIndex: 0)
        // 发出通知
        SIMChatNotificationCenter.postNotificationName(SIMChatConversationMessageDidRecive, object: m)
        // 真正的发送
    }
    ///
    /// 重新发送
    ///
    func resend(m: SIMChatMessage) {
        // 必须要存在的才能重新发送
        guard let idx = messages.indexOf(m) else {
            
            return
        }
        SIMLog.trace()
        // 填写发送信息
        m.sender = sender
        m.sentTime = .now
        m.sentStatus = .Sending
        // 填写接收者信息
        m.recver = recver
        m.recvTime = .now
        m.recvStatus = .Unknow
        // 调整结构
        messages.removeAtIndex(idx)
        messages.insert(m, atIndex: 0)
        // 发出通知
        SIMChatNotificationCenter.postNotificationName(SIMChatConversationMessageDidUpdate, object: m)
        // 真正的发送
    }
    ///
    /// 删除消息
    ///
    func remove(m: SIMChatMessage) {
        // 必须要存在的才能删除
        guard let idx = messages.indexOf(m) else {
            return
        }
        SIMLog.trace()
        // 真的需要删除?
        messages.removeAtIndex(idx)
        // 通知
        SIMChatNotificationCenter.postNotificationName(SIMChatConversationMessageDidRemove, object: m)
    }
    ///
    /// 标记消息为己读
    ///
    func read(m: SIMChatMessage) {
        SIMLog.trace()
        
        // 通知
        SIMChatNotificationCenter.postNotificationName(SIMChatConversationMessageDidUpdate, object: m)
    }
    ///
    /// 查询多条消息
    ///
    func query(count: Int, latest: SIMChatMessage?) {
        SIMLog.trace()
    }
}

// MARK: - Helper
extension SIMChatConversation {
    ///
    /// 第一条, 这是最新的
    ///
    var latest: SIMChatMessage? { return messages.first }
    ///
    /// 最后一条, 这是最旧的
    ///
    var last: SIMChatMessage? { return messages.last }
    ///
    /// 总数
    ///
    var count: Int { return messages.count }
    ///
    /// 未读总数
    ///
    var unread: Int {
        // TODO: 未读记数
        return 0
    }
}


/// 接口1
@objc protocol SIMChatConversationInterface : NSObjectProtocol {
    
    // send
    // remove
    // update
    // query + block
    
}

let SIMChatConversationMessageDidRecive = "SIMChatConversationMessageDidRecive"
let SIMChatConversationMessageDidRemove = "SIMChatConversationMessageDidRemove"
let SIMChatConversationMessageDidUpdate = "SIMChatConversationMessageDidUpdate"

