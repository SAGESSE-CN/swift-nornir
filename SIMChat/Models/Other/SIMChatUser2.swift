//
//  SIMChatUser2.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// ### 用户模型
/// - TODO: 其他属性以后再扩展
///
class SIMChatUser2: NSObject {
    
    /// 初始化
    init(identifier: String, name: String? = nil, gender: Int = 0, portrait: NSURL? = nil) {
        self.identifier = identifier
        self.name = name
        self.gender = gender
        self.portrait = portrait
        super.init()
    }
   
    /// 用户标识符
    var identifier: String
    /// 用户名
    var name: String?
    /// 用户头像
    var portrait: NSURL?
    
    /// 0未知, 1男, 1女
    var gender: Int = 0
    
    /// 附加数据
    var extra: AnyObject?
}

/// assign
extension SIMChatUser2 {
    /// 覆盖
    func assign(other: SIMChatUser2) {
        self.identifier = other.identifier
        self.name = other.name
        self.portrait = other.portrait
        self.gender = other.gender
        self.extra = other.extra
    }
}

/// 比较两个用户
func ==(lhs: SIMChatUser2?, rhs: SIMChatUser2?) -> Bool {
    return lhs === rhs || lhs?.identifier == rhs?.identifier
}
