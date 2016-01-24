//
//  SIMChatLayout.swift
//  SIMChat
//
//  Created by sagesse on 1/17/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

public final class SIMChatLayout {
    public class Config: FirstAttribute {
        public func priority(v: CGFloat) -> Self {
            context?.priority = UILayoutPriority(v)
            return self
        }
        public func multiplier(v: CGFloat) -> Self {
            context?.multiplier = v
            return self
        }
        public func submit() -> SIMChatLayout {
            layout.submit()
            return layout
        }
        
        private override init(_ layout: SIMChatLayout, _ context: Context?) {
            super.init(layout, context)
            if let context = context {
                layout.contexts.append(context)
            }
        }
    }
    public class Relation {
        func equ(v: AnyObject) -> SecondAttribute {
            context.relation = .Equal
            context.secondItem = v
            return SecondAttribute(layout, context)
        }
        func lte(v: AnyObject) -> SecondAttribute {
            context.relation = .LessThanOrEqual
            context.secondItem = v
            return SecondAttribute(layout, context)
        }
        func gte(v: AnyObject) -> SecondAttribute {
            context.relation = .GreaterThanOrEqual
            context.secondItem = v
            return SecondAttribute(layout, context)
        }
        
        private var layout: SIMChatLayout
        private var context: Context
        private init(_ layout: SIMChatLayout, _ context: Context) {
            self.layout = layout
            self.context = context
        }
    }
    public class RelationOfConst: Relation {
        public func equ(v: CGFloat) -> Config {
            context.relation = .Equal
            context.secondItem = nil
            context.secondAttribute = context.firstAttribute
            context.constant = v
            return Config(layout, context)
        }
        public func lte(v: CGFloat) -> Config {
            context.relation = .LessThanOrEqual
            context.secondItem = nil
            context.secondAttribute = context.firstAttribute
            context.constant = v
            return Config(layout, context)
        }
        public func gte(v: CGFloat) -> Config {
            context.relation = .GreaterThanOrEqual
            context.secondItem = nil
            context.secondAttribute = context.firstAttribute
            context.constant = v
            return Config(layout, context)
        }
    }
    public class FirstAttribute {
        
        public var top: Relation { return set(.Top) }
        public var left: Relation { return set(.Left) }
        public var right: Relation { return set(.Right) }
        public var bottom: Relation { return set(.Bottom) }
        
        public var leading: Relation { return set(.Leading) }
        public var trailing: Relation { return set(.Trailing) }
        
        public var centerX: Relation { return set(.CenterX) }
        public var centerY: Relation { return set(.CenterY) }
        public var baseline: Relation { return set(.Baseline) }
        
        public var width: RelationOfConst { return setV2(.Width) }
        public var height: RelationOfConst { return setV2(.Height) }
        
        private func set(att: NSLayoutAttribute) -> Relation {
            let context = Context()
            context.firstAttribute = att
            return Relation(layout, context)
        }
        private func setV2(att: NSLayoutAttribute) -> RelationOfConst {
            let context = Context()
            context.firstAttribute = att
            return RelationOfConst(layout, context)
        }
        private init(_ layout: SIMChatLayout, _ context: Context? = nil) {
            self.layout = layout
            self.context = context
        }
        
        private var layout: SIMChatLayout
        private var context: Context?
    }
    public class SecondAttribute {
        public var top:         Config { return top(0) }
        public var left:        Config { return left(0) }
        public var right:       Config { return right(0) }
        public var bottom:      Config { return bottom(0) }
        public var leading:     Config { return leading(0) }
        public var trailing:    Config { return trailing(0) }
        public var centerX:     Config { return centerX(0) }
        public var centerY:     Config { return centerY(0) }
        public var baseline:    Config { return baseline(0) }
        public var width:       Config { return width(0) }
        public var height:      Config { return height(0) }
        
        public func top(v:CGFloat)      -> Config { return set(.Top, v) }
        public func left(v:CGFloat)     -> Config { return set(.Left, v) }
        public func right(v:CGFloat)    -> Config { return set(.Right, -v) }
        public func bottom(v:CGFloat)   -> Config { return set(.Bottom, -v) }
        public func leading(v:CGFloat)  -> Config { return set(.Leading, v) }
        public func trailing(v:CGFloat) -> Config { return set(.Trailing, v) }
        public func centerX(v:CGFloat)  -> Config { return set(.CenterX, v) }
        public func centerY(v:CGFloat)  -> Config { return set(.CenterY, v) }
        public func baseline(v:CGFloat) -> Config { return set(.Baseline, v) }
        public func width(v:CGFloat)    -> Config { return set(.Width, v) }
        public func height(v:CGFloat)   -> Config { return set(.Height, v) }
        
        private func set(att: NSLayoutAttribute, _ v: CGFloat) -> Config {
            context.secondAttribute = att
            context.constant = v
            return Config(layout, context)
        }
        private init(_ layout: SIMChatLayout, _ context: Context) {
            self.layout = layout
            self.context = context
        }
        
        private var layout: SIMChatLayout
        private var context: Context
    }
    
    public var top: CGFloat {
        set { _top?.constant = newValue }
        get { return _top?.constant ?? 0 }
    }
    public var left: CGFloat {
        set { _left?.constant = newValue }
        get { return _left?.constant ?? 0 }
    }
    public var right: CGFloat {
        set { _right?.constant = -newValue }
        get { return -(_right?.constant ?? 0) }
    }
    public var bottom: CGFloat {
        set { _bottom?.constant = -newValue }
        get { return -(_bottom?.constant ?? 0) }
    }
    
    public var leading: CGFloat {
        set { _leading?.constant = newValue }
        get { return _leading?.constant ?? 0 }
    }
    public var trailing: CGFloat {
        set { _trailing?.constant = newValue }
        get { return _trailing?.constant ?? 0 }
    }
    
    public var centerX: CGFloat {
        set { _centerX?.constant = newValue }
        get { return _centerX?.constant ?? 0 }
    }
    public var centerY: CGFloat {
        set { _centerY?.constant = newValue }
        get { return _centerY?.constant ?? 0 }
    }
    public var baseline: CGFloat {
        set { _baseline?.constant = newValue }
        get { return _baseline?.constant ?? 0 }
    }
    
    public var width: CGFloat {
        set { _width?.constant = newValue }
        get { return _width?.constant ?? 0 }
    }
    public var height: CGFloat {
        set { _height?.constant = newValue }
        get { return _height?.constant ?? 0 }
    }
    
    static func make(v: UIView) -> Config {
        if v.translatesAutoresizingMaskIntoConstraints {
            v.translatesAutoresizingMaskIntoConstraints = false
        }
        let layout = self.init(v)
        layout.autoSubmit()
        return Config(layout, nil)
    }
    
    private class Context {
        
        private var constant: CGFloat?
        private var multiplier: CGFloat?
        private var priority: UILayoutPriority?
        
        private var shouldBeArchived: Bool?
        
        // firstItem.firstAttribute {==,<=,>=} secondItem.secondAttribute * multiplier + constant
        
        private var firstItem: UIView?
        private var firstAttribute: NSLayoutAttribute?
        private var relation: NSLayoutRelation?
        private var secondItem: AnyObject?
        private var secondAttribute: NSLayoutAttribute?
        
        private var constraint: NSLayoutConstraint?
    }
    
    /// 提交
    private func submit() {
        guard !isSubmit else {
            return
        }
        // 生成.
        for context in contexts {
            guard let firstAttribute = context.firstAttribute else {
                continue
            }
            guard let relation = context.relation else {
                continue
            }
            guard let secondAttribute = context.secondAttribute else {
                continue
            }
            
            let constraint = NSLayoutConstraint(
                item: value,
                attribute: firstAttribute,
                relatedBy: relation,
                toItem: context.secondItem,
                attribute: secondAttribute,
                multiplier: context.multiplier ?? 1,
                constant: context.constant ?? 0)
            
            constraint.priority = context.priority ?? UILayoutPriorityRequired
            if let secondItem = context.secondItem {
                let container: UIView = {
                    if let view = secondItem as? UIView {
                        var a = view
                        while true {
                            var b = self.value
                            while true {
                                if a === b {
                                    return a
                                }
                                guard let s = b.superview else {
                                    break
                                }
                                b = s
                            }
                            guard let s = a.superview else {
                                break
                            }
                            a = s
                        }
                    }
                    return self.value
                }()
                container.addConstraint(constraint)
            } else {
                value.addConstraint(constraint)
            }
            context.constraint = constraint
            switch firstAttribute {
            case .Top:      _top = constraint
            case .Left:     _left = constraint
            case .Right:    _right = constraint
            case .Bottom:   _bottom = constraint
            case .Leading:  _leading = constraint
            case .Trailing: _trailing = constraint
            case .CenterX:  _centerX = constraint
            case .CenterY:  _centerY = constraint
            case .Baseline: _baseline = constraint
            case .Width:    _width = constraint
            case .Height:   _height = constraint
            default : break
            }
        }
        isSubmit = true
    }
    
    /// 延迟执行
    private func autoSubmit() {
//        let runLoop = CFRunLoopGetCurrent()
//        let runLoopMode = kCFRunLoopCommonModes//kCFRunLoopDefaultMode
//        let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.BeforeWaiting.rawValue, false, 0) { observer, _ in
//            CFRunLoopRemoveObserver(runLoop, observer, runLoopMode)
//            self.submit()
//        }
//        
//        CFRunLoopAddObserver(runLoop, observer, runLoopMode)
    }
    
    private init(_ v: UIView) {
        self.value = v
    }
    
    private var value: UIView
    private var isSubmit: Bool = false
    private var contexts: [Context] = []
    
    private weak var _top: NSLayoutConstraint?
    private weak var _left: NSLayoutConstraint?
    private weak var _right: NSLayoutConstraint?
    private weak var _bottom: NSLayoutConstraint?
    
    private weak var _leading: NSLayoutConstraint?
    private weak var _trailing: NSLayoutConstraint?
    private weak var _centerX: NSLayoutConstraint?
    private weak var _centerY: NSLayoutConstraint?
    private weak var _baseline: NSLayoutConstraint?
    
    private weak var _width: NSLayoutConstraint?
    private weak var _height: NSLayoutConstraint?
}