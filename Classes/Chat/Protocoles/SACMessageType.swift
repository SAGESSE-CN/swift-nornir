//
//  SACMessageType.swift
//  SAChat
//
//  Created by sagesse on 30/12/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import Foundation

@objc public protocol SACMessageType: class {
    
    var name: String { get }
    
    // 发送/接收时间
    var date: Date { get }
    
    // 发送者和接收者
    var sender: SACUserType { get }
    var receiver: SACUserType { get }
    
//    open var countOfBytesReceived: Int64 { get }
//    open var countOfBytesSent: Int64 { get }
//    open var countOfBytesExpectedToSend: Int64 { get }
//    open var countOfBytesExpectedToReceive: Int64 { get }
    
    /// 消息内容
    var content: SACMessageContentType { get }
    
    /// 配置信息
    var options: SACMessageOptions { get }
}
