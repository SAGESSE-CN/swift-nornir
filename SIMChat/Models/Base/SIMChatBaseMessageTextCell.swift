//
//  SIMChatBaseCell+Text.swift
//  SIMChat
//
//  Created by sagesse on 1/20/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

///
/// 文本
///
public class SIMChatBaseMessageTextCell: SIMChatBaseMessageBubbleCell {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 添加父类的
        _bubbleMenuItems.appendContentsOf(super.bubbleMenuItems)
        
        // TODO: 有性能问题, 需要重新实现
        
        // config views
        contentLabel.font = UIFont.systemFontOfSize(16)
        contentLabel.numberOfLines = 0
        contentLabel.textColor = UIColor.blackColor()
        // add views
        bubbleView.contentView.addSubview(contentLabel)
        // add constraints
        SIMChatLayout.make(contentLabel)
            .top.equ(bubbleView.contentView).top(8)
            .left.equ(bubbleView.contentView).left(8)
            .right.equ(bubbleView.contentView).right(8)
            .bottom.equ(bubbleView.contentView).bottom(8)
            .submit()
    }
    /// 显示类型
    public override var style: Style {
        didSet {
            switch style {
            case .Left:  contentLabel.textColor = UIColor.blackColor()
            case .Right: contentLabel.textColor = UIColor.whiteColor()
            case .Unknow: break
            }
        }
    }
    /// 消息内容
    public override var model: SIMChatMessage? {
        didSet {
            guard let message = model where message != oldValue else {
                return
            }
            
            if let content = message.content as? SIMChatBaseMessageTextContent {
                self.contentLabel.text = content.content
            }
        }
    }
    private lazy var contentLabel = SIMChatLabel(frame: CGRectZero)
    
    private lazy var _bubbleMenuItems: Array<UIMenuItem> = [
        UIMenuItem(title: "复制", action: "_copyMessage:")
    ]
}

// MARK: - Event

extension SIMChatBaseMessageTextCell {
    /// 气泡菜单
    public override var bubbleMenuItems: Array<UIMenuItem> {
        return _bubbleMenuItems
    }
}