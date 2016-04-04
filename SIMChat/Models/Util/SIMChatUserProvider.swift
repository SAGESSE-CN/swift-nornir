//
//  SIMChatUserProvider.swift
//  SIMChat
//
//  Created by sagesse on 1/15/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation

///
/// 用户信息提供者
///
public class SIMChatUserProvider {
    /// 初始化
    public init(manager: SIMChatManager) {
        self.users = [:]
        self.manager = manager
    }
    
    private var users: Dictionary<String, SIMChatUserProtocol>
    private weak var manager: SIMChatManager?
}

extension SIMChatUserProvider {
    ///
    /// 更新用户信息
    ///
    /// - parameter user: 新的用户信息
    ///
    func updateUser(user: SIMChatUserProtocol) {
    }
    ///
    /// 获取用户信息
    ///
    /// - parameter identifier: 用户的唯一标识
    ///
    func userWithIdentifier(identifier: String) -> SIMChatUserProtocol {
        if let user = users[identifier] {
            return user
        }
        fatalError()
//        // 创建
//        let user = manager!.classProvider.user.user(identifier)
//        users[identifier] = user
//        return user
    }
    ///
    /// 获取用户详细信息
    ///
    /// - parameter identifier: 用户的唯一标识
    ///
    func userDetailWithIdentifier(identifier: String) -> SIMChatUserProtocol {
        let user = userWithIdentifier(identifier)
        // 如果详情没有加载. 继续加载.
        if true {
        }
        return user
    }
}
