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
        guard let observer = _menuNotifyObserver else{
            return
        }
        NotificationCenter.default.removeObserver(observer)
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
//        debugger.addText("\(_layoutAttributes!.indexPath) \(message.date)", key: "text")
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == _menuGesture else {
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
        
        let rect = UIEdgeInsetsInsetRect(info.layoutedRect(with: .content), -content.layoutMargins)
        let menuController = UIMenuController.shared
        
        // set responder
        (NSClassFromString("UICalloutBar") as? AnyObject)?.setValue(self, forKeyPath: "sharedCalloutBar.responderTarget")
        
        // set menu display position
        menuController.setTargetRect(convert(rect, to: view), in: view)
        menuController.setMenuVisible(true, animated: true)
        
        // really show?
        guard menuController.isMenuVisible else {
            return 
        }
        
        // set selected
        self.isHighlighted = true
        self._menuNotifyObserver = NotificationCenter.default.addObserver(forName: .UIMenuControllerWillHideMenu, object: nil, queue: nil) { [weak self] notification in
            // is release?
            guard let observer = self?._menuNotifyObserver else {
                return 
            }
            NotificationCenter.default.removeObserver(observer)
            // cancel select
            self?.isHighlighted = false
            self?._menuNotifyObserver = nil
        }
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // menu bar only process
        guard sender is UIMenuController else {
            // other is default process
            return super.canPerformAction(action, withSender: sender)
        }
        // check collectionView and attributes
        guard let view = _collectionView, let indexPath = _layoutAttributes?.indexPath else {
            return false
        }
        // forward to collectionView
        guard let result = view.delegate?.collectionView?(view, canPerformAction: action, forItemAt: indexPath, withSender: sender) else {
            return false 
        }
        return result
    }
    
    open override func perform(_ action: Selector!, with sender: Any!) -> Unmanaged<AnyObject>! {
        // menu bar only process
        guard sender is UIMenuController else {
            // other is default process
            return super.perform(action, with: sender)
        }
        // check collectionView and attributes
        guard let view = _collectionView, let indexPath = _layoutAttributes?.indexPath else {
            return nil
        }
        // forward to collectionView
        view.delegate?.collectionView?(view, performAction: action, forItemAt: indexPath, withSender: sender)
        
        return nil
    }
    
    private func _commonInit() {

    }
    
    private var _bubbleView: UIImageView?
    
    private var _cardView: SACMessageContentViewType?
    private var _avatarView: SACMessageContentViewType?
    private var _contentView: SACMessageContentViewType?
    
    private var _menuNotifyObserver: Any?
    private var _menuGesture: UILongPressGestureRecognizer? {
        return value(forKeyPath: "_menuGesture") as? UILongPressGestureRecognizer
    }
    
    private var _collectionView: UICollectionView? {
        return value(forKeyPath: "_collectionView") as? UICollectionView
    }
    
    private var _layoutAttributes: SACChatViewLayoutAttributes?
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

fileprivate prefix func -(edg: UIEdgeInsets) -> UIEdgeInsets {
    // 取反
    return .init(top: -edg.top, left: -edg.left, bottom: -edg.bottom, right: edg.right)
}
