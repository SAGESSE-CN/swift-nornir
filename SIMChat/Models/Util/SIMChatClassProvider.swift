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
        
        unknowCell = SIMChatBaseMessageUnknowCell.self
        cells = [
            NSStringFromClass(SIMChatBaseMessageTextContent.self):    SIMChatBaseMessageTextCell.self,
            NSStringFromClass(SIMChatBaseMessageTipsContent.self):    SIMChatBaseMessageTipsCell.self,
            NSStringFromClass(SIMChatBaseMessageDateContent.self):    SIMChatBaseMessageDateCell.self,
            NSStringFromClass(SIMChatBaseMessageAudioContent.self):   SIMChatBaseMessageAudioCell.self,
            NSStringFromClass(SIMChatBaseMessageImageContent.self):   SIMChatBaseMessageImageCell.self
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
    public var unknowCell: SIMChatMessageCellProtocol.Type
    ///
    /// 显示内容时使用的类型
    ///
    public private(set) var cells: Dictionary<String, SIMChatMessageCellProtocol.Type> = [:]
}

// MARK: - Register

extension SIMChatClassProvider {
    ///
    /// 注册显示内容时使用的类型
    ///
    public func registerCell(contentType: SIMChatMessageContentProtocol.Type, viewType: SIMChatMessageCellProtocol.Type) {
        return cells[NSStringFromClass(contentType)] = viewType
    }
    ///
    /// 获取显示内容时使用的类型, 如果没有注册返回unknowCell
    ///
    public func cell(contentType: SIMChatMessageContentProtocol.Type) -> SIMChatMessageCellProtocol.Type {
        return cells[NSStringFromClass(contentType)] ?? unknowCell
    }
}