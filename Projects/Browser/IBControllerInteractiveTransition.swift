//
//  BrowseInteractiveTransition.swift
//  Browser
//
//  Created by sagesse on 11/17/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class IBControllerDismissInteractiveTransition: NSObject, UIViewControllerInteractiveTransitioning, CALayerDelegate {
    init?(transition: IBControllerAnimatedTransition) {
        self.fromContext = transition.fromContext
        self.toContext = transition.toContext
        super.init()
        
        let recognizer = self.fromContext.context.browseInteractiveDismissGestureRecognizer
        recognizer?.addTarget(self, action: #selector(gestureRecognizerHandler(_:)))
        
        // init
        startPoint = recognizer?.location(in: nil) ?? .zero
    }
    deinit {
        let recognizer = self.fromContext.context.browseInteractiveDismissGestureRecognizer
        recognizer?.removeTarget(self, action: #selector(gestureRecognizerHandler(_:)))
    }
    
    let fromContext: IBControllerAnimatedTransitionContextObject 
    let toContext: IBControllerAnimatedTransitionContextObject
    
    var completionSpeed: CGFloat { 
        return 1
    }
    var completionCurve: UIViewAnimationCurve { 
        return .easeOut
    }
    
    var startPoint: CGPoint = .zero
    
    var contentFromFrame: CGRect = .zero
    var contentToFrame: CGRect = .zero
    
    var fromContentAngle: CGFloat = 0
    var fromContentViewFrame: CGRect = .zero
    var fromContentSuperviewFrame: CGRect = .zero
    var fromBackgroundColor: UIColor?
    
    // 用于取消时的恢复操作
    var fromContentViewCenter: CGPoint = .zero
    var fromContentViewBounds: CGRect = .zero
    
    var toContentAngle: CGFloat = 0
    var toContentViewFrame: CGRect = .zero
    var toContentSuperviewFrame: CGRect = .zero
    var toBackgroundColor: UIColor?
    
    weak var contentSuperview: UIView?
    weak var contentView: UIView?
    
    var transition: UIViewControllerContextTransitioning?
    
    let transitionBackgroundView: UIView = UIView()
    let transitionSuperview: UIView = UIView()
    var transitionView: UIView? {
        return contentView
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func gestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: nil)
        let percent = (location.y - startPoint.y) / (UIScreen.main.bounds.height * 3 / 5)
        
        guard sender.state != .changed else {
            update(min(max(percent, 0), 1), at: location)
            return
        }
        guard sender.state == .ended && sender.velocity(in: nil).y >= 0 else {
            cancel()
            return
        }
        finish()
    }
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromContext = self.fromContext
        let toContext = self.toContext
        
        // save
        let contentView = fromContext.view
        let contentSuperview = fromContext.view.superview
        
        guard let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) else {
            fatalError()
        }
        // refresh layout
        toView.frame = containerView.bounds
        toView.layoutIfNeeded()
        
        // add context view
        containerView.insertSubview(toView, belowSubview: fromView)
        containerView.addSubview(transitionBackgroundView)
        containerView.addSubview(transitionSuperview)
        
        // gather context information
        
        fromBackgroundColor = fromView.backgroundColor
        fromContentSuperviewFrame = containerView.convert(fromContext.view.bounds, from: fromContext.view)
        fromContentViewCenter = fromContext.view.center
        fromContentViewBounds = fromContext.view.bounds
        fromContentViewFrame = containerView.convert(fromContext.view.bounds, from: fromContext.view)
        fromContentAngle = fromContext.angle()
        
        toBackgroundColor = UIColor.clear
        toContentSuperviewFrame = containerView.convert(toContext.view.superview?.bounds ?? .zero, from: toContext.view.superview)
        toContentViewFrame = containerView.convert(toContext.align(rect: toContext.view.bounds), from: toContext.view)
        toContentAngle = toContext.angle()
        
        self.contentSuperview = contentSuperview
        self.contentView = contentView
        self.transition = transitionContext
        
        // add temp view
        
        transitionBackgroundView.frame = fromView.frame
        transitionBackgroundView.backgroundColor = fromView.backgroundColor
        transitionBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        transitionSuperview.clipsToBounds = true
        transitionSuperview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        transitionSuperview.addSubview(contentView)
        
        // fixed frame
        transitionSuperview.frame = fromContentSuperviewFrame
        transitionView?.frame = containerView.convert(fromContentViewFrame, to: transitionSuperview)
        
        //let toolbar = transition?.viewController(forKey: .from)?.navigationController?.toolbar
        
        toContext.view.isHidden = true
        transition?.view(forKey: .from)?.isHidden = true
    }
    
    func update(_ percent: CGFloat, at point: CGPoint) {
        
        let af = CGAffineTransform(translationX: point.x - startPoint.x, y: point.y - startPoint.y)
        
        transitionSuperview.transform = af.scaledBy(x: 1 - (percent * 0.3), y: 1 - (percent * 0.3))
        transitionBackgroundView.alpha = 1 - percent
        
        transition?.updateInteractiveTransition(percent)
        
    }
    
    func cancel() {
        guard let _ = transition?.containerView, let contentView = self.contentView else {
            fatalError()
        }
        
        // 这里没有动画, 并不知道怎么解决
        transition?.updateInteractiveTransition(0)
        
        //UIView.animate(withDuration: transitionDuration(using: transition), animations: { 
        UIView.animate(withDuration: transitionDuration(using: transition), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: .curveEaseIn, animations: { 
            
            self.transitionSuperview.transform = .identity
            self.transitionBackgroundView.alpha = 1
            
        }, completion: { _ in
        
            // reset context
            self.toContext.view.isHidden = false
            
            self.contentSuperview?.addSubview(contentView)
            self.contentSuperview?.layoutIfNeeded()
            self.transitionView?.bounds = self.fromContentViewBounds
            self.transitionView?.center = self.fromContentViewCenter
            
            self.transition?.view(forKey: .to)?.removeFromSuperview()
            
            self.transition?.view(forKey: .from)?.isHidden = false
            self.transition?.view(forKey: .from)?.layoutIfNeeded()
            
            // clear context
            self.transitionBackgroundView.removeFromSuperview()
            self.transitionSuperview.removeFromSuperview()
            
            self.transition?.cancelInteractiveTransition()
            self.transition?.completeTransition(false)
        })
    }
    func finish() {
        guard let containerView = transition?.containerView, let contentView = self.contentView else {
            fatalError()
        }
        
        transition?.finishInteractiveTransition()
        
        //UIView.animate(withDuration: transitionDuration(using: transition), animations: { 
        UIView.animate(withDuration: transitionDuration(using: transition), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: .curveEaseIn, animations: { 
            
            self.transitionBackgroundView.alpha = 0
            self.transitionSuperview.frame = self.toContentSuperviewFrame
            self.transitionView?.transform = contentView.transform.rotated(by: (self.toContentAngle - self.fromContentAngle)) 
            self.transitionView?.frame = containerView.convert(self.toContentViewFrame, to: self.transitionSuperview) 
            
        }, completion: { _ in
            
            // reset context
            self.toContext.view.isHidden = false
            self.transition?.view(forKey: .from)?.isHidden = false
            
            self.contentSuperview?.addSubview(contentView)
            self.transitionView?.transform = contentView.transform.rotated(by: -(self.toContentAngle - self.fromContentAngle)) 
            self.transitionView?.frame = containerView.convert(self.fromContentViewFrame, to: self.contentSuperview) 
            
            // clear context
            self.transitionBackgroundView.removeFromSuperview()
            self.transitionSuperview.removeFromSuperview()
            
            self.transition?.containerView.layoutIfNeeded()
            self.transition?.completeTransition(true)
        })
    }
}
