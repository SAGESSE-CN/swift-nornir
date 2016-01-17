//
//  SIMHelper.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit


/// 提供 | 操作支持
func |<T : OptionSetType>(lhs: T, rhs: T) -> T {
    return lhs.union(rhs)
}

/// 为时间提供 - 操作支持
func -(lhs: NSDate, rhs: NSDate) -> NSTimeInterval {
    return lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970
}

/// 让枚举支持 allZeros
extension OptionSetType where RawValue : BitwiseOperationsType {
    static var allZeros: Self {
        return self.init()
    }
}

/// 生成约束
func NSLayoutConstraintMake(item: AnyObject, _ attribute: NSLayoutAttribute, _ relatedBy: NSLayoutRelation, _ toItem: AnyObject?, _ attribute2: NSLayoutAttribute, _ constant: CGFloat = 0, _ priority: CGFloat = 1000, _ multiplier: CGFloat = 1) -> NSLayoutConstraint {
    let c = NSLayoutConstraint(item: item, attribute: attribute, relatedBy: relatedBy, toItem: toItem, attribute: attribute2, multiplier: multiplier, constant: constant)
    c.priority = UILayoutPriority(priority)
    return c
}

/// 生成约束, 用vfl
func NSLayoutConstraintMake(format: String, views: [String : AnyObject], options opts: NSLayoutFormatOptions = .allZeros, metrics: [String : AnyObject]? = nil) -> [NSLayoutConstraint] {
    return NSLayoutConstraint.constraintsWithVisualFormat(format, options: opts, metrics: metrics, views: views)
}

/// 添加build
public class SIMView : UIView {
    /// 序列化
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.build()
    }
    /// 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.build()
    }
    /// 构建
    func build() {
    }
}

/// 添加build
class SIMControl : UIControl {
    /// 序列化
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.build()
    }
    /// 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.build()
    }
    /// 构建
    func build() {
    }
}

/// 添加build
class SIMImageView : UIImageView {
    /// 序列化
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.build()
    }
    /// 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.build()
    }
    /// 初始化
    override init(image: UIImage?) {
        super.init(image: image)
        self.build()
    }
    /// 初始化
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        self.build()
    }
    /// 构建
    func build() {
    }
}

/// 添加build
class SIMTableViewCell : UITableViewCell {
    /// 序列化
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.build()
    }
    /// 初始化
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.build()
    }
    /// 构建
    func build() {
    }
}

/// 添加build
class SIMViewController : UIViewController {
    /// 序列化
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.build()
    }
    /// 初始化
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.build()
    }
    /// 构建
    func build() {
    }
}

extension NSDate {
    /// 零
    class var zero: NSDate {
        return NSDate(timeIntervalSince1970: 0)
    }
    /// 现在
    class var now: NSDate {
        return NSDate()
    }
    /// 友好的显示
    var visual: String {
        let df = NSDateFormatter()
        // format
        df.dateStyle = .MediumStyle
        df.timeStyle = .ShortStyle
        // ok
        return df.stringFromDate(self)
    }
}

extension NSTimer {
    class func scheduledTimerWithTimeInterval2(ti: NSTimeInterval, _ aTarget: AnyObject, _ aSelector: Selector, _ userInfo: AnyObject? = nil) -> NSTimer {
        return self.scheduledTimerWithTimeInterval(ti, target: aTarget, selector: aSelector, userInfo: userInfo, repeats: true)
    }
}


public final class SIMChatLayout {
    public class Config: FirstAttribute {
        func priority(v: CGFloat) -> Self {
            context?.priority = UILayoutPriority(v)
            return self
        }
        func multiplier(v: CGFloat) -> Self {
            context?.multiplier = v
            return self
        }
        func submit() -> SIMChatLayout {
            // 生成.
            for context in layout.contexts {
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
                    item: layout.value,
                    attribute: firstAttribute,
                    relatedBy: relation,
                    toItem: context.secondItem,
                    attribute: secondAttribute,
                    multiplier: context.multiplier ?? 1,
                    constant: context.constant ?? 0)
                
                constraint.priority = context.priority ?? UILayoutPriorityRequired
                if let secondItem = context.secondItem {
                    if let view = secondItem as? UIView {
                        view.addConstraint(constraint)
                    }
                } else {
                    if let view = layout.value as? UIView {
                        view.addConstraint(constraint)
                    }
                }
                context.constraint = constraint
                switch firstAttribute {
                case .Top:      layout._top = constraint
                case .Left:     layout._left = constraint
                case .Right:    layout._right = constraint
                case .Bottom:   layout._bottom = constraint
                case .Leading:  layout._leading = constraint
                case .Trailing: layout._trailing = constraint
                case .CenterX:  layout._centerX = constraint
                case .CenterY:  layout._centerY = constraint
                case .Baseline: layout._baseline = constraint
                case .Width:    layout._width = constraint
                case .Height:   layout._height = constraint
                default : break
                }
            }
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
            context.firstAttribute = .Height
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
        public func right(v:CGFloat)    -> Config { return set(.Right, v) }
        public func bottom(v:CGFloat)   -> Config { return set(.Bottom, v) }
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
        set { _right?.constant = newValue }
        get { return _right?.constant ?? 0 }
    }
    public var bottom: CGFloat {
        set { _bottom?.constant = newValue }
        get { return _bottom?.constant ?? 0 }
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
    
    static func make(v: AnyObject) -> Config {
        return Config(self.init(v), nil)
    }
    
    private class Context {
        
        private var constant: CGFloat?
        private var multiplier: CGFloat?
        private var priority: UILayoutPriority?
        
        private var shouldBeArchived: Bool?
        
        // firstItem.firstAttribute {==,<=,>=} secondItem.secondAttribute * multiplier + constant
        
        private var firstItem: AnyObject?
        private var firstAttribute: NSLayoutAttribute?
        private var relation: NSLayoutRelation?
        private var secondItem: AnyObject?
        private var secondAttribute: NSLayoutAttribute?
        
        private var constraint: NSLayoutConstraint?
    }
    
    private init(_ v: AnyObject) {
        self.value = v
    }
    
    private var value: AnyObject
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
