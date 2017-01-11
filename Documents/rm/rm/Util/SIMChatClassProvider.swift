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
    private init() {
//        user = SIMChatBaseUser.self
//        message = SIMChatBaseMessage.self
//        conversation = SIMChatBaseConversation.self
        
//        _allMessageCells = [
//            SIMChatUnknowMessageKey:     SIMChatUnknowMessageCell.self,
//            SIMChatTimeLineMessageKey:   SIMChatTimeLineMessageCell.self,
//            
////            SIMChatRevokedMessageKey:    SIMChatBaseMessageTipsCell.self,
////            SIMChatDestoryedMessageKey:  SIMChatBaseMessageTipsCell.self,
////            
////            NSStringFromClass(SIMChatBaseMessageTextContent.self):    SIMChatBaseMessageTextCell.self,
////            NSStringFromClass(SIMChatBaseMessageTipsContent.self):    SIMChatBaseMessageTipsCell.self,
////            NSStringFromClass(SIMChatBaseMessageAudioContent.self):   SIMChatBaseMessageAudioCell.self,
////            NSStringFromClass(SIMChatBaseMessageImageContent.self):   SIMChatBaseMessageImageCell.self
//        ]
    }
    
    ///
    /// 显示内容时使用的类型
    ///
    private var _allMessageCells: Dictionary<String, SIMChatMessageCellProtocol.Type> = [:]
    
    ///
    /// 单例
    ///
    public static let sharedInstance: SIMChatClassProvider = SIMChatClassProvider()
    
//}
//
//// MARK: - Register
//
//extension SIMChatClassProvider {
    
    ///
    /// 获取所有己经注册的Cell
    ///
    public func registeredAllCells() -> Dictionary<String, SIMChatMessageCellProtocol.Type> {
        return _allMessageCells
    }
    
    ///
    /// 注册显示内容时使用的类型
    ///
    public func registerCell(_ contentType: SIMChatMessageBody.Type, viewType: SIMChatMessageCellProtocol.Type) {
        return _allMessageCells[NSStringFromClass(contentType)] = viewType
    }
    ///
    /// 获取注册的Cell
    ///
    public func registeredCell(_ content: SIMChatMessageBody) -> (String, SIMChatMessageCellProtocol.Type)? {
        let type = type(of: content)
        let key = NSStringFromClass(type)
        // 获取己之兼容的类型
        let idx = _allMessageCells.index {
            if $0.0 == key {
                return true
            }
            return (content as AnyObject).isKind(of: $0.1)
        }
        if let idx = idx {
            return _allMessageCells[idx]
        }
        return nil
    }
    
    ///
    /// 注册未知消息时显示的Cell
    ///
    public func registerUnknowCell(_ viewType: SIMChatMessageCellProtocol.Type) {
        return _allMessageCells[SIMChatUnknowMessageKey] = viewType
    }
    ///
    /// 获取未知消息时显示的Cell
    ///
    public func registeredUnknowCell() -> SIMChatMessageCellProtocol.Type {
        return _allMessageCells[SIMChatUnknowMessageKey]!
    }
    
    ///
    /// 注册撤销时显示的Cell
    ///
    public func registerRevokedCell(_ viewType: SIMChatMessageCellProtocol.Type) {
        return _allMessageCells[SIMChatRevokedMessageKey] = viewType
    }
    ///
    /// 获取撤销时显示的Cell
    ///
    public func registeredRevokedCell() -> SIMChatMessageCellProtocol.Type {
        return _allMessageCells[SIMChatRevokedMessageKey]!
    }
    
    ///
    /// 注册销毁时显示的Cell
    ///
    public func registerDestoryedCell(_ viewType: SIMChatMessageCellProtocol.Type) {
        return _allMessageCells[SIMChatDestoryedMessageKey] = viewType
    }
    ///
    /// 获取销毁时显示的Cell
    ///
    public func registeredDestoryedCell() -> SIMChatMessageCellProtocol.Type {
        return _allMessageCells[SIMChatDestoryedMessageKey]!
    }
}

/// 未知的消息的Key
public let SIMChatUnknowMessageKey = "SIMChat.Message.Unknow"
/// 日期的消息的Key
public let SIMChatTimeLineMessageKey = "SIMChat.Message.TimeLine"
/// 撤消的消息的Key
public let SIMChatRevokedMessageKey = "SIMChat.Message.Revoked"
/// 销毁的消息的Key
public let SIMChatDestoryedMessageKey = "SIMChat.Message.Destroyed"
