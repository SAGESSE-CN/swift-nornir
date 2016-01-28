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
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        for d in delegates {
            if !(d.element?.gestureRecognizerShouldBegin?(gestureRecognizer) ?? true) {
                return false
            }
        }
        return true
    }
    
    @available(iOS 3.2, *)
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        for d in delegates {
            if d.element?.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer: otherGestureRecognizer) ?? true {
                return true
            }
        }
        return false
    }

    @available(iOS 7.0, *)
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        for d in delegates {
            if d.element?.gestureRecognizer?(gestureRecognizer, shouldRequireFailureOfGestureRecognizer: otherGestureRecognizer) ?? true {
                return true
            }
        }
        return false
    }
    
    @available(iOS 7.0, *)
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        for d in delegates {
            if d.element?.gestureRecognizer?(gestureRecognizer, shouldBeRequiredToFailByGestureRecognizer: otherGestureRecognizer) ?? true {
                return true
            }
        }
        return false
    }
    
    @available(iOS 3.2, *)
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        for d in delegates {
            if !(d.element?.gestureRecognizer?(gestureRecognizer, shouldReceiveTouch: touch) ?? true) {
                return false
            }
        }
        return true
    }

    @available(iOS 9.0, *)
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceivePress press: UIPress) -> Bool {
        for d in delegates {
            if !(d.element?.gestureRecognizer?(gestureRecognizer, shouldReceivePress: press) ?? true) {
                return false
            }
        }
        return true
    }
    
    public override func respondsToSelector(aSelector: Selector) -> Bool {
        if aSelector == "gestureRecognizer:shouldRequireFailureOfGestureRecognizer:" {
            return delegates.contains {
                $0.element?.respondsToSelector(aSelector) ?? false
            }
        }
        if aSelector == "gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:" {
            return delegates.contains {
                $0.element?.respondsToSelector(aSelector) ?? false
            }
        }
        return super.respondsToSelector(aSelector)
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
