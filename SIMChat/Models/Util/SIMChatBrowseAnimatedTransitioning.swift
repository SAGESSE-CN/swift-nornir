//
//  SIMChatBrowseAnimatedTransitioning.swift
//  SIMChat
//
//  Created by sagesse on 2/28/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

///
/// 浏览的目标
///
public protocol SIMChatBrowseAnimatedTransitioningTarget: class {
    /// 目标
    var targetView: UIImageView? { get }
}

///
/// 浏览
///
public class SIMChatBrowseAnimatedTransitioning: NSObject, UIViewControllerTransitioningDelegate {
    /// 实现
    private class Imp: NSObject, UIViewControllerAnimatedTransitioning {
        init(duration: NSTimeInterval, closer: UIViewControllerContextTransitioning -> Void) {
            self.duration = duration
            self.closer = closer
        }
        
        @objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
            return duration
        }
        
        @objc func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
            closer(transitionContext)
        }
        
        // 持续时间
        let closer: UIViewControllerContextTransitioning -> Void
        let duration: NSTimeInterval
    }
    
    public init(from: SIMChatBrowseAnimatedTransitioningTarget, to: SIMChatBrowseAnimatedTransitioningTarget) {
        self.from = from
        self.to = to
    }
    
    /// 转换
    private func __convertRect(view: UIImageView?) -> CGRect {
        guard let view = view, image = view.image else {
            return CGRectZero
        }
        return __convertRect(image.size, rect: view.bounds, view.contentMode)
    }
    /// 转换
    private func __convertRect(size: CGSize, rect: CGRect, _ mode: UIViewContentMode) -> CGRect {
        if mode == .ScaleToFill {
            // no change
            return rect
        }
        if mode == .ScaleAspectFit {
            let scale = min(rect.width / max(size.width, 0.01), rect.height / max(size.height, 0.01))
            // scale to fit
            return CGRectMake(
                rect.minX + (rect.width - size.width * scale) / 2,
                rect.minY + (rect.height - size.height * scale) / 2,
                size.width * scale,
                size.height * scale)
        }
        if mode == .ScaleAspectFill {
            let scale = max(rect.width / max(size.width, 0.01), rect.height / max(size.height, 0.01))
            // scale to fill
            return CGRectMake(
                rect.minX + (rect.width - size.width * scale) / 2,
                rect.minY + (rect.height - size.height * scale) / 2,
                size.width * scale,
                size.height * scale)
        }
        var frame = CGRectMake(0, 0, size.width, size.height)
        if mode == .Left || mode == .TopLeft || mode == .BottomLeft {
            // Align left
            frame.origin.x = rect.minX + 0
        } else if mode == .Right || mode == .TopRight || mode == .BottomRight {
            // Align right
            frame.origin.x = rect.minX + (rect.width - size.width)
        } else {
            // Center
            frame.origin.x = rect.minX + (rect.width - size.width) / 2
        }
        if mode == .Top || mode == .TopLeft || mode == .TopRight {
            // Align top
            frame.origin.y = rect.minY + 0
        } else if mode == .Bottom || mode == .BottomLeft || mode == .BottomRight {
            // Align bottom
            frame.origin.y = rect.minY + (rect.height - size.height)
        } else {
            // Center
            frame.origin.y = rect.minY + (rect.height - size.height) / 2
        }
        return frame
    }
    
    
    /// 弹出
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Imp(duration: duration) { context in
            // 获取上下文视图
            guard let fromVC = context.viewControllerForKey(UITransitionContextFromViewControllerKey),
                toVC = context.viewControllerForKey(UITransitionContextToViewControllerKey),
                containerView = context.containerView() else {
                    context.completeTransition(false)
                    return
            }
            
            toVC.view.frame = fromVC.view.bounds
            
            let fromView = self.from.targetView
            let toView = self.to.targetView
            
            // 计算实际大小
            let fframe = self.__convertRect(fromView)
            let tframe = self.__convertRect(toView)
            
            // 生成辅助
            let imageView = UIImageView()
            let backgroundView = UIView(frame: containerView.bounds)
            
            // 配置
            imageView.image = fromView?.image ?? toView?.image
            imageView.frame = containerView.convertRect(fframe, fromView: fromView)
            backgroundView.backgroundColor = toVC.view.backgroundColor
            backgroundView.alpha = 0
            
            containerView.addSubview(toVC.view)
            
            if tframe.size != CGSizeZero {
                toVC.view.hidden = true
                fromView?.hidden = true
                containerView.addSubview(backgroundView)
                containerView.addSubview(imageView)
            } else {
                toVC.view.hidden = false
                toVC.view.alpha = 0
            }
            
            // 开始
            UIView.animateWithDuration(self.duration,
                animations: {
                    toVC.view.alpha = 1
                    backgroundView.alpha = 1
                    imageView.frame = containerView.convertRect(tframe, fromView: toView)
                },
                completion: { f in
                    toVC.view.hidden = false
                    fromView?.hidden = false
                    
                    backgroundView.removeFromSuperview()
                    imageView.removeFromSuperview()
                    
                    context.completeTransition(f)
                })
        }
    }
   
    /// 消失
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Imp(duration: duration) { context in
            // 获取上下文视图
            guard let fromVC = context.viewControllerForKey(UITransitionContextFromViewControllerKey),
                containerView = context.containerView(),
                fromView = self.to.targetView,
                toView = self.from.targetView else {
                    context.completeTransition(false)
                    return
            }
            
            // 计算实际大小
            let fframe = self.__convertRect(fromView)
            let tframe = self.__convertRect(toView)
            
            // 生成辅助
            let imageView = UIImageView()
            let backgroundView = UIView(frame: containerView.bounds)
            
            // 配置
            fromVC.view.alpha = 1
            imageView.image = fromView.image ?? toView.image
            imageView.frame = containerView.convertRect(fframe, fromView: fromView)
            backgroundView.backgroundColor = fromVC.view.backgroundColor
            backgroundView.alpha = 1
            
            if fframe.size != CGSizeZero {
                toView.hidden = true
                fromVC.view.hidden = true
                containerView.addSubview(backgroundView)
                containerView.addSubview(imageView)
            }
            
            // 开始
            UIView.animateWithDuration(self.duration,
                animations: {
                    fromVC.view.alpha = 0
                    backgroundView.alpha = 0
                    imageView.frame = containerView.convertRect(tframe, fromView: toView)
                },
                completion: { f in
                    toView.hidden = false
                    backgroundView.removeFromSuperview()
                    imageView.removeFromSuperview()
                    
                    context.completeTransition(f)
                })
        }
    }
    
    // 时间
    let duration: NSTimeInterval = 0.35
    
    let to: SIMChatBrowseAnimatedTransitioningTarget
    let from: SIMChatBrowseAnimatedTransitioningTarget
}
