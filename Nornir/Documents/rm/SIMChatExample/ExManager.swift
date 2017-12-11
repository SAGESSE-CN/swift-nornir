//
//  ExManager.swift
//  SIMChatExample
//
//  Created by sagesse on 2/3/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import SIMChat
//import ImSDK

//class ExManager: SIMChatBaseManager {
////    private class Listener: NSObject, TIMMessageListener {
////        init(manager: ExManager) {
////            self.manager = manager
////        }
////        weak var manager: ExManager?
////        @objc func onNewMessage(msgs: [AnyObject]!) {
////            manager?.onNewMessage(msgs)
////        }
////    }
//    
//    override init() {
//        super.init()
//        
////        classProvider.user = ExUser.self
////        classProvider.message = ExMessage.self
////        classProvider.conversation = ExConversation.self
//    }
//    
////    ///
////    /// 登录用户
////    ///
////    /// - parameter user: 用户信息
////    /// - parameter closure: 执行结果
////    ///
////    override func login(user: SIMChatUserProtocol, closure: SIMChatResult<Void, NSError> -> Void) {
////        SIMLog.trace()
////        // 检查是否有权限
////        guard let sign = (user as? ExUser)?.sign else {
////            closure(.Failure(NSError(domain: "该用户没有权限", code: -1, userInfo: nil)))
////            return
////        }
////        imp.login(user.identifier,
////            userSig: sign,
////            succ: {
////                super.login(user, closure: closure)
////            },
////            fail: { code, error in
////                closure(.Failure(NSError(domain: error, code: Int(code), userInfo: nil)))
////            })
////    }
////    ///
////    /// 登出用户
////    ///
////    /// - parameter closure: 执行结果
////    ///
////    override func logout(closure: SIMChatResult<Void, NSError> -> Void) {
////        SIMLog.trace()
////        
////        imp.logout({
////                super.logout(closure)
////            },
////            fail: { code, error in
////                closure(.Failure(NSError(domain: error, code: Int(code), userInfo: nil)))
////            })
////    }
////    
////    ///
////    /// 所有的会话
////    ///
////    override func allConversations() -> Array<SIMChatConversation> {
////        SIMLog.trace()
////        
////        let conversations = super.allConversations()
////        //if conversations.count != Int(imp.ConversationCount()) {
////        //    //imp.getConversationByIndex(<#T##index: Int32##Int32#>)
////        //}
////        return conversations
////    }
//    override func conversation(_ receiver: SIMChatUserProtocol) -> SIMChatConversation {
//        return ExConversation(receiver: receiver, manager: self)
//    }
////    ///
////    /// 删除会话
////    ///
////    /// - parameter receiver: 被删除会放的接收者信息
////    ///
////    override func removeConversation(receiver: SIMChatUserProtocol) {
////        SIMLog.trace()
////        
////        super.removeConversation(receiver)
////        imp.deleteConversation(receiver.type.toConversationType(), receiver: receiver.identifier)
////    }
////    
////    /// 实现
////    lazy var imp: TIMManager = {
////        let m = TIMManager.sharedInstance()
////        m.initSdk(1400007115)
////        m.setMessageListener(self.listener)
////        return m
////    }()
////    
////    @objc func onNewMessage(msgs: [AnyObject]!) {
////        let messages = msgs.flatMap { $0 as? TIMMessage }
////        messages.forEach {
////            guard let conv = self.conversations[$0.getConversation().getReceiver()] as? ExConversation else {
////                return
////            }
////            conv.receiveMessageFromRemote(conv.convert($0))
////        }
////    }
////    
////    private lazy var listener: Listener = Listener(manager: self)
//    
//    static var sharedInstance: SIMChatManager = ExManager()
//}
//
////// MARK: - Conversation
////extension SDChatManager {
////    ///
////    /// 获取会话, 如果不存在创建
////    ///
////    /// :param: recver 接收者
////    ///
////    override func conversationWithRecver(recver: SIMChatUserProtocol) -> SDChatConversation {
////        return super.conversationWithRecver(recver) as! SDChatConversation
////    }
////    ///
////    /// 创建会话
////    /// :param: recver 接收者
////    ///
////    override func conversationOfMake(recver: SIMChatUserProtocol) -> SDChatConversation {
////        return SDChatConversation(receiver: recver, sender: self.currentUser)
////    }
////}
//
////extension SIMChatUserType {
////    func toConversationType() -> TIMConversationType {
////        switch self {
////        case User:      return .C2C
////        case Group:     return .GROUP
////        case System:    return .SYSTEM
////        }
////    }
////}
