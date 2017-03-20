//
//  BrowserAnimator.swift
//  Ubiquity
//
//  Created by SAGESSE on 3/20/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal protocol BrowserAnimatableTransitioning: class {
    // generate transitioning context for key and index path
    func transitioningContext(using animator: BrowserAnimator, for key: UITransitionContextViewControllerKey, at indexPath: IndexPath) -> BrowserContextTransitioning?
}
internal protocol BrowserInteractivableTransitioning: BrowserAnimatableTransitioning {
    // the gesture recognizer responsible for top or dismiss view controller.
    var interactiveDismissGestureRecognizer: UIPanGestureRecognizer { get }
}

internal class BrowserContextTransitioning: NSObject {
    
//    var indexPath: IndexPath
//    var orientation: UIImageOrientation
//    
//    var contentSize: CGSize
//    var contentSizeWithOrientation: CGSize {
//        if isLandscape() {
//            return CGSize(width: contentSize.height, height: contentSize.width)
//        }
//        return contentSize
//    }
//    
//    var contentMode: UIViewContentMode
//    
//    var view: UIView
//    var context: IBControllerContextTransitioning
//
    
//    func align(rect: CGRect) -> CGRect {
//        let size = contentSizeWithOrientation
//        // if contentMode is scale is used in all rect
//        if contentMode == .scaleToFill {
//            return rect
//        }
//        var x = rect.minX
//        var y = rect.minY
//        var width = size.width
//        var height = size.height
//        // if contentMode is aspect scale to fit, calculate the zoom ratio
//        if contentMode == .scaleAspectFit {
//            let scale = min(rect.width / max(size.width, 1), rect.height / max(size.height, 1))
//            
//            width = size.width * scale
//            height = size.height * scale
//        }
//        // if contentMode is aspect scale to fill, calculate the zoom ratio
//        if contentMode == .scaleAspectFill {
//            let scale = max(rect.width / max(size.width, 1), rect.height / max(size.height, 1))
//            
//            width = size.width * scale
//            height = size.height * scale
//        }
//        // horizontal alignment
//        if [.left, .topLeft, .bottomLeft].contains(contentMode) {
//            // align left
//            x += (0)
//            
//        } else if [.right, .topRight, .bottomRight].contains(contentMode) {
//            // align right
//            x += (rect.width - width)
//            
//        } else {
//            // algin center
//            x += (rect.width - width) / 2
//        }
//        // vertical alignment
//        if [.top, .topLeft, .topRight].contains(contentMode) {
//            // align top
//            y += (0)
//            
//        } else if [.bottom, .bottomLeft, .bottomRight].contains(contentMode) {
//            // align bottom
//            y += (rect.height - width)
//            
//        } else {
//            // algin center
//            y += (rect.height - height) / 2
//        }
//        return CGRect(x: x, y: y, width: width, height: height)
//    }
//    func angle() -> CGFloat {
//        switch orientation {
//        case .up, .upMirrored:  return 0 * CGFloat(M_PI_2)
//        case .right, .rightMirrored: return 1 * CGFloat(M_PI_2)
//        case .down, .downMirrored: return 2 * CGFloat(M_PI_2)
//        case .left, .leftMirrored: return 3 * CGFloat(M_PI_2)
//        }
//    }
//    func isLandscape() -> Bool {
//        switch orientation {
//        case .left, .leftMirrored: return true
//        case .right, .rightMirrored: return true
//        case .up, .upMirrored: return false
//        case .down, .downMirrored: return false
//        }
//    }
    
    internal init(container: Container, view: UIView, at indexPath: IndexPath) {
        self.view = view
        self.container = container
        self.indexPath = indexPath
        super.init()
    }
    
    internal let container: Container
    
    internal let view: UIView
    internal let indexPath: IndexPath
    
    internal var contentMode: UIViewContentMode = .scaleAspectFill
    internal var contentOrientation: UIImageOrientation = .up
    
}

internal class BrowserAnimator: NSObject {
    
    internal init(destination: BrowserAnimatableTransitioning, source: BrowserAnimatableTransitioning, at indexPath: IndexPath) {
        self.indexPath = indexPath
        super.init()
        self.sourceTransitioning = source
        self.destinationTransitioning = destination
    }

    internal var indexPath: IndexPath
    
    internal weak var sourceTransitioning: BrowserAnimatableTransitioning?
    internal weak var destinationTransitioning: BrowserAnimatableTransitioning?
}

///
/// Provide custom transition delegate forward support
///
extension BrowserAnimator: UINavigationControllerTransitioningDelegate {
    
    internal func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        logger.debug()
        return nil
    }
    internal func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        logger.debug()
        return nil
    }
    
    internal func animationController(forPush pushed: UIViewController, from: UIViewController, source: UINavigationController) -> UIViewControllerAnimatedTransitioning? {
        // fetch from transitioning context, if nil ignore the event
        guard let fromContext = sourceTransitioning?.transitioningContext(using: self, for: .from, at: indexPath) else {
            return nil
        }
        // fetch to transitioning context, if nil ignore the event
        guard let toContext = destinationTransitioning?.transitioningContext(using: self, for: .to, at: indexPath) else {
            return nil
        }
        // generation of transitioning animator
        //return BrowserShowTransition(animator: self, from: fromContext, to: toContext)
        return nil
    }
    
    internal func animationController(forPop poped: UIViewController, from: UIViewController, source: UINavigationController) -> UIViewControllerAnimatedTransitioning? {
        // fetch from transitioning context, if nil ignore the event
        guard let fromContext = destinationTransitioning?.transitioningContext(using: self, for: .from, at: indexPath) else {
            return nil
        }
        // fetch to transitioning context, if nil ignore the event
        guard let toContext = sourceTransitioning?.transitioningContext(using: self, for: .to, at: indexPath) else {
            return nil
        }
        // generation of transitioning animator
        //return BrowserDismissTransition(animator: self, from: fromContext, to: toContext)
        return nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        logger.debug()
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        logger.debug()
        return nil
    }
    
    func interactionControllerForPop(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        logger.debug()
        return nil
    }
    func interactionControllerForPush(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        logger.debug()
        return nil
    }
}

internal class BrowserShowTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    internal init(animator: BrowserAnimator, from: BrowserContextTransitioning, to: BrowserContextTransitioning) {
        self.animator = animator
        self.fromContext = from
        self.toContext = to
        super.init()
    }
    
    internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        let containerView = transitionContext.containerView
//        let fromContext = self.fromContext
//        let toContext = self.toContext
//        
//        guard let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) else {
//            super.animateTransition(using: transitionContext)
//            return
//        }
//        
//        let superview = toContext.view.superview
//        let transitionView = toContext.view
//        let transitionSuperview = UIView()
//        let backgroundView = UIView()
//        
//        // add context view
//        containerView.insertSubview(toView, aboveSubview: fromView)
//        containerView.addSubview(backgroundView)
//        containerView.addSubview(transitionSuperview)
//        
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
//        backgroundView.frame = toView.frame
//        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
    
    internal let animator: BrowserAnimator
    
    internal let fromContext: BrowserContextTransitioning
    internal let toContext: BrowserContextTransitioning
}

internal class BrowserDismissTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    internal init(animator: BrowserAnimator, from: BrowserContextTransitioning, to: BrowserContextTransitioning) {
        self.animator = animator
        self.fromContext = from
        self.toContext = to
        super.init()
    }
    
    
    internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        let containerView = transitionContext.containerView
//        let fromContext = self.fromContext
//        let toContext = self.toContext
//        
//        guard let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) else {
//            super.animateTransition(using: transitionContext)
//            return
//        }
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
    
    internal let animator: BrowserAnimator
    
    internal let fromContext: BrowserContextTransitioning
    internal let toContext: BrowserContextTransitioning
}

//class IBControllerAnimatedTransitionContextObject {
//    
//    init?(transitionContext: IBControllerContextTransitioning, at indexPath: IndexPath, for key: UITransitionContextViewKey) {
//        guard let view = transitionContext.browseTransitioningView(at: indexPath, forKey: key) else {
//            return nil
//        }
//        
//        self.indexPath = indexPath
//        self.orientation = transitionContext.browseContentOrientation(at: indexPath)
//        
//        self.contentSize = transitionContext.browseContentSize(at: indexPath) 
//        self.contentMode = transitionContext.browseContentMode(at: indexPath) 
//        
//        self.view = view
//        self.context = transitionContext
//    }
//    
//    func align(rect: CGRect) -> CGRect {
//        let size = contentSizeWithOrientation
//        // if contentMode is scale is used in all rect
//        if contentMode == .scaleToFill {
//            return rect
//        }
//        var x = rect.minX
//        var y = rect.minY
//        var width = size.width
//        var height = size.height
//        // if contentMode is aspect scale to fit, calculate the zoom ratio
//        if contentMode == .scaleAspectFit {
//            let scale = min(rect.width / max(size.width, 1), rect.height / max(size.height, 1))
//            
//            width = size.width * scale
//            height = size.height * scale
//        }
//        // if contentMode is aspect scale to fill, calculate the zoom ratio
//        if contentMode == .scaleAspectFill {
//            let scale = max(rect.width / max(size.width, 1), rect.height / max(size.height, 1))
//            
//            width = size.width * scale
//            height = size.height * scale
//        }
//        // horizontal alignment
//        if [.left, .topLeft, .bottomLeft].contains(contentMode) {
//            // align left
//            x += (0)
//            
//        } else if [.right, .topRight, .bottomRight].contains(contentMode) {
//            // align right
//            x += (rect.width - width)
//            
//        } else {
//            // algin center
//            x += (rect.width - width) / 2
//        }
//        // vertical alignment
//        if [.top, .topLeft, .topRight].contains(contentMode) {
//            // align top
//            y += (0)
//            
//        } else if [.bottom, .bottomLeft, .bottomRight].contains(contentMode) {
//            // align bottom
//            y += (rect.height - width)
//            
//        } else {
//            // algin center
//            y += (rect.height - height) / 2
//        }
//        return CGRect(x: x, y: y, width: width, height: height)
//    }
//    func angle() -> CGFloat {
//        switch orientation {
//        case .up, .upMirrored:  return 0 * CGFloat(M_PI_2)
//        case .right, .rightMirrored: return 1 * CGFloat(M_PI_2)
//        case .down, .downMirrored: return 2 * CGFloat(M_PI_2)
//        case .left, .leftMirrored: return 3 * CGFloat(M_PI_2)
//        }
//    }
//    func isLandscape() -> Bool {
//        switch orientation {
//        case .left, .leftMirrored: return true
//        case .right, .rightMirrored: return true
//        case .up, .upMirrored: return false
//        case .down, .downMirrored: return false
//        }
//    }
//}
//
//
//
//class IBControllerShowAnimatedTransition: IBControllerAnimatedTransition {
//    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//    }
//}
//class IBControllerDismissAnimatedTransition: IBControllerAnimatedTransition {
//    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//    }
//}

//
//public protocol IBControllerContextTransitioning: class {
//    
//    var browseIndexPath: IndexPath? { get }
//    var browseInteractiveDismissGestureRecognizer: UIGestureRecognizer? { get }
//    
//    func browseContentSize(at indexPath: IndexPath) -> CGSize
//    func browseContentMode(at indexPath: IndexPath) -> UIViewContentMode
//    func browseContentOrientation(at indexPath: IndexPath) -> UIImageOrientation
//    
//    func browseTransitioningView(at indexPath: IndexPath, forKey key: UITransitionContextViewKey) -> UIView?
//}
//
//public class IBControllerAnimator: NSObject, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
//    
//    public init(from: IBControllerContextTransitioning, to: IBControllerContextTransitioning) {
//        super.init()
//        self.from = from
//        self.to = to
//    }
//    
//    public weak var from: IBControllerContextTransitioning?
//    public weak var to: IBControllerContextTransitioning?
//    
//    // MARK: UIViewControllerTransitioningDelegate
//    
//    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        if let from = from, let to = to, let indexPath = from.browseIndexPath {
//            return IBControllerShowAnimatedTransition(for: indexPath, from: from, to: to)
//        }
//        return nil
//    }
//    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        if let from = from, let to = to, let indexPath = to.browseIndexPath {
//            return IBControllerDismissAnimatedTransition(for: indexPath, from: to, to: from)
//        }
//        return nil
//    }
//    
//    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return nil
//    }
//    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        guard let transition = animator as? IBControllerDismissAnimatedTransition, _isInteracting else {
//            return nil
//        }
//        return IBControllerDismissInteractiveTransition(transition: transition)
//    }
//    
//    // MARK: UINavigationControllerDelegate
//    
//    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        if operation == .push, let from = from, let to = to, let indexPath = from.browseIndexPath {
//            return IBControllerShowAnimatedTransition(for: indexPath, from: from, to: to)
//        }
//        if operation == .pop, let from = from, let to = to, let indexPath = to.browseIndexPath {
//            return IBControllerDismissAnimatedTransition(for: indexPath, from: to, to: from)
//        }
//        return nil
//    }
//    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        guard let transition = animationController as? IBControllerDismissAnimatedTransition, _isInteracting else {
//            return nil
//        }
//        return IBControllerDismissInteractiveTransition(transition: transition)
//    }
//    
//    // MARK: Ivar
//    
//    private var _isInteracting: Bool {
//        guard let state = to?.browseInteractiveDismissGestureRecognizer?.state else {
//            return false
//        }
//        guard state == .began || state == .changed else {
//            return false
//        }
//        return true
//    }
//}
//
//public extension IBControllerContextTransitioning {
//    
//    public var browseInteractiveDismissGestureRecognizer: UIGestureRecognizer? { 
//        return nil
//    }
//}
