//
//  SIMChatMessageCell+Unknow.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/////
///// 消息单元格-未知
/////
//class SIMChatMessageCellUnknow: SIMChatMessageCell {
//    /// 构建
//    override func build() {
//        super.build()
//        
//        let vs = ["t" : titleLabel]
//        
//        // config
//        titleLabel.text = "未知的消息类型"
//        titleLabel.numberOfLines = 0
//        titleLabel.font = UIFont.systemFontOfSize(11)
//        titleLabel.textColor = UIColor(hex: 0x7B7B7B)
//        titleLabel.textAlignment = NSTextAlignment.Center
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        // add views
//        contentView.addSubview(titleLabel)
//        
//        // add constraints
//        contentView.addConstraints(NSLayoutConstraintMake("H:|-(8)-[t]-(8)-|", views: vs))
//        contentView.addConstraints(NSLayoutConstraintMake("V:|-(16)-[t]-(8)-|", views: vs))
//    }
//    
//    private(set) lazy var titleLabel = UILabel()
//}
