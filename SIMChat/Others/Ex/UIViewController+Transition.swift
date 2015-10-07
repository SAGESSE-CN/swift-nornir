//
//  UIViewController+Transition.swift
//  SIMChat
//
//  Created by sagesse on 9/20/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit


// MARK: - Snapshoot
extension UIView {
    ///
    /// make a snapshoot
    ///
    func snapshoot() -> UIImage! {
        
        // prepare
        UIGraphicsBeginImageContext(bounds.size)
        // draw
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        // get result
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // close
        UIGraphicsEndImageContext()
        
        return image
    }
}

// MARK: - Custom Present
extension UIViewController {
    ///
    /// 弹出的时候显示的视图
    ///
    var presentingView: UIView? {
        return nil
    }
    ///
    /// 显示(ios7未测试)
    ///
    func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, fromView: UIView?, completion: (() -> Void)?) {
        SIMLog.trace()
        
        // TODO: 还有一个未处理的情况
        // 准备呗
        let src = self
        let dest = viewControllerToPresent
        let window = TransitionContext.window
        let context = TransitionContext()
        let mask = UIView()
        let tp = UIImageView()
        
        // 预加载
        dest.view.frame = src.view.bounds
        dest.modalTransitionContext = context
        
        // 一些配置
        context.toView = dest.presentingView
        context.fromView = fromView
        
        //window.frame = UIScreen.mainScreen().bounds
        
        mask.frame = window.bounds
        mask.backgroundColor = dest.view.backgroundColor
        mask.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        tp.image = context.fromViewSnapshoot
        tp.backgroundColor = UIColor.clearColor()
        
        window.rootViewController = nil
        window.addSubview(mask)
        window.addSubview(tp)
        window.makeKeyAndVisible()
        
        // 计算位置
        let from = context.fromView!.convertRect(context.fromView!.bounds, toView: context.fromView?.window)
        let to = context.toView!.convertRect(context.toView!.bounds, toView: dest.view)
        
        //SIMLog.debug("will present view controller, from: \(from) to: \(to)")
        
        // 先不要显示遮罩层, 通过动画慢慢的显示
        tp.frame = from
        mask.alpha = 0
        
        //
        UIView.animateWithDuration(context.duration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            
            tp.frame = to
            mask.alpha = 1
            
        }, completion: { s in
            // 不能在这里弹出, 会导致动画栈失衡
            dispatch_async(dispatch_get_main_queue()) {
                // continue
                self.presentViewController(dest, animated: false, completion: {
                    // finsh, clean
                    //Log.debug("did present view controller")
                    
                    tp.removeFromSuperview()
                    mask.removeFromSuperview()
                    window.hidden = true
                    
                    // end
                    completion?()
                })
            }
        })
    }
    ///
    /// 消失(ios7未测试)
    ///
    func dismissViewControllerAnimated(flag: Bool, fromView: UIView?, completion: (() -> Void)?) {
        SIMLog.trace()
        
        // TODO: 还有一个未处理的情况
        // 准备啊
        let src = self
        let window = TransitionContext.window
        let context = src.modalTransitionContext
        let mask = UIView()
        let tp = UIImageView()
        // config
        //window.frame = UIScreen.mainScreen().bounds
        mask.frame = window.bounds
        mask.backgroundColor = src.view.backgroundColor
        mask.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        tp.image = context.toViewSnapshoot
        tp.backgroundColor = UIColor.clearColor()
        
        window.addSubview(mask)
        window.addSubview(tp)
        window.makeKeyAndVisible()
        // 计算位置
        let to = context.toView!.convertRect(context.toView!.bounds, toView: context.toView?.window)
        // 直接显示遮罩层
        tp.frame = to
        mask.alpha = 1
        // 直接关闭他
        self.dismissViewControllerAnimated(false, completion: {
            // 理由同上
            dispatch_async(dispatch_get_main_queue()) {
                // next
                let from = context.fromView!.convertRect(context.fromView!.bounds, toView: context.fromView?.window)
                //SIMLog.debug("will dismiss view controller, from: \(to), to: \(from)")
                // 动画淡出
                UIView.animateWithDuration(context.duration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                    
                    tp.frame = from
                    mask.alpha = 0
                    
                }, completion: { s in
                    // finsh, clean
                    //Log.debug("did dismiss view controller")
                    tp.removeFromSuperview()
                    mask.removeFromSuperview()
                    window.hidden = true
                    // end
                    completion?()
                })
            }
        })
    }
    ///
    /// 转场的环境.
    ///
    var modalTransitionContext: TransitionContext! {
        set {
            self.willChangeValueForKey("modalTransitionContext")
            objc_setAssociatedObject(self, modalTransitionContextKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.didChangeValueForKey("modalTransitionContext")
        }
        get {
            return objc_getAssociatedObject(self, modalTransitionContextKey) as? TransitionContext
        }
    }
}

///
/// 环境
///
class TransitionContext : NSObject {
    
    var duration: NSTimeInterval = 0.25
    
    weak var fromView: UIView?
    weak var toView: UIView?
    
    var fromViewSnapshoot: UIImage! {
        // 如果他本来就是imageview了, 那就不需要生成了
        if let v = fromView as? UIImageView {
            if let img = v.image ?? toViewSnapshoot {
                return img
            }
        }
        // 打个快照.
        return fromView?.snapshoot()
    }
    var toViewSnapshoot: UIImage! {
        // 如果他本来就是imageview了, 那就不需要生成了
        if let v = toView as? UIImageView {
            if let img = v.image {
                return img
            }
        }
        return toView?.snapshoot()
    }
    
    // TOOD: 因为是直接使用addSubview到window, 所以转屏有问题. 有时间再处理他吧
    static var window: UIWindow = {
        let w = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        w.windowLevel = UIWindowLevelStatusBar + 10
        
        return w
    }()
}

///
let modalTransitionContextKey = unsafeAddressOf("modalTransitionContextKey")