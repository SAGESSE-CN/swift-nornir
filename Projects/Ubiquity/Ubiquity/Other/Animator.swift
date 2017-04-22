//
//  Animator.swift
//  Ubiquity
//
//  Created by SAGESSE on 3/21/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal protocol TransitioningView: class {
    
    var ub_frame: CGRect { get }
    var ub_bounds: CGRect { get }
    var ub_transform: CGAffineTransform { get }
    
    func ub_snapshotView(afterScreenUpdates: Bool) -> UIView?
}
internal protocol TransitioningContext: class {
    
    var ub_isAnimated: Bool { get }
    // This indicates whether the transition is currently interactive.
    var ub_isInteractive: Bool { get }
    
    var ub_operation: Animator.Operation { get }
    
    var ub_containerView: UIView { get }
    var ub_transitioningView: UIView? { get }
    
    func ub_view(for key: Animator.Content) -> UIView?
    func ub_viewController(for key: Animator.Content) -> UIViewController?
    
    func ub_transitioningView(for key: Animator.Content) -> TransitioningView?
    
    func ub_update(percent: CGFloat, at offset: CGPoint)
    func ub_complete(_ didComplete: Bool)
    
}
internal protocol TransitioningDataSource: class {
    
    func ub_transitionView(using animator: Animator, for operation: Animator.Operation) -> TransitioningView?
    
    func ub_transitionShouldStart(using animator: Animator, for operation: Animator.Operation) -> Bool
    func ub_transitionShouldStartInteractive(using animator: Animator, for operation: Animator.Operation) -> Bool
    
    func ub_transitionDidPrepare(using animator: Animator, context: TransitioningContext)
    func ub_transitionDidStart(using animator: Animator, context: TransitioningContext)
    
    func ub_transitionWillEnd(using animator: Animator, context: TransitioningContext, transitionCompleted: Bool)
    func ub_transitionDidEnd(using animator: Animator, transitionCompleted: Bool)
}
internal extension TransitioningDataSource {
    
    func ub_transitionShouldStartInteractive(using animator: Animator, for key: Animator.Operation) -> Bool {
        return false
    }
    
    func ub_transitionDidPrepare(using animator: Animator, context: TransitioningContext) {
        // the default implementation is empty
    }
    func ub_transitionDidStart(using animator: Animator, context: TransitioningContext) {
        // the default implementation is empty
    }
    func ub_transitionWillEnd(using animator: Animator, context: TransitioningContext, transitionCompleted: Bool) {
        // the default implementation is empty
    }
    func ub_transitionDidEnd(using animator: Animator, transitionCompleted: Bool) {
        // the default implementation is empty
    }
}


internal class Animator: NSObject {
    enum Content: Int {
        case from
        case to
        case source
        case destination
    }
    enum Operation: Int {
        case pop
        case push
        case present
        case dismiss
        
        var appear: Bool {
            return self == .push
                || self == .present
        }
        var disappear: Bool {
            return self == .pop
                || self == .dismiss
        }
    }

    init(source: TransitioningDataSource, destination: TransitioningDataSource) {
        self.source = source
        self.destination = destination
        super.init()
    }
    
    weak var source: TransitioningDataSource?
    weak var destination: TransitioningDataSource?
    
    var duration: TimeInterval = 0.35
    var indexPath: IndexPath?
    
    func ub_animate(with options: UIViewAnimationOptions, animations: @escaping () -> Swift.Void, completion: ((Bool) -> Void)? = nil) {
        //UIView.animate(withDuration: duration * 5, delay: 0, options: options, animations: animations, completion: completion)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: options, animations: animations, completion: completion)
    }
}

extension Animator: UINavigationControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        logger.info?.write()
        return nil
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        logger.info?.write()
        return nil
    }
    
    func animationController(forPush pushed: UIViewController, from: UIViewController, source: UINavigationController) -> UIViewControllerAnimatedTransitioning? {
        logger.trace?.write()
        
        guard self.source?.ub_transitionShouldStart(using: self, for: .push) ?? false else {
            return nil
        }
        guard self.destination?.ub_transitionShouldStart(using: self, for: .push) ?? false else {
            return nil
        }
        return Animator.AnimatedTransitioning(animator: self, operation: .push)
    }
    func animationController(forPop poped: UIViewController, from: UIViewController, source: UINavigationController) -> UIViewControllerAnimatedTransitioning? {
        logger.trace?.write()
        
        guard self.source?.ub_transitionShouldStart(using: self, for: .pop) ?? false else {
            return nil
        }
        guard self.destination?.ub_transitionShouldStart(using: self, for: .pop) ?? false else {
            return nil
        }
        return Animator.AnimatedTransitioning(animator: self, operation: .pop)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        logger.info?.write()
        return nil
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        logger.trace?.write()
//        guard self.source.ub_transitionShouldStartInteractive(using: self, for: .pop) else {
//            return nil
//        }
//        return Animator.InteractivedTransitioning(animator: self, transitioning: animator, operation: .push)
        return nil
    }
    
    func interactionControllerForPop(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        logger.trace?.write()
        
        guard self.destination?.ub_transitionShouldStartInteractive(using: self, for: .pop) ?? false else {
            return nil
        }
        return Animator.InteractivedTransitioning(animator: self, transitioning: animator, operation: .pop)
    }
    func interactionControllerForPush(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        logger.info?.write()
        return nil
    }
}
extension Animator {
    /// 快照
    internal class SnapshotView: UIView {
        
        init(animator: Animator) {
            self.animator = animator
            self.containerView = UIView()
            //self.destination = destination
            super.init(frame: .zero)
            _setup()
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        override class var layerClass: AnyClass {
            return SnapshotLayer.self
        }
        
        private func _setup() {
            // config
            containerView.clipsToBounds = true
            containerView.backgroundColor = .clear
            // add to view
            addSubview(containerView)
        }
        
        func prepare(with view: TransitioningView?) {
            // 生成快照
            guard let snapshotView = view?.ub_snapshotView(afterScreenUpdates: true) else {
                return
            }
            contentView = snapshotView
            containerView.addSubview(snapshotView)
        }
        
        func apply(with view: TransitioningView?) {
            guard let view = view else {
                return
            }
            // setup transitioning
            transitioningView = view
            // setup transitioning view
            let frame = convert(view.ub_frame, from: superview)
            containerView.transform = view.ub_transform
            containerView.bounds = .init(origin: .zero, size: frame.size)
            containerView.center = .init(x: frame.midX, y: frame.midY)
            // setup transitioning content view
            contentView?.frame = view.ub_bounds
        }
        func apply(with view: TransitioningView?, percent: CGFloat, at offset: CGPoint) {
            guard let view = transitioningView else {
                return
            }
            let transform = view.ub_transform
            let frame = convert(view.ub_frame, from: superview)
            // setup transitioning view
            containerView.transform = transform.concatenating(.init(scaleX: 1 - damping(percent), y: 1 - damping(percent)))
            containerView.center = .init(x: frame.midX + offset.x, y: frame.midY + offset.y)
        }
        
        func link(_ closer: @escaping (CGFloat) -> Void) {
            guard let layer = (layer as? SnapshotLayer) else {
                return
            }
            handler = closer
            CATransaction.setDisableActions(true)
            layer.percent = 0
            CATransaction.setDisableActions(false)
            layer.percent = 1
        }
        func damping(_ v1: CGFloat) -> CGFloat {
            return v1 * 0.5
        }
        
        override func display(_ layer: CALayer) {
            guard let layer = (layer.presentation() as? SnapshotLayer) else {
                return
            }
            handler?(layer.percent)
        }
        
        var handler: ((CGFloat) -> Void)?
        var transitioningView: TransitioningView?
        
        var contentView: UIView?
        var containerView: UIView
        
        var animator: Animator
    }
    internal class SnapshotLayer: CALayer {
        
        override init() {
            super.init()
        }
        override init(layer: Any) {
            super.init(layer: layer)
            if let layer = layer as? SnapshotLayer {
                percent = layer.percent
            }
        }
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override class func needsDisplay(forKey key: String) -> Bool {
            switch key {
            case #keyPath(percent):
                return true
                
            default:
                return super.needsDisplay(forKey: key)
            }
        }
        override func action(forKey event: String) -> CAAction? {
            switch event {
            case #keyPath(percent):
                guard let animation = super.action(forKey: #keyPath(backgroundColor)) as? CABasicAnimation else {
                    return nil
                }
                animation.keyPath = event
                animation.fromValue = presentation()?.percent
                animation.toValue = nil
                return animation
                
            default:
                return super.action(forKey: event)
            }
        }
        
        @NSManaged var percent: CGFloat
    }
}

extension Animator {
    /// 动画转场
    internal class AnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
        init(animator: Animator, operation: Animator.Operation) {
            self.animator = animator
            self.operation = operation
            super.init()
        }
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return animator.duration
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            // create transition context
            let context = AnimatedTransitioningContext(animator: animator, context: transitionContext, operation: operation)
            let application = UIApplication.shared
            // apply transition context for from
            context.prepare(for: .from)
            application.beginIgnoringInteractionEvents()
            // preform animation
            animator.ub_animate(with: .curveEaseInOut, animations: {
                // apply transition context for to
                context.apply(for: .to)
                
            }, completion: { finished in
                // complate transition, clear context
                context.complete(!transitionContext.transitionWasCancelled)
                application.endIgnoringInteractionEvents()
            })
        }
        
        // This is a convenience and if implemented will be invoked by the system when the transition context's completeTransition: method is invoked.
        func animationEnded(_ transitionCompleted: Bool) {
        }
        
        var animator: Animator
        var operation: Animator.Operation
    }
    internal class AnimatedTransitioningContext: NSObject, TransitioningContext {
        init(animator: Animator, context: UIViewControllerContextTransitioning, operation: Animator.Operation) {
            self.context = context
            self.animator = animator
            self.operation = operation
            self.snapshotView = SnapshotView(animator: animator)
            super.init()
        }
        
        
        var ub_isAnimated: Bool {
            return context.isAnimated
        }
        var ub_isInteractive: Bool {
            return context.isInteractive
        }
        
        var ub_operation: Animator.Operation {
            return operation
        }
        
        var ub_containerView: UIView {
            return context.containerView
        }
        var ub_transitioningView: UIView? {
            return snapshotView.containerView
        }
        
        func ub_view(for key: Animator.Content) -> UIView? {
            switch (ub_operation, key) {
            case (.push, .source), (.present, .source): return context.view(forKey: .from)
            case (.push, .destination), (.present, .destination): return context.view(forKey: .to)
                
            case (.pop, .source), (.dismiss, .source): return context.view(forKey: .to)
            case (.pop, .destination), (.dismiss, .destination): return context.view(forKey: .from)
                
            case (_, .from): return context.view(forKey: .from)
            case (_, .to): return context.view(forKey: .to)
            }
        }
        func ub_viewController(for key: Animator.Content) -> UIViewController? {
            switch (ub_operation, key) {
            case (.push, .source), (.present, .source): return context.viewController(forKey: .from)
            case (.push, .destination), (.present, .destination): return context.viewController(forKey: .to)
                
            case (.pop, .source), (.dismiss, .source): return context.viewController(forKey: .to)
            case (.pop, .destination), (.dismiss, .destination): return context.viewController(forKey: .from)
                
            case (_, .from): return context.viewController(forKey: .from)
            case (_, .to): return context.viewController(forKey: .to)
            }
        }
        
        func ub_transitioningView(for key: Animator.Content) -> TransitioningView? {
            switch (operation, key) {
            case (.push, .from), (.present, .from): return sourceView
            case (.push, .to), (.present, .to): return destinationView
                
            case (.pop, .from), (.dismiss, .from): return destinationView
            case (.pop, .to), (.dismiss, .to): return sourceView
                
            case (_, .source): return sourceView
            case (_, .destination): return destinationView
            }
        }
        
        func ub_backgroundColor(for key: Animator.Content) -> UIColor? {
            switch (key, operation.appear) {
            case (.destination, true), (.to, true):
                return ub_view(for: key)?.backgroundColor
                
            case (.source, false), (.from, false):
                return ub_view(for: key)?.backgroundColor
                
            default:
                return .clear
            }
        }
        
        func ub_update(percent: CGFloat, at offset: CGPoint) {
        }
        func ub_complete(_ didComplete: Bool) {
        }
        
        func prepare(for key: Animator.Content) {
            logger.trace?.write()
        
            // fetch from view & to view, if is empty, is an unknow error
            guard let fromView = context.view(forKey: .from), let toView = context.view(forKey: .to) else {
                logger.error?.write("'from view' or 'to view' no found!")
                return
            }
            // same time display fromView and toView
            context.containerView.insertSubview(toView, aboveSubview: fromView)
            // refresh layout, fix layout of the screen after the rotation error issue
            if toView.frame != context.containerView.bounds {
                toView.frame = context.containerView.bounds
                toView.layoutIfNeeded()
            }
            // notice delegate prepare
            animator.source?.ub_transitionDidPrepare(using: animator, context: self)
            animator.destination?.ub_transitionDidPrepare(using: animator, context: self)
            // setup transition context for snapshot view
            snapshotView.frame = context.containerView.bounds
            snapshotView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            context.containerView.addSubview(snapshotView)
            // setup transition context for init
            snapshotView.prepare(with: ub_transitioningView(for: .destination))
            apply(for: key)
            // setup transition context for other
            ub_view(for: .destination)?.isHidden = true
            // notice delegate start
            animator.source?.ub_transitionDidStart(using: animator, context: self)
            animator.destination?.ub_transitionDidStart(using: animator, context: self)
        }
        func complete(_ completed: Bool) {
            logger.trace?.write(completed)
            
            // notice delegate
            animator.source?.ub_transitionWillEnd(using: animator, context: self, transitionCompleted: completed)
            animator.destination?.ub_transitionWillEnd(using: animator, context: self, transitionCompleted: completed)
            // setup transition context for other
            ub_view(for: .destination)?.isHidden = false
            // clear context
            snapshotView.removeFromSuperview()
            // notice delegate
            animator.source?.ub_transitionDidEnd(using: animator, transitionCompleted: completed)
            animator.destination?.ub_transitionDidEnd(using: animator, transitionCompleted: completed)
            // commit
            context.completeTransition(completed)
        }
        
        func apply(for key: Animator.Content) {
            logger.trace?.write(key)
        
            snapshotView.apply(with: ub_transitioningView(for: key))
            snapshotView.backgroundColor = ub_backgroundColor(for: key)
        }
        
        let context: UIViewControllerContextTransitioning
        let animator: Animator
        let operation: Animator.Operation
        let snapshotView: SnapshotView
        
        var sourceView: TransitioningView? {
            if let view = _sourceView {
                return view
            }
            let view = animator.source?.ub_transitionView(using: animator, for: operation)
            _sourceView = view
            return view
        }
        var destinationView: TransitioningView? {
            if let view = _destinationView {
                return view
            }
            let view = animator.destination?.ub_transitionView(using: animator, for: operation)
            _destinationView = view
            return view
        }
        
        private var _sourceView: TransitioningView??
        private var _destinationView: TransitioningView??
    }
}
extension Animator {
    /// 交互转场
    internal class InteractivedTransitioning: NSObject, UIViewControllerInteractiveTransitioning {
        init(animator: Animator, transitioning: UIViewControllerAnimatedTransitioning, operation: Animator.Operation) {
            self.animator = animator
            self.operation = operation
            self.transitioning = transitioning
            super.init()
        }
        
        var completionSpeed: CGFloat {
            return 1
        }
        var completionCurve: UIViewAnimationCurve {
            return .easeInOut
        }
        
        func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
            // create transition context
            context = InteractivedTransitioningContext(animator: animator, context: transitionContext, operation: operation)
            // apply transition context for from
            context?.prepare(for: .from)
        }
        
        var context: InteractivedTransitioningContext?
        var animator: Animator
        var operation: Animator.Operation
        var transitioning: UIViewControllerAnimatedTransitioning
    }
    internal class InteractivedTransitioningContext: AnimatedTransitioningContext {
        
        override func ub_update(percent: CGFloat, at offset: CGPoint) {
            logger.trace?.write(offset, percent)
            
            context.updateInteractiveTransition(percent)
            
            snapshotView.apply(with: ub_transitioningView(for: .to), percent: percent, at: offset)
            snapshotView.backgroundColor = ub_backgroundColor(for: .from)?.withAlphaComponent(1 - min(percent * 1.2, 1))
            
            _percentComplete = percent
        }
        override func ub_complete(_ didComplete: Bool) {
            logger.trace?.write(didComplete)
            
            if didComplete {
                finish()
            } else {
                cancel()
            }
        }
        
        func cancel() {
            logger.trace?.write()
            
            UIView.animate(withDuration: 0.2) {
                let percent = self._percentComplete
                // link to the core animation context
                self.snapshotView.link { p in
                    self.context.updateInteractiveTransition(percent * (1 - p))
                }
            }
            
            animator.ub_animate(with: .curveEaseInOut, animations: {
                self.apply(for: .from)
                self.snapshotView.backgroundColor = self.ub_backgroundColor(for: .from)
            }, completion: { _ in
                self.snapshotView.handler = nil // must clear
                self.context.cancelInteractiveTransition()
                self.complete(false)
            })
        }
        func finish() {
            logger.trace?.write()
            
            UIView.animate(withDuration: 0.2) {
                self.context.finishInteractiveTransition()
            }
            
            animator.ub_animate(with: .curveEaseInOut, animations: {
                self.apply(for: .to)
                self.snapshotView.backgroundColor = self.ub_backgroundColor(for: .to)
            }, completion: { _ in
                self.complete(true)
            })
        }
        
        private var _percentComplete: CGFloat = 0
    }
}
