//
//  SIMChatUserProtocol.swift
//  SIMChat
//
//  Created by sagesse on 10/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 用户
@objc protocol SIMChatUserProtocol {
    /// 用户类型
    var type: SIMChatUserType { get }
    /// 用户唯一标识符
    var identifier: String { get }
    /// 用户名
    var name: String? { get }
    /// 用户头像
    var portrait: String? { get }
}

/// 用户类型
@objc enum SIMChatUserType : Int {
    /// 单聊
    case C2C
    /// 群聊
    case Group
    /// 讨论组
    case Discussion
    /// 公众号
    case Robot
    /// 系统消息
    case System
}

/// 比较两个用户
func ==(lhs: SIMChatUserProtocol?, rhs: SIMChatUserProtocol?) -> Bool {
    return lhs === rhs || (lhs?.type == rhs?.type && lhs?.identifier == rhs?.identifier)
}