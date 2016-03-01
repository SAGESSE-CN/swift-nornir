//
//  SIMChatBaseFileParser.swift
//  SIMChat
//
//  Created by sagesse on 3/1/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation

///
/// 基础解释器
///
public class SIMChatBaseFileParser: SIMChatParserProtocol {
    
    ///
    /// 获取实例
    ///
    public static func sharedInstance() -> SIMChatBaseFileParser {
        return _sharedInstance
    }
    
    // MARK: SIMChatParserProtocol
    
    ///
    /// 解释器的标识符
    ///
    public let identifier: String = "sa"
    ///
    /// 解码
    ///
    /// - parameter URL:        包含信息的地址
    /// - parameter success:    成功回调, 参数1为结果
    /// - parameter fail:       失败回调, 参数1为错误信息
    ///
    public func decode(URL: NSURL, success: (AnyObject -> Void)?, fail: (NSError -> Void)?) {
        do {
            guard let value = URL.fragment, type = URL.path else {
                throw NSError(domain: "support URL", code: -1, userInfo: nil)
            }
            switch type {
            case "/path":
                // 加载文件
                success?(value)
            case "/net":
                // 加载网络文件
                // TODO: not imp
                fatalError("not imp") // 未实现
                //success?(value)
            default:
                throw NSError(domain: "support type", code: -1, userInfo: nil)
            }
        } catch let error as NSError {
            fail?(error)
        }
    }
    
    // MARK: Encode
    
    ///
    /// 包装
    ///
    public func encode(path: String) -> NSURL {
        let uc = NSURLComponents()
        
        uc.scheme = "simchat"
        uc.host = "swift.im.sa"
        uc.user = identifier
        uc.path = "/path"
        uc.fragment = path
        
        return uc.URL!
    }
    ///
    /// 包装
    ///
    public func encode(URL: NSURL) -> NSURL {
        let uc = NSURLComponents()
        
        uc.scheme = "simchat"
        uc.host = "swift.im.sa"
        uc.user = identifier
        uc.path = "/net"
        uc.fragment = URL.absoluteString
        
        return uc.URL!
    }
    
    /// 禁止创建
    private init() { }
    /// 唯一实例
    private static var _sharedInstance = SIMChatBaseFileParser()
}