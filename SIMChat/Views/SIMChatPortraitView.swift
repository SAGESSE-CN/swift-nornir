//
//  SIMChatPortraitView.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

//
// +-----+
// | +-+ |
// | +-+ |
// +-----+
//

///
/// 聊天头像
///
class SIMChatPortraitView: SIMView {
   
    /// 构建.
    override func build() {
        super.build()
        
        let vs = ["c" : contentView]
        
        // config
        contentView.clipsToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // add views
        addSubview(contentView)
        
        // add constraints
        addConstraints(NSLayoutConstraintMake("H:|-(5)-[c]-(5)-|", views: vs))
        addConstraints(NSLayoutConstraintMake("V:|-(5)-[c]-(5)-|", views: vs))
    }
    /// 大小发生改变
    override var bounds: CGRect {
        willSet { contentView.layer.cornerRadius = contentView.bounds.width / 2 }
    }
   
    /// 关联的用户
    var user: SIMChatUser? {
        willSet {
            contentView.image = SIMChatImageManager.defaultPortrait1
            //imageView.sd_setImageWithURL(NSURL(string: newValue?.portrait ?? ""), placeholderImage: SIMPortraitView.defaultPortrait)
        }
    }
    
    private(set) lazy var contentView = UIImageView()
}
