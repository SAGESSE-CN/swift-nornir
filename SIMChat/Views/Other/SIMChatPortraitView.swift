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
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // add views
        addSubview(contentView)
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.bounds.width / 2
    }
    
    /// 关联的用户
    var user: SIMChatUserProtocol? {
        didSet {
            contentView.image = self.defaultPortrait
        }
    }
    /// 
    private var defaultPortrait: UIImage? {
        // 如果性别为女, 显示2号头像
        if user?.gender == .Female {
            return SIMChatImageManager.defaultPortrait2
        }
        /// 如果性别为男, 显示1号头像
        if user?.gender == .Male {
            return SIMChatImageManager.defaultPortrait1
        }
        // 否则.. 显示未
        return SIMChatImageManager.defaultPortrait1
    }
    
    private(set) lazy var contentView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        return view
    }()
}
