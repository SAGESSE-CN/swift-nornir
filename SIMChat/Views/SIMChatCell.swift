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
    /// 构建
    override func build() {
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
    func reloadData(m: SIMChatMessage, ofUser u: SIMChatUser?) {
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
    
    private(set) var user: SIMChatUser?                // 当前用户
    private(set) var message: SIMChatMessage?          // 关联的消息
}

/// MARK: - /// Type
extension SIMChatCell {
    /// 类型
    enum SIMChatCellStyle : Int {
        case Left
        case Right
    }
}

/// MARK: - /// Event 
extension SIMChatCell {
    /// 删除.
    dynamic func chatCellDelete(sender: AnyObject?) {
        SIMLog.trace()
        //delegate?.chatCellDidDelete?(self)
    }
}

/// MARK: - /// 代理
@objc protocol SIMChatCellDelegate : NSObjectProtocol {
    
    ///
    optional func chatCellDidDelete(chatCell: SIMChatCell)
    optional func chatCellDidCopy(chatCell: SIMChatCell)
    
//    /// 点击消息
//    optional func chatCellWillPress(chatCell: SIMChatCell, withEvent event: SIMChatCellEvent) -> Bool
//    optional func chatCellDidPress(chatCell: SIMChatCell, withEvent event: SIMChatCellEvent)
//    
//    /// 长按消息
//    optional func chatCellWillLongPress(chatCell: SIMChatCell, withEvent event: SIMChatCellEvent) -> Bool
//    optional func chatCellDidLongPress(chatCell: SIMChatCell, withEvent event: SIMChatCellEvent)
}