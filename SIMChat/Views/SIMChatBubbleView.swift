//
//  SIMChatBubbleView.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

//
//   /--------+-\
//  <| +------+ +
//   | |      | |
//   + +------+ |
//   \-+--------/
//

///
/// 聊天气泡
///
class SIMChatBubbleView : SIMView {
    /// 构建
    override func build() {
        super.build()
        
        let vs = ["c" : contentView]
       
        // config
        
        // 内容使用al
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        // 关于背景直接使用am
        backgroundView.frame = bounds
        backgroundView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        // add views
        
        addSubview(backgroundView)
        addSubview(contentView)
        
        // add constraints
        addConstraints(NSLayoutConstraintMake("H:|-(9)-[c]-(9)-|", views: vs))
        addConstraints(NSLayoutConstraintMake("V:|-(7)-[c]-(7)-|", views: vs))
    }
    /// 背景图
    var backgroundImage: UIImage? {
        set { return backgroundView.image = newValue }
        get { return backgroundView.image }
    }
    
    private(set) lazy var contentView = UIView()
    private(set) lazy var backgroundView = UIImageView()
}

/// 消息转发
extension SIMChatBubbleView {
    override var gestureRecognizers: [UIGestureRecognizer]? {
        set { return contentView.gestureRecognizers = newValue }
        get { return contentView.gestureRecognizers }
    }
    override func addGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
        return contentView.addGestureRecognizer(gestureRecognizer)
    }
    override func removeGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
        return contentView.removeGestureRecognizer(gestureRecognizer)
    }
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return contentView.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}