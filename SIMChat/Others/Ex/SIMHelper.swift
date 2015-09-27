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
class SIMView : UIView {
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

///
enum SIMChatTextFieldItemStyle : Int {
    case None       = 0x0000
    case Keyboard   = 0x0100
    case Voice      = 0x0101
    case Emoji      = 0x0102
    case Tool       = 0x0103
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

