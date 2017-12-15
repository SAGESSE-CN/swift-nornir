//
//  Session.swift
//  Nornir
//
//  Created by SAGESSE on 12/13/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import Foundation

public protocol ConversationObserver: class {
    
    func conversation(_ conversation: Conversation, didSend messages: Array<Message>)
    
    func conversation(_ conversation: Conversation, didReceive messages: Array<Message>)
    
    func conversation(_ conversation: Conversation, didRevoke messages: Array<Message>)
    
    func conversation(_ conversation: Conversation, didRemove messages: Array<Message>)
}


open class Conversation {
    
    public init() {
    }
    
//    let sender: User = User()
//    let reciver: User = User()
    
    // 获取历史消息
    func history(with last: Message? = nil, limit: Int = 24, block: () -> ()) {
        block()
    }
    
    // 发送消息
    // 重发消息
    func send(_ message: Message) {
    }
    
    // 删除消息(仅本地)
    func remove(_ message: Message) {
    }
    
    // 撤回消息
    func revoke(_ message: Message) {
        
    }
    
    
    func add(_ observer: ConversationObserver) {
    }
    
    func remove(_ observer: ConversationObserver) {
    }
    
    //
    //    // 新消息/
    //    // 历史
    //
}
