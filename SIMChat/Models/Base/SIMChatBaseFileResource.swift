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
        case URL(NSURL)
        case Path(String)
        case Custom(AnyObject)
    }
    
    /// 连接
    public init(_ URL: NSURL) {
        value = .URL(URL)
    }
    /// 地址
    public init(_ path: String) {
        value = .Path(path)
    }
    /// 自定义数据
    public init(_ custom: AnyObject) {
        value = .Custom(custom)
    }
    
    /// 资源id
    public let identifier: String = NSUUID().UUIDString
    /// 资源链接
    public var resourceURL: NSURL {
        switch value {
        case .URL(let URL):
            return URL
        case .Path(let path):
            return NSURL(fileURLWithPath: path)
        case .Custom(_):
            return NSURL(string: "simchat://custom")!
        }
    }
    
    ///
    /// 获取资源
    ///
    /// - parameter closure: 结果回调
    ///
    public func resource(closure: SIMChatResult<AnyObject, NSError> -> Void) {
        // no imp
    }
    
    /// 内容
    public let value: Value
}
