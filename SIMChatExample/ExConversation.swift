//
//  ExConversation.swift
//  SIMChatExample
//
//  Created by sagesse on 2/3/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import SIMChat
import ImSDK

class ExConversation: SIMChatBaseConversation {
    
    required init(receiver: SIMChatUserProtocol, manager: SIMChatManager) {
        super.init(receiver: receiver, manager: manager)
//        // load
//        if let manager = manager as? ExManager {
//            self.imp = manager.imp.getConversation(receiver.type.toConversationType(), receiver: receiver.identifier)
//        }
    }

    //var imp: TIMConversation?
    private var _allMessagesIsLoaded: Bool = false
    
    /// 所有消息都己经加载
    override var allMessagesIsLoaded: Bool {
        return _allMessagesIsLoaded
    }
    
//    override func sendMessage(message: SIMChatMessage, isResend: Bool, closure: SIMChatMessageHandler?) {
//        SIMLog.trace()
//        
//        guard let message = message as? ExMessage else {
//            return
//        }
////        imp?.sendMessage(message.imp,
////            succ: {
////                closure?(.Success(message))
////            },
////            fail: { code, error in
////                closure?(.Failure(NSError(domain: error, code: Int(code), userInfo: nil)))
////        })
//    }
    
    override func loadHistoryMessages(last: SIMChatMessage?, count: Int, closure: SIMChatMessagesHandler?) {
        SIMLog.trace()
        
//        imp?.getMessage(Int32(count), last: nil,
//            succ: { arr in
//                let ms = arr.map { self.convert($0 as! TIMMessage) }
//                self._allMessagesIsLoaded = (ms.count < count)
//                self.messages.appendContentsOf(ms)
//                closure?(.Success(ms.reverse()))
//            },
//            fail: { code, error in
//                closure?(.Failure(NSError(domain: error, code: Int(code), userInfo: nil)))
        //            })
        dispatch_after_at_now(0.5, dispatch_get_main_queue()) {
            //                    if rand() % 3 == 0 {
            //                        op.failure(NSError(domain: "", code: 0, userInfo: nil))
            //                        return
            //                    }
            let ms = self.makeRandHistory()
            self.messages.appendContentsOf(ms)
            closure?(.Success(ms))
        }
    }
    
//    func convert(message: TIMMessage) -> SIMChatMessage {
//        let content = message.getElem(0).toSIMChatMessageContent()
//        
//        let s: SIMChatUserProtocol = {
//            if message.sender() == receiver.identifier {
//                return receiver
//            }
//            return sender
//        }()
//        let r: SIMChatUserProtocol = {
//            if message.getConversation().getReceiver() == sender.identifier {
//                return sender
//            }
//            return receiver
//        }()
//        
//        let m = ExMessage(content: content, receiver: r, sender: s, identifier: message.msgId())
//        
//        if message.isReaded() {
//            m.status = .Read
//        } else {
//            m.status = .Unread
//        }
//        
//        m.timestamp = message.timestamp()
//        m.isSelf = message.isSelf()
//        m.imp = message
//        
//        return m
//    }
    
    
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
   
    
    
    func makeRandHistory() -> Array<SIMChatMessage> {
        var rs: Array<SIMChatMessage> = []
        
        let path = SIMChatBaseImageResource(NSBundle.mainBundle().pathForResource("t1", ofType: "jpg")!)
        let tpath = SIMChatBaseImageResource(NSBundle.mainBundle().pathForResource("t1_t", ofType: "jpg")!)
        let size = CGSizeMake(1600, 1200)
        
        let path2 = SIMChatBaseImageResource(NSBundle.mainBundle().pathForResource("t2", ofType: "jpg")!)
        let tpath2 = SIMChatBaseImageResource(NSBundle.mainBundle().pathForResource("t2_t", ofType: "jpg")!)
        let size2 = CGSizeMake(1115, 1600)
        
        let apath = SIMChatBaseAudioResource(NSBundle.mainBundle().pathForResource("m1", ofType: "m4a")!)
        
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
                let m = SIMChatBaseMessage(content: c, receiver: o, sender: s)
                //m.option = [.TimeLineHidden]
                m.timestamp = NSDate(timeIntervalSinceNow: i + 3)
                m.status = status
                rs.append(m)
            }
            
            if true || (rand() % 10) < 6 {
                let c = SIMChatBaseMessageTextContent(content: makeRandText())
                let m = SIMChatBaseMessage(content: c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (r % 2 == 0)
                m.status = status
                m.timestamp = NSDate(timeIntervalSinceNow: i + 0)
                rs.append(m)
            }
            if true || (rand() % 10) < 6 {
                let c = SIMChatBaseMessageTextContent(content: makeRandText())
                let m = SIMChatBaseMessage(content: c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (r % 2 == 0)
                m.status = status
                m.timestamp = NSDate(timeIntervalSinceNow: i + 0)
                rs.append(m)
            }
            
            if true || (rand() % 10) == 2 {
                let c = SIMChatBaseMessageImageContent(origin: path, thumbnail: tpath, size: size)
                let m = SIMChatBaseMessage(content: c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (r % 2 == 0)
                m.status = status
                m.timestamp = NSDate(timeIntervalSinceNow: i + 1)
                rs.append(m)
            }
            if true || (rand() % 10) == 2 {
                let c = SIMChatBaseMessageImageContent(origin: path2, thumbnail: tpath2, size: size2)
                let m = SIMChatBaseMessage(content: c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (r % 2 == 0)
                m.status = status
                m.timestamp = NSDate(timeIntervalSinceNow: i + 1)
                rs.append(m)
            }
            
            if true || (rand() % 10) < 2 {
                let c = SIMChatBaseMessageAudioContent(origin: apath, duration: 6.2 * Double((r % 3600) + 1))
                let m = SIMChatBaseMessage(content: c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (r % 2 == 0)
                m.status = status
                m.timestamp = NSDate(timeIntervalSinceNow: i + 2)
                rs.append(m)
            }
            if true || (rand() % 10) < 2 {
                let c = SIMChatBaseMessageAudioContent(origin: apath, duration: 6.2 * Double((r % 3600) + 1))
                let m = SIMChatBaseMessage(content: c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (r % 2 == 0)
                m.status = status
                m.timestamp = NSDate(timeIntervalSinceNow: i + 2)
                rs.append(m)
            }
            
            if true || (rand() % 10) < 3 {
                let c = SIMChatBaseMessageTipsContent(content: "this is a tips\nThis is a very long long long long long long long long the tips")
                let m = SIMChatBaseMessage(content: c, receiver: o, sender: s)
                m.option = [.TimeLineHidden]
                m.timestamp = NSDate(timeIntervalSinceNow: i + 3)
                m.status = status
                rs.append(m)
            }
            if true || (rand() % 20) == 0  {
                let c = NSNull()
                let m = SIMChatBaseMessage(content: c, receiver: o, sender: s)
                m.option = [.TimeLineHidden]
                m.status = status
                m.timestamp = NSDate(timeIntervalSinceNow: i + 4)
                rs.append(m)
            }
        }
        
        return rs
    }
}
