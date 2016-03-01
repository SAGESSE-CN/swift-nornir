//
//  SIMChatParserProtocol.swift
//  SIMChat
//
//  Created by sagesse on 3/1/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation

///
/// 解释器协议
///
public protocol SIMChatParserProtocol: class {
    ///
    /// 解释器的标识符
    ///
    var identifier: String { get }
    ///
    /// 解码
    ///
    /// - parameter URL:        包含信息的地址
    /// - parameter success:    成功回调, 参数1为结果
    /// - parameter fail:       失败回调, 参数1为错误信息
    ///
    func decode(URL: NSURL, success: (AnyObject -> Void)?, fail: (NSError -> Void)?)
}