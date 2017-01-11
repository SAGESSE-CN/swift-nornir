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
        init(duration: TimeInterval, closer: @escaping (UIViewControllerContextTransitioning) -> Void) {
            self.duration = duration
            self.closer = closer
        }
        
        @objc func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return duration
        }
        
        @objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            closer(transitionContext)
        }
        
        // 持续时间
        let closer: (UIViewControllerContextTransitioning) -> Void
        let duration: TimeInterval
    }
    
    public init(from: SIMChatBrowseAnimatedTransitioningTarget, to: SIMChatBrowseAnimatedTransitioningTarget) {
        self.from = from
        self.to = to
    }
    
    /// 转换
    private func __convertRect(_ view: UIImageView?) -> CGRect {
        guard let view = view, let image = view.image else {
            return CGRect.zero
        }
        return __convertRect(image.size, rect: view.bounds, view.contentMode)
    }
    /// 转换
    private func __convertRect(_ size: CGSize, rect: CGRect, _ mode: UIViewContentMode) -> CGRect {
        if mode == .scaleToFill {
            // no change
            return rect
        }
        if mode == .scaleAspectFit {
            let scale = min(rect.width / max(size.width, 0.01), rect.height / max(size.height, 0.01))
            // scale to fit
            return CGRect(
                x: rect.minX + (rect.width - size.width * scale) / 2,
                y: rect.minY + (rect.height - size.height * scale) / 2,
                width: size.width * scale,
                height: size.height * scale)
        }
        if mode == .scaleAspectFill {
            let scale = max(rect.width / max(size.width, 0.01), rect.height / max(size.height, 0.01))
            // scale to fill
            return CGRect(
                x: rect.minX + (rect.width - size.width * scale) / 2,
                y: rect.minY + (rect.height - size.height * scale) / 2,
                width: size.width * scale,
                height: size.height * scale)
        }
        var frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if mode == .left || mode == .topLeft || mode == .bottomLeft {
            // Align left
            frame.origin.x = rect.minX + 0
        } else if mode == .right || mode == .topRight || mode == .bottomRight {
            // Align right
            frame.origin.x = rect.minX + (rect.width - size.width)
        } else {
            // Center
            frame.origin.x = rect.minX + (rect.width - size.width) / 2
        }
        if mode == .top || mode == .topLeft || mode == .topRight {
            // Align top
            frame.origin.y = rect.minY + 0
        } else if mode == .bottom || mode == .bottomLeft || mode == .bottomRight {
            // Align bottom
            frame.origin.y = rect.minY + (rect.height - size.height)
        } else {
            // Center
            frame.origin.y = rect.minY + (rect.height - size.height) / 2
        }
        return frame
    }
    
    
    /// 弹出
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Imp(duration: duration) { context in
            // 获取上下文视图
            guard let fromVC = context.viewController(forKey: UITransitionContextViewControllerKey.from),
                let toVC = context.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                    context.completeTransition(false)
                    return
            }
            let containerView = context.containerView
            
            containerView.backgroundColor = .clear
            
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
            imageView.frame = containerView.convert(fframe, from: fromView)
            backgroundView.backgroundColor = toVC.view.backgroundColor
            backgroundView.alpha = 0
            
            containerView.addSubview(fromVC.view)
            containerView.addSubview(toVC.view)
            
            if tframe.size != CGSize.zero {
                toVC.view.isHidden = true
                fromView?.isHidden = true
                containerView.addSubview(backgroundView)
                containerView.addSubview(imageView)
            } else {
                toVC.view.isHidden = false
                toVC.view.alpha = 0
            }
            
            fromVC.beginAppearanceTransition(false, animated: false)
            
            // 开始
            UIView.animate(withDuration: self.duration,
                animations: {
                    toVC.view.alpha = 1
                    backgroundView.alpha = 1
                    imageView.frame = containerView.convert(tframe, from: toView)
                },
                completion: { f in
                    toVC.view.isHidden = false
                    fromView?.isHidden = false
                    
                    backgroundView.removeFromSuperview()
                    imageView.removeFromSuperview()
                    
                    fromVC.view.removeFromSuperview()
                    fromVC.endAppearanceTransition()
                    
                    context.completeTransition(true)
                })
        }
    }
   
    /// 消失
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Imp(duration: duration) { context in
            // 获取上下文视图
            guard let fromVC = context.viewController(forKey: UITransitionContextViewControllerKey.from),
                let toVC = context.viewController(forKey: UITransitionContextViewControllerKey.to),
                let fromView = self.to.targetView,
                let toView = self.from.targetView else {
                    context.completeTransition(false)
                    return
            }
            let containerView = context.containerView
            
            // 计算实际大小
            let fframe = self.__convertRect(fromView)
            let tframe = self.__convertRect(toView)
            
            // 生成辅助
            let imageView = UIImageView()
            let backgroundView = UIView(frame: containerView.bounds)
            
            // 配置
            fromVC.view.alpha = 1
            imageView.image = fromView.image ?? toView.image
            imageView.frame = containerView.convert(fframe, from: fromView)
            backgroundView.backgroundColor = fromVC.view.backgroundColor
            backgroundView.alpha = 1
            
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            
            if fframe.size != CGSize.zero {
                toView.isHidden = true
                fromVC.view.isHidden = true
                containerView.addSubview(backgroundView)
                containerView.addSubview(imageView)
            }
            
            toVC.beginAppearanceTransition(true, animated: false)
            
            // 开始
            UIView.animate(withDuration: self.duration,
                animations: {
                    fromVC.view.alpha = 0
                    backgroundView.alpha = 0
                    imageView.frame = containerView.convert(tframe, from: toView)
                },
                completion: { f in
                    toView.isHidden = false
                    backgroundView.removeFromSuperview()
                    imageView.removeFromSuperview()
                    
                    containerView.superview?.insertSubview(toVC.view, belowSubview: containerView)
                    toVC.endAppearanceTransition()
                    
                    context.completeTransition(f)
                })
        }
    }
    
    // 时间
    let duration: TimeInterval = 0.35
    
    let to: SIMChatBrowseAnimatedTransitioningTarget
    let from: SIMChatBrowseAnimatedTransitioningTarget
}
