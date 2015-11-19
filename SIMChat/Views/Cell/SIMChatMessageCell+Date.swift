//
//  SIMChatMessageCell+Date.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 消息单元格-日期
///
class SIMChatMessageCellDate: SIMChatMessageCell {
    /// 构建
    override func build() {
        super.build()
        
        let vs = ["t" : titleLabel]
        
        // config
        titleLabel.numberOfLines = 1
        titleLabel.font = UIFont.systemFontOfSize(11)
        titleLabel.textColor = UIColor(hex: 0x7B7B7B)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // add views
        contentView.addSubview(titleLabel)
        
        // add constraints
        contentView.addConstraints(NSLayoutConstraintMake("H:|-(8)-[t]-(8)-|", views: vs))
        contentView.addConstraints(NSLayoutConstraintMake("V:|-(16)-[t]-(8)-|", views: vs))
    }
    /// 消息内容
    override var message: SIMChatMessageProtocol? {
        didSet {
            // 检查
            guard let m = message else {
                // 空, 没有什么好说的
                return
            }
            // 更新数据
            self.titleLabel.text = m.receiveTime.visual
        }
    }
    
    private(set) lazy var titleLabel = UILabel()
}