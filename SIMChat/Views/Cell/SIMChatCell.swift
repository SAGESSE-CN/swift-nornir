//
//  SIMChatCell.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 消息单元格
///
class SIMChatCell: SIMTableViewCell {
    /// 释放
    deinit {
        // 追踪
        SIMLog.trace("created count \(--self.dynamicType.createdCount)")
    }
    /// 构建
    override func build() {
        // 追踪
        SIMLog.trace("created count \(++self.dynamicType.createdCount)")
        
        super.build()
        self.clipsToBounds = true
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    ///
    /// 重新加载数据.
    ///
    /// :param: u   当前用户
    /// :param: m   需要显示的消息
    ///
    func reloadData(m: SIMChatMessage, ofUser u: SIMChatUser2?) {
        // 更新用户数据 
        self.user = u
        self.message = m
        // 更新显示类型
        self.style = (m.sender == u ? .Right : .Left)
    }
    ///
    /// 计算高度, 在计算之前需要设置好约束和数据
    ///
    /// :returns: 合适的大小
    ///
    override func systemLayoutSizeFittingSize(targetSize: CGSize) -> CGSize {
        // 更新
        self.layoutIfNeeded()
        // 实现计算的是contentView的大小
        let s = contentView.systemLayoutSizeFittingSize(targetSize)
        // 然后修正
        return CGSizeMake(s.width, s.height + 1)
    }
    /// 允许响应
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    /// 检查是否使用该菜单
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        // 允许使用删除
        if action == "chatCellDelete:" {
            return true
        }
        return false
    }
    
    /// 显示类型
    var style = SIMChatCellStyle.Left
    /// 是否可用
    var enabled = true
    
    /// 代理.
    weak var delegate: SIMChatCellDelegate?
    
    private(set) var user: SIMChatUser2?                // 当前用户
    private(set) var message: SIMChatMessage?          // 关联的消息
    
    private(set) static var createdCount = 0
}

// MARK: - Event
extension SIMChatCell {
    /// 删除.
    dynamic func chatCellDelete(sender: AnyObject) {
        self.delegate?.chatCellDidDelete?(self)
    }
    /// 点击
    dynamic func chatCellPress(sender: SIMChatCellEvent) {
        self.delegate?.chatCellDidPress?(self, withEvent: sender)
    }
    /// 长按
    dynamic func chatCellLongPress(sender: SIMChatCellEvent) {
        self.delegate?.chatCellDidLongPress?(self, withEvent: sender)
    }
}

// MARK: - Delegate
@objc protocol SIMChatCellDelegate : NSObjectProtocol {
    
    optional func chatCellDidCopy(chatCell: SIMChatCell)
    optional func chatCellDidDelete(chatCell: SIMChatCell)
    
    optional func chatCellDidReSend(chatCell: SIMChatCell)
    
    optional func chatCellDidPress(chatCell: SIMChatCell, withEvent event: SIMChatCellEvent)
    optional func chatCellDidLongPress(chatCell: SIMChatCell, withEvent event: SIMChatCellEvent)
    
}

/// 类型
enum SIMChatCellStyle : Int {
    case Left
    case Right
}

/// 事件源
enum SIMChatCellEventType : Int {
    case Bubble         // 气泡
    case VisitCard      // 名片
    case Portrait       // 头像
}

/// 事件
class SIMChatCellEvent : NSObject {
    init(_ type: SIMChatCellEventType, _ sender: AnyObject? = nil, _ event: UIEvent? = nil, _ extra: AnyObject? = nil) {
        self.type = type
        self.event = event
        self.sender = sender
        self.extra = extra
        super.init()
    }
    var type: SIMChatCellEventType
    var event: UIEvent?
    var sender: AnyObject?
    var extra: AnyObject?
}
