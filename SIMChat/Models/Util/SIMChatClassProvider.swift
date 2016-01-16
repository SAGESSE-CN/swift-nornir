//
//  SIMChatClassProvider.swift
//  SIMChat
//
//  Created by sagesse on 1/15/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation

///
/// 类提供者
///
public class SIMChatClassProvider {
    ///
    /// 初始化
    ///
    public init() {
        user = SIMChatBaseUser.self
        message = SIMChatBaseMessage.self
        conversation = SIMChatBaseConversation.self
        
        unknowCell = SIMChatBaseCell.Unknow.self
        cells = [
            NSStringFromClass(SIMChatBaseContent.Text.self):    SIMChatBaseCell.Text.self,
            NSStringFromClass(SIMChatBaseContent.Tips.self):    SIMChatBaseCell.Tips.self,
            NSStringFromClass(SIMChatBaseContent.Date.self):    SIMChatBaseCell.Date.self,
            NSStringFromClass(SIMChatBaseContent.Audio.self):   SIMChatBaseCell.Audio.self,
            NSStringFromClass(SIMChatBaseContent.Image.self):   SIMChatBaseCell.Image.self
        ]
    }
    
    ///
    /// 用户使用的类型
    ///
    public var user: SIMChatUserProtocol.Type
    ///
    /// 消息使用的类型
    ///
    public var message: SIMChatMessageProtocol.Type
    ///
    /// 会话使用的类型
    ///
    public var conversation: SIMChatConversationProtocol.Type
    
    ///
    /// 显示未知内容时使用的类型
    ///
    public var unknowCell: SIMChatCellProtocol.Type
    ///
    /// 显示内容时使用的类型
    ///
    public private(set) var cells: Dictionary<String, SIMChatCellProtocol.Type> = [:]
}

// MARK: - Register

extension SIMChatClassProvider {
    ///
    /// 注册显示内容时使用的类型
    ///
    public func registerCell(contentType: SIMChatContentProtocol.Type, viewType: SIMChatCellProtocol.Type) {
        return cells[NSStringFromClass(contentType)] = viewType
    }
    ///
    /// 获取显示内容时使用的类型, 如果没有注册返回unknowCell
    ///
    public func cell(contentType: SIMChatContentProtocol.Type) -> SIMChatCellProtocol.Type {
        return cells[NSStringFromClass(contentType)] ?? unknowCell
    }
}