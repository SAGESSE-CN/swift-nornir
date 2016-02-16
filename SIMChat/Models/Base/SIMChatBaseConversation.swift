//
//  SIMChatBaseConversation.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import Foundation

///
/// 聊天会话
///
public class SIMChatBaseConversation: SIMChatConversationProtocol {
    ///
    /// 创建一个新的会话
    ///
    /// - parameter receiver: 会话的接收者
    /// - parameter manager:  关联的管理器
    ///
    public required init(
        receiver: SIMChatUserProtocol,
        manager: SIMChatManagerProtocol) {
            self.receiver = receiver
            self.manager = manager
    }
    
    ///
    /// 接收者信息
    ///
    public var receiver: SIMChatUserProtocol
    ///
    /// 发送都信息
    ///
    public var sender: SIMChatUserProtocol {
        guard let user = manager?.user else {
            fatalError("Must login")
        }
        return user
    }
    
    /// 相关的管理器
    public weak var manager: SIMChatManagerProtocol?
    /// 代理
    public weak var delegate: SIMChatConversationDelegate?
    
    ///
    /// 创建一个新的会话
    ///
    /// - parameter receiver: 会话的接收者
    /// - parameter manager:  关联的管理器
    ///
    public class func conversation(
        receiver: SIMChatUserProtocol,
        manager: SIMChatManagerProtocol) -> SIMChatConversationProtocol {
            return self.init(
                receiver: receiver,
                manager: manager)
    }
    
    /// 所有的消息
    public var messages: Array<SIMChatMessageProtocol> = []
}

// MARK: - Util

extension SIMChatBaseConversation {
    ///
    /// 最新的一条消息, 如果为nil则没有
    ///
    public var latest: SIMChatMessageProtocol? {
        return messages.last
    }
    ///
    /// 未读消息数量, 为0则没有
    ///
    public var unreadCount: Int {
        return messages.count
    }
}

// MARK: - Message

extension SIMChatBaseConversation {
    ///
    /// 加载(历史)消息
    ///
    /// - parameter last: 最后一条消息(结果不包含该消息), 如果为nil则没有最后一条从头开始
    /// - parameter count: 容量
    /// - returns: 返回结果是Array<SIMChatMessageProtocol>
    ///
    public func loadHistoryMessages(
        last: SIMChatMessageProtocol?,
        count: Int) -> SIMChatRequest<Array<SIMChatMessageProtocol>> {
            SIMLog.trace()
            return SIMChatRequest.request {
                $0.success(self.messages)
            }
    }
    ///
    /// 发送消息
    ///
    /// - parameter message: 需要发送的消息
    /// - parameter isResend: 是否是重发消息
    /// - returns: 返回结果是SIMChatMessageProtocol
    ///
    public func sendMessage(
        message: SIMChatMessageProtocol,
        isResend: Bool) -> SIMChatRequest<SIMChatMessageProtocol> {
            SIMLog.trace()
            return SIMChatRequest.request {
                $0.success(message)
            }
    }
    ///
    /// 发送消息状态
    ///
    /// - parameter message: 需要发送的消息(包含己修改的信息)
    /// - returns: 返回结果是SIMChatMessageProtocol
    ///
    public func sendMessageState(message: SIMChatMessageProtocol) -> SIMChatRequest<SIMChatMessageProtocol> {
        SIMLog.trace()
        return SIMChatRequest.request {
            $0.success(message)
        }
    }
    ///
    /// 删除消息
    ///
    /// - parameter message: 需要删除的消息
    /// - returns: 返回结果是Void
    ///
    public func removeMessage(message: SIMChatMessageProtocol) -> SIMChatRequest<Void> {
        SIMLog.trace()
        return SIMChatRequest.request {
            $0.success()
        }
    }
}

// MARK: - Message Of Remote

extension SIMChatBaseConversation {
    ///
    /// 服务端要求更新消息
    ///
    /// - parameter message: 被操作的消息
    ///
    public func updateMessageFromRemote(messsage: SIMChatMessageProtocol) {
        SIMLog.trace()
    }
    ///
    /// 接收到来自服务端的消息
    ///
    /// - parameter message: 被操作的消息
    ///
    public func receiveMessageFromRemote(messsage: SIMChatMessageProtocol) {
        SIMLog.trace()
    }
    ///
    /// 服务端要求更删除消息
    ///
    /// - parameter message: 被操作的消息
    ///
    public func removeMessageFromRemote(messsage: SIMChatMessageProtocol) {
        SIMLog.trace()
    }
}

//class SIMChatConversation: NSObject {
//    /// 初始化
//    init(receiver: SIMChatUserProtocol, sender: SIMChatUserProtocol) {
//        self.receiver = receiver
//        self.sender = sender
//        super.init()
//    }
//    /// 代理
//    weak var delegate: SIMChatConversationDelegate?
//    
//    private(set) var sender: SIMChatUserProtocol
//    private(set) var receiver: SIMChatUserProtocol
//    
//    /// 消息
//    private(set) lazy var messages = Array<SIMChatMessage>()
//}
//
//// MARK: - Protocol
//extension SIMChatConversation : SIMChatConversationProtocol {
//    ///
//    /// 查询消息
//    ///
//    func queryMessages(total: Int, last: SIMChatMessage?, _ finish: ([SIMChatMessage] -> Void)?, _ fail: SIMChatFailBlock?) {
//        SIMLog.trace("last: \(last)")
//        // 如果last为nil, 从0开始
//        // 如果last不为nil, 从last的下一个开始
//        // 如果last不能找到, 从最后开始
//        // 起点
//        let sp = (last != nil) ? ((messages.indexOf(last!) ?? messages.count - 1) + 1) : 0
//        let ts = messages[sp ..<  min(sp + min(messages.count - sp, count), messages.count)]
//        // 缓存了?
//        if ts.count >= total {
//            finish?(Array<SIMChatMessage>(ts))
//            return
//        }
//        // 加载更多
//        finish?(Array<SIMChatMessage>(ts))
//    }
//    ///
//    /// 发送消息
//    ///
//    func sendMessage(m: SIMChatMessage, isResend: Bool, _ finish: SIMChatFinishBlock?, _ fail: SIMChatFailBlock?) {
//        SIMLog.trace("resend: \(isResend)")
//        // 填写发送信息
//        m.sender = self.sender
//        m.sentTime = .now
//        // 填写接收信息
//        m.receiver = self.receiver
//        m.receiveTime = .now
//        // 填写当前状态
//        m.ownership = true
//        m.status = .Sending
//        // 调整结构
//        if isResend {
//            // 如果真的存在
//            if let idx = self.messages.indexOf(m) {
//                // 调整他的位置
//                self.messages.removeAtIndex(idx)
//                self.messages.insert(m, atIndex: 0)
//                // 请求更新
//                self.updateMessageForRemote(m)
//            }
//        } else {
//            // 不需要insert, 因为由reciveMessage来insert
//            // 收到了一条新消息
//            self.reciveMessageForRemote(m)
//        }
//        // 直接完成
//        finish?()
//    }
//    ///
//    /// 删除消息
//    /// 只是调用removeMessageForRemote然后完成
//    ///
//    func removeMessage(m: SIMChatMessage, _ finish: SIMChatFinishBlock?, _ fail: SIMChatFailBlock?) {
//        // 要求删除
//        self.removeMessageForRemote(m)
//        // 直接完成
//        finish?()
//    }
//    ///
//    /// 标记消息为己读
//    ///
//    func readMessage(m: SIMChatMessage, _ finish: SIMChatFinishBlock?, _ fail: SIMChatFailBlock?) {
//        // :)
//        m.status = .Read
//        m.statusChanged()
//        // 要求删除
//        self.updateMessageForRemote(m)
//        // 直接完成
//        finish?()
//    }
//    ///
//    /// 远端获取到了一条消息
//    ///
//    func reciveMessageForRemote(m: SIMChatMessage) {
//        // 保存
//        self.messages.insert(m, atIndex: 0)
//        // 发出通知
//        self.delegate?.chatConversation?(self, didReciveMessage: m)
//    }
//    ///
//    /// 远端要求删除一条消息
//    ///
//    func removeMessageForRemote(m: SIMChatMessage) {
//        // 必须要存在的才能删除
//        guard let idx = self.messages.indexOf(m) else {
//            return
//        }
//        // 删除
//        self.messages.removeAtIndex(idx)
//        // 发出通知
//        self.delegate?.chatConversation?(self, didRemoveMessage: m)
//    }
//    ///
//    /// 远端要求更新一条消息
//    ///
//    func updateMessageForRemote(m: SIMChatMessage) {
//        // 发出通知
//        self.delegate?.chatConversation?(self, didUpdateMessage: m)
//    }
//}
//
//// MARK: - Helper
//extension SIMChatConversation {
//    ///
//    /// 第一条, 这是最新的
//    ///
//    var latest: SIMChatMessage? { return messages.first }
//    ///
//    /// 最后一条, 这是最旧的
//    ///
//    var last: SIMChatMessage? { return messages.last }
//    ///
//    /// 总数
//    ///
//    var count: Int { return messages.count }
//    ///
//    /// 未读总数
//    ///
//    var unread: Int {
//        // TODO: 未读记数
//        return 0
//    }
//}
//
