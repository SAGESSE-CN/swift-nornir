//
//  SIMChatResourceProtocol.swift
//  SIMChat
//
//  Created by sagesse on 3/4/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation

///
/// 资源协议
///
public protocol SIMChatResourceProtocol {
    /// 资源id
    var identifier: String { get }
    /// 资源链接
    var resourceURL: NSURL { get }
    
    ///
    /// 获取资源
    ///
    /// - parameter closure: 结果回调
    ///
    func resource(closure: SIMChatResult<AnyObject, NSError> -> Void)
}