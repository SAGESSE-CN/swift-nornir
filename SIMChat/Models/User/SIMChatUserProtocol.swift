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
    
    /// 用户名
    var name: String? { get }
    /// 用户头像
    var portrait: String? { get }
    /// 用户唯一标识符
    var identifier: String { get }
}

/// 用户性别
@objc enum SIMChatUserGender : Int {
    case Unknow     /// 未知
    case Male       /// 男
    case Female     /// 女
}

/// 比较两个用户
func ==(lhs: SIMChatUserProtocol, rhs: SIMChatUserProtocol?) -> Bool {
    return lhs.identifier == rhs?.identifier
}