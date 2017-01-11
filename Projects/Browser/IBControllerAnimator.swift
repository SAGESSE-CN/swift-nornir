//
//  IBControllerAnimator.swift
//  Browser
//
//  Created by sagesse on 11/14/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

public protocol IBControllerContextTransitioning: class {
    
    var browseIndexPath: IndexPath? { get }
    var browseInteractiveDismissGestureRecognizer: UIGestureRecognizer? { get }
    
    func browseContentSize(at indexPath: IndexPath) -> CGSize
    func browseContentMode(at indexPath: IndexPath) -> UIViewContentMode
    func browseContentOrientation(at indexPath: IndexPath) -> UIImageOrientation
    
    func browseTransitioningView(at indexPath: IndexPath, forKey key: UITransitionContextViewKey) -> UIView?
}

public class IBControllerAnimator: NSObject, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    public init(from: IBControllerContextTransitioning, to: IBControllerContextTransitioning) {
        super.init()
        self.from = from
        self.to = to
    }
    
    public weak var from: IBControllerContextTransitioning?
    public weak var to: IBControllerContextTransitioning?
    
    // MARK: UIViewControllerTransitioningDelegate
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let from = from, let to = to, let indexPath = from.browseIndexPath {
            return IBControllerShowAnimatedTransition(for: indexPath, from: from, to: to)
        }
        return nil
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let from = from, let to = to, let indexPath = to.browseIndexPath {
            return IBControllerDismissAnimatedTransition(for: indexPath, from: to, to: from)
        }
        return nil
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let transition = animator as? IBControllerDismissAnimatedTransition, _isInteracting else {
            return nil
        }
        return IBControllerDismissInteractiveTransition(transition: transition)
    }
    
    // MARK: UINavigationControllerDelegate
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push, let from = from, let to = to, let indexPath = from.browseIndexPath {
            return IBControllerShowAnimatedTransition(for: indexPath, from: from, to: to)
        }
        if operation == .pop, let from = from, let to = to, let indexPath = to.browseIndexPath {
            return IBControllerDismissAnimatedTransition(for: indexPath, from: to, to: from)
        }
        return nil
    }
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let transition = animationController as? IBControllerDismissAnimatedTransition, _isInteracting else {
            return nil
        }
        return IBControllerDismissInteractiveTransition(transition: transition)
    }
    
    // MARK: Ivar
    
    private var _isInteracting: Bool {
        guard let state = to?.browseInteractiveDismissGestureRecognizer?.state else {
            return false
        }
        guard state == .began || state == .changed else {
            return false
        }
        return true
    }
}

public extension IBControllerContextTransitioning {
    
    public var browseInteractiveDismissGestureRecognizer: UIGestureRecognizer? { 
        return nil
    }
}
