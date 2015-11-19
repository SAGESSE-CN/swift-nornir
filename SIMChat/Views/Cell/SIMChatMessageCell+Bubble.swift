//
//  SIMChatMessageCell+Bubble.swift
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
class SIMChatMessageCellBubble: SIMChatMessageCell {
    /// 销毁
    deinit {
        removeObserver(self, forKeyPath: "visitCardView.hidden")
        // :)
        SIMChatNotificationCenter.removeObserver(self, name: SIMChatUser2InfoChangedNotification)
        SIMChatNotificationCenter.removeObserver(self, name: SIMChatMessageStatusChangedNotification)
    }
    /// 构建
    override func build() {
        super.build()
        
        let vs = ["p" : portraitView,
                  "c" : visitCardView,
                  "s" : stateView,
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
        stateView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        portraitView.translatesAutoresizingMaskIntoConstraints = false
        visitCardView.translatesAutoresizingMaskIntoConstraints = false
       
        // add views
        contentView.addSubview(visitCardView)
        contentView.addSubview(portraitView)
        contentView.addSubview(bubbleView)
        contentView.addSubview(stateView)
        
        // add constraints
        
        addConstraints(NSLayoutConstraintMake("H:[p]-mh1@ph0-[b]-mh1@ph1-[p]", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("H:[p]-mh1@ph0-[c]-mh1@ph1-[p]", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("H:|-==mh0@ph0-[p(s0)]-mh0@ph2-|", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("H:|->=mh2-[b]->=mh2-|", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("H:|->=mh2-[c]->=mh2-|", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("V:|-(==mv0)-[p(s0)]-(>=0@850)-|", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("V:|-(==mv1)-[c(s1)]-(==2@pv1)-[b]|", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("V:|-(mv0@pv0)-[b(>=p)]", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("V:|-(mv0@pv0)-[b(>=p)]", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("H:[b]-(4@ph0)-[s]-(4@ph1)-[b]", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("V:[s]-(mv0)-|", views: vs, metrics: ms))
        
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
    /// 安装事件
    override func install() {
        super.install()
        
        // :)
        SIMChatNotificationCenter.addObserver(self, selector: "onUserInfoChanged:", name: SIMChatUser2InfoChangedNotification)
        SIMChatNotificationCenter.addObserver(self, selector: "onMessageStateChanged:", name: SIMChatMessageStatusChangedNotification)
        
        // add events
        bubbleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBubblePress:"))
        bubbleView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "onBubbleLongPress:"))
        portraitView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onPortraitPress:"))
        portraitView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "onPortraitLongPress:"))
        visitCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onVisitCardPress:"))
        visitCardView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "onVisitCardLongPress:"))
        
        stateView.addTarget(self, action: "onRetryPress:", forControlEvents: .TouchUpInside)
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
    override var style: SIMChatMessageCellStyle  {
        willSet {
            // 没有改变
            guard newValue != style else {
                return
            }
            // 检查
            switch newValue {
            case .Left:
                self.bubbleView.backgroundImage = SIMChatImageManager.defaultBubbleRecive
                
            case .Right:
                self.bubbleView.backgroundImage = SIMChatImageManager.defaultBubbleSend
                
            case .Unknow:
                break
            }
            // 修改约束
            leftConstraints.forEach {
                $0.priority = newValue == .Left ? self.hPriority : 1
            }
            // 需要更新布局
            setNeedsLayout()
        }
    }
    /// 消息内容
    override var message: SIMChatMessageProtocol? {
        didSet {
            // 检查
            guard let m = message else {
                // 空, 没有什么好说的
                return
            }
            // 关于名片显示
            if m.option & SIMChatMessageOption.ContactShow != 0 {
                // 强制显示
                self.visitCardView.hidden = false
            } else if m.option & SIMChatMessageOption.ContactHidden != 0 {
                // 强制隐藏
                self.visitCardView.hidden = true
            } else if m.sender === nil {
                // 并没有发送者
                // 强制隐藏
                self.visitCardView.hidden = true
            } else {
//                // 如果是自己, 隐藏
//                // 如果是C2C,  隐藏
//                // 如果是Robot, 隐藏
//                if let r = m.receiver where m.ownership || r.type == .C2C || r.type == .Robot {
//                    // 隐藏
//                    self.visitCardView.hidden = true
//                } else {
//                    // 显示
//                    self.visitCardView.hidden = false
//                }
            }
            // 关于头像
            self.portraitView.user = m.sender
            self.visitCardView.user = m.sender
            // 关于状态
            self.onMessageStateChanged(nil)
        }
    }
    
    /// 自动调整
    private let hPriority = UILayoutPriority(700)
    private let vPriority = UILayoutPriority(800)
    
    private lazy var topConstraints = [NSLayoutConstraint]()
    private lazy var leftConstraints = [NSLayoutConstraint]()
    
    private(set) lazy var stateView = SIMChatStatusView(frame: CGRectZero)
    private(set) lazy var bubbleView = SIMChatBubbleView(frame: CGRectZero)
    private(set) lazy var portraitView = SIMChatPortraitView(frame: CGRectZero)
    private(set) lazy var visitCardView = SIMChatVisitCardView(frame: CGRectZero)
}

// MARK: - Notifications
extension SIMChatMessageCellBubble {
    /// 用户信息改变
    internal dynamic func onUserInfoChanged(sender: NSNotification) {
        // 为空说明不需要做何处理
        guard let message = self.message where enabled else {
            return
        }
        // 改变的是他
        if let u = sender.object as? SIMChatUserProtocol where u == message.sender {
            // TODO: 更新sender, 防止同步错误
            // message.sender = u
            // 关于头像
            self.portraitView.user = u
            // 关于名片
            self.visitCardView.user = u
        }
    }
    /// 消息状态改变
    internal dynamic func onMessageStateChanged(sender: NSNotification?) {
        // 为空说明不需要做何处理
        guard let message = self.message where enabled else {
            return
        }
        // 检查是不是自己的消息.
        if sender != nil && sender!.object !== message {
            return
        }
        // 检查状态
        switch message.status {
        case .Error:
            self.stateView.status = .Failed
        case .Sending:      fallthrough
        case .Receiving:
            self.stateView.status = .Waiting
        default:
            self.stateView.status = .None
        }
    }
}

// MARK: - Events
extension SIMChatMessageCellBubble {
    
    func onBubblePress(sender: AnyObject) {
        self.chatCellPress(SIMChatMessageCellEvent(.Bubble, sender, nil))
    }
    func onBubbleLongPress(sender: AnyObject) {
        self.chatCellLongPress(SIMChatMessageCellEvent(.Bubble, sender, nil))
    }
    func onPortraitPress(sender: AnyObject) {
        self.chatCellPress(SIMChatMessageCellEvent(.Portrait, sender, nil))
    }
    func onPortraitLongPress(sender: AnyObject) {
        self.chatCellLongPress(SIMChatMessageCellEvent(.Portrait, sender, nil))
    }
    func onVisitCardPress(sender: AnyObject) {
        self.chatCellPress(SIMChatMessageCellEvent(.VisitCard, sender, nil))
    }
    func onVisitCardLongPress(sender: AnyObject) {
        self.chatCellLongPress(SIMChatMessageCellEvent(.VisitCard, sender, nil))
    }
    func onRetryPress(sender: AnyObject) {
        SIMLog.trace()
        self.delegate?.chatCellDidReSend?(self)
    }
}