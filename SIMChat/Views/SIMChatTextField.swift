//
//  SIMChatInputView.swift
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
class SIMChatTextField : SIMView {
    /// 构建
    override func build() {
        super.build()
        
        let line = SIMChatLine()
        let items = (leftItems as [UIView])  + [textView] + (rightItems as [UIView])
        
        // configs
        textView.font = UIFont.systemFontOfSize(16)
        textView.backgroundColor = UIColor.clearColor()
        textView.scrollIndicatorInsets = UIEdgeInsetsMake(2, 0, 2, 0)
        textView.returnKeyType = .Send
        textView.delegate = self
        backgroundView.image = SIMChatImageManager.defautlInputBackground
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        // line使用am
        line.frame = CGRectMake(0, 0, bounds.width, 1)
        line.contentMode = .Top
        line.autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin
        line.tintColor = UIColor(hex: 0xBDBDBD)
        
        // add view
        addSubview(backgroundView)
        for item in items {
            // disable translates
            item.translatesAutoresizingMaskIntoConstraints = false
            // add
            addSubview(item)
            // add tag, if need
            if let btn = item as? SIMChatTextFieldItem {
                btn.addTarget(self, action: "onItem:", forControlEvents: .TouchUpInside)
            }
        }
        addSubview(line)
        
        // add constraints
        
        addConstraint(NSLayoutConstraintMake(backgroundView, .Top, .Equal, textView, .Top))
        addConstraint(NSLayoutConstraintMake(backgroundView, .Left, .Equal, textView, .Left))
        addConstraint(NSLayoutConstraintMake(backgroundView, .Right, .Equal, textView, .Right))
        addConstraint(NSLayoutConstraintMake(backgroundView, .Bottom, .Equal, textView, .Bottom))
        
        // ..
        for idx in 0 ..< items.count {
            // ...
            let item = items[idx]
            // top
            if item is UITextView { // is textView
                addConstraint(NSLayoutConstraintMake(item, .Top,    .Equal, self,   .Top, 5))
            } else {
                addConstraint(NSLayoutConstraintMake(item, .Top,    .Equal, self,   .Top, 6))
            }
            // left
            if idx == 0 { // is first
                addConstraint(NSLayoutConstraintMake(item, .Left,   .Equal, self,   .Left, 5))
            } else {
                let pt = items[idx - 1]
                let fix = item.isKindOfClass(pt.dynamicType) ? 0 : 5
                addConstraint(NSLayoutConstraintMake(item, .Left,   .Equal, pt,     .Right, CGFloat(fix)))
            }
            // right
            if idx == items.count - 1 { // is end
                addConstraint(NSLayoutConstraintMake(item, .Right,  .Equal, self,   .Right, -5))
            }
            // bottom
            if item is UITextView { // is textView
                addConstraint(NSLayoutConstraintMake(item, .Bottom, .Equal, self,   .Bottom, -5))
            } else {
                addConstraint(NSLayoutConstraintMake(item, .Width,  .Equal, nil,    .Width, 34))
                addConstraint(NSLayoutConstraintMake(item, .Height, .Equal, nil,    .Height, 34))
            }
        }
    }
    /// 当前焦点
    override func isFirstResponder() -> Bool {
        return super.isFirstResponder() || self.textView.isFirstResponder()
    }
    /// 放弃焦点
    override func resignFirstResponder() -> Bool {
        if self.selectedItem != nil {
            self.selectedItem = nil
            self.selectedStyle = .None
        }
        if self.isFirstResponder() {
            return super.resignFirstResponder() || self.textView.resignFirstResponder()
        }
        return false
    }
    /// 重新取得焦点
    override func becomeFirstResponder() -> Bool {
        return self.textView.becomeFirstResponder()
    }
    /// ...
    override func intrinsicContentSize() -> CGSize {
        if textView.contentSize.height > maxHeight {
            // 不要改变
            return CGSizeMake(bounds.width, bounds.height)
        }
        return CGSizeMake(bounds.width, max(textView.contentSize.height, 36) + 10)
    }
    /// 内容
    var text: String! {
        set {
            self.textView.text = newValue
            self.textViewDidChange(textView)
        }
        get {
            return self.textView.text
        }
    }
    /// 当前选中的
    var selectedStyle: SIMChatTextFieldItemStyle = .None {
        didSet {
            self.delegate?.chatTextField?(self, didSelectItem: selectedStyle.rawValue)
        }
    }
    /// 最大高度
    var maxHeight: CGFloat = 80
    /// 代理
    weak var delegate: SIMChatTextFieldDelegate?
    
    var enabled: Bool = true {
        willSet {
            
            // 关闭输入
            self.backgroundView.highlighted = newValue
            self.textView.userInteractionEnabled = newValue
            
            for view in self.subviews {
                if let btn = view as? UIButton {
                    btn.enabled = newValue
                }
            }
        }
    }
    
    var contentSize: CGSize {
        return textView.contentSize
    }
    var contentOffset: CGPoint {
        return textView.contentOffset
    }
    
    private var selectedItem: SIMChatTextFieldItem? {
        willSet { self.selectedItem?.actived = false }
        didSet  { self.selectedItem?.actived = true }
    }
    private lazy var textView = UITextView()
    private lazy var backgroundView = UIImageView()
    
    private lazy var leftItems: [SIMChatTextFieldItem] = [
        SIMChatTextFieldItem(style: .Voice)
    ]
    private lazy var rightItems: [SIMChatTextFieldItem] = [
        SIMChatTextFieldItem(style: .Emoji),
        SIMChatTextFieldItem(style: .Tool)
    ]
}

/// MARK: - /// Type
extension SIMChatTextField {
    ///
    /// 输入输的选项
    ///
    class SIMChatTextFieldItem : UIButton {
        
        /// 初始化
        required init?(coder aDecoder: NSCoder) {
            self.style = .Keyboard
            super.init(coder: aDecoder)
            self.update(self.style)
            self.tag = self.style.rawValue
        }
        /// 初始化
        init(style: SIMChatTextFieldItemStyle) {
            self.style = style
            super.init(frame: CGRectZero)
            self.update(self.style)
            self.tag = style.rawValue
        }
        /// 按钮类型
        var style: SIMChatTextFieldItemStyle {
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
        private func update(style: SIMChatTextFieldItemStyle) {
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

/// MARK: - /// Text View Delegate and Forward
extension SIMChatTextField : UITextViewDelegate {
    /// 将要编辑文本
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if delegate?.chatTextFieldShouldBeginEditing?(self) ?? true {
            // 取消选中
            self.selectedItem = nil
            self.selectedStyle = .Keyboard
            // ok
            return true
        }
        return false
    }
    /// 己经开始编辑了
    func textViewDidBeginEditing(textView: UITextView) {
        delegate?.chatTextFieldDidBeginEditing?(self)
    }
    /// 将要结束
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        if delegate?.chatTextFieldShouldEndEditing?(self) ?? true {
            return true
        }
        return false
    }
    /// 己经结束
    func textViewDidEndEditing(textView: UITextView) {
        delegate?.chatTextFieldDidEndEditing?(self)
    }
    /// 文本将要改变
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if delegate?.chatTextField?(self, shouldChangeCharactersInRange: range, replacementString: text) ?? true {
            // 这是换行
            if text == "\n" {
                return self.delegate?.chatTextFieldShouldReturn?(self) ?? true
            }
            // 这是clear
            if text.isEmpty {
                return self.delegate?.chatTextFieldShouldClear?(self) ?? true
            }
            // 其他
            return true
        }
        return false
    }
    /// 文本己经改变.
    func textViewDidChange(textView: UITextView) {
        // 必须要先更新一下, 否则高度计算不准确
        self.textView.layoutIfNeeded()
        let src = textView.bounds.height
        let dst = textView.contentSize.height
        // 只有不同才会调整
        if src != dst {
            if textView.contentSize.height < maxHeight {
                SIMLog.trace("src: \(src), dst: \(dst)")
                UIView.animateWithDuration(0.25) {
                    self.invalidateIntrinsicContentSize()
                    self.layoutIfNeeded()
                    self.superview?.layoutIfNeeded()
                }
                // 更新offset
                textView.setContentOffset(CGPointZero, animated: true)
                // 大小发生了改变, 通知
                delegate?.chatTextFieldContentSizeDidChange?(self)
            }
        }
        
        // 通知
        delegate?.chatTextFieldDidChange?(self)
    }
    /// 滚动到最后
    func scrollViewToBottom() {
        SIMLog.trace()
        let ch = textView.contentSize.height
        let bh = textView.bounds.height
        let py = textView.contentOffset.y
        if ch - bh > py {
            textView.setContentOffset(CGPointMake(0, ch - bh), animated: true)
        }
    }
}

/// MARK: - /// Event
extension SIMChatTextField {
    /// 选项
    func onItem(sender: SIMChatTextFieldItem) {
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

/// 代理
@objc protocol SIMChatTextFieldDelegate : NSObjectProtocol {
    
    optional func chatTextField(chatTextField: SIMChatTextField, didSelectItem item: Int)
    
    optional func chatTextFieldShouldBeginEditing(chatTextField: SIMChatTextField) -> Bool
    optional func chatTextFieldDidBeginEditing(chatTextField: SIMChatTextField)
    
    optional func chatTextFieldShouldEndEditing(chatTextField: SIMChatTextField) -> Bool
    optional func chatTextFieldDidEndEditing(chatTextField: SIMChatTextField)
    
    optional func chatTextFieldDidChange(chatTextField: SIMChatTextField)
    optional func chatTextField(chatTextField: SIMChatTextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    
    optional func chatTextFieldContentSizeDidChange(chatTextField: SIMChatTextField)
    
    optional func chatTextFieldShouldClear(chatTextField: SIMChatTextField) -> Bool
    optional func chatTextFieldShouldReturn(chatTextField: SIMChatTextField) -> Bool
}
