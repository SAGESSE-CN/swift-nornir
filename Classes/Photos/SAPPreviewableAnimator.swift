//
//  SAPPreviewableAnimator.swift
//  SAC
//
//  Created by SAGESSE on 10/12/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

public class SAPPreviewableAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // is empty
    }
    
    public static func pop(item: AnyObject, from: SAPPreviewableDelegate, to: SAPPreviewableDelegate) -> SAPPreviewableAnimator? {
        return SAPPreviewablePopAnimator(item: item, from: from, to: to)
    }
    public static func push(item: AnyObject, from: SAPPreviewableDelegate, to: SAPPreviewableDelegate) -> SAPPreviewableAnimator? {
        return SAPPreviewablePushAnimator(item: item, from: from, to: to)
    }
    
    fileprivate var _item: AnyObject
    
    fileprivate var _tContext: SAPPreviewable
    fileprivate var _fContext: SAPPreviewable
    
    fileprivate weak var _tDelegate: SAPPreviewableDelegate?
    fileprivate weak var _fDelegate: SAPPreviewableDelegate?
    
    fileprivate init?(item: AnyObject, from: SAPPreviewableDelegate, to: SAPPreviewableDelegate) {
        guard let fp = from.fromPreviewable(with: item), let tp = to.toPreviewable(with: item) else {
            return nil
        }
        _item = item
        _tContext = tp
        _fContext = fp
        super.init()
        _tDelegate = to
        _fDelegate = from
    }
}

internal class SAPPreviewablePushAnimator: SAPPreviewableAnimator {
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //_logger.trace()
        
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        let previewView = SAPPreviewableView()
        let bakcgroundView = UIView()
        
        //添加toView到上下文
        if let toView = toView, let fromView = fromView {
            containerView.insertSubview(toView, belowSubview: fromView)
        }
        // 添加快照到上下文
        containerView.addSubview(bakcgroundView)
        containerView.addSubview(previewView)
        
        let fromRect = containerView.convert(_fContext.previewingFrame, from: containerView.window)
        let toRect = containerView.convert(_tContext.previewingFrame, from: containerView.window)
        
        previewView.previewing = _fContext
        previewView.frame = fromRect
        previewView.layoutIfNeeded()
        
        bakcgroundView.alpha = 0
        bakcgroundView.frame = containerView.bounds
        bakcgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bakcgroundView.backgroundColor = toView?.backgroundColor
        
        toView?.isHidden = true
        
        _fDelegate?.previewable?(_fContext, willShowItem: _item)
        _tDelegate?.previewable?(_tContext, willShowItem: _item)
        
        //UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { [_tContext] in
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 15, options: .curveEaseInOut, animations: { [_tContext] in

            previewView.previewing = _tContext
            previewView.frame = toRect
            previewView.layoutIfNeeded()
            
            bakcgroundView.alpha = 1
            
        }, completion: { [_item, _tContext, _fContext, _tDelegate, _fDelegate] _ in
            
            toView?.isHidden = false
            previewView.removeFromSuperview()
            bakcgroundView.removeFromSuperview()
            
            _tDelegate?.previewable?(_tContext, didShowItem: _item)
            _fDelegate?.previewable?(_fContext, didShowItem: _item)
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
internal class SAPPreviewablePopAnimator: SAPPreviewableAnimator {
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //_logger.trace()
        
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        let previewView = SAPPreviewableView()
        let bakcgroundView = UIView()
        
        //添加toView到上下文
        if let toView = toView, let fromView = fromView {
            containerView.insertSubview(toView, belowSubview: fromView)
        }
        // 添加快照到上下文
        containerView.addSubview(bakcgroundView)
        containerView.addSubview(previewView)
        
        let fromRect = containerView.convert(_fContext.previewingFrame, from: containerView.window)
        let toRect = containerView.convert(_tContext.previewingFrame, from: containerView.window)
        
        previewView.previewing = _fContext
        previewView.frame = fromRect
        previewView.layoutIfNeeded()
        
        bakcgroundView.alpha = 1
        bakcgroundView.frame = containerView.bounds
        bakcgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bakcgroundView.backgroundColor = fromView?.backgroundColor
        
        fromView?.isHidden = true
        
        _fDelegate?.previewable?(_fContext, willShowItem: _item)
        _tDelegate?.previewable?(_tContext, willShowItem: _item)
        
        //UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { [_tContext] in
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: .curveEaseOut, animations: { [_tContext] in

            previewView.previewing = _tContext
            previewView.frame = toRect
            previewView.layoutIfNeeded()
            
            bakcgroundView.alpha = 0
            
        }, completion: { [_item, _tContext, _fContext, _tDelegate, _fDelegate] _ in
            
            toView?.isHidden = false
            previewView.removeFromSuperview()
            bakcgroundView.removeFromSuperview()
            
            _tDelegate?.previewable?(_tContext, didShowItem: _item)
            _fDelegate?.previewable?(_fContext, didShowItem: _item)
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
