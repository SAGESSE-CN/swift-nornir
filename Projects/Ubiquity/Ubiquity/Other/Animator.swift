//
//  Animator.swift
//  Ubiquity
//
//  Created by SAGESSE on 3/21/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal enum TransitioningOperation: Int {
    case pop
    case push
    case present
    case dismiss
}

internal enum TransitioningContextKey: Int {
    case from
    case to
    
    static func source(for operation: TransitioningOperation) -> TransitioningContextKey {
        switch operation {
        case .push, .present: return .from
        case .pop, .dismiss: return .to
        }
    }
    static func destination(for operation: TransitioningOperation) -> TransitioningContextKey {
        switch operation {
        case .push, .present: return .to
        case .pop, .dismiss: return .from
        }
    }
}

internal class Animator: NSObject {
    
    internal init(destination: AnimatableTransitioningDelegate, source: AnimatableTransitioningDelegate, at indexPath: IndexPath) {
        self.indexPath = indexPath
        super.init()
        self.source = source
        self.destination = destination
    }
    
    internal var duration: TimeInterval = 0.35
    internal var indexPath: IndexPath
    
    internal weak var source: AnimatableTransitioningDelegate?
    internal weak var destination: AnimatableTransitioningDelegate?
}

internal class TransitioningScene: NSObject {
    
    internal init(view: UIView, at indexPath: IndexPath) {
        self.view = view
        self.indexPath = indexPath
        super.init()
    }
    
    internal let view: UIView
    internal let indexPath: IndexPath
    
    internal var contentMode: UIViewContentMode = .scaleAspectFill
    internal var contentOrientation: UIImageOrientation = .up
}

internal protocol TransitioningContext: class {
    
    var operation: TransitioningOperation { get }
    
    var indexPath: IndexPath { get }
    var containerView: UIView { get }
    
    // This indicates whether the transition is animatable
    var isAnimated: Bool { get }
    /// This indicates whether the transition is currently interactive.
    var isInteractive: Bool { get }
    
    var transitionWasCancelled: Bool { get }
    
    func scene(for key: TransitioningContextKey) -> TransitioningScene
    func delegate(for key: TransitioningContextKey) -> AnimatableTransitioningDelegate?
    
    func view(for key: UITransitionContextViewKey) -> UIView?
    func viewController(for key: UITransitionContextViewControllerKey) -> UIViewController?
    
    func completeTransition(_ didComplete: Bool)
}

internal protocol AnimatableTransitioningDelegate: class {
    // generate transition object for key and index path
    func transitioningScene(using animator: Animator, operation: TransitioningOperation, at indexPath: IndexPath) -> TransitioningScene?
    
    // generate transitioning animation
    func animateTransition(using animator: Animator, context: TransitioningContext)
    // transitioning animation end
    func animationEnded(using animator: Animator, transitionCompleted: Bool)
}
internal extension AnimatableTransitioningDelegate {
    // generate transitioning animation
    internal func animateTransition(using animator: Animator, context: TransitioningContext) {
        context.completeTransition(true)
    }
    // transitioning animation end
    internal func animationEnded(using animator: Animator, transitionCompleted: Bool) {
        // nothing
    }
}

internal protocol InteractivableTransitioningDelegate: class {
    // the gesture recognizer responsible for top or dismiss view controller.
    var interactiveDismissGestureRecognizer: UIPanGestureRecognizer { get }
}

///
///  Provide transition animation perform
///
internal extension Animator {
    
    internal func animate(for context: TransitioningContext, options: UIViewAnimationOptions, animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        
        var state = true
        var group = DispatchGroup()
        
        // set transition animation complete callback
        (context as? AnimatorTransitioningContext)?.setCompleteHandler { finished in
            // :)
            state = finished && state
            group.leave()
        }
        // perfrom transition animation for source
        if let delegate = context.delegate(for: .from) {
            group.enter()
            delegate.animateTransition(using: self, context: context)
        }
        // perform transition animation for destination
        if let delegate = context.delegate(for: .to) {
            group.enter()
            delegate.animateTransition(using: self, context: context)
        }
        // perfrom transition animation for default
        group.enter()
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations) { finished in
            // :)
            state = finished && state
            group.leave()
        }
        // wait all animation finish
        group.notify(queue: .main) {
            completion?(state)
        }
    }
    
    internal func animationEnded(for context: TransitioningContext, transitionCompleted: Bool) {
        if let delegate = context.delegate(for: .from) {
            delegate.animationEnded(using: self, transitionCompleted: transitionCompleted)
        }
        if let delegate = context.delegate(for: .to) {
            delegate.animationEnded(using: self, transitionCompleted: transitionCompleted)
        }
    }
}

///
/// Provide custom transition delegate forward support
///
extension Animator: UINavigationControllerTransitioningDelegate {
    
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        logger.debug()
        return nil
    }
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        logger.debug()
        return nil
    }
    
    open func animationController(forPush pushed: UIViewController, from: UIViewController, source: UINavigationController) -> UIViewControllerAnimatedTransitioning? {
        // fetch from transitioning context, if nil ignore the event
        guard let fromScene = self.source?.transitioningScene(using: self, operation: .push, at: indexPath) else {
            return nil
        }
        // fetch to transitioning context, if nil ignore the event
        guard let toScene = self.destination?.transitioningScene(using: self, operation: .push, at: indexPath) else {
            return nil
        }
        // generation of transitioning animator
        return AnimatorShowTransition(animator: self, from: fromScene, to: toScene, operation: .push)
    }
    
    open func animationController(forPop poped: UIViewController, from: UIViewController, source: UINavigationController) -> UIViewControllerAnimatedTransitioning? {
        // fetch from transitioning context, if nil ignore the event
        guard let fromScene = self.destination?.transitioningScene(using: self, operation: .pop, at: indexPath) else {
            return nil
        }
        // fetch to transitioning context, if nil ignore the event
        guard let toScene = self.source?.transitioningScene(using: self, operation: .pop, at: indexPath) else {
            return nil
        }
        // generation of transitioning animator
        return AnimatorDismissTransition(animator: self, from: fromScene, to: toScene, operation: .pop)
    }
    
    open func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        logger.debug()
        return nil
    }

    open func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        logger.debug()
        return nil
    }
    
    open func interactionControllerForPop(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        logger.debug()
        return nil
    }
    open func interactionControllerForPush(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        logger.debug()
        return nil
    }
}

///
/// implementation show transition animation
///
internal class AnimatorTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    internal init(animator: Animator, from: TransitioningScene, to: TransitioningScene, operation: TransitioningOperation) {
        self.operation = operation
        self.animator = animator
        self.from = from
        self.to = to
        super.init()
    }
    
    internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animator.duration
    }
    internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.completeTransition(transitionContext.transitionWasCancelled)
    }
    
    internal let to: TransitioningScene
    internal let from: TransitioningScene
    internal let animator: Animator
    internal let operation: TransitioningOperation
}

///
/// implementation show transition animation
///
internal class AnimatorShowTransition: AnimatorTransition {
    
    internal override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // get from view & to view , if is empty, is an unknow error
        guard let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) else {
            return
        }
        let containerView = UIView()
        let animator = self.animator
        let context = AnimatorTransitioningContext(self, contentView: containerView, transition: transitionContext)
        
        // setup transitioning context
        toView.isHidden = true
        
        // refresh layout, fix layout of the screen after the rotation error issue
        if toView.frame != transitionContext.containerView.bounds {
            toView.frame = transitionContext.containerView.bounds
            toView.layoutIfNeeded()
        }
        
        // setup container view
        containerView.frame = transitionContext.containerView.convert(toView.bounds, from: toView)
        containerView.backgroundColor = .clear
        
        // add to transitioning context
        transitionContext.containerView.insertSubview(toView, aboveSubview: fromView)
        transitionContext.containerView.addSubview(containerView)
        
        // perform with animate
        animator.animate(for: context, options: .curveEaseIn, animations: {
            
            containerView.backgroundColor = toView.backgroundColor
            
        }, completion: { finished in
            
            // restore transitioning context
            toView.isHidden = false
            
            containerView.removeFromSuperview()
            
            transitionContext.completeTransition(!context.transitionWasCancelled)
            animator.animationEnded(for: context, transitionCompleted: !transitionContext.transitionWasCancelled)
        })
    }
}

///
/// implementation dismiss transition animation
///
internal class AnimatorDismissTransition: AnimatorTransition {
    
    internal override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // get from view & to view , if is empty, is an unknow error
        guard let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) else {
            return
        }
        let containerView = UIView()
        let animator = self.animator
        let context = AnimatorTransitioningContext(self, contentView: containerView, transition: transitionContext)
        
        // setup transitioning context
        fromView.isHidden = true
        
        // refresh layout, fix layout of the screen after the rotation error issue
        if toView.frame != transitionContext.containerView.bounds {
            toView.frame = transitionContext.containerView.bounds
            toView.layoutIfNeeded()
        }
        
        // setup container view
        containerView.frame = transitionContext.containerView.convert(toView.bounds, from: toView)
        containerView.backgroundColor = fromView.backgroundColor
        
        // add to transitioning context
        transitionContext.containerView.insertSubview(toView, aboveSubview: fromView)
        transitionContext.containerView.addSubview(containerView)
        
        // perform with animate
        animator.animate(for: context, options: .curveEaseIn, animations: {
            
            containerView.backgroundColor = .clear
            
        }, completion: { finished in
            
            // restore transitioning context
            fromView.isHidden = false
            
            containerView.removeFromSuperview()
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            animator.animationEnded(for: context, transitionCompleted: !transitionContext.transitionWasCancelled)
        })
    }
}

fileprivate class AnimatorTransitioningContext: NSObject, TransitioningContext {
    
    init(_ animationController: AnimatorTransition, contentView: UIView, transition: UIViewControllerContextTransitioning) {
        _controller = animationController
        _contentView = contentView
        _transitionContext = transition
        super.init()
    }
    
    var operation: TransitioningOperation {
        return _controller.operation
    }
    
    var indexPath: IndexPath {
        return _controller.animator.indexPath
    }
    
    var containerView: UIView {
        return _contentView
    }
    
    // This indicates whether the transition is animatable
    var isAnimated: Bool {
        return _transitionContext.isAnimated
    }
    /// This indicates whether the transition is currently interactive.
    var isInteractive: Bool {
        return _transitionContext.isInteractive
    }
    
    var transitionWasCancelled: Bool {
        return _transitionContext.transitionWasCancelled
    }
    
    func scene(for key: TransitioningContextKey) -> TransitioningScene {
        switch key {
        case .from: return _controller.from
        case .to: return _controller.to
        }
    }
    func delegate(for key: TransitioningContextKey) -> AnimatableTransitioningDelegate? {
        switch (operation, key) {
        case (.push, .from), (.present, .from), (.pop, .to), (.dismiss, .to):
            return _controller.animator.source
            
        case (.push, .to), (.present, .to), (.pop, .from), (.dismiss, .from):
            return _controller.animator.destination
            
        }
    }
    
    func view(for key: UITransitionContextViewKey) -> UIView? {
        return _transitionContext.view(forKey: key)
    }
    func viewController(for key: UITransitionContextViewControllerKey) -> UIViewController? {
        return _transitionContext.viewController(forKey: key)
    }
    
    func completeTransition(_ didComplete: Bool) {
        _completeHandler?(didComplete)
    }
    
    func setCompleteHandler(_ handler: @escaping ((Bool) -> Void)) {
        _completeHandler = handler
    }
    
    private var _controller: AnimatorTransition
    private var _contentView: UIView
    private var _transitionContext: UIViewControllerContextTransitioning
    
    private var _completeHandler: ((Bool) -> Void)?
}

