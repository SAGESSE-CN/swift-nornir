//
//  SIMHelper.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

//
///// 提供 | 操作支持
//func |<T : OptionSet>(lhs: T, rhs: T) -> T {
//    return lhs.union(rhs)
//}
//
///// 为时间提供 - 操作支持
//func -(lhs: Date, rhs: Date) -> TimeInterval {
//    return lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970
//}
//
///// 让枚举支持 allZeros
//extension OptionSet where RawValue : BitwiseOperations {
//    static var allZeros: Self {
//        return self.init()
//    }
//}

///// 生成约束
//func NSLayoutConstraintMake(_ item: AnyObject, _ attribute: NSLayoutAttribute, _ relatedBy: NSLayoutRelation, _ toItem: AnyObject?, _ attribute2: NSLayoutAttribute, _ constant: CGFloat = 0, _ priority: CGFloat = 1000, _ multiplier: CGFloat = 1) -> NSLayoutConstraint {
//    let c = NSLayoutConstraint(item: item, attribute: attribute, relatedBy: relatedBy, toItem: toItem, attribute: attribute2, multiplier: multiplier, constant: constant)
//    c.priority = UILayoutPriority(priority)
//    return c
//}
//
///// 生成约束, 用vfl
//func NSLayoutConstraintMake(_ format: String, views: [String : AnyObject], options opts: NSLayoutFormatOptions = .allZeros, metrics: [String : AnyObject]? = nil) -> [NSLayoutConstraint] {
//    return NSLayoutConstraint.constraints(withVisualFormat: format, options: opts, metrics: metrics, views: views)
//}

extension UIColor {
    static var random: UIColor {
        let maxValue: UInt32 = 24
        return UIColor(red: CGFloat(arc4random() % maxValue) / CGFloat(maxValue),
                       green: CGFloat(arc4random() % maxValue) / CGFloat(maxValue) ,
                       blue: CGFloat(arc4random() % maxValue) / CGFloat(maxValue) ,
                       alpha: 1)
    }
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
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.build()
    }
    /// 构建
    func build() {
    }
}

extension Date {
    /// 零
    static var zero: Date {
        return Date(timeIntervalSince1970: 0)
    }
    /// 现在
    static var now: Date {
        return Date()
    }
    /// 友好的显示
    var visual: String {
        let df = DateFormatter()
        // format
        df.dateStyle = .medium
        df.timeStyle = .short
        // ok
        return df.string(from: self)
    }
}

extension Timer {
    class func scheduledTimerWithTimeInterval2(_ ti: TimeInterval, _ aTarget: AnyObject, _ aSelector: Selector, _ userInfo: AnyObject? = nil) -> Timer {
        return self.scheduledTimer(timeInterval: ti, target: aTarget, selector: aSelector, userInfo: userInfo, repeats: true)
    }
}

public func dispatch_after_at_now(_ interval: TimeInterval, _ queue: DispatchQueue, _ block: @escaping ()->()) {
    let t = DispatchTimeInterval.seconds(Int(interval))
    queue.asyncAfter(deadline: DispatchTime.now() + t, execute: block)
}

extension Collection {
    /// 分隔成组
    public func splitInGroup(compare: (Iterator.Element, Iterator.Element) throws -> Bool) rethrows -> [SubSequence] {
        var result = Array<SubSequence>()
        var begin = startIndex
        while begin != endIndex {
            var end = self.index(begin, offsetBy: 1)
            
            while end != endIndex {
                if try !compare(self[self.index(end, offsetBy: -1)], self[end]) {
                    break
                }
                end = self.index(end, offsetBy: 1)
            }
            result.append(self[begin ..< end])
            begin = end
        }
        return result
    }
}
