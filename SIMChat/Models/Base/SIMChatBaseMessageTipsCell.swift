//
//  SIMChatBaseCell+Tips.swift
//  SIMChat
//
//  Created by sagesse on 1/20/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

///
/// 提示信息
///
public class SIMChatBaseMessageTipsCell: SIMChatBaseMessageBaseCell {
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
            .bottom.equ(contentView).bottom(13)
            .centerX.equ(contentView).centerX
            .submit()
        
        SIMChatLayout.make(titleLabel)
            .top.equ(bubbleImageView).top(5)
            .left.equ(bubbleImageView).left(10)
            .right.equ(bubbleImageView).right(10)
            .bottom.equ(bubbleImageView).bottom(5)
            .submit()
    }
    /// 关联的消息
    public override var model: SIMChatMessage? {
        didSet {
            guard let message = model where message !== oldValue else {
                return
            }
            
            if let content = message.content as? SIMChatBaseMessageTipsContent {
                titleLabel.text = content.content
            } else {
                if message.status.isDestroyed() {
                    titleLabel.text = "该消息己焚"
                } else if message.status.isRevoked() {
                    if message.isSelf {
                        titleLabel.text = "您撤回了一条消息"
                    } else {
                        titleLabel.text = "对方撤回了一条消息"
                    }
                }
            }
        }
    }
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = UIFont.systemFontOfSize(12)
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
