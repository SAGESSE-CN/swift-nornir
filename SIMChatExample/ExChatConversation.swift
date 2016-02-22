//
//  ExChatConversation.swift
//  SIMChatExample
//
//  Created by sagesse on 2/3/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import SIMChat

class Unknow: SIMChatMessageContentProtocol {
}

class ExChatConversation: SIMChatBaseConversation {
    
    /// 所有消息都己经加载
    override var allMessagesIsLoaded: Bool {
        return messages.count > 2000
    }
    
    override func sendMessage(message: SIMChatMessageProtocol, isResend: Bool) -> SIMChatRequest<SIMChatMessageProtocol> {
        message.status = .Sending
        message.date = NSDate()
        return super.sendMessage(message, isResend: isResend)
    }

    override func loadHistoryMessages(last: SIMChatMessageProtocol?, count: Int) -> SIMChatRequest<Array<SIMChatMessageProtocol>> {
            return SIMChatRequest.request { op in
                dispatch_after_at_now(0.5, dispatch_get_main_queue()) {
//                    if rand() % 3 == 0 {
//                        op.failure(NSError(domain: "", code: 0, userInfo: nil))
//                        return
//                    }
                    let ms = self.makeRandHistory()
                    self.messages.appendContentsOf(ms)
                    op.success(ms)
                }
            }
    }
    
    
    static let ttv = [
        "class",
        "deinit",
        "enum",
        "extension",
        "func",
        "import",
        "init",
        "let",
        "protocol",
        "static",
        "struct",
        "subscript",
        "typealias",
        "var",
        
        "break",
        "case","continue",
        "default",
        "do",
        "else",
        "fallthrough",
        "if",
        "in",
        "for",
        "return",
        "switch",
        "where",
        "while",
        
        "as",
        "dynamicType",
        "is",
        "new",
        "super",
        "self",
        "Self",
        "Type",
        "__COLUMN__",
        "__FILE__",
        "__FUNCTION__",
        "__LINE__",
        
        "associativity",
        "didSet",
        "get",
        "infix",
        "inout",
        "left",
        "mutating",
        "none",
        "nonmutating",
        "operator",
        "override",
        "postfix",
        "precedence",
        "prefix",
        "rightset",
        "unowned",
        "unowned(safe)",
        "unowned(unsafe)",
        "weak",
        "willSet"
    ]
    static let txx = [
        "Unknow",
        "Sending",
        "Sent",
        "Unread",
        "Receiving",
        "Received",
        "Read",
        "Played",
        "Destroyed",
        "Revoked",
        "Error"
    ]
    
    func makeRandText() -> String {
        var str = ""
        let r = (rand() % 50) + 1
        let count = self.dynamicType.ttv.count
        for _ in 0 ..< r {
            let x = self.dynamicType.ttv[Int(rand()) % count]
            if str.isEmpty {
                str = x
            } else {
                str.appendContentsOf(" \(x)")
            }
        }
        return str
    }
    var i: NSTimeInterval = 0
   
    
    
    func makeRandHistory() -> Array<SIMChatMessageProtocol> {
        var rs: Array<SIMChatMessageProtocol> = []
        
        let path = NSBundle.mainBundle().pathForResource("t1", ofType: "jpg")!
        
        for r in 0 ..< (2 * 11) {
        //while rs.count < 10 {
            //let r = rand()
            
            i += 999
            
            let status = SIMChatMessageStatus(rawValue: r / 2) ?? .Error
            let o = (r % 2 == 0) ? receiver : sender
            let s = (r % 2 == 0) ? sender   : receiver
            
            // 添加一个提示
            if r % 2 == 0 {
                let c = SIMChatBaseMessageTipsContent(content: "Message Example: \(self.dynamicType.txx[status.rawValue])")
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                //m.option = [.TimeLineHidden]
                m.date = NSDate(timeIntervalSinceNow: i + 3)
                m.status = status
                rs.append(m)
            }
            
            if true || (rand() % 10) < 6 {
                let c = SIMChatBaseMessageTextContent(content: makeRandText())
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (r % 2 == 0)
                m.status = status
                m.date = NSDate(timeIntervalSinceNow: i + 0)
                rs.append(m)
            }
            if true || (rand() % 10) < 6 {
                let c = SIMChatBaseMessageTextContent(content: makeRandText())
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (r % 2 == 0)
                m.status = status
                m.date = NSDate(timeIntervalSinceNow: i + 0)
                rs.append(m)
            }
            
            if true || (rand() % 10) == 2 {
                let c = SIMChatBaseMessageImageContent(remote: path, size: CGSizeMake(640, 480))
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (r % 2 == 0)
                m.status = status
                m.date = NSDate(timeIntervalSinceNow: i + 1)
                rs.append(m)
            }
            if true || (rand() % 10) == 2 {
                let c = SIMChatBaseMessageImageContent(remote: path, size: CGSizeMake(640, 480))
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (r % 2 == 0)
                m.status = status
                m.date = NSDate(timeIntervalSinceNow: i + 1)
                rs.append(m)
            }
            
            if true || (rand() % 10) < 2 {
                let c = SIMChatBaseMessageAudioContent(remote: path, duration: 6.2 * Double((r % 3600) + 1))
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (r % 2 == 0)
                m.status = status
                m.date = NSDate(timeIntervalSinceNow: i + 2)
                rs.append(m)
            }
            if true || (rand() % 10) < 2 {
                let c = SIMChatBaseMessageAudioContent(remote: path, duration: 6.2 * Double((r % 3600) + 1))
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (r % 2 == 0)
                m.status = status
                m.date = NSDate(timeIntervalSinceNow: i + 2)
                rs.append(m)
            }
            
            if true || (rand() % 10) < 3 {
                let c = SIMChatBaseMessageTipsContent(content: "this is a tips\nThis is a very long long long long long long long long the tips")
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.TimeLineHidden]
                m.date = NSDate(timeIntervalSinceNow: i + 3)
                m.status = status
                rs.append(m)
            }
            if true || (rand() % 20) == 0  {
                let c = Unknow()
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.TimeLineHidden]
                m.status = status
                m.date = NSDate(timeIntervalSinceNow: i + 4)
                rs.append(m)
            }
        }
        
        let c = SIMChatBaseMessageAudioContent(remote: path, duration: 88)
        let m = SIMChatBaseMessage.messageWithContent(c, receiver: receiver, sender: sender)
        m.option = [.ContactShow]
        m.isSelf = true//(r % 2 == 0)
        m.status = .Unread //status
        m.date = NSDate(timeIntervalSinceNow: i + 2)
        rs.append(m)
        
        return rs
    }
}

//extension SDChatConversation {
//    override func queryMessages(total: Int, last: SIMChatMessage?, _ finish: ([SIMChatMessage] -> Void)?, _ fail: SIMChatFailBlock?) {
//        super.queryMessages(total, last: last, { [weak self] ms in
//            // 己经完成了
//            guard ms.count < total && !(self?.allLoaded ?? true) else {
//                finish?(ms)
//                return
//            }
//            SIMLog.trace("finish")
//            // 并没有
//            finish?(ms)
//        }, fail)
//    }
//    override func sendMessage(m: SIMChatMessage, isResend: Bool, _ finish: SIMChatFinishBlock?, _ fail: SIMChatFailBlock?) {
//        super.sendMessage(m, isResend: isResend, {
//            // 1秒后完成
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
//                SIMLog.trace("finish")
//                
//                m.status = rand() % 20 == 0 ? .Error : .Sent
//                m.statusChanged()
//                
//                finish?()
//                
//            }
//            // 2秒后收到一条新消息
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
//                let nm = SIMChatMessage(m.content)
//                
//                nm.sender = self.receiver
//                nm.sentTime = m.sentTime
//                nm.receiver = self.receiver
//                nm.receiveTime = .now
//                nm.status = .Unread
//                
//                self.reciveMessageForRemote(nm)
//            }
//        }, fail)
//        
//    }
//}
