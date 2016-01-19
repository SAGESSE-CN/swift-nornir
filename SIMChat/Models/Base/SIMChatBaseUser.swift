//
//  SIMChatBaseUser.swift
//  SIMChat
//
//  Created by sagesse on 1/16/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation

///
/// 聊天用户
///
public class SIMChatBaseUser: SIMChatUserProtocol {
    ///
    /// 初始化
    ///
    public required init(
        identifier: String,
        name: String? = nil,
        portrait: String? = nil) {
            self.identifier = identifier
            self.name = name
            self.portrait = portrait
    }
    ///
    /// 用户ID(唯一标识符)
    ///
    public var identifier: String
    ///
    /// 昵称, 如果为空, 将直接显示用户ID
    ///
    public var name: String?
    ///
    /// 用户头像<br>
    /// 一个完整的URL<br>
    /// http://domain:port/path?query=value
    ///
    public var portrait: String?
    
    ///
    /// 用户类型, 默认为User
    ///
    public var type: SIMChatUserType = .User
    ///
    /// 用户类型, 该属性只对User类型有效, 默认为Unknow
    ///
    public var gender: SIMChatUserGender = .Unknow
    
    ///
    /// 创建一个新的用户
    ///
    /// - parameter identifier: 唯一标识符
    /// - parameter name:       昵称
    /// - parameter portrait:   头像
    /// - returns: 用户
    ///
    public class func user(
        identifier: String,
        name: String?,
        portrait: String?) -> SIMChatUserProtocol {
            return self.init(
                identifier: identifier,
                name: name,
                portrait: portrait)
    }
}
