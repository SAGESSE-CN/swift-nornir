//
//  SIMChatUserProtocol.swift
//  SIMChat
//
//  Created by sagesse on 10/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import Foundation

///
/// 抽象的聊天用户协议.
///
public protocol SIMChatUserProtocol: class {
    ///
    /// 昵称, 如果为空, 将直接显示用户ID
    ///
    var name: String? { get }
    ///
    /// 用户头像<br>
    /// 一个完整的URL<br>
    /// http://domain:port/path?query=value
    ///
    var portrait: String? { get }
    ///
    /// 用户ID(唯一标识符)
    ///
    var identifier: String { get }
    
    ///
    /// 用户类型, 默认为User
    ///
    var type: SIMChatUserType { get }
    ///
    /// 用户类型, 该属性只对User类型有效, 默认为Unknow
    /// - TODO: 这个类型不应该放在这里.
    ///
    var gender: SIMChatUserGender { get }
    
    ///
    /// 创建一个新的用户
    ///
    /// - parameter identifier: 唯一标识符
    /// - parameter name:       昵称
    /// - parameter portrait:   头像
    /// - returns: 用户
    ///
    static func user(identifier: String, name: String?, portrait: String?) -> SIMChatUserProtocol
}

// MARK: - Convenience

extension SIMChatUserProtocol {
    ///
    /// 创建用户(便利版本)
    ///
    /// - parameter identifier: 唯一标识符
    /// - parameter name:       昵称
    /// - parameter portrait:   头像
    /// - returns: 用户
    ///
    public static func user(identifier: String) -> SIMChatUserProtocol {
        return user(identifier, name: nil)
    }
    ///
    /// 创建用户(便利版本)
    ///
    /// - parameter identifier: 唯一标识符
    /// - parameter name:       昵称
    /// - parameter portrait:   头像
    /// - returns: 用户
    ///
    public static func user(identifier: String, name: String?) -> SIMChatUserProtocol {
        return user(identifier, name: nil, portrait: nil)
    }
}

// MARK: - User compare

public func !=(lhs: SIMChatUserProtocol, rhs: SIMChatUserProtocol?) -> Bool {
    return !(lhs == rhs)
}
public func ==(lhs: SIMChatUserProtocol, rhs: SIMChatUserProtocol?) -> Bool {
    return lhs.type == rhs?.type && lhs.identifier == rhs?.identifier
}

// MARK: - User Other Type

///
/// 用户性别
///
public enum SIMChatUserGender: Int {
    case Unknow
    case Male
    case Female
}

///
/// 用户类型
///
public enum SIMChatUserType: Int {
    case User
    case Group
    case System
}


public let SIMChatUserInfoDidChangeNotification = "SIMChatUserInfoDidChangeNotification"