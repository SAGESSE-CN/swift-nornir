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
    init(receiver: SIMChatUserProtocol, sender: SIMChatUserProtocol) {
        self.receiver = receiver
        self.sender = sender
        super.init()
    }
    /// 代理
    weak var delegate: SIMChatConversationDelegate?
    
    private(set) var sender: SIMChatUserProtocol
    private(set) var receiver: SIMChatUserProtocol
    
    /// 消息
    private(set) lazy var messages = Array<SIMChatMessage>()
}

// MARK: - Protocol
extension SIMChatConversation : SIMChatConversationProtocol {
    ///
    /// 查询消息
    ///
    func queryMessages(total: Int, last: SIMChatMessage?, _ finish: ([SIMChatMessage] -> Void)?, _ fail: SIMChatFailBlock?) {
        SIMLog.trace("last: \(last)")
        // 如果last为nil, 从0开始
        // 如果last不为nil, 从last的下一个开始
        // 如果last不能找到, 从最后开始
        // 起点
        let sp = (last != nil) ? ((messages.indexOf(last!) ?? messages.count - 1) + 1) : 0
        let ts = messages[sp ..<  min(sp + min(messages.count - sp, count), messages.count)]
        // 缓存了?
        if ts.count >= total {
            finish?(Array<SIMChatMessage>(ts))
            return
        }
        // 加载更多
        finish?(Array<SIMChatMessage>(ts))
    }
    ///
    /// 发送消息
    ///
    func sendMessage(m: SIMChatMessage, isResend: Bool, _ finish: SIMChatFinishBlock?, _ fail: SIMChatFailBlock?) {
        SIMLog.trace("resend: \(isResend)")
        // 填写发送信息
        m.sender = self.sender
        m.sentTime = .now
        // 填写接收信息
        m.receiver = self.receiver
        m.receiveTime = .now
        // 填写当前状态
        m.owns = true
        m.status = .Sending
        // 调整结构
        if isResend {
            // 如果真的存在
            if let idx = self.messages.indexOf(m) {
                // 调整他的位置
                self.messages.removeAtIndex(idx)
                self.messages.insert(m, atIndex: 0)
                // 请求更新
                self.updateMessageForRemote(m)
            }
        } else {
            // 不需要insert, 因为由reciveMessage来insert
            // 收到了一条新消息
            self.reciveMessageForRemote(m)
        }
        // 直接完成
        finish?()
    }
    ///
    /// 删除消息
    /// 只是调用removeMessageForRemote然后完成
    ///
    func removeMessage(m: SIMChatMessage, _ finish: SIMChatFinishBlock?, _ fail: SIMChatFailBlock?) {
        // 要求删除
        self.removeMessageForRemote(m)
        // 直接完成
        finish?()
    }
    ///
    /// 标记消息为己读
    ///
    func readMessage(m: SIMChatMessage, _ finish: SIMChatFinishBlock?, _ fail: SIMChatFailBlock?) {
        // :)
        m.status = .Read
        m.statusChanged()
        // 要求删除
        self.updateMessageForRemote(m)
        // 直接完成
        finish?()
    }
    ///
    /// 远端获取到了一条消息
    ///
    func reciveMessageForRemote(m: SIMChatMessage) {
        // 保存
        self.messages.insert(m, atIndex: 0)
        // 发出通知
        self.delegate?.chatConversation?(self, didReciveMessage: m)
    }
    ///
    /// 远端要求删除一条消息
    ///
    func removeMessageForRemote(m: SIMChatMessage) {
        // 必须要存在的才能删除
        guard let idx = self.messages.indexOf(m) else {
            return
        }
        // 删除
        self.messages.removeAtIndex(idx)
        // 发出通知
        self.delegate?.chatConversation?(self, didRemoveMessage: m)
    }
    ///
    /// 远端要求更新一条消息
    ///
    func updateMessageForRemote(m: SIMChatMessage) {
        // 发出通知
        self.delegate?.chatConversation?(self, didUpdateMessage: m)
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

