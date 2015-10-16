//
//  SIMChatCell+Image.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SIMChatCellImage: SIMChatCellBubble {
    /// 构建
    override func build() {
        super.build()
        
        let vs = ["c": contentView2]
        
        // config
        contentView2.clipsToBounds = true
        contentView2.contentMode = .ScaleAspectFill
        contentView2.translatesAutoresizingMaskIntoConstraints = false
        
        contentView2Width = NSLayoutConstraintMake(contentView2, .Width, .Equal, nil, .Width, 0, 751)
        contentView2Height = NSLayoutConstraintMake(contentView2, .Height, .Equal, nil, .Height, 0, 751)
        
        // add views
        bubbleView.contentView.addSubview(contentView2)
        
        contentView.addConstraint(contentView2Width)
        contentView.addConstraint(contentView2Height)
        
        contentView.addConstraints(NSLayoutConstraintMake("H:|-(0)-[c]-(0)-|", views: vs))
        contentView.addConstraints(NSLayoutConstraintMake("V:|-(0)-[c]-(0)-|", views: vs))
    }
    ///
    /// 重新加载数据.
    ///
    /// :param: u   当前用户
    /// :param: m   需要显示的消息
    ///
    override func reloadData(m: SIMChatMessage, ofUser u: SIMChatUser2?) {
        super.reloadData(m, ofUser: u)
        
        if let content = m.content as? SIMChatMessageContentImage {
            
            let width = max(content.thumbnailSize.width, 32)
            let height = max(content.thumbnailSize.height, 1)
            let scale = min(min(135, width) / width, min(135, height) / height)

            contentView2Width.constant = width * scale
            contentView2Height.constant = height * scale
            
            setNeedsLayout()

            // 最大值是135

            if let img = content.thumbnail.get() {
                contentView2.image = img
                content.thumbnail.clean()
            } else  {
                contentView2.image = SIMChatImageManager.defaultImage
                if enabled {
                    content.thumbnail.setter { [weak self] newValue in
                        // up..
                        self?.contentView2.image = newValue
                    }
                }
            }
        }
    }
    /// 检查是否使用.
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        // 允许复制
        if action == "chatCellCopy:" {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    private(set) var contentView2Width: NSLayoutConstraint!
    private(set) var contentView2Height: NSLayoutConstraint!
    
    private(set) lazy var contentView2 = UIImageView()
}

// MARK: - Event
extension SIMChatCellImage {
    /// 复制
    dynamic func chatCellCopy(sender: AnyObject?) {
        SIMLog.trace()
        if let ctx = message?.content as? SIMChatMessageContentImage where ctx.origin.storaged {
            UIPasteboard.generalPasteboard().image = *(ctx.origin)
            // 完成
            self.delegate?.chatCellDidCopy?(self)
        }
    }
}