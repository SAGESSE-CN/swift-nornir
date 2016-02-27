//
//  SIMChatMediaImageBrowser.swift
//  SIMChat
//
//  Created by sagesse on 2/23/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation

public protocol SIMChatImageTransitioningProtocol {
}

extension UIImage {
    
    func convertRect(rect: CGRect, fromContentMode mode: UIViewContentMode) -> CGRect {
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
}


internal class SIMChatMediaImageBrowserTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    init(src: UIImageView, dest: UIImageView) {
        self.src = src
        self.dest = dest
        super.init()
    }
    
    var src: UIImageView
    var dest: UIImageView
    
    let duration: NSTimeInterval = 0.35
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    var value: Int = 0
    
    func setup(v: Int) -> Self {
        value = v
        return self
    }
    
    func presentAnimateTransition(transitionContext: UIViewControllerContextTransitioning, src: UIImageView, dest: UIImageView) {
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            containerView = transitionContext.containerView() else {
                return
        }
        
        toVC.view.frame = fromVC.view.bounds
        toVC.view.alpha = 0
        
        // 对fromVC.view的截图添加动画效果
        let backgroundView = UIView(frame: containerView.bounds)
        
        let srcImage = src.image!
        let destImage = dest.image!
        let tempView = UIImageView()
        
        let srcFrame = srcImage.convertRect(src.bounds, fromContentMode: src.contentMode)
        let destFrame = destImage.convertRect(dest.bounds, fromContentMode: dest.contentMode)
        
        tempView.frame = containerView.convertRect(srcFrame, fromView: src)
        tempView.image = destImage
        
        SIMLog.trace(srcImage)
        SIMLog.trace(destImage)
        
        src.hidden = true
        
        backgroundView.backgroundColor = toVC.view.backgroundColor
        backgroundView.alpha = 0
        
        // 要实现转场，必须加入到containerView中
        containerView.addSubview(backgroundView)
        containerView.addSubview(toVC.view)
        containerView.addSubview(tempView)
        
        UIView.animateWithDuration(duration,
            animations: {
                
                backgroundView.alpha = 1
                tempView.frame = containerView.convertRect(destFrame, fromView: dest)
            },
            completion: { f in
                
                SIMLog.trace()
                
                toVC.view.alpha = 1
                
                self.src.hidden = false
                
                backgroundView.removeFromSuperview()
                tempView.removeFromSuperview()
                
                transitionContext.completeTransition(f)
            })
    }
    func dismissAnimateTransition(transitionContext: UIViewControllerContextTransitioning, src: UIImageView, dest: UIImageView) {
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            containerView = transitionContext.containerView() else {
                return
        }
        
        toVC.view.frame = fromVC.view.bounds
        //toVC.view.alpha = 0
        
        // 对fromVC.view的截图添加动画效果
        let backgroundView = UIView(frame: containerView.bounds)
        
        let srcImage = src.image!
        let destImage = dest.image!
        let tempView = UIImageView()
        
        let srcFrame = srcImage.convertRect(src.bounds, fromContentMode: src.contentMode)
        let destFrame = destImage.convertRect(dest.bounds, fromContentMode: dest.contentMode)
        
        tempView.frame = containerView.convertRect(srcFrame, fromView: src)
        tempView.image = srcImage
        
        backgroundView.backgroundColor = fromVC.view.backgroundColor
        
        fromVC.view.hidden = true
        
        // 要实现转场，必须加入到containerView中
        containerView.addSubview(backgroundView)
        containerView.addSubview(tempView)
        
        UIView.animateWithDuration(duration,
            animations: {
                backgroundView.alpha = 0
                tempView.frame = containerView.convertRect(destFrame, fromView: dest)
            },
            completion: { f in
                SIMLog.trace()
                
                backgroundView.removeFromSuperview()
                tempView.removeFromSuperview()
                
                transitionContext.completeTransition(true)
        })
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        switch value {
        case 0: presentAnimateTransition(transitionContext, src: src, dest: dest)
        case 1: dismissAnimateTransition(transitionContext, src: dest, dest: src)
        default:
            break
        }
    }
    
}

public class SIMChatMediaImageBrowser: UIViewController, SIMChatMediaBrowserProtocol, UIViewControllerTransitioningDelegate {
    
    
    var xview = UIImageView(frame: CGRectZero)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blackColor()
        
        xview.frame = view.bounds
        xview.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        xview.image = UIImage(named: "t1.jpg")
        xview.contentMode = .ScaleAspectFit
        //xview.contentMode = .ScaleAspectFill
        
        view.addSubview(xview)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SIMLog.trace()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        SIMLog.trace()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
//    
//    var b = false
//    
//    public override func prefersStatusBarHidden() -> Bool {
//        return b
//    }
//    
//    public override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
//        return .Fade
//    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        close()
    }
    
    public func browse(URL: NSURL) {
        SIMLog.trace(URL)
    }
    
    public func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func show(fromView: UIView) {
        guard let window = fromView.window, rootViewController = window.rootViewController else {
            return // 并没有显示
        }
        
        SIMLog.trace()
        
        t = SIMChatMediaImageBrowserTransitioning(src: fromView as! UIImageView, dest: xview)
        // 自定义转场动画
        transitioningDelegate = self
        modalPresentationStyle = .Custom
        
        //UIPercentDrivenInteractiveTransition
        
        rootViewController.presentViewController(self, animated: true, completion: nil)
    }
    
    var t: SIMChatMediaImageBrowserTransitioning?
   
    
    // MARK: UIViewControllerTransitioningDelegate
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return t?.setup(0)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return t?.setup(1)
    }
    
}