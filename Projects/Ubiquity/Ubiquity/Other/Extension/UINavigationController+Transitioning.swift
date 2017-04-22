//
//  UINavigationController+Transitioning.swift
//  Ubiquity
//
//  Created by SAGESSE on 3/19/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

/// navigation controller transitioning delegate
@objc internal protocol  UINavigationControllerTransitioningDelegate: UIViewControllerTransitioningDelegate {
    
    @objc optional func animationController(forPush pushed: UIViewController, from: UIViewController, source: UINavigationController) -> UIViewControllerAnimatedTransitioning?

    @objc optional func animationController(forPop poped: UIViewController, from: UIViewController, source: UINavigationController) -> UIViewControllerAnimatedTransitioning?

    
    @objc optional func interactionControllerForPush(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?

    @objc optional func interactionControllerForPop(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    
}

/// view controller custom transitioning support
internal extension UIViewController {
    // contains the navigation controller transitioning animation
    weak var ub_transitioningDelegate: UINavigationControllerTransitioningDelegate? {
        set { return transitioningDelegate = __ub_file_init(newValue) }
        get { return transitioningDelegate as? UINavigationControllerTransitioningDelegate }
    }
}

/// navigation controller custom transitioning support
fileprivate extension UINavigationController {
    
    fileprivate dynamic func __ub_pushViewController(_ viewController: UIViewController, animated: Bool) {
        // if view controller need custom transitioning animation
        guard let transitioningDelegate = viewController.ub_transitioningDelegate, animated else {
            // no need, ignore
            return __ub_pushViewController(viewController, animated: animated)
        }
        // perform custom transitioning animation
        return __ub_perform(transitioning: transitioningDelegate, operation: .push) {
            return __ub_pushViewController(viewController, animated: animated)
        }
    }
    fileprivate dynamic func __ub_popViewController(animated: Bool) -> UIViewController? {
        // if view controller need custom transitioning animation
        guard let transitioningDelegate = topViewController?.ub_transitioningDelegate else {
            // no need, ignore
            return __ub_popViewController(animated: animated)
        }
        // perform custom transitioning animation
        return __ub_perform(transitioning: transitioningDelegate, operation: .pop) {
            return __ub_popViewController(animated: animated)
        }
    }
    
    fileprivate func __ub_perform<T>(transitioning: UINavigationControllerTransitioningDelegate, operation: UINavigationControllerOperation, closure: ((Void) -> T)) -> T {
        // generated a transitioning helper
        let helper = UINavigationControllerTransitioningHelper(transitioning: transitioning)
        // setup helper
        helper.delegate = delegate
        helper.operation = operation
        // switch environment
        delegate = helper
        defer { delegate = helper.delegate }
        // perform user code
        return closure()
    }
}


fileprivate class UINavigationControllerTransitioningHelper: NSObject, UINavigationControllerDelegate {
    
    init(transitioning: UINavigationControllerTransitioningDelegate ) {
        self.transitioning = transitioning
        super.init()
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // if operation is push, check transitioning wether implement delegate method
        if operation == .push && transitioning.responds(to: #selector(transitioning.animationController(forPush:from:source:))) {
            return transitioning.interactionControllerForPush?(using: animationController)
        }
        // if operation is pop, check transitioning wether implement delegate method
        if operation == .pop && transitioning.responds(to: #selector(transitioning.animationController(forPop:from:source:))) {
            return transitioning.interactionControllerForPop?(using: animationController)
        }
        // other case, perform origin method
        return delegate?.navigationController?(navigationController, interactionControllerFor: animationController)
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // if operation is push, check transitioning wether implement delegate method
        if operation == .push && transitioning.responds(to: #selector(transitioning.animationController(forPush:from:source:))) {
            return transitioning.animationController?(forPush: toVC, from: fromVC, source: navigationController)
        }
        // if operation is pop, check transitioning wether implement delegate method
        if operation == .pop && transitioning.responds(to: #selector(transitioning.animationController(forPop:from:source:))) {
            return transitioning.animationController?(forPop: fromVC, from: toVC, source: navigationController)
        }
        // other case, perform origin method
        return delegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        return delegate?.responds(to: aSelector) ?? super.responds(to: aSelector)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return delegate
    }
    
    var operation: UINavigationControllerOperation = .none
    weak var delegate: UINavigationControllerDelegate?
    unowned var transitioning: UINavigationControllerTransitioningDelegate
}


private var __ub_file_init: (UIViewControllerTransitioningDelegate?) -> UIViewControllerTransitioningDelegate? = {
    
    let cls = UINavigationController.self
    
    let m11 = class_getInstanceMethod(cls, #selector(cls.pushViewController(_:animated:)))
    let m21 = class_getInstanceMethod(cls, #selector(cls.popViewController(animated:)))
    
    let m12 = class_getInstanceMethod(cls, #selector(cls.__ub_pushViewController(_:animated:)))
    let m22 = class_getInstanceMethod(cls, #selector(cls.__ub_popViewController(animated:)))
    
    method_exchangeImplementations(m11, m12)
    method_exchangeImplementations(m21, m22)
    
    return { $0 }
}()
