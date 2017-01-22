//
//  SACChatViewCell.swift
//  SAChat
//
//  Created by SAGESSE on 26/12/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

// 因为效率问题不能使用Auto Layout

open class SACChatViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    deinit {
        _removeObserverForMenu()
    }
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let layoutAttributes = layoutAttributes as? SACChatViewLayoutAttributes else {
            return
        }
        _updateLayoutAttributes(layoutAttributes)
        _updateViews()
        _updateViewLayouts()
        _updateViewValues()
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let rect = _layoutAttributes?.info?.layoutedBoxRect(with: .all) else {
            return false
        }
        return rect.contains(point)
    }
    
    open class var cardViewClass: SACMessageContentViewType.Type {
        return SACMessageCardView.self
    }
    open class var avatarViewClass: SACMessageContentViewType.Type {
        return SACMessageAvatarView.self
    }
    
    private func _updateLayoutAttributes(_ layoutAttributes: SACChatViewLayoutAttributes) {
        _layoutAttributes = layoutAttributes
        
        // update touch response event
        isUserInteractionEnabled = layoutAttributes.message?.options.isUserInteractionEnabled ?? false
    }
    
    private func _updateViews() {
        // prepare
        guard let message = _layoutAttributes?.message else {
            return
        }
        let options = message.options
        // create/destory bubble
        if options.showsBubble {
            // create
            if _bubbleView == nil {
                _bubbleView = UIImageView()
            }
            if let view = _bubbleView, view.superview == nil {
                insertSubview(view, belowSubview: contentView)
            }
        } else {
            // destory
            if let view = _bubbleView {
                view.removeFromSuperview()
            }
            _bubbleView = nil
        }
        // create/destory visit card view
        if options.showsCard {
            // create
            if _cardView == nil {
                _cardView = type(of: self).cardViewClass._init()
            }
            if let view = _cardView as? UIView, view.superview == nil {
                contentView.addSubview(view)
            }
        } else {
            // destory
            if let view = _cardView as? UIView {
                view.removeFromSuperview()
            }
            _cardView = nil
        }
        // create/destory avatar view
        if options.showsAvatar {
            // create
            if _avatarView == nil {
                _avatarView = type(of: self).avatarViewClass._init()
            }
            if let view = _avatarView as? UIView, view.superview == nil {
                contentView.addSubview(view)
            }
        } else {
            // destory
            if let view = _avatarView as? UIView {
                view.removeFromSuperview()
            }
            _avatarView = nil
        }
        // create content view, if needed
        if _contentView == nil {
            // create
            _contentView = type(of: message.content).viewType._init()
            // move
            if let view = _contentView as? UIView, view.superview == nil {
                contentView.addSubview(view)
            }
        }
    }
    private func _updateViewLayouts() {
        // prepare
        guard let layoutInfo = _layoutAttributes?.info else {
            return
        }
        // update bubble view layout
        if let view = _bubbleView {
            view.frame = layoutInfo.layoutedRect(with: .bubble)
            //view.frame = layoutInfo.layoutedBoxRect(with: .content)
        }
        // update visit card view layout
        if let view = _cardView as? UIView {
            view.frame = layoutInfo.layoutedRect(with: .card)
        }
        // update avatar view layout
        if let view = _avatarView as? UIView {
            view.frame = layoutInfo.layoutedRect(with: .avatar)
        }
        // update content view layout
        if let view = _contentView as? UIView {
            view.frame = layoutInfo.layoutedRect(with: .content)
        }
    }
    private func _updateViewValues() {
        // prepare
        guard let message = _layoutAttributes?.message else {
            return
        }
        let options = message.options
        
        _cardView?.apply(message)
        _avatarView?.apply(message)
        _contentView?.apply(message)
        
        if let view = _bubbleView {
            switch options.alignment {
            case .left:
                let edg = UIEdgeInsetsMake(25, 25, 25, 25)
                
                view.image = UIImage.sac_init(named: "chat_bubble_recive_nor")?.resizableImage(withCapInsets: edg)
                view.highlightedImage = UIImage.sac_init(named: "chat_bubble_recive_press")?.resizableImage(withCapInsets: edg)
                
            case .right:
                let edg = UIEdgeInsetsMake(25, 25, 25, 25)
                view.image = UIImage.sac_init(named: "chat_bubble_send_nor")?.resizableImage(withCapInsets: edg)
                view.highlightedImage = UIImage.sac_init(named: "chat_bubble_send_press")?.resizableImage(withCapInsets: edg)
                
            case .center:
                let edg = UIEdgeInsetsMake(11, 11, 11, 11)
                
                view.image = UIImage.sac_init(named: "chat_bubble_tips_nor")?.resizableImage(withCapInsets: edg)
                view.highlightedImage = nil
            }
        }
//        if let f = _layoutAttributes?.info?.layoutedBoxRect(with: .content) {
//            debugger.addRect(f, key: "f")
//        }
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === _menuGesture else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        guard let rect = _layoutAttributes?.info?.layoutedBoxRect(with: .content) else {
            return false
        }
        guard rect.contains(gestureRecognizer.location(in: contentView)) else {
            return false
        }
        return true
    }
    
    private dynamic func _menuDismissed(_ sender: Notification) {
        //logger.trace()
        
        isHighlighted = false
        
        _removeObserverForMenu()
    }
    private dynamic func _handleMenuGesture(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else {
            return
        }
        guard let view = _contentView as? UIView,
            let content = _layoutAttributes?.message?.content,
            let info = _layoutAttributes?.info else {
            return
        }
        //logger.trace()
       
        let rect = UIEdgeInsetsInsetRect(info.layoutedRect(with: .content), { edg -> UIEdgeInsets in
            return .init(top: -edg.top,
                         left: -edg.left,
                         bottom: -edg.bottom,
                         right: -edg.right)
        }(content.layoutMargins))
        
        let mc = UIMenuController.shared
        
        // 设置响应者
        let cls = NSClassFromString("UICalloutBar") as? AnyObject
        cls?.setValue(self, forKeyPath: "sharedCalloutBar.responderTarget")
        
        mc.setTargetRect(convert(rect, to: view), in: view)
        mc.setMenuVisible(true, animated: true)
        
        
        isHighlighted = true
        
        _addObserverForMenu()
    }
    
    private func _addObserverForMenu() {
        guard !_observingMenu else {
            return
        }
        //_logger.trace()
        _observingMenu = true
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(_menuDismissed(_:)), name: .UIMenuControllerWillHideMenu, object: nil)
    }
    private func _removeObserverForMenu() {
        guard _observingMenu else {
            return
        }
        //_logger.trace()
        _observingMenu = false
        
        let center = NotificationCenter.default
        center.removeObserver(self, name: .UIMenuControllerWillHideMenu, object: nil)
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            return true
        }
        if action == #selector(delete(_:)) {
            return true
        }
        return false
    }
    
    private func _commonInit() {
        
        _menuGesture.delegate = self
        
        contentView.addGestureRecognizer(_menuGesture)
    }
    
    private var _bubbleView: UIImageView?
    
    private var _cardView: SACMessageContentViewType?
    private var _avatarView: SACMessageContentViewType?
    private var _contentView: SACMessageContentViewType?
    
    private var _observingMenu: Bool = false
    
    private var _layoutAttributes: SACChatViewLayoutAttributes?
    
    private lazy var _menuGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(_handleMenuGesture(_:)))
}


fileprivate extension SACMessageContentViewType {
    // 如果是NSObject对象, 直接使用self.init()会导致无法释放内存
    // 解决方案是转为显式类型再调用cls.init()
    fileprivate static func _init() -> SACMessageContentViewType {
        guard let cls = self as? NSObject.Type else {
            return self.init()
        }
        guard let ob = cls.init() as? SACMessageContentViewType else {
            return self.init()
        }
        return ob
    }
}
