//
//  SIMChatUser2Manager.swift
//  SIMChat
//
//  Created by sagesse on 9/27/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/////
///// 用户管理器
/////
//class SIMChatUser2Manager: NSObject {
////    /// 获取用户
////    subscript (identifier: String) -> SIMChatUserProtocol {
////        set {
////            // 更新
//////            if let oldValue = self.caches.updateValue(newValue, forKey: identifier) {
//////                // 覆盖更新
//////                // TODO: update
//////                //oldValue.assign(newValue)
//////            }
////            // 改变了, 发出通知
////            SIMChatNotificationCenter.postNotificationName(SIMChatUser2InfoChangedNotification, object: newValue)
////        }
////        get {
////            // 如果缓存了, 直接使用
////            if let user = self.caches[identifier] {
////                return user
////            }
////            // 没有缓存
////            let user = SIMChatUser(identifier: identifier, name: nil, portrait: nil, gender: .Unknow)
////            // 请求详情
////            self.delegate?.chatUserManager?(self, willRequestDetailInfo: user)
////            // 先认为是请求完成的避免重复请求
////            self.caches[identifier] = user
////            // ok
////            return user
////        }
////    }
//    /// 用户信息缓存
//    var caches = Dictionary<String, SIMChatUserProtocol>()
//    /// 缓存的用户数量
//    var count: Int {
//        return caches.count
//    }
//    
//    /// 代理
//    weak var delegate: SIMChatUser2ManagerDelegate?
//    
//    /// 单例
//    static let sharedManager = SIMChatUser2Manager()
//}
//
//// Delegate
//@objc protocol SIMChatUser2ManagerDelegate : NSObjectProtocol {
//    optional func chatUserManager(chatUserManager: SIMChatUser2Manager, willRequestDetailInfo user: SIMChatUserProtocol)
//}
//
/// 用户信息改变通知
//let SIMChatUser2InfoChangedNotification = "SIMChatUser2InfoChangedNotification"