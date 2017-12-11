//
//  SIMChatEmoticonProtocol.swift
//  SIMChat
//
//  Created by sagesse on 2/10/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation

///
/// 表情
///
public protocol SIMChatEmoticon: class {
    ///
    /// 表情码
    ///
    var code: String { get }
    ///
    /// 关联的静态图
    ///
    var png: UIImage? { get }
    ///
    /// 关联的动态图
    ///
    var gif: UIImage? { get }
    ///
    /// 表情类型, 0 图片, 1 Emoji
    ///
    var type: Int { get }
}
