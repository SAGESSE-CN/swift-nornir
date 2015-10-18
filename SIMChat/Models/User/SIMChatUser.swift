//
//  SIMChatUser.swift
//  SIMChat
//
//  Created by sagesse on 10/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 普通用户
class SIMChatUser : NSObject, SIMChatUserProtocol {
    /// 初始化
    init(identifier: String, name: String? = nil, portrait: String? = nil, gender: SIMChatUserGender = .Unknow) {
        self.name = name
        self.gender = gender
        self.portrait = portrait
        self.identifier = identifier
        super.init()
    }
    var gender: SIMChatUserGender
    
    /// 附加数据
    var extra: AnyObject?
    
    /// 用户名
    var name: String?
    /// 用户头像
    var portrait: String?
    /// 用户唯一标识符
    let identifier: String
    /// 用户类型
    var type: SIMChatUserType {
        return .C2C
    }
}

/// 用户性别
enum SIMChatUserGender {
    case Unknow     /// 未知
    case Male       /// 男
    case Female     /// 女
}