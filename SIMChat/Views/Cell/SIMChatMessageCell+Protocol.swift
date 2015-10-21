//
//  SIMChatMessageCell+Protocol.swift
//  SIMChat
//
//  Created by sagesse on 10/20/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 消息单元格接口
@objc protocol SIMChatMessageCellProtocol {
    /// 类型
    var style: SIMChatMessageCellStyle { set get }
    /// 是否启用
    var enabled: Bool { set get }
    /// 消息内容
    var message: SIMChatMessageProtocol? { set get }
    
    /// 获取大小
    func systemLayoutSizeFittingSize(targetSize: CGSize) -> CGSize
}

// MARK: - Delegate
@objc protocol SIMChatMessageCellDelegate : NSObjectProtocol {
    
    optional func chatCellDidCopy(chatCell: SIMChatMessageCell)
    optional func chatCellDidDelete(chatCell: SIMChatMessageCell)
    
    optional func chatCellDidReSend(chatCell: SIMChatMessageCell)
    
    optional func chatCellDidPress(chatCell: SIMChatMessageCell, withEvent event: SIMChatMessageCellEvent)
    optional func chatCellDidLongPress(chatCell: SIMChatMessageCell, withEvent event: SIMChatMessageCellEvent)
    
}