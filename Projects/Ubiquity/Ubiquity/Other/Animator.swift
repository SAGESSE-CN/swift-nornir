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
}

internal class Animator: NSObject {
    
    internal init(destination: AnimatableTransitioningDelegate, source: AnimatableTransitioningDelegate, at indexPath: IndexPath) {
        self.indexPath = indexPath
        super.init()
        self.source = source
        self.destination = destination
    }
    
    internal var duration: TimeInterval = 0.5
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
        // no thing
    }
    // transitioning animation end
    internal func animationEnded(using animator: Animator, transitionCompleted: Bool) {
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
        
        if let delegate = context.delegate(for: .from) {
            delegate.animateTransition(using: self, context: context)
        }
        if let delegate = context.delegate(for: .to) {
            delegate.animateTransition(using: self, context: context)
        }
        
        // perfrom system animation
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations) { finished in
            // :)
            completion?(finished)
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
        let contentView = UIView()
        let animator = self.animator
        let context = AnimatorTransitioningContext(self, contentView: contentView, transition: transitionContext)
        
        // setup transitioning context
        toView.isHidden = true
        
        // setup content view
        contentView.layer.borderColor = UIColor.random.cgColor
        contentView.layer.borderWidth = 1
        contentView.frame = transitionContext.containerView.convert(self.from.view.bounds, from: self.from.view)
        
        // setup container view
        containerView.frame = transitionContext.containerView.convert(toView.bounds, from: toView)
        containerView.backgroundColor = .clear
        containerView.addSubview(contentView)
        
        // add to transitioning context
        transitionContext.containerView.insertSubview(toView, aboveSubview: fromView)
        transitionContext.containerView.addSubview(containerView)
        
        // perform with animate
        animator.animate(for: context, options: .curveEaseIn, animations: {
            
            containerView.backgroundColor = toView.backgroundColor
            contentView.frame = transitionContext.containerView.convert(self.to.view.bounds, from: self.to.view)
            
        }, completion: { finished in
            
            // restore transitioning context
            toView.isHidden = false
            
            contentView.removeFromSuperview()
            containerView.removeFromSuperview()
            
            transitionContext.completeTransition(!context.transitionWasCancelled)
            animator.animationEnded(for: context, transitionCompleted: !transitionContext.transitionWasCancelled)
        })
        
//        let containerView = transitionContext.containerView
        
        // add context view
        
        //let superview = toContext.view
        //let transitionView = toContext.view
        //let transitionSuperview = UIView()
        
//        containerView.addSubview(transitionSuperview)
//        // refresh layout
//        fromView.frame = containerView.bounds
//        fromView.layoutIfNeeded()
//        
//        let toColor = toView.backgroundColor
//        let fromColor = UIColor.clear
//        
//        // convert rect to containerView
//        let toSuperviewFrame = containerView.convert(toContext.view.bounds, from: toContext.view)
//        let fromSuperviewFrame = containerView.convert(fromContext.view.superview?.bounds ?? .zero, from: fromContext.view.superview)
//        
//        let toViewFrame = containerView.convert(toContext.view.bounds, from: toContext.view)
//        let fromViewFrame = containerView.convert(fromContext.align(rect: fromContext.view.bounds), from: fromContext.view)
//        
//        let toAngle = toContext.angle()
//        let fromAngle = fromContext.angle()
//
//        transitionSuperview.frame = fromSuperviewFrame
//        transitionSuperview.clipsToBounds = true
//        transitionSuperview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        transitionSuperview.addSubview(transitionView)
//        transitionView.transform = transitionView.transform.rotated(by: (fromAngle - toAngle))
//        transitionView.frame = containerView.convert(fromViewFrame, to: transitionSuperview)
//        
//        backgroundView.backgroundColor = fromColor
//        
//        toView.isHidden = true
//        fromContext.view.isHidden = true
//
//        //UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
        
        
//        animator.transition(for: transitionContext, from: fromContext, to: toContext, duration: transitionDuration(using: transitionContext), options: .curveEaseOut) { _ in
//            // restore context
//            toView.isHidden = false
////            superview?.addSubview(transitionView)
////            
////            fromContext.view.isHidden = false
////            
////            transitionView.frame = containerView.convert(toViewFrame, to: superview) 
////            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
////            
////            backgroundView.removeFromSuperview()
////            transitionSuperview.removeFromSuperview()
//            
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        }
        
//        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 16, options: .curveEaseOut, animations: {
//            
//            backgroundView.backgroundColor = toColor
//            
//            transitionSuperview.frame = toSuperviewFrame
//            transitionView.transform = transitionView.transform.rotated(by: -(fromAngle - toAngle))
//            transitionView.frame = containerView.convert(toViewFrame, to: transitionSuperview) 
//            
//        }, completion: { _ in
//            
//            // restore context
//            toView.isHidden = false
//            superview?.addSubview(transitionView)
//            
//            fromContext.view.isHidden = false
//            
//            transitionView.frame = containerView.convert(toViewFrame, to: superview) 
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//            
//            backgroundView.removeFromSuperview()
//            transitionSuperview.removeFromSuperview()
//        })
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
        let contentView = UIView()
        let animator = self.animator
        let context = AnimatorTransitioningContext(self, contentView: contentView, transition: transitionContext)
        
        // setup transitioning context
        fromView.isHidden = true
        
        // setup content view
        contentView.layer.borderColor = UIColor.random.cgColor
        contentView.layer.borderWidth = 1
        contentView.frame = transitionContext.containerView.convert(self.from.view.bounds, from: self.from.view)
        
        // setup container view
        containerView.frame = transitionContext.containerView.convert(toView.bounds, from: toView)
        containerView.backgroundColor = fromView.backgroundColor
        containerView.addSubview(contentView)
        
        // add to transitioning context
        transitionContext.containerView.insertSubview(toView, aboveSubview: fromView)
        transitionContext.containerView.addSubview(containerView)
        
        // perform with animate
        animator.animate(for: context, options: .curveEaseIn, animations: {
            
            containerView.backgroundColor = .clear
            contentView.frame = transitionContext.containerView.convert(self.to.view.bounds, from: self.to.view)
            
        }, completion: { finished in
            
            // restore transitioning context
            fromView.isHidden = false
            
            contentView.removeFromSuperview()
            containerView.removeFromSuperview()
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            animator.animationEnded(for: context, transitionCompleted: !transitionContext.transitionWasCancelled)
        })
        
//        let containerView = transitionContext.containerView
//
//        let superview = fromContext.view.superview
//        let transitionView = fromContext.view
//        let transitionSuperview = UIView()
//        let backgroundView = UIView()
//        
//        // add context view
//        containerView.insertSubview(toView, belowSubview: fromView)
//        containerView.addSubview(backgroundView)
//        containerView.addSubview(transitionSuperview)
//        
//        // refresh layout
//        toView.frame = containerView.bounds
//        toView.layoutIfNeeded()
//        
//        let toColor = UIColor.clear
//        let fromColor = fromView.backgroundColor
//        
//        // convert rect to containerView
//        let toSuperviewFrame = containerView.convert(toContext.view.superview?.bounds ?? .zero, from: toContext.view.superview)
//        let fromSuperviewFrame = containerView.convert(fromContext.view.bounds, from: fromContext.view)
//        
//        let toViewFrame = containerView.convert(toContext.align(rect: toContext.view.bounds), from: toContext.view)
//        let fromViewFrame = containerView.convert(fromContext.view.bounds, from: fromContext.view)
//        
//        let toAngle = toContext.angle()
//        let fromAngle = fromContext.angle()
//        
//        backgroundView.frame = fromView.frame
//        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        
//        transitionSuperview.frame = fromSuperviewFrame
//        transitionSuperview.clipsToBounds = true
//        transitionSuperview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        transitionSuperview.addSubview(transitionView)
//        transitionView.frame = containerView.convert(fromViewFrame, to: transitionSuperview)
//        
//        fromView.isHidden = true
//        toContext.view.isHidden = true
//        backgroundView.backgroundColor = fromColor
//        
//        //UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { 
//        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: .curveEaseIn, animations: { 
//            
//            backgroundView.backgroundColor = toColor
//            
//            transitionSuperview.frame = toSuperviewFrame
//            transitionView.transform = transitionView.transform.rotated(by: (toAngle - fromAngle))
//            transitionView.frame = containerView.convert(toViewFrame, to: transitionSuperview) 
//            
//        }, completion: { _ in
//            
//            // restore context
//            fromView.isHidden = false
//            
//            superview?.addSubview(transitionView)
//            
//            toContext.view.isHidden = false
//            
//            transitionView.transform = transitionView.transform.rotated(by: -(toAngle - fromAngle))
//            transitionView.frame = containerView.convert(fromViewFrame, to: superview) 
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//            
//            backgroundView.removeFromSuperview()
//            transitionSuperview.removeFromSuperview()
//        })
        
    }
}

fileprivate class AnimatorTransitioningContext: NSObject, TransitioningContext {
    
    fileprivate init(_ animationController: AnimatorTransition, contentView: UIView, transition: UIViewControllerContextTransitioning) {
        _controller = animationController
        _contentView = contentView
        _transitionContext = transition
        super.init()
    }
    
    var operation: TransitioningOperation {
        return _controller.operation
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
    
    private var _controller: AnimatorTransition
    private var _contentView: UIView
    private var _transitionContext: UIViewControllerContextTransitioning
}

