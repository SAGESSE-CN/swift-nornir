//
//  SIMChatInputPanel.swift
//  SIMChat
//
//  Created by sagesse on 2/3/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation

///
/// 输入面板协议
///
public protocol SIMChatInputPanelProtocol: class {
    ///
    /// 回调代理, 这个属性是由Container更新的
    ///
    weak var delegate: SIMChatInputPanelDelegate? { set get }
    ///
    /// 创建获取面板
    ///
    static func inputPanel() -> UIView
    ///
    /// 获取对应的Item
    ///
    static func inputPanelItem() -> SIMChatInputItemProtocol
}

///
/// 输入面板代理
///
public protocol SIMChatInputPanelDelegate: class {
}

