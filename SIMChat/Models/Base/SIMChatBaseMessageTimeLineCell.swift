//
//  SIMChatBaseMessageTimeLineCell.swift
//  SIMChat
//
//  Created by sagesse on 1/20/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

///
/// 日期信息
///
public class SIMChatBaseMessageTimeLineCell: SIMChatBaseMessageBaseCell {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
            .top.equ(contentView).top(16)
            .left.equ(contentView).left(8)
            .right.equ(contentView).right(8)
            .bottom.equ(contentView).bottom(8)
            .submit()
    }
    /// 关联的消息
    public override var message: SIMChatMessageProtocol? {
        didSet {
            guard let message = message where message !== oldValue else {
                return
            }
            if let content = message.content as? SIMChatBaseMessageTimeLineContent {
                titleLabel.text = "\(content.backMessage?.date ?? message.date)"
            }
        }
    }
    private lazy var titleLabel = UILabel()
}
