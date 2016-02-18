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
        
        _allMessageCells = [
            SIMChatMessageUnknowContentKey:     SIMChatBaseMessageUnknowCell.self,
            SIMChatMessageTimeLineContentKey:   SIMChatBaseMessageTimeLineCell.self,
            
            SIMChatMessageRevokedContentKey:    SIMChatBaseMessageTipsCell.self,
            SIMChatMessageDestoryedContentKey:  SIMChatBaseMessageTipsCell.self,
            
            NSStringFromClass(SIMChatBaseMessageTextContent.self):    SIMChatBaseMessageTextCell.self,
            NSStringFromClass(SIMChatBaseMessageTipsContent.self):    SIMChatBaseMessageTipsCell.self,
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
    /// 显示内容时使用的类型
    ///
    private var _allMessageCells: Dictionary<String, SIMChatMessageCellProtocol.Type> = [:]
}

// MARK: - Register

extension SIMChatClassProvider {
    
    ///
    /// 获取所有己经注册的Cell
    ///
    public func registeredAllCells() -> Dictionary<String, SIMChatMessageCellProtocol.Type> {
        return _allMessageCells
    }
    
    ///
    /// 注册显示内容时使用的类型
    ///
    public func registerCell(contentType: SIMChatMessageContentProtocol.Type, viewType: SIMChatMessageCellProtocol.Type) {
        return _allMessageCells[NSStringFromClass(contentType)] = viewType
    }
    ///
    /// 获取注册的Cell
    ///
    public func registeredCell(content: SIMChatMessageContentProtocol) -> (String, SIMChatMessageCellProtocol.Type)? {
        let type = content.dynamicType
        let key = NSStringFromClass(type)
        // 获取己之兼容的类型
        let idx = _allMessageCells.indexOf {
            if $0.0 == key {
                return true
            }
            return (content as AnyObject).isKindOfClass($0.1)
        }
        if let idx = idx {
            return _allMessageCells[idx]
        }
        return nil
    }
    
    ///
    /// 注册未知消息时显示的Cell
    ///
    public func registerUnknowCell(viewType: SIMChatMessageCellProtocol.Type) {
        return _allMessageCells[SIMChatMessageUnknowContentKey] = viewType
    }
    ///
    /// 获取未知消息时显示的Cell
    ///
    public func registeredUnknowCell() -> SIMChatMessageCellProtocol.Type {
        return _allMessageCells[SIMChatMessageUnknowContentKey]!
    }
    
    ///
    /// 注册撤销时显示的Cell
    ///
    public func registerRevokedCell(viewType: SIMChatMessageCellProtocol.Type) {
        return _allMessageCells[SIMChatMessageRevokedContentKey] = viewType
    }
    ///
    /// 获取撤销时显示的Cell
    ///
    public func registeredRevokedCell() -> SIMChatMessageCellProtocol.Type {
        return _allMessageCells[SIMChatMessageRevokedContentKey]!
    }
    
    ///
    /// 注册销毁时显示的Cell
    ///
    public func registerDestoryedCell(viewType: SIMChatMessageCellProtocol.Type) {
        return _allMessageCells[SIMChatMessageDestoryedContentKey] = viewType
    }
    ///
    /// 获取销毁时显示的Cell
    ///
    public func registeredDestoryedCell() -> SIMChatMessageCellProtocol.Type {
        return _allMessageCells[SIMChatMessageDestoryedContentKey]!
    }
    
    ///
    /// 注册显示日期时显示的Cell
    ///
    public func registerTimeLineCell(viewType: SIMChatMessageCellProtocol.Type) {
        return _allMessageCells[SIMChatMessageTimeLineContentKey] = viewType
    }
    ///
    /// 获取显示日期时显示的Cell
    ///
    public func registeredTimeLineCell() -> SIMChatMessageCellProtocol.Type {
        return _allMessageCells[SIMChatMessageDestoryedContentKey]!
    }
}

/// 未知的消息的Key
public let SIMChatMessageUnknowContentKey = "SIMChat.Message.Unknow"
/// 撤消的消息的Key
public let SIMChatMessageRevokedContentKey = "SIMChat.Message.Revoked"
/// 销毁的消息的Key
public let SIMChatMessageDestoryedContentKey = "SIMChat.Message.Destroyed"
/// 日期的消息的Key
public let SIMChatMessageTimeLineContentKey = "SIMChat.Message.TimeLine"
