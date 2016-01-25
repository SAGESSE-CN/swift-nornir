//
//  SIMChatBaseCell.swift
//  SIMChat
//
//  Created by sagesse on 1/17/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

///
/// 打包起来
///
public struct SIMChatBaseCell {
    ///
    /// 最基本的实现
    ///
    public class Base: UITableViewCell, SIMChatCellProtocol {
        public var message: SIMChatMessageProtocol?
        public var conversation: SIMChatConversationProtocol?
        public weak var eventDelegate: SIMChatCellEventDelegate?
    }
}

// MARK: - Bubble

extension SIMChatBaseCell {
    ///
    /// 包含一个气泡
    ///
    public class Bubble: UITableViewCell, SIMChatCellProtocol {
        public enum Style {
            case Unknow
            case Left
            case Right
        }
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            _bubbleMenuItems = [UIMenuItem(title: "删除", action: "messageDelete:")]
            
            // TODO: 有性能问题, 需要重新实现
        
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
            
            stateView.hidden = true
            
            //stateView.backgroundColor = UIColor.purpleColor()
            //bubbleView.backgroundColor = UIColor.purpleColor()
            //portraitView.backgroundColor = UIColor.purpleColor()
            //visitCardView.backgroundColor = UIColor.purpleColor()
            
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
            
            initEvent()
        }
        /// 销毁
        deinit {
            removeObserver(self, forKeyPath: "visitCardView.hidden")
        }
        /// kvo
        public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            if keyPath ==  "visitCardView.hidden" {
                // 直接更新
                topConstraints.forEach {
                    $0.priority = self.visitCardView.hidden ? self.vPriority : 1
                }
                // 需要更新约束
                setNeedsLayout()
            }
        }
        /// 关联的内容
        public var message: SIMChatMessageProtocol? {
            didSet {
                guard let m = message else {
                    return
                }
                // 气泡方向
                style = m.isSelf ? .Right : .Left
                // 关于名片显示
                if m.option.contains(.ContactShow) {
                    // 强制显示
                    visitCardView.hidden = false
                } else if m.option.contains(.ContactHidden) {
                    // 强制隐藏
                    visitCardView.hidden = true
                } else {
                    // 自动选择
                    if m.isSelf || m.receiver.type == .User {
                        visitCardView.hidden = true
                    } else {
                        visitCardView.hidden = false
                    }
                }
                userUpdate()
                messageUpdate()
            }
        }
        /// 更新类型.
        public var style: Style = .Unknow {
            willSet {
                // 没有改变
                guard newValue != style else {
                    return
                }
                // 检查
                switch newValue {
                case .Left:     bubbleView.backgroundImage = SIMChatImageManager.defaultBubbleRecive
                case .Right:    bubbleView.backgroundImage = SIMChatImageManager.defaultBubbleSend
                case .Unknow:   break
                }
                // 修改约束
                leftConstraints.forEach {
                    $0.priority = newValue == .Left ? self.hPriority : 1
                }
                // 需要更新布局
                setNeedsLayout()
            }
        }
        
        private lazy var _bubbleMenuItems: Array<UIMenuItem> = []
        
        /// 自动调整
        private let hPriority = UILayoutPriority(700)
        private let vPriority = UILayoutPriority(800)
        
        private lazy var topConstraints = [NSLayoutConstraint]()
        private lazy var leftConstraints = [NSLayoutConstraint]()
    
        private(set) lazy var stateView = SIMChatStatusView(frame: CGRectZero)
        private(set) lazy var bubbleView = SIMChatBubbleView(frame: CGRectZero)
        private(set) lazy var portraitView = SIMChatPortraitView(frame: CGRectZero)
        private(set) lazy var visitCardView = SIMChatVisitCardView(frame: CGRectZero)
        
        public var conversation: SIMChatConversationProtocol?
        public weak var eventDelegate: SIMChatCellEventDelegate?
    }
}


// MARK: - Event

extension SIMChatBaseCell.Bubble {
    // TODO: 设计存在问题. 需要重构
    
    /// 气泡长按的菜单项
    public var bubbleMenuItems: Array<UIMenuItem> { return _bubbleMenuItems }
    
    /// 初始化事件
    private func initEvent() {
        
        SIMChatNotificationCenter.addObserver(self,
            selector: "onUserInfoDidChange:",
            name: SIMChatUserInfoDidChangeNotification)
        SIMChatNotificationCenter.addObserver(self,
            selector: "onMessageStatusDidChange:",
            name: SIMChatMessageStatusChangedNotification)

        // add events
        bubbleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onPressOfBubble:"))
        bubbleView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "onLongPressOfBubble:"))
        portraitView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onPressOfPortrait:"))
        portraitView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "onLongPressOfPortrait:"))
        
        stateView.addTarget(self, action: "onPressOfStatusRetry:", forControlEvents: .TouchUpInside)
    }
    /// 检查是否允许获取焦点
    public override func canBecomeFirstResponder() -> Bool {
        return true
    }
    /// 检查是否使用该菜单
    public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
//        return true
        return bubbleMenuItems.contains {
            return $0.action == action
        }
    }
    /// 重新定义点击区域
    public override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
//        if isFirstResponder() {
//            resignFirstResponder()
//            return nil
//        }
        let view = super.hitTest(point, withEvent: event)
        if view != nil && view != contentView {
            return view
        }
        return nil
    }
    /// 气泡点击事件
    private dynamic func onPressOfBubble(sender: UITapGestureRecognizer) {
        guard let message = message where sender.state == .Ended else {
            return
        }
        eventDelegate?.cellEvent(self, clickMessage: message)
    }
    /// 气泡长按事件
    private dynamic func onLongPressOfBubble(sender: UILongPressGestureRecognizer) {
        guard sender.state == .Began && !bubbleMenuItems.isEmpty else {
            return
        }
        // 准备菜单
        let mu = UIMenuController.sharedMenuController()
        
//        becomeFirstResponder()
        mu.menuItems = bubbleMenuItems
        mu.setMenuVisible(true, animated: true)
        mu.setTargetRect(bubbleView.frame, inView: self)
    }
    /// 状态
    private dynamic func onPressOfStatusRetry(sender: AnyObject) {
        guard let message = message else {
            return
        }
        eventDelegate?.cellEvent(self, retryMessage: message)
    }
    /// 头像点击事件
    private dynamic func onPressOfPortrait(sender: UITapGestureRecognizer) {
        guard let user = portraitView.user where sender.state == .Ended else {
            return
        }
        eventDelegate?.cellEvent(self, showProfile: user)
    }
    /// 头像长按事件
    private dynamic func onLongPressOfPortrait(sender: UILongPressGestureRecognizer) {
        guard let user = portraitView.user where sender.state == .Began else {
            return
        }
        eventDelegate?.cellEvent(self, replyUser: user)
    }
    
    /// 消息状态改变通知
    private dynamic func onMessageStatusDidChange(sender: NSNotification) {
        guard let message = sender.object as? SIMChatMessageProtocol where message == self.message else {
            return
        }
        messageUpdate()
    }
    /// 用户信息改变通知
    private dynamic func onUserInfoDidChange(sender: NSNotification) {
        guard let user = sender.object as? SIMChatUserProtocol where user == portraitView.user else {
            return
        }
        userUpdate()
    }
    
    /// 复制消息
    private dynamic func messageCopy(sender: AnyObject) {
        guard let message = message else {
            return
        }
        eventDelegate?.cellEvent(self, copyMessage: message)
    }
    /// 删除消息
    private dynamic func messageDelete(sender: AnyObject) {
        guard let message = message else {
            return
        }
        eventDelegate?.cellEvent(self, removeMessage: message)
    }
    /// 更新消息
    private func messageUpdate() {
        guard let message = message where superview != nil else {
            return
        }
        switch message.status {
        case .Error:
            stateView.status = .Failed
            stateView.userInteractionEnabled = true
            stateView.hidden = false
        case .Receiving, .Sending:
            stateView.status = .Waiting
            stateView.userInteractionEnabled = false
            stateView.hidden = false
        default:
            stateView.status = .None
            stateView.hidden = true
        }
    }
    /// 更新用户
    private func userUpdate() {
        guard superview != nil else {
            return
        }
        portraitView.user = message?.sender
        visitCardView.user = message?.sender
    }
}

