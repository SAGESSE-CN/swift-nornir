//
//  SIMChatInputBar.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

//
// +---+------+---+---+
// | Y |      | @ | + |
// +---+------+---+---+
//                  

///
/// 聊天输入栏
///
public class SIMChatInputBar : UIView {
    public required init?(coder aDecoder: NSCoder) {
        SIMLog.trace()
        super.init(coder: aDecoder)
        build()
    }
    public override init(frame: CGRect) {
        SIMLog.trace()
        super.init(frame: frame)
        build()
    }
    deinit {
        SIMLog.trace()
    }

    //    /// 构建
//    private func build2() {
//    
//        //QQInputAccessoryViewCell
//        
//        let line = SIMChatLine()
//        let items = (leftItems as [UIView])  + [textView] + (rightItems as [UIView])
//        
//        // configs
//        textView.font = UIFont.systemFontOfSize(16)
//        textView.backgroundColor = UIColor.clearColor()
//        textView.scrollIndicatorInsets = UIEdgeInsetsMake(2, 0, 2, 0)
//        textView.returnKeyType = .Send
//        textView.delegate = self
////        backgroundView.image = SIMChatImageManager.defautlInputBackground
////        backgroundView.translatesAutoresizingMaskIntoConstraints = false
//        // line使用am
//        line.frame = CGRectMake(0, 0, bounds.width, 1)
//        line.contentMode = .Top
//        line.autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin
//        line.tintColor = UIColor(hex: 0xBDBDBD)
//        
//        // add view
//        addSubview(backgroundView)
//        for item in items {
//            // disable translates
//            item.translatesAutoresizingMaskIntoConstraints = false
//            // add
//            addSubview(item)
//            // add tag, if need
//            if let btn = item as? SIMChatInputBarItem {
//                btn.addTarget(self, action: "onItem:", forControlEvents: .TouchUpInside)
//            }
//        }
//        addSubview(line)
//        
//        // add constraints
//        
////        addConstraint(NSLayoutConstraintMake(backgroundView, .Top, .Equal, textView, .Top))
////        addConstraint(NSLayoutConstraintMake(backgroundView, .Left, .Equal, textView, .Left))
////        addConstraint(NSLayoutConstraintMake(backgroundView, .Right, .Equal, textView, .Right))
////        addConstraint(NSLayoutConstraintMake(backgroundView, .Bottom, .Equal, textView, .Bottom))
//        
//        // ..
//        for idx in 0 ..< items.count {
//            // ...
//            let item = items[idx]
//            // top
//            if item is UITextView { // is textView
//                addConstraint(NSLayoutConstraintMake(item, .Top,    .Equal, self,   .Top, 5))
//            } else {
//                addConstraint(NSLayoutConstraintMake(item, .Top,    .Equal, self,   .Top, 6))
//            }
//            // left
//            if idx == 0 { // is first
//                addConstraint(NSLayoutConstraintMake(item, .Left,   .Equal, self,   .Left, 5))
//            } else {
//                let pt = items[idx - 1]
//                let fix = item.isKindOfClass(pt.dynamicType) ? 0 : 5
//                addConstraint(NSLayoutConstraintMake(item, .Left,   .Equal, pt,     .Right, CGFloat(fix)))
//            }
//            // right
//            if idx == items.count - 1 { // is end
//                addConstraint(NSLayoutConstraintMake(item, .Right,  .Equal, self,   .Right, -5))
//            }
//            // bottom
//            if item is UITextView { // is textView
//                addConstraint(NSLayoutConstraintMake(item, .Bottom, .Equal, self,   .Bottom, -5))
//            } else {
//                addConstraint(NSLayoutConstraintMake(item, .Width,  .Equal, nil,    .Width, 34))
//                addConstraint(NSLayoutConstraintMake(item, .Height, .Equal, nil,    .Height, 34))
//            }
//        }
//    }
    /// 当前选中的
    public var selectedStyle: SIMChatInputBarItemStyle = .None {
        didSet {
//            self.delegate?.chatTextField?(self, didSelectItem: selectedStyle.rawValue)
        }
    }
    /// 最大高度
    var maxHeight: CGFloat = 80
    
    var enabled: Bool = true {
        willSet {
//            // 关闭输入
//            self.backgroundView.highlighted = newValue
//            self.textView.userInteractionEnabled = newValue
//            
//            for view in self.subviews {
//                if let btn = view as? UIButton {
//                    btn.enabled = newValue
//                }
//            }
        }
    }
    
    /// 代理
    public weak var delegate: SIMChatInputBarDelegate?
    
    var contentSize: CGSize {
        return _textView.contentSize
    }
    var contentOffset: CGPoint {
        return _textView.contentOffset
    }
    
    private var selectedItem: SIMChatInputBarItem? {
        willSet { self.selectedItem?.actived = false }
        didSet  { self.selectedItem?.actived = true }
    }
    
    private lazy var leftItems: [SIMChatInputBarItem] = [
        SIMChatInputBarItem(style: .Voice)
    ]
    private lazy var rightItems: [SIMChatInputBarItem] = [
        SIMChatInputBarItem(style: .Emoji),
        SIMChatInputBarItem(style: .Tool)
    ]
    
    
    private lazy var _backgroundView: UIImageView = {
        let view =  UIImageView()
        view.image = SIMChatImageManager.defautlInputBackground
        return view
    }()
    private lazy var _accessoryView: AccessoryView = {
        let view = AccessoryView(frame: self.bounds)
        view.dataSource = self
        view.backgroundColor = UIColor.clearColor()
        return view
    }()
    private lazy var _textView: TextView = {
        let view = TextView()
        view.font = UIFont.systemFontOfSize(16)
        view.returnKeyType = .Send
        view.backgroundColor = UIColor.clearColor()
        view.scrollIndicatorInsets = UIEdgeInsetsMake(2, 0, 2, 0)
        return view
    }()
    
    private lazy var lineView: UIView = UIView()
}

extension SIMChatInputBar {
    /// 输入框
    public var textView: UITextView { return _textView }
    /// 额外选项
    public var accessoryView: UIView { return _accessoryView }
    /// 背景
    public var backgroundView: UIView { return _backgroundView }
    
    /// 内容
    public var text: String? {
        set { return textView.text = newValue }
        get { return textView.text }
    }
}

extension SIMChatInputBar {
    /// 输入样式
    public enum Style: Int {
        case None   = 0
        case Emoji
        case Tool
        case Audio
    }
    /// 额外选项
    public class Accessory {
        public init(image: UIImage?, tag: Int) {
        }
    }
}

extension SIMChatInputBar {
    /// 初始化
    private func build() {
        
        backgroundColor = UIColor(hex: 0xEBECEE)
        textView.delegate = self
        lineView.backgroundColor = UIColor.grayColor()
        
        addSubview(backgroundView)
        addSubview(textView)
        addSubview(lineView)
        addSubview(accessoryView)
        
        // add layout
        
        SIMChatLayout.make(backgroundView)
            .top.equ(self).top(7)
            .left.equ(self).left(10)
            .right.equ(self).right(10)
            .submit()
        
        SIMChatLayout.make(textView)
            .top.equ(backgroundView).top
            .left.equ(backgroundView).left
            .right.equ(backgroundView).right
            .bottom.equ(backgroundView).bottom
            .submit()
        
        SIMChatLayout.make(lineView)
            .top.equ(self).top
            .left.equ(self).left
            .right.equ(self).right
            .height.equ(1 / UIScreen.mainScreen().scale)
            .submit()
        
        SIMChatLayout.make(accessoryView)
            .top.equ(backgroundView).bottom
            .left.equ(self).left
            .right.equ(self).right
            .bottom.equ(self).bottom
            .height.gte(5)
            .submit()
    }
}

// MARK: - Accessory
extension SIMChatInputBar  {
    /// 自定义的输入框
    private class TextView: UITextView {
        private override func intrinsicContentSize() -> CGSize {
            if contentSize.height > maxHeight {
                return CGSizeMake(contentSize.width, maxHeight)
            }
            return contentSize
        }
        private override var contentSize: CGSize {
            didSet {
                guard oldValue != contentSize && (oldValue.height <= maxHeight || contentSize.height <= maxHeight) else {
                    return
                }
                invalidateIntrinsicContentSize()
                // 只有正在显示的时候才添加动画
                guard window != nil else {
                    return
                }
                UIView.animateWithDuration(0.25) {
                    // 必须在更新父视图之前
                    self.layoutIfNeeded()
                    // 必须显示父视图, 因为这个改变会导致父视图大小改变
                    self.superview?.layoutIfNeeded()
                }
                SIMChatNotificationCenter.postNotificationName(SIMChatInputBarFrameDidChangeNotification, object: superview)
            }
        }
        
        private var maxHeight: CGFloat = 93
    }
    /// 额外选项
    private class AccessoryView: UICollectionView {
        private class Cell: UICollectionViewCell {
        }
        private init(frame: CGRect) {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSizeMake(34, 34)
            layout.sectionInset = UIEdgeInsetsMake(8, 10, 8, 10)
            super.init(frame: frame, collectionViewLayout: layout)
            registerClass(Cell.self, forCellWithReuseIdentifier: "Cell")
        }
        private required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        private override func intrinsicContentSize() -> CGSize {
            return contentSize
        }
        private override var contentSize: CGSize {
            didSet {
                if oldValue != contentSize {
                    invalidateIntrinsicContentSize()
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDateSource
extension SIMChatInputBar: UICollectionViewDataSource {
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.purpleColor()
        return cell
    }
}

// MARK: - Type
extension SIMChatInputBar {
    
    
    ///
    /// 输入输的选项
    ///
    class SIMChatInputBarItem : UIButton {
        
        /// 初始化
        required init?(coder aDecoder: NSCoder) {
            self.style = .Keyboard
            super.init(coder: aDecoder)
            self.update(self.style)
            self.tag = self.style.rawValue
        }
        /// 初始化
        init(style: SIMChatInputBarItemStyle) {
            self.style = style
            super.init(frame: CGRectZero)
            self.update(self.style)
            self.tag = style.rawValue
        }
        /// 按钮类型
        var style: SIMChatInputBarItemStyle {
            willSet {
                update(actived ? .Keyboard : newValue)
            }
        }
        /// 激活的
        var actived: Bool = false {
            willSet {
                update(newValue ? .Keyboard : style)
            }
        }
        /// 更新
        private func update(style: SIMChatInputBarItemStyle) {
            if let item = SIMChatImageManager.inputItemImages[style] {
                setImage(item.n, forState: .Normal)
                setImage(item.h, forState: .Highlighted)
                
                // duang
                let ani = CATransition()
                
                ani.duration = 0.25
                ani.fillMode = kCAFillModeBackwards
                ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                ani.type = kCATransitionFade
                ani.subtype = kCATransitionFromTop
                        
                layer.addAnimation(ani, forKey: "s")
            }
        }
    }
}

// MARK: - Life Cycel

extension SIMChatInputBar  {
    
    public override func isFirstResponder() -> Bool {
        if selectedStyle != .None {
            return true
        }
        return self.textView.isFirstResponder() || super.isFirstResponder()
    }
    
    public override func resignFirstResponder() -> Bool {
        if self.selectedItem != nil {
            self.selectedItem = nil
            self.selectedStyle = .None
        }
        if self.isFirstResponder() {
            return super.resignFirstResponder() || self.textView.resignFirstResponder()
        }
        return false
    }
    
    public override func becomeFirstResponder() -> Bool {
        return self.textView.becomeFirstResponder()
    }
}


// MARK: - Text View Delegate and Forward
extension SIMChatInputBar : UITextViewDelegate {
    /// 将要编辑文本
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        guard delegate?.inputBarShouldBeginEditing?(self) ?? true else {
            return false
        }
        // 取消选中
        self.selectedItem = nil
        self.selectedStyle = .Keyboard
        
        return true
    }
    /// 己经开始编辑了
    public func textViewDidBeginEditing(textView: UITextView) {
        delegate?.inputBarDidBeginEditing?(self)
    }
    /// 将要结束
    public func textViewShouldEndEditing(textView: UITextView) -> Bool {
        guard delegate?.inputBarShouldEndEditing?(self) ?? true else {
            return false
        }
        return true
    }
    /// 己经结束
    public func textViewDidEndEditing(textView: UITextView) {
        delegate?.inputBarDidEndEditing?(self)
    }
    /// 文本将要改变
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard delegate?.inputBar?(self, shouldChangeCharactersInRange: range, replacementString: text) ?? true else {
            return false
        }
        // 这是换行
        if text == "\n" {
            return delegate?.inputBarShouldReturn?(self) ?? true
        }
        // 这是clear
        if text.isEmpty && range.location == 0 && range.length == (self.text as NSString?)?.length {
            return delegate?.inputBarShouldClear?(self) ?? true
        }
        
        return true
    }
    /// 文本己经改变.
    public func textViewDidChange(textView: UITextView) {
        delegate?.inputBarDidChange?(self)
    }
    /// 选择改变
    public func textViewDidChangeSelection(textView: UITextView) {
        delegate?.inputBarDidChangeSelection?(self)
    }
    
    /// 滚动到最后
    func scrollViewToBottom() {
        SIMLog.trace()
//        let ch = textView.contentSize.height
//        let bh = textView.bounds.height
//        let py = textView.contentOffset.y
//        if ch - bh > py {
//            textView.setContentOffset(CGPointMake(0, ch - bh), animated: true)
//        }
    }
}

// MARK: - Event
extension SIMChatInputBar {
    /// 选项
    func onItem(sender: SIMChatInputBarItem) {
        if sender.actived {
            self.selectedItem = nil
            self.selectedStyle = .Keyboard
            self.textView.becomeFirstResponder()
        } else {
            self.selectedItem = sender
            self.selectedStyle = sender.style
            self.textView.resignFirstResponder()
        }
    }
}

/// 选项类型
public enum SIMChatInputBarItemStyle : Int {
    
    case None       = 0x0000
    case Keyboard   = 0x0100
    case Voice      = 0x0101
    case Emoji      = 0x0102
    case Tool       = 0x0103
}

@objc public protocol SIMChatInputBarDelegate: NSObjectProtocol {
    
    optional func inputBarShouldBeginEditing(inputBar: SIMChatInputBar) -> Bool
    optional func inputBarDidBeginEditing(inputBar: SIMChatInputBar)
    
    optional func inputBarShouldEndEditing(inputBar: SIMChatInputBar) -> Bool
    optional func inputBarDidEndEditing(inputBar: SIMChatInputBar)
    
    optional func inputBarShouldClear(inputBar: SIMChatInputBar) -> Bool
    optional func inputBarShouldReturn(inputBar: SIMChatInputBar) -> Bool
    
    optional func inputBar(inputBar: SIMChatInputBar, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    
    optional func inputBarDidChange(inputBar: SIMChatInputBar)
    optional func inputBarDidChangeSelection(inputBar: SIMChatInputBar)
}

public let SIMChatInputBarFrameDidChangeNotification = "SIMChatInputBarFrameDidChangeNotification"