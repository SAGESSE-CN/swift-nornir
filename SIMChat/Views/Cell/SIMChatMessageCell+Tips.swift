//
//  SIMChatMessageCell+Tips.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 消息单元格-提示
///
class SIMChatMessageCellTips: SIMChatMessageCell {
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
    ///
    /// 重新加载数据.
    ///
    /// :param: u   当前用户
    /// :param: m   需要显示的消息
    ///
    override func reloadData(m: SIMChatMessage) {
        super.reloadData(m)
        // 更新数据
        self.titleLabel.text = m.sentTime.visual
    }
    
    private(set) lazy var titleLabel = UILabel()
}
