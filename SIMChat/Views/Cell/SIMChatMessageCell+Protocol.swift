//
//  SIMChatMessageCellProtocol.swift
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
    var message: SIMChatMessageProtocol { set get }
    
    /// 获取大小
    func systemLayoutSizeFittingSize(targetSize: CGSize) -> CGSize
}