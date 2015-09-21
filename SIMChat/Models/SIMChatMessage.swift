//
//  SIMChatMessage.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 消息模型
class SIMChatMessage: NSObject {
    
    /// 消息
    var id = NSUUID().UUIDString
    var type = 0
    var target: String?
    
    /// 发送者, 如果发送者为空, 视为系统消息
    var sender: SIMChatUser?                            // 为nil, 自动隐藏名字
    var sentTime: NSDate = .zero                        // 为0
    //var sentStatus: SIMSentStatus = .Unknow
    
    /// 接收者, 如果接收者为空, 视为广播信息
    var recver: SIMChatUser?
    var recvTime: NSDate = .zero
    //var recvStatus: SIMReceivedStatus = .Unknow
    
    /// 内容
    var extra: AnyObject?
    var content: AnyObject?
    
    /// 其他配置
    var mute = false            // 静音
    var hidden = false          // 透明消息
    var hiddenName = false      // 隐藏名字
    
    /// 辅助信息
    var height = CGFloat(0)     // 为0表示需要计算
}

/// MARK: - /// Time
extension SIMChatMessage {
    
    /// 生成时间
    func makeDateWithMessage(m: SIMChatMessage) {
        
        self.type = m.type
        self.target = m.target
        
        self.sender = nil
        self.sentTime = m.sentTime
        //self.sentStatus = .Unknow
        
        self.recver = nil
        self.recvTime = m.recvTime
        //self.recvStatus = .Unknow
        
        self.extra = nil
        self.content = SIMChatContentDate(date: self.recvTime)
        
        self.mute = true
        self.hidden = false
        self.hiddenName = true
        self.height = 0
    }
}

///
/// 操作符重载
///
func ==(lhs: SIMChatMessage?, rhs: SIMChatMessage?) -> Bool {
    return lhs === rhs || lhs?.id == rhs?.id
}