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
    case source
    case destination
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
    
    internal var view: UIView?
    
    internal var frame: CGRect = .zero
    internal var transform: CGAffineTransform = .identity
    
    internal var bounds: CGRect = .zero
    internal var center: CGPoint = .zero
    
    internal var orientation: UIImageOrientation = .up
    
    internal var contentSize: CGSize = .zero
    internal var contentMode: UIViewContentMode = .scaleAspectFill
    
    internal func align(rect: CGRect) -> CGRect {
        var size = contentSize
        if isLandscape {
            swap(&size.width, &size.height)
        }
        // if contentMode is scale is used in all rect
        if contentMode == .scaleToFill {
            return rect
        }
        var x = rect.minX
        var y = rect.minY
        var width = size.width
        var height = size.height
        // if contentMode is aspect scale to fit, calculate the zoom ratio
        if contentMode == .scaleAspectFit {
            let scale = min(rect.width / max(size.width, 1), rect.height / max(size.height, 1))
            
            width = size.width * scale
            height = size.height * scale
        }
        // if contentMode is aspect scale to fill, calculate the zoom ratio
        if contentMode == .scaleAspectFill {
            let scale = max(rect.width / max(size.width, 1), rect.height / max(size.height, 1))
            
            width = size.width * scale
            height = size.height * scale
        }
        // horizontal alignment
        if [.left, .topLeft, .bottomLeft].contains(contentMode) {
            // align left
            x += (0)
            
        } else if [.right, .topRight, .bottomRight].contains(contentMode) {
            // align right
            x += (rect.width - width)
            
        } else {
            // algin center
            x += (rect.width - width) / 2
        }
        // vertical alignment
        if [.top, .topLeft, .topRight].contains(contentMode) {
            // align top
            y += (0)
            
        } else if [.bottom, .bottomLeft, .bottomRight].contains(contentMode) {
            // align bottom
            y += (rect.height - width)
            
        } else {
            // algin center
            y += (rect.height - height) / 2
        }
        return CGRect(x: x, y: y, width: width, height: height)
    }
    var angle: CGFloat {
        switch orientation {
        case .up, .upMirrored:  return 0 * CGFloat(M_PI_2)
        case .right, .rightMirrored: return 1 * CGFloat(M_PI_2)
        case .down, .downMirrored: return 2 * CGFloat(M_PI_2)
        case .left, .leftMirrored: return 3 * CGFloat(M_PI_2)
        }
    }
    var isLandscape: Bool {
        switch orientation {
        case .left, .leftMirrored: return true
        case .right, .rightMirrored: return true
        case .up, .upMirrored: return false
        case .down, .downMirrored: return false
        }
    }
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
    
    func view(for key: TransitioningContextKey) -> UIView?
    func viewController(for key: TransitioningContextKey) -> UIViewController?
    
    func completeTransition(_ didComplete: Bool)
}

internal protocol AnimatableTransitioningDelegate: class {
    // generate transition object for key and index path
    func transitioningScene(using animator: Animator, operation: TransitioningOperation, at indexPath: IndexPath) -> TransitioningScene?
    
    // prepare transition animation
    func animationPreparing(using animator: Animator, context: TransitioningContext)
    // generate transitioning animation
    func animateTransition(using animator: Animator, context: TransitioningContext)
    // transitioning animation end
    func animationEnded(using animator: Animator, transitionCompleted: Bool)
}
internal extension AnimatableTransitioningDelegate {
    // prepare transition animation
    internal func animationPreparing(using animator: Animator, context: TransitioningContext) {
    }
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
        
        let to = context.delegate(for: .to)
        let from = context.delegate(for: .from)
        
        // prepare transition animation
        from?.animationPreparing(using: self, context: context)
        to?.animationPreparing(using: self, context: context)
        // set transition animation complete callback
        (context as? AnimatorTransitioningContext)?.setCompleteHandler { finished in
            // :)
            state = finished && state
            group.leave()
        }
        // perfrom transition animation for source
        if let delegate = from {
            group.enter()
            delegate.animateTransition(using: self, context: context)
        }
        // perform transition animation for destination
        if let delegate = to {
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
        
        // refresh layout, fix layout of the screen after the rotation error issue
        if toView.frame != transitionContext.containerView.bounds {
            toView.frame = transitionContext.containerView.bounds
            toView.layoutIfNeeded()
        }
        
        // setup container view
        containerView.frame = transitionContext.containerView.convert(toView.bounds, from: toView)
        containerView.backgroundColor = .clear
        
        // add to transitioning context
        transitionContext.containerView.insertSubview(toView, aboveSubview: containerView)
        transitionContext.containerView.insertSubview(containerView, belowSubview: toView)
        
        // perform with animate
        animator.animate(for: context, options: .curveEaseIn, animations: {
            
            containerView.backgroundColor = toView.backgroundColor
            
        }, completion: { finished in
            
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
        switch (operation, key) {
        case (.push, .source), (.present, .source): return _controller.from
        case (.push, .destination), (.present, .destination): return _controller.to
            
        case (.pop, .source), (.dismiss, .source): return _controller.to
        case (.pop, .destination), (.dismiss, .destination): return _controller.from
            
        case (_, .from): return _controller.from
        case (_, .to): return _controller.to
        }
    }
    func delegate(for key: TransitioningContextKey) -> AnimatableTransitioningDelegate? {
        switch (operation, key) {
        case (.push, .from), (.present, .from): return _controller.animator.source
        case (.push, .to), (.present, .to): return _controller.animator.destination
            
        case (.pop, .from), (.dismiss, .from): return _controller.animator.destination
        case (.pop, .to), (.dismiss, .to): return _controller.animator.source
            
        case (_, .source): return _controller.animator.source
        case (_, .destination): return _controller.animator.destination
        }
    }
    
    func view(for key: TransitioningContextKey) -> UIView? {
        switch (operation, key) {
        case (.push, .source), (.present, .source): return _transitionContext.view(forKey: .from)
        case (.push, .destination), (.present, .destination): return _transitionContext.view(forKey: .to)
            
        case (.pop, .source), (.dismiss, .source): return _transitionContext.view(forKey: .to)
        case (.pop, .destination), (.dismiss, .destination): return _transitionContext.view(forKey: .from)
            
        case (_, .from): return _transitionContext.view(forKey: .from)
        case (_, .to): return _transitionContext.view(forKey: .to)
        }
    }
    func viewController(for key: TransitioningContextKey) -> UIViewController? {
        switch (operation, key) {
        case (.push, .source), (.present, .source): return _transitionContext.viewController(forKey: .from)
        case (.push, .destination), (.present, .destination): return _transitionContext.viewController(forKey: .to)
            
        case (.pop, .source), (.dismiss, .source): return _transitionContext.viewController(forKey: .to)
        case (.pop, .destination), (.dismiss, .destination): return _transitionContext.viewController(forKey: .from)
            
        case (_, .from): return _transitionContext.viewController(forKey: .from)
        case (_, .to): return _transitionContext.viewController(forKey: .to)
        }
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

