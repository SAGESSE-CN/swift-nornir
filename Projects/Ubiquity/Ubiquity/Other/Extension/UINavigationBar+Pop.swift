//
//  UINavigationBar+Pop.swift
//  Ubiquity
//
//  Created by sagesse on 11/17/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


public extension UINavigationBar {
    
    private static var _pop_delegate: String = {
        let m1 = class_getInstanceMethod(UINavigationBar.self, #selector(popItem(animated:)))
        let m2 = class_getInstanceMethod(UINavigationBar.self, #selector(pop_popItem(animated:)))
        method_exchangeImplementations(m1, m2)
        return "_pop_delegate"
    }()
    public weak var pop_delegate: UINavigationBarDelegate? {
        set { return objc_setAssociatedObject(self, &UINavigationBar._pop_delegate, newValue, .OBJC_ASSOCIATION_ASSIGN) }
        get { return objc_getAssociatedObject(self, &UINavigationBar._pop_delegate) as? UINavigationBarDelegate }
    }
    
    private dynamic func pop_popItem(animated: Bool) -> UINavigationItem? {
        guard let item = topItem else {
            return pop_popItem(animated: animated)
        }
        guard pop_delegate?.navigationBar?(self, shouldPop: item) ?? true else {
            let view = subviews.first(where: { $0.alpha <= 0.5 })
            
            view?.alpha = 1
            if animated, let ani = subviews.flatMap({ $0.layer.animation(forKey: "opacity") }).first {
                view?.layer.add(ani, forKey: "opacity")
            }
            
            return nil
        }
        let result = pop_popItem(animated: animated)
        pop_delegate?.navigationBar?(self, didPop: item)
        return result
    }
}
