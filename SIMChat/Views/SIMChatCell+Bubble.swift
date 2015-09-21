//
//  SIMChatCell+Bubble.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

// 
// +----------------+
// | O xxxxxx       |
// | <----------\   |
// |  |         |   |
// |  \---------/   |
// +----------------+
//
//

///
/// 消息单元格-气泡
///
class SIMChatCellBubble: SIMChatCell {
    /// 销毁
    deinit {
        removeObserver(self, forKeyPath: "visitCardView.hidden")
    }
    /// 构建
    override func build() {
        super.build()
        
        let vs = ["p" : portraitView,
                  "c" : visitCardView,
                  "b" : bubbleView]
        
        let ms = ["s0" : 50,
                  "s1" : 16,
            
                  "mh0" : 7,
                  "mh1" : 0,
                  "mh2" : 57,
                  
                  "mv0" : 8,
                  "mv1" : 13,
                  
                  "ph0" : hPriority,
                  "ph1" : hPriority - 1,
                  "ph2" : hPriority - 2,
                  
                  "pv0" : vPriority,
                  "pv1" : vPriority - 1]
        
        let addConstraints = contentView.addConstraints
        
        /// config
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        portraitView.translatesAutoresizingMaskIntoConstraints = false
        visitCardView.translatesAutoresizingMaskIntoConstraints = false
       
        // add views
        contentView.addSubview(bubbleView)
        contentView.addSubview(portraitView)
        contentView.addSubview(visitCardView)
        
        // add constraints
        
        addConstraints(NSLayoutConstraintMake("H:[p]-mh1@ph0-[b]-mh1@ph1-[p]", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("H:[p]-mh1@ph0-[c]-mh1@ph1-[p]", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("H:|-==mh0@ph0-[p(s0)]-mh0@ph2-|", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("H:|->=mh2-[b]->=mh2-|", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("H:|->=mh2-[c]->=mh2-|", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("V:|-(==mv0)-[p(s0)]-(>=0@850)-|", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("V:|-(==mv1)-[c(s1)]-(==2@pv1)-[b]|", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("V:|-(mv0@pv0)-[b(>=p)]", views: vs, metrics: ms))

        // get constraints
        contentView.constraints.forEach {
            if $0.priority == self.hPriority {
                leftConstraints.append($0)
            } else if $0.priority == self.vPriority {
                topConstraints.append($0)
            }
        }
        
        // add kvos
        addObserver(self, forKeyPath: "visitCardView.hidden", options: .New, context: nil)
    }
    ///
    /// 重新加载数据.
    ///
    /// :param: u   当前用户
    /// :param: m   需要显示的消息
    ///
    override func reloadData(m: SIMChatMessage, ofUser u: SIMChatUser?) {
        super.reloadData(m, ofUser: u)
        // 关于名片
        if !m.hiddenName && m.sender != nil {
            // 显示名片
            self.visitCardView.user = m.sender
            self.visitCardView.hidden = m.sender == u
        } else {
            // 隐藏名片
            self.visitCardView.user = nil
            self.visitCardView.hidden = true
        }
        // 关于头像
        self.portraitView.user = m.sender
    }
    /// kvo
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath ==  "visitCardView.hidden" {
            // 直接更新
            topConstraints.forEach {
                $0.priority = self.visitCardView.hidden ? self.vPriority : 1
            }
            // 需要更新约束
            setNeedsLayout()
        }
    }
    /// 显示类型
    override var style: SIMChatCellStyle  {
        willSet {
            switch newValue {
            case .Left:
                self.bubbleView.backgroundImage = UIImage(named: "simchat_bubble_recive")
                self.portraitView.defaultPortrait = SIMChatImageManager.defaultPortrait2
                
            case .Right:    
                self.bubbleView.backgroundImage = UIImage(named: "simchat_bubble_send")
                self.portraitView.defaultPortrait = SIMChatImageManager.defaultPortrait1
            }
            // 修改约束
            leftConstraints.forEach {
                $0.priority = newValue == .Left ? self.hPriority : 1
            }
            // 需要更新布局
            setNeedsLayout()
        }
    }
    
    private func addConstraint(constraint: NSLayoutConstraint, _ dir: SIMChatCellBoubbleConstraintDir) {
    }
    
    /// 自动调整
    private let hPriority = UILayoutPriority(700)
    private let vPriority = UILayoutPriority(800)
    
    private lazy var topConstraints = [NSLayoutConstraint]()
    private lazy var leftConstraints = [NSLayoutConstraint]()
    
    // 该死的bug
    private(set) lazy var bubbleView: SIMChatBubbleView = SIMChatBubbleView()
    private(set) lazy var portraitView: SIMChatPortraitView = SIMChatPortraitView()
    private(set) lazy var visitCardView: SIMChatVisitCardView = SIMChatVisitCardView()
}

/// MARK: - /// Type
extension SIMChatCell {
    /// 类型
    enum SIMChatCellBoubbleConstraintDir : Int {
        case Left
        case Right
        case Top
        case Bottom
        case None
    }
}
