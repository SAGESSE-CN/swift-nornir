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
        
        
        _imageView.clipsToBounds = true
        _imageView.contentMode = .ScaleAspectFill
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // add views
        bubbleView.contentView.addSubview(_imageView)
        
        _imageViewLayout = SIMChatLayout.make(_imageView)
            .top.equ(bubbleView.contentView).top
            .left.equ(bubbleView.contentView).left
            .right.equ(bubbleView.contentView).right
            .bottom.equ(bubbleView.contentView).bottom
            .width.equ(0).priority(751)
            .height.equ(0).priority(751)
            .submit()
    }
    /// 消息
    public override var model: SIMChatMessage? {
        didSet {
            guard let message = model, content = content where message != oldValue else {
                return
            }
            let width = max(content.size.width, 32)
            let height = max(content.size.height, 1)
            let scale = min(min(135, width) / width, min(135, height) / height)
            
            _imageViewLayout?.width = width * scale
            _imageViewLayout?.height = height * scale
            
            guard superview != nil else {
                return
            }
            
            /// 默认
            isLoaded = false
            imageView?.image = self.dynamicType.defaultImage
            // 加载
            SIMChatFileProvider.sharedInstance().loadResource(content.thumbnail) { [weak self] in
                guard let image = $0.value as? UIImage where message == self?.model else {
                    return
                }
                self?.isLoaded = true
                self?.imageView?.image = image
            }
        }
    }
    /// 内容
    private var content: SIMChatBaseMessageImageContent? {
        return model?.content as? SIMChatBaseMessageImageContent
    }
    
    public var isLoaded: Bool = false
    public override var imageView: UIImageView? {
        return _imageView
    }
    
    private var _imageViewLayout: SIMChatLayout?
    private lazy var _imageView: UIImageView = UIImageView()
    
    private static let defaultImage = UIImage(named: "simchat_images_default")
}
