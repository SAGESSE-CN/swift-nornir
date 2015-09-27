//
//  SIMChatUserManager.swift
//  SIMChat
//
//  Created by sagesse on 9/27/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 用户管理器
///
class SIMChatUserManager: NSObject {
    /// 获取用户
    subscript (identifier: String) -> SIMChatUser {
        set {
            // 直接更新
            self.caches[identifier] = newValue
            // 改变了, 发出通知
            SIMChatNotificationCenter.postNotificationName(SIMChatUserInfoChangedNotification, object: newValue)
        }
        get {
            // 如果缓存了, 直接使用
            if let user = self.caches[identifier] {
                return user
            }
            // 没有缓存
            let user = SIMChatUser(identifier: identifier)
            // 请求详情
            self.delegate?.chatUserManager?(self, willRequestDetailInfo: user)
            // 先认为是请求完成的避免重复请求
            self.caches[identifier] = user
            // ok
            return user
        }
    }
    /// 用户信息缓存
    var caches = Dictionary<String, SIMChatUser>()
    /// 缓存的用户数量
    var count: Int {
        return caches.count
    }
    
    /// 代理
    weak var delegate: SIMChatUserManagerDelegate?
    
    /// 单例
    static let sharedManager = SIMChatUserManager()
}

// Delegate
@objc protocol SIMChatUserManagerDelegate : NSObjectProtocol {
    optional func chatUserManager(chatUserManager: SIMChatUserManager, willRequestDetailInfo user: SIMChatUser)
}

/// 用户信息改变通知 
let SIMChatUserInfoChangedNotification = "SIMChatUserInfoChangedNotification"