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
/// - TODO: 未考虑扩展问题
///
class SIMChatTextField : SIMView {

    /// 构建
    override func build() {
        super.build()
        
        let line = SIMChatLine()
        let items = (leftItems as [UIView])  + [contentView] + (rightItems as [UIView])
        
        // configs
        contentView.font = UIFont.systemFontOfSize(16)
        contentView.backgroundColor = UIColor.clearColor()
        contentView.scrollIndicatorInsets = UIEdgeInsetsMake(2, 0, 2, 0)
        contentView.returnKeyType = .Send
        contentView.delegate = self
        contentBackgroundView.image = SIMChatImageManager.defautlInputBackground
        contentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        // line使用am
        line.frame = CGRectMake(0, 0, bounds.width, 1)
        line.contentMode = .Top
        line.autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin
        line.tintColor = UIColor(hex: 0xBDBDBD)
        
        // add view
        addSubview(contentBackgroundView)
        for item in items {
            // disable translates
            item.translatesAutoresizingMaskIntoConstraints = false
            // add
            addSubview(item)
            // add tag, if need
            if let btn = item as? SIMChatTextFieldItem {
                btn.addTarget(self, action: "onEvent:", forControlEvents: .TouchUpInside)
            }
        }
        addSubview(line)
        
        // add constraints
        
        addConstraint(NSLayoutConstraintMake(contentBackgroundView, .Top, .Equal, contentView, .Top))
        addConstraint(NSLayoutConstraintMake(contentBackgroundView, .Left, .Equal, contentView, .Left))
        addConstraint(NSLayoutConstraintMake(contentBackgroundView, .Right, .Equal, contentView, .Right))
        addConstraint(NSLayoutConstraintMake(contentBackgroundView, .Bottom, .Equal, contentView, .Bottom))
        
        // ..
        for idx in 0 ..< items.count {
            // ...
            let item = items[idx]
            // top
            if item is UITextView { // is contentView
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
            if item is UITextView { // is contentView
                addConstraint(NSLayoutConstraintMake(item, .Bottom, .Equal, self,   .Bottom, -5))
            } else {
                addConstraint(NSLayoutConstraintMake(item, .Width,  .Equal, nil,    .Width, 34))
                addConstraint(NSLayoutConstraintMake(item, .Height, .Equal, nil,    .Height, 34))
            }
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(0, max(contentView.contentSize.height + 10, 44))
    }
    
    private(set) lazy var contentView = UITextView()
    private(set) lazy var contentBackgroundView = UIImageView()
    
    private(set) lazy var leftItems: [SIMChatTextFieldItem] = [
        SIMChatTextFieldItem(style: .Voice)
    ]
    private(set) lazy var rightItems: [SIMChatTextFieldItem] = [
        SIMChatTextFieldItem(style: .Emoji),
        SIMChatTextFieldItem(style: .Tool)
    ]
    
    private(set) var currentItem: SIMChatTextFieldItem?
}


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
        }
        /// 初始化
        init(style: SIMChatTextFieldItemStyle) {
            self.style = style
            super.init(frame: CGRectZero)
            self.update(self.style)
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


extension SIMChatTextField : UITextViewDelegate {
    
    /// 将要编辑文本
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return true
    }
    /// 文本己经改变.
    func textViewDidChange(textView: UITextView) {
        //self.layoutIfNeeded()
        UIView.animateWithDuration(0.25) {
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }
    }
}


extension SIMChatTextField {
    
    ///
    /// 事件
    ///
    func onEvent(sender: SIMChatTextFieldItem?) {
        SIMLog.trace()
        
        currentItem?.actived = false
        currentItem = sender
        currentItem?.actived = true
        
    }
}