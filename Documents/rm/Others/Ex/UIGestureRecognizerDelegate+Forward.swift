//
//  UIGestureRecognizerDelegate+Forward.swift
//  SIMChat
//
//  Created by sagesse on 1/29/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

/// 代理转发
public class UIGestureRecognizerDelegateForwarder: NSObject, UIGestureRecognizerDelegate {
    public init(_ orign: UIGestureRecognizerDelegate?,  to dst: [UIGestureRecognizerDelegate]) {
        self.delegates = dst.map { WeakElement(element: $0) }
        self.orign = orign
        if let x = orign {
            self.delegates.append(WeakElement(element: x))
        }
    }
    
    @available(iOS 3.2, *)
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        for d in delegates {
            if !(d.element?.gestureRecognizerShouldBegin?(gestureRecognizer) ?? true) {
                return false
            }
        }
        return true
    }
    
    @available(iOS 3.2, *)
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        for d in delegates {
            if d.element?.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) ?? true {
                return true
            }
        }
        return false
    }

    @available(iOS 7.0, *)
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        for d in delegates {
            if d.element?.gestureRecognizer?(gestureRecognizer, shouldRequireFailureOf: otherGestureRecognizer) ?? true {
                return true
            }
        }
        return false
    }
    
    @available(iOS 7.0, *)
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        for d in delegates {
            if d.element?.gestureRecognizer?(gestureRecognizer, shouldBeRequiredToFailBy: otherGestureRecognizer) ?? true {
                return true
            }
        }
        return false
    }
    
    @available(iOS 3.2, *)
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        for d in delegates {
            if !(d.element?.gestureRecognizer?(gestureRecognizer, shouldReceive: touch) ?? true) {
                return false
            }
        }
        return true
    }

    @available(iOS 9.0, *)
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        for d in delegates {
            if !(d.element?.gestureRecognizer?(gestureRecognizer, shouldReceive: press) ?? true) {
                return false
            }
        }
        return true
    }
    
    public override func responds(to aSelector: Selector) -> Bool {
        if aSelector == #selector(UIGestureRecognizerDelegate.gestureRecognizer(_:shouldRequireFailureOf:)) {
            return delegates.contains {
                $0.element?.responds(to: aSelector) ?? false
            }
        }
        if aSelector == #selector(UIGestureRecognizerDelegate.gestureRecognizer(_:shouldBeRequiredToFailBy:)) {
            return delegates.contains {
                $0.element?.responds(to: aSelector) ?? false
            }
        }
        return super.responds(to: aSelector)
    }
    
    var delegates: [WeakElement] = []
    weak var orign: UIGestureRecognizerDelegate?
    
    class WeakElement {
        init(element: UIGestureRecognizerDelegate) {
            self.element = element
        }
        weak var element: UIGestureRecognizerDelegate?
    }
}
