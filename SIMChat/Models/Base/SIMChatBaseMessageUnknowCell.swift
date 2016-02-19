//
//  SIMChatBaseCell+Unknow.swift
//  SIMChat
//
//  Created by sagesse on 1/20/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

///
/// 未知的信息
///
public class SIMChatBaseMessageUnknowCell: SIMChatBaseMessageBaseCell {
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // add views
        contentView.addSubview(bubbleImageView)
        contentView.addSubview(titleLabel)
        // add constraints
        
        SIMChatLayout.make(bubbleImageView)
            .top.equ(contentView).top
            .left.gte(contentView).left(10)
            .right.lte(contentView).right(10)
            .bottom.equ(contentView).bottom(17)
            .centerX.equ(contentView).centerX
            .submit()
        
        SIMChatLayout.make(titleLabel)
            .top.equ(bubbleImageView).top(5)
            .left.equ(bubbleImageView).left(10)
            .right.equ(bubbleImageView).right(10)
            .bottom.equ(bubbleImageView).bottom(5)
            .submit()
    }
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = UIFont.systemFontOfSize(12)
        view.text = "未知的消息类型"
        view.textColor = UIColor(argb: 0xFF7B7B7B)
        view.textAlignment = NSTextAlignment.Center
        return view
    }()
    private lazy var bubbleImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "simchat_bubble_tips")
        return view
    }()
}

