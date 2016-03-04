//
//  SIMChatBaseCell+Image.swift
//  SIMChat
//
//  Created by sagesse on 1/20/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

///
/// 图片
///
public class SIMChatBaseMessageImageCell: SIMChatBaseMessageBubbleCell {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // TODO: 有性能问题, 需要重新实现
        
        // config
        previewImageView.clipsToBounds = true
        previewImageView.contentMode = .ScaleAspectFill
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // add views
        bubbleView.contentView.addSubview(previewImageView)
        
        previewImageViewLayout = SIMChatLayout.make(previewImageView)
            .top.equ(bubbleView.contentView).top
            .left.equ(bubbleView.contentView).left
            .right.equ(bubbleView.contentView).right
            .bottom.equ(bubbleView.contentView).bottom
            .width.equ(0).priority(751)
            .height.equ(0).priority(751)
            .submit()
    }
    /// 消息
    public override var message: SIMChatMessageProtocol? {
        didSet {
            guard let message = message, content = content where message != oldValue else {
                return
            }
            let width = max(content.size.width, 32)
            let height = max(content.size.height, 1)
            let scale = min(min(135, width) / width, min(135, height) / height)
            
            previewImageViewLayout?.width = width * scale
            previewImageViewLayout?.height = height * scale
            
            guard superview != nil else {
                return
            }
            
            /// 默认
            previewImageView.image = self.dynamicType.defaultImage
            // 加载
            SIMChatFileProvider.sharedInstance().loadResource(content.thumbnail) { [weak self] in
                guard let image = $0.value as? UIImage where message == self?.message else {
                    return
                }
                self?.previewImageView.image = image
            }
        }
    }
    /// 内容
    private var content: SIMChatBaseMessageImageContent? {
        return message?.content as? SIMChatBaseMessageImageContent
    }
    
    private weak var _request: SIMChatFileRequest?
    
    private(set) var previewImageViewLayout: SIMChatLayout?
    private(set) lazy var previewImageView = UIImageView()
    
    private static let defaultImage = UIImage(named: "simchat_images_default")
}
