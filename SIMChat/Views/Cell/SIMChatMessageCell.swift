//
//  SIMChatMessageCell.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 消息单元格(基类!!)
///
class SIMChatMessageCell: SIMTableViewCell, SIMChatMessageCellProtocol {
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
    /// 安装(事件)
    func install() {
    }
    /// 卸载(事件)
    func uninstall() {
    }
    ///
    /// 计算高度, 在计算之前需要设置好约束和数据
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
    
    /// 类型
    var style: SIMChatMessageCellStyle = .Unknow
    /// 消息内容
    var message: SIMChatMessageProtocol? {
        willSet {
            // o(n _ n)o
            if newValue?.ownership ?? false {
                style = .Right
            } else {
                style = .Left
            }
        }
    }
    /// 是否启用
    var enabled: Bool = false {
        didSet {
            // 检查有没有改变
            guard oldValue != enabled else {
                return
            }
            // 检查结果
            if enabled {
                // 安装
                install()
            } else {
                // 卸载
                uninstall()
            }
        }
    }
    /// 代理.
    weak var delegate: SIMChatMessageCellDelegate?
    
    /// 测试计数
    private(set) static var createdCount = 0
}

// MARK: - Event
extension SIMChatMessageCell {
    /// 删除.
    dynamic func chatCellDelete(sender: AnyObject) {
        self.delegate?.chatCellDidDelete?(self)
    }
    /// 点击
    dynamic func chatCellPress(sender: SIMChatMessageCellEvent) {
        self.delegate?.chatCellDidPress?(self, withEvent: sender)
    }
    /// 长按
    dynamic func chatCellLongPress(sender: SIMChatMessageCellEvent) {
        self.delegate?.chatCellDidLongPress?(self, withEvent: sender)
    }
}


/// 类型
@objc enum SIMChatMessageCellStyle : Int {
    case Unknow
    case Left
    case Right
}

/// 事件源
enum SIMChatMessageCellEventType : Int {
    case Bubble         // 气泡
    case VisitCard      // 名片
    case Portrait       // 头像
}

/// 事件
class SIMChatMessageCellEvent : NSObject {
    init(_ type: SIMChatMessageCellEventType, _ sender: AnyObject? = nil, _ event: UIEvent? = nil, _ extra: AnyObject? = nil) {
        self.type = type
        self.event = event
        self.sender = sender
        self.extra = extra
        super.init()
    }
    var type: SIMChatMessageCellEventType
    var event: UIEvent?
    var sender: AnyObject?
    var extra: AnyObject?
}
