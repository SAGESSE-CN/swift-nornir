//
//  SIMChatBaseFileResource.swift
//  SIMChat
//
//  Created by sagesse on 3/4/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation

///
/// 文件资源
///
public class SIMChatBaseFileResource: SIMChatResourceProtocol {
    /// 实际内容
    public enum Value {
        case url(Foundation.URL)
        case path(String)
        case custom(AnyObject)
    }
    
    /// 连接
    public init(_ URL: Foundation.URL) {
        value = .url(URL)
    }
    /// 地址
    public init(_ path: String) {
        value = .path(path)
    }
    /// 自定义数据
    public init(_ custom: AnyObject) {
        value = .custom(custom)
    }
    
    /// 资源id
    public let identifier: String = UUID().uuidString
    /// 资源链接
    public var resourceURL: URL {
        switch value {
        case .url(let URL):
            return URL
        case .path(let path):
            return URL(fileURLWithPath: path)
        case .custom(_):
            return URL(string: "simchat://custom")!
        }
    }
    
    ///
    /// 获取资源
    ///
    /// - parameter closure: 结果回调
    ///
    public func resource(_ closure: (SIMChatResult<AnyObject, NSError>) -> Void) {
        // no imp
    }
    
    /// 内容
    public let value: Value
}
