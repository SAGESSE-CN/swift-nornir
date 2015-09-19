//
//  SIMChatUser.swift
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
class SIMChatUser: NSObject {
    
    /// 初始化
    init(identifier: String, name: String? = nil, portrait: NSURL? = nil) {
        self.identifier = identifier
        self.name = name
        self.portrait = portrait
        super.init()
    }
   
    /// 用户标识符
    var identifier: String
    /// 用户名
    var name: String?
    /// 用户头像
    var portrait: NSURL?
    
    /// 附加数据
    var extra: AnyObject?
}

/// 比较两个用户
func ==(lhs: SIMChatUser?, rhs: SIMChatUser?) -> Bool {
    return lhs === rhs || lhs?.identifier == rhs?.identifier
}