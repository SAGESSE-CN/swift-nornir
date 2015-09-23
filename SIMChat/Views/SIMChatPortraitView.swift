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
    /// 释放
    deinit {
        // remove kvo
        removeObserver(self, forKeyPath: "contentView.bounds")
    }
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
        
        // add kvos
        addObserver(self, forKeyPath: "contentView.bounds", options: .New, context: nil)
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        // 直接更新
        contentView.layer.cornerRadius = contentView.bounds.width / 2
    }
    /// 关联的用户
    var user: SIMChatUser? {
        didSet {
            contentView.image = self.defaultPortrait
        }
    }
    /// 
    private var defaultPortrait: UIImage? {
        // 如果性别为女, 显示2号头像
        if self.user?.gender == 2 {
            return SIMChatImageManager.defaultPortrait2
        }
        // 否则
        return SIMChatImageManager.defaultPortrait1
    }
    
    private(set) lazy var contentView = UIImageView()
}
