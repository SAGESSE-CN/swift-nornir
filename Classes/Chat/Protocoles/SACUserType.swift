//
//  SACUserType.swift
//  SAChat
//
//  Created by sagesse on 30/12/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import Foundation

@objc public protocol SACUserType: class {
    
    /// 用户ID(唯一标识符)
    var identifier: String { get }
    
    /// 昵称
    var name: String? { get }
    /// 用户头像
    var portrait: String? { get }
    
//    ///
//    /// 用户类型, 默认为User
//    ///
//    var type: SIMChatUserType { get }
//    ///
//    /// 用户类型, 该属性只对User类型有效, 默认为Unknow
//    /// - TODO: 这个类型不应该放在这里.
//    ///
//    var gender: SIMChatUserGender { get }
//    
//    ///
//    /// 创建一个新的用户
//    ///
//    /// - parameter identifier: 唯一标识符
//    /// - parameter name:       昵称
//    /// - parameter portrait:   头像
//    /// - returns: 用户
//    ///
//    static func user(_ identifier: String, name: String?, portrait: String?) -> SACUserType
}

//// MARK: - Convenience
//
//extension SACUserType {
//    ///
//    /// 创建用户(便利版本)
//    ///
//    /// - parameter identifier: 唯一标识符
//    /// - parameter name:       昵称
//    /// - parameter portrait:   头像
//    /// - returns: 用户
//    ///
//    public static func user(_ identifier: String) -> SACUserType {
//        return user(identifier, name: nil)
//    }
//    ///
//    /// 创建用户(便利版本)
//    ///
//    /// - parameter identifier: 唯一标识符
//    /// - parameter name:       昵称
//    /// - parameter portrait:   头像
//    /// - returns: 用户
//    ///
//    public static func user(_ identifier: String, name: String?) -> SACUserType {
//        return user(identifier, name: nil, portrait: nil)
//    }
//}
//
//// MARK: - User compare
//
//public func !=(lhs: SACUserType, rhs: SACUserType?) -> Bool {
//    return !(lhs == rhs)
//}
//public func ==(lhs: SACUserType, rhs: SACUserType?) -> Bool {
//    return lhs.type == rhs?.type && lhs.identifier == rhs?.identifier
//}
//
//// MARK: - User Other Type
//
/////
///// 用户性别
/////
//public enum SIMChatUserGender: Int {
//    case unknow
//    case male
//    case female
//}
//
/////
///// 用户类型
/////
//public enum SIMChatUserType: Int {
//    case user
//    case group
//    case system
//}
//
//
//public let SIMChatUserInfoDidChangeNotification = "SIMChatUserInfoDidChangeNotification"
