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
    init(recver: SIMChatUser2, manager: SIMChatManager) {
        
        self.manager = manager
        self.recver = recver
        
        super.init()
    }
    
    /// 管理器(保留联系)
    weak var manager: SIMChatManager!
    weak var delegate: SIMChatConversationDelegate?
    
    /// 发送者
    var sender: SIMChatUser2 { return manager.user }
    /// 接收者
    private(set) var recver: SIMChatUser2
    
    /// 消息
    private(set) lazy var messages = Array<SIMChatMessage>()
}

// MARK: - Initiative
extension SIMChatConversation {
    ///
    /// 发送一条消息
    ///
    func send(content: AnyObject) {
        SIMLog.trace()
        // 生成
        let m = SIMChatMessage(content)
        // 填写发送信息
        m.sender = self.sender
        m.sentTime = .now
        m.sentStatus = .Sending
        // 填写接收者信息
        m.recver = self.recver
        m.recvTime = .now
        m.recvStatus = .Unknow
        
        self.recived(m)
        self.manager.sendMessage(m, finish: {
            // 发送成功
            m.sentStatus = .Sent
            self.updated(m)
        }, fail: { e in
            // 发送失败
            m.sentStatus = .Failed
            self.updated(m)
        })
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
        m.sender = self.sender
        m.sentTime = .now
        m.sentStatus = .Sending
        // 填写接收者信息
        m.recver = self.recver
        m.recvTime = .now
        m.recvStatus = .Unknow
        // 调整结构
        self.messages.removeAtIndex(idx)
        self.messages.insert(m, atIndex: 0)
        
        self.updated(m)
        self.manager.sendMessage(m, finish: {
            // 发送成功
            m.sentStatus = .Sent
            self.updated(m)
        }, fail: { e in
            // 发送失败
            m.sentStatus = .Failed
            self.updated(m)
        })
    }
    ///
    /// 删除消息
    ///
    func remove(m: SIMChatMessage) {
        SIMLog.trace()
        // 删除
        self.manager.removeMessage(m, finish: {
            self.removed(m)
        }, fail: { e in
            // 出错了
            self.removed(m)
        })
    }
    ///
    /// 更新消息
    ///
    func read(m: SIMChatMessage) {
        SIMLog.trace()
        // 更新为己读
        m.recvStatus = .Read
        // 更新
        self.manager.updateMessage(m, finish: {
            self.updated(m)
        }, fail: { e in
            // 出错了
            self.updated(m)
        })
    }
    /// 查询消息
    func query(count: Int, last: SIMChatMessage?, finish: ([SIMChatMessage] -> Void)?, fail: (NSError -> Void)?) {
        SIMLog.trace()
        // 真的需要查询?
        self.manager.queryMessages(count, last: last, finish: { ms in
            // 更新
            self.messages.insertContentsOf(ms, at: self.messages.endIndex)
            // 完成
            finish?(ms)
        }, fail: fail)
    }
}

// MARK: - Passive
extension SIMChatConversation {
    ///
    /// 新消息
    ///
    func recived(m: SIMChatMessage) {
        // 保存
        messages.insert(m, atIndex: 0)
        // 发出通知
        delegate?.chatConversation?(self, didReciveMessage: m)
    }
    ///
    /// 删除
    ///
    func removed(m: SIMChatMessage) {
        // 必须要存在的才能删除
        guard let idx = messages.indexOf(m) else {
            return
        }
        // 删除
        self.messages.removeAtIndex(idx)
        // 发出通知
        delegate?.chatConversation?(self, didUpdateMessage: m)
    }
    ///
    /// 更新
    ///
    func updated(m: SIMChatMessage) {
        // 发出通知
        delegate?.chatConversation?(self, didUpdateMessage: m)
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


/// 代理
@objc protocol SIMChatConversationDelegate : NSObjectProtocol {
   
    optional func chatConversation(conversation: SIMChatConversation, didReciveMessage message: SIMChatMessage)
    optional func chatConversation(conversation: SIMChatConversation, didRemoveMessage message: SIMChatMessage)
    optional func chatConversation(conversation: SIMChatConversation, didUpdateMessage message: SIMChatMessage)
}

