//
//  SIMChatBaseCell.swift
//  SIMChat
//
//  Created by sagesse on 1/17/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

///
/// 最基本的实现
///
public class SIMChatBaseMessageBaseCell: UITableViewCell, SIMChatMessageCellProtocol {
    public var model: SIMChatMessage?
    public weak var conversation: SIMChatConversation?
    public weak var delegate: protocol<SIMChatMessageCellDelegate, SIMChatMessageCellMenuDelegate>?
    
    /// 时间线
    public var showTimeLine: Bool {
        return false
    }
}

///
/// 包含一个气泡
///
public class SIMChatBaseMessageBubbleCell: UITableViewCell, SIMChatMessageCellProtocol {
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
        
        _bubbleMenuItems = [
            UIMenuItem(title: "删除", action: "_removeMessage:"),
            UIMenuItem(title: "撤销", action: "_revokeMessage:")
        ]
        
        // TODO: 有性能问题, 需要重新实现
        
        let vs = [
            "p" : portraitView,
            "c" : visitCardView,
            "s" : stateView,
            "b" : bubbleView
        ]
        
        let ms = [
//            "s0" : 40,
//            "s1" : 16,
//            "mh0" : 7,
//            "mh1" : 0,
//            "mh2" : 57,
//            
//            "mv0" : 4,
//            "mv1" : 9,
            
            "ph0" : hPriority,
            "ph1" : hPriority - 1,
            "ph2" : hPriority - 2,
            
            "pv0" : vPriority,
            "pv1" : vPriority - 1
        ]
        
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
        
        // 8上/7下/3中
        // 10
        // 10左 4左
        
        // 54 = 10 + 40 + 4
        
        // add constraints
        addConstraints(NSLayoutConstraintMake("H:|->=54-[b]->=54-|", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("H:|->=54-[c]->=54-|", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("H:[p]-(4@ph0)-[b]-(4@ph1)-[p]", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("H:[p]-(10@ph0)-[c]-(10@ph1)-[p]", views: vs, metrics: ms))
        
        addConstraints(NSLayoutConstraintMake("H:|-(==10@ph0)-[p(40)]-(==10@ph2)-|", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("V:|-(==8)-[p(40)]-(>=7@850)-|", views: vs, metrics: ms))
        
        addConstraints(NSLayoutConstraintMake("V:|-(==8)-[c(16)]-(==2@pv1)-[b]-7-|", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("V:|-(3@pv0)-[b(>=p)]", views: vs, metrics: ms))
        //addConstraints(NSLayoutConstraintMake("V:|-(mv0@pv0)-[b(>=p)]", views: vs, metrics: ms))
        addConstraints(NSLayoutConstraintMake("H:[b]-(4@ph0)-[s]-(4@ph1)-[b]", views: vs, metrics: ms))
        //addConstraints(NSLayoutConstraintMake("V:[s]-18-|", views: vs, metrics: ms))
        
        SIMChatLayout.make(stateView).bottom.equ(bubbleView).bottom(5).submit()
        
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
    public var model: SIMChatMessage? {
        didSet {
            messageUpdate()
            guard let m = model where m != oldValue else {
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
    /// 显示时间线
    public var showTimeLine: Bool {
        return true
    }
    
    public override func willMoveToWindow(newWindow: UIWindow?) {
        if window == nil || newWindow != nil {
            let _ = _initEvents
        }
        super.willMoveToWindow(newWindow)
    }
    
    /// 初始化事件
    public func initEvents() {
//        SIMLog.trace()
        
        SIMChatNotificationCenter.addObserver(self, selector: "userInfoDidChange:", name: SIMChatUserInfoDidChangeNotification)
        SIMChatNotificationCenter.addObserver(self, selector: "statusDidChange:", name: SIMChatMessageStatusChangedNotification)
        
        stateView.addTarget(self, action: "statusDidPressRetry:", forControlEvents: .TouchUpInside)
        
        _bubbleGRP.delegate = self
        _bubbleGRLP.delegate = self
        _portraitGRP.delegate = self
        _portraitGRLP.delegate = self

        // add events
        bubbleView.addGestureRecognizer(_bubbleGRP)
        bubbleView.addGestureRecognizer(_bubbleGRLP)
        portraitView.addGestureRecognizer(_portraitGRP)
        portraitView.addGestureRecognizer(_portraitGRLP)
    }
    
    private lazy var _initEvents: Void = self.initEvents()
    
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
    
    public weak var conversation: SIMChatConversation?
    public weak var delegate: protocol<SIMChatMessageCellDelegate, SIMChatMessageCellMenuDelegate>?
    
    
    private lazy var _bubbleGRP: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: "bubbleDidPress:")
    private lazy var _bubbleGRLP: UIGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "bubbleDidLongPress:")
    
    private lazy var _portraitGRP: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: "portraitDidPress:")
    private lazy var _portraitGRLP: UIGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "portraitDidLongPress:")
}


// MARK: - Event

extension SIMChatBaseMessageBubbleCell {
    // TODO: 设计存在问题. 需要重构
    
    /// 气泡长按的菜单项
    public var bubbleMenuItems: Array<UIMenuItem> { return _bubbleMenuItems }
    
    /// 检查是否允许获取焦点
    public override func canBecomeFirstResponder() -> Bool {
        return true
    }
    /// 检查是否使用该菜单
    public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return bubbleMenuItems.contains {
            return $0.action == action
        }
    }
    /// 重新定义点击区域
    public override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if isFirstResponder() {
            resignFirstResponder()
            return nil
        }
        let view = super.hitTest(point, withEvent: event)
        if view != nil && view != contentView {
            return view
        }
        return nil
    }
    
    /// 控制手势状态
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let user = portraitView.user where portraitView.bounds.contains(gestureRecognizer.locationInView(portraitView)) {
            if gestureRecognizer == _portraitGRP {
                return delegate?.cellEvent(self, shouldPressUser: user) ?? true
            } else if gestureRecognizer == _portraitGRLP {
                return delegate?.cellEvent(self, shouldLongPressUser: user) ?? true
            }
        }
        if let message = model where bubbleView.bounds.contains(gestureRecognizer.locationInView(bubbleView)) {
            if gestureRecognizer == _bubbleGRP {
                return delegate?.cellEvent(self, shouldPressMessage: message) ?? true
            } else if gestureRecognizer == _bubbleGRLP {
                return delegate?.cellEvent(self, shouldLongPressMessage: message) ?? true
            }
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    
    private dynamic func _copyMessage(sender: AnyObject) {
        guard let message = model else {
            return
        }
        if delegate?.cellMenu(self, shouldCopyMessage: message) ?? true {
            delegate?.cellMenu(self, didCopyMessage: message)
        }
    }
    private dynamic func _removeMessage(sender: AnyObject) {
        guard let message = model else {
            return
        }
        if delegate?.cellMenu(self, shouldRemoveMessage: message) ?? true {
            delegate?.cellMenu(self, didRemoveMessage: message)
        }
    }
    private dynamic func _revokeMessage(sender: AnyObject) {
        guard let message = model else {
            return
        }
        if delegate?.cellMenu(self, shouldRevokeMessage: message) ?? true {
             delegate?.cellMenu(self, didRevokeMessage: message)
        }
    }
    
    
    /// 更新消息
    private func messageUpdate() {
        guard let message = model where superview != nil else {
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
        portraitView.user = model?.sender
        visitCardView.user = model?.sender
    }
    
    internal dynamic func bubbleDidPress(sender: UITapGestureRecognizer) {
        guard let message = model where sender.state == .Ended else {
            return
        }
        delegate?.cellEvent(self, didPressMessage: message)
    }
    internal dynamic func bubbleDidLongPress(sender: UILongPressGestureRecognizer) {
        guard let message = model where sender.state == .Began else {
            return
        }
        delegate?.cellEvent(self, didLongPressMessage: message)
    }
    internal dynamic func portraitDidPress(sender: UITapGestureRecognizer) {
        guard let user = portraitView.user where sender.state == .Ended else {
            return
        }
        delegate?.cellEvent(self, didPressUser: user)
    }
    internal dynamic func portraitDidLongPress(sender: UILongPressGestureRecognizer) {
        guard let user = portraitView.user where sender.state == .Began else {
            return
        }
        delegate?.cellEvent(self, didLongPressUser: user)
    }
    internal dynamic func statusDidPressRetry(sender: AnyObject) {
        guard let message = model else {
            return
        }
        if delegate?.cellMenu(self, shouldRetryMessage: message) ?? true {
            delegate?.cellMenu(self, didRetryMessage: message)
        }
    }
    internal dynamic func statusDidChange(sender: NSNotification) {
        guard let message = sender.object as? SIMChatMessage where message == self.model else {
            return
        }
        messageUpdate()
    }
    internal dynamic func userInfoDidChange(sender: NSNotification) {
        guard let user = sender.object as? SIMChatUserProtocol where user == portraitView.user else {
            return
        }
        userUpdate()
    }
}

