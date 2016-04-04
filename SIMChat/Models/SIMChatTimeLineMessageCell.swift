//
//  SIMChatTimeLineMessageCell.swift
//  SIMChat
//
//  Created by sagesse on 3/17/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

///
/// 时间线
///
internal class SIMChatTimeLineMessageCell: SIMChatBaseMessageBaseCell {
    
    /// 反序列化
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /// 初始化
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // config
        titleLabel.text = ""
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFontOfSize(11)
        titleLabel.textColor = UIColor(argb: 0xFF7B7B7B)
        titleLabel.textAlignment = NSTextAlignment.Center
        // add views
        contentView.addSubview(titleLabel)
        // add constraints
        SIMChatLayout.make(titleLabel)
            .top.equ(contentView).top(21)
            .left.equ(contentView).left(0)
            .right.equ(contentView).right(0)
            .bottom.equ(contentView).bottom(9)
            .submit()
    }
    
    /// 关联的消息
    override var model: SIMChatMessage? {
        didSet {
            guard let message = model as? SIMChatTimeLineMessage where message !== oldValue else {
                return
            }
            // 更新时间信息
            titleLabel.text = "\(message.timestamp)"
        }
    }
    
    private lazy var titleLabel = UILabel()
}
