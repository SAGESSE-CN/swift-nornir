//
//  SIMChatEmoticonGroupProtocol.swift
//  SIMChat
//
//  Created by sagesse on 2/10/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation

///
/// 一组表情
///
public protocol SIMChatEmoticonGroup: class {
    
    ///
    /// 唯一id
    ///
    var identifier: String { get }
    ///
    /// 图标
    ///
    var icon: UIImage? { get }
    ///
    /// 组名
    ///
    var name: String? { get }
    
    ///
    /// 该组表情所有的表情
    ///
    var emoticons: Array<SIMChatEmoticon> { get }
    
    ///
    /// 子组
    ///
    var groups: Array<SIMChatEmoticonGroup>? { get }
    
    ///
    /// 该组默认显示, 如果全部没有指定 那显示第一个
    ///
    var isDefault: Bool { get }
}
