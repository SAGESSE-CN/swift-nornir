//
//  IBControllerAnimatedTransition.swift
//  Browser
//
//  Created by sagesse on 11/17/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class IBControllerAnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    init?(for indexPath: IndexPath, from: IBControllerContextTransitioning, to: IBControllerContextTransitioning) {
        guard let fromContext = IBControllerAnimatedTransitionContextObject(transitionContext: from, at: indexPath, for: .from) else {
            return nil
        }
        guard let toContext = IBControllerAnimatedTransitionContextObject(transitionContext: to, at: indexPath, for: .to) else {
            return nil
        }
        
        self.fromContext = fromContext
        self.toContext = toContext
        
        super.init()
    }
    
    let fromContext: IBControllerAnimatedTransitionContextObject 
    let toContext: IBControllerAnimatedTransitionContextObject
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        fatalError("no imp")
    }
}

class IBControllerAnimatedTransitionContextObject {
    
    init?(transitionContext: IBControllerContextTransitioning, at indexPath: IndexPath, for key: UITransitionContextViewKey) {
        guard let view = transitionContext.browseTransitioningView(at: indexPath, forKey: key) else {
            return nil
        }
        
        self.indexPath = indexPath
        self.orientation = transitionContext.browseContentOrientation(at: indexPath)
        
        self.contentSize = transitionContext.browseContentSize(at: indexPath) 
        self.contentMode = transitionContext.browseContentMode(at: indexPath) 
        
        self.view = view
        self.context = transitionContext
    }
    
    var indexPath: IndexPath
    var orientation: UIImageOrientation
    
    var contentSize: CGSize
    var contentSizeWithOrientation: CGSize {
        if isLandscape() {
            return CGSize(width: contentSize.height, height: contentSize.width)
        }
        return contentSize
    }
    
    var contentMode: UIViewContentMode
    
    var view: UIView
    var context: IBControllerContextTransitioning
    
    func align(rect: CGRect) -> CGRect {
        let size = contentSizeWithOrientation
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
    func angle() -> CGFloat {
        switch orientation {
        case .up, .upMirrored:  return 0 * CGFloat(M_PI_2)
        case .right, .rightMirrored: return 1 * CGFloat(M_PI_2)
        case .down, .downMirrored: return 2 * CGFloat(M_PI_2)
        case .left, .leftMirrored: return 3 * CGFloat(M_PI_2)
        }
    }
    func isLandscape() -> Bool {
        switch orientation {
        case .left, .leftMirrored: return true
        case .right, .rightMirrored: return true
        case .up, .upMirrored: return false
        case .down, .downMirrored: return false
        }
    }
}



class IBControllerShowAnimatedTransition: IBControllerAnimatedTransition {
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromContext = self.fromContext
        let toContext = self.toContext
        
        guard let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) else {
            super.animateTransition(using: transitionContext)
            return
        }
        
        let superview = toContext.view.superview
        let transitionView = toContext.view
        let transitionSuperview = UIView()
        let backgroundView = UIView()
        
        // add context view
        containerView.insertSubview(toView, aboveSubview: fromView)
        containerView.addSubview(backgroundView)
        containerView.addSubview(transitionSuperview)
        
        // refresh layout
        fromView.frame = containerView.bounds
        fromView.layoutIfNeeded()
        
        let toColor = toView.backgroundColor
        let fromColor = UIColor.clear
        
        // convert rect to containerView
        let toSuperviewFrame = containerView.convert(toContext.view.bounds, from: toContext.view)
        let fromSuperviewFrame = containerView.convert(fromContext.view.superview?.bounds ?? .zero, from: fromContext.view.superview)
        
        let toViewFrame = containerView.convert(toContext.view.bounds, from: toContext.view)
        let fromViewFrame = containerView.convert(fromContext.align(rect: fromContext.view.bounds), from: fromContext.view)
        
        let toAngle = toContext.angle()
        let fromAngle = fromContext.angle()
        
        backgroundView.frame = toView.frame
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        transitionSuperview.frame = fromSuperviewFrame
        transitionSuperview.clipsToBounds = true
        transitionSuperview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        transitionSuperview.addSubview(transitionView)
        transitionView.transform = transitionView.transform.rotated(by: (fromAngle - toAngle))
        transitionView.frame = containerView.convert(fromViewFrame, to: transitionSuperview)
        
        backgroundView.backgroundColor = fromColor
        
        toView.isHidden = true
        fromContext.view.isHidden = true
        
        //UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 16, options: .curveEaseOut, animations: { 
            
            backgroundView.backgroundColor = toColor
            
            transitionSuperview.frame = toSuperviewFrame
            transitionView.transform = transitionView.transform.rotated(by: -(fromAngle - toAngle))
            transitionView.frame = containerView.convert(toViewFrame, to: transitionSuperview) 
            
        }, completion: { _ in
            
            // restore context
            toView.isHidden = false
            superview?.addSubview(transitionView)
            
            fromContext.view.isHidden = false
            
            transitionView.frame = containerView.convert(toViewFrame, to: superview) 
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            backgroundView.removeFromSuperview()
            transitionSuperview.removeFromSuperview()
        })
    }
}
class IBControllerDismissAnimatedTransition: IBControllerAnimatedTransition {
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromContext = self.fromContext
        let toContext = self.toContext
        
        guard let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) else {
            super.animateTransition(using: transitionContext)
            return
        }
        let superview = fromContext.view.superview
        let transitionView = fromContext.view
        let transitionSuperview = UIView()
        let backgroundView = UIView()
        
        // add context view
        containerView.insertSubview(toView, belowSubview: fromView)
        containerView.addSubview(backgroundView)
        containerView.addSubview(transitionSuperview)
        
        // refresh layout
        toView.frame = containerView.bounds
        toView.layoutIfNeeded()
        
        let toColor = UIColor.clear
        let fromColor = fromView.backgroundColor
        
        // convert rect to containerView
        let toSuperviewFrame = containerView.convert(toContext.view.superview?.bounds ?? .zero, from: toContext.view.superview)
        let fromSuperviewFrame = containerView.convert(fromContext.view.bounds, from: fromContext.view)
        
        let toViewFrame = containerView.convert(toContext.align(rect: toContext.view.bounds), from: toContext.view)
        let fromViewFrame = containerView.convert(fromContext.view.bounds, from: fromContext.view)
        
        let toAngle = toContext.angle()
        let fromAngle = fromContext.angle()
        
        backgroundView.frame = fromView.frame
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        transitionSuperview.frame = fromSuperviewFrame
        transitionSuperview.clipsToBounds = true
        transitionSuperview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        transitionSuperview.addSubview(transitionView)
        transitionView.frame = containerView.convert(fromViewFrame, to: transitionSuperview)
        
        fromView.isHidden = true
        toContext.view.isHidden = true
        backgroundView.backgroundColor = fromColor
        
        //UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { 
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: .curveEaseIn, animations: { 
            
            backgroundView.backgroundColor = toColor
            
            transitionSuperview.frame = toSuperviewFrame
            transitionView.transform = transitionView.transform.rotated(by: (toAngle - fromAngle))
            transitionView.frame = containerView.convert(toViewFrame, to: transitionSuperview) 
            
        }, completion: { _ in
            
            // restore context
            fromView.isHidden = false
            
            superview?.addSubview(transitionView)
            
            toContext.view.isHidden = false
            
            transitionView.transform = transitionView.transform.rotated(by: -(toAngle - fromAngle))
            transitionView.frame = containerView.convert(fromViewFrame, to: superview) 
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            backgroundView.removeFromSuperview()
            transitionSuperview.removeFromSuperview()
        })
    }
}

