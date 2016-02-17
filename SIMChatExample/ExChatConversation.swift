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

    override func loadHistoryMessages(last: SIMChatMessageProtocol?, count: Int) -> SIMChatRequest<Array<SIMChatMessageProtocol>> {
            return SIMChatRequest.request { op in
                dispatch_after_at_now(0.5, dispatch_get_main_queue()) {
                    op.success(self.makeRandHistory())
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
    func makeRandHistory() -> Array<SIMChatMessageProtocol> {
        var rs: Array<SIMChatMessageProtocol> = []
        
        let path = NSBundle.mainBundle().pathForResource("t1", ofType: "jpg")!
        
        while rs.count < 10 {
            let r = rand()
            
            let o = (r % 2 == 0) ? receiver : sender
            let s = (r % 2 == 0) ? sender   : receiver
            if (rand() % 10) < 6 {
                let c = SIMChatBaseMessageTextContent(content: makeRandText())
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (r % 2 == 0)
                m.status = .Sending
                rs.append(m)
            }
            if (rand() % 10) == 2 {
                let c = SIMChatBaseMessageImageContent(remote: path, size: CGSizeMake(640, 480))
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (r % 2 == 0)
                m.status = .Receiving
                rs.append(m)
            }
            if (rand() % 10) < 2 {
                let c = SIMChatBaseMessageAudioContent(remote: path, duration: 6.2 * Double((r % 3600) + 1))
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (r % 2 == 0)
                m.status = .Error
                rs.append(m)
            }
            if (rand() % 50) < 1 {
                let c = SIMChatBaseMessageDateContent()
                rs.append(SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s))
            }
            if (rand() % 10) < 3 {
                let c = SIMChatBaseMessageTipsContent(content: "this is a tips\nThis is a very long long long long long long long long the tips")
                rs.append(SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s))
            }
            if (rand() % 20) == 0  {
                let c = Unknow()
                rs.append(SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s))
            }
        }
        
        return rs
    }
    
    
    func makeTestData() {
        
        let path = NSBundle.mainBundle().pathForResource("t1", ofType: "jpg")!
        
        for i in 0 ..< 1 {
            let o = (i % 2 == 0) ? receiver : sender
            let s = (i % 2 == 0) ? sender   : receiver
            if true {
                let c = SIMChatBaseMessageTextContent(content: "this is a tips\nThis is a very long long long long long long long long the tips")
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (i % 2 == 0)
                m.status = .Sending
                messages.append(m)
            }
            if true {
                let c = SIMChatBaseMessageImageContent(remote: path, size: CGSizeMake(640, 480))
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (i % 2 == 0)
                m.status = .Receiving
                messages.append(m)
            }
            if true {
                let c = SIMChatBaseMessageAudioContent(remote: path, duration: 6.2 * Double(i + 1))
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (i % 2 == 0)
                m.status = .Error
                messages.append(m)
            }
            if true {
                let c = SIMChatBaseMessageDateContent()
                messages.append(SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s))
            }
            if true {
                let c = SIMChatBaseMessageTipsContent(content: "this is a tips\nThis is a very long long long long long long long long the tips")
                messages.append(SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s))
            }
            if true {
                let c = Unknow()
                messages.append(SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s))
            }
        }
    }
    
    var allLoaded = false
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
