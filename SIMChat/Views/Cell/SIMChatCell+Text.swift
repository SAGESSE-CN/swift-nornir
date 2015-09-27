//
//  SIMChatCell+Text.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 消息单元格-纯文本
///
class SIMChatCellText: SIMChatCellBubble {
    /// 构建ui
    override func build() {
        super.build()
    
        let vs = ["c" : contentLabel]
        
        // config views
        contentLabel.font = UIFont.systemFontOfSize(16)
        contentLabel.numberOfLines = 0
        contentLabel.textColor = UIColor.blackColor()
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // add views
        bubbleView.contentView.addSubview(contentLabel)
        
        // add constraints
        contentView.addConstraints(NSLayoutConstraintMake("H:|-(8)-[c]-(8)-|", views: vs))
        contentView.addConstraints(NSLayoutConstraintMake("V:|-(8)-[c]-(8)-|", views: vs))
    }
    ///
    /// 重新加载数据.
    ///
    /// :param: u   当前用户
    /// :param: m   需要显示的消息
    ///
    override func reloadData(m: SIMChatMessage, ofUser u: SIMChatUser?) {
        super.reloadData(m, ofUser: u)
        // 更新文本
        if let content = m.content as? SIMChatContentText {
            self.contentLabel.text = content.text
            self.contentLabel.preferredMaxLayoutWidth = 0
        }
    }
    ///
    /// 计算高度, 在计算之前需要设置好约束
    ///
    /// :returns: 合适的大小
    ///
    override func systemLayoutSizeFittingSize(targetSize: CGSize) -> CGSize {
        // 额外的配置
        self.contentLabel.preferredMaxLayoutWidth = 0
        self.layoutIfNeeded()
        self.contentLabel.preferredMaxLayoutWidth = contentLabel.bounds.width
        // 继续计算
        return super.systemLayoutSizeFittingSize(targetSize)
    }
    /// 检查是否使用.
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        // 允许复制
        if action == "chatCellCopy:" {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    /// 显示类型
    override var style: SIMChatCellStyle  {
        willSet {
            switch newValue {
            case .Left:  contentLabel.textColor = UIColor.blackColor()
            case .Right: contentLabel.textColor = UIColor.whiteColor()
            }
        }
    }
    
    private(set) lazy var contentLabel = UILabel()
}


// MARK: - Event
extension SIMChatCellText {
    /// 复制
    dynamic func chatCellCopy(sender: AnyObject) {
        SIMLog.trace()
        if let ctx = message?.content as? SIMChatContentText {
            // 复制进去:)
            UIPasteboard.generalPasteboard().string = ctx.text
            // 完成
            self.delegate?.chatCellDidCopy?(self)
        }
    }
}
    