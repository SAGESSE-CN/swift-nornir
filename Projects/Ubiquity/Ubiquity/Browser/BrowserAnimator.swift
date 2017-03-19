//
//  BrowserAnimator.swift
//  Ubiquity
//
//  Created by SAGESSE on 3/20/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserAnimator: NSObject {

}

///
/// custom transition support
///
extension BrowserAnimator: UINavigationControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        logger.debug()
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        logger.debug()
        return nil
    }
    
    func animationController(forPop poped: UIViewController, from: UIViewController, source: UINavigationController) -> UIViewControllerAnimatedTransitioning? {
        logger.debug()
        return nil
    }
    func animationController(forPush pushed: UIViewController, from: UIViewController, source: UINavigationController) -> UIViewControllerAnimatedTransitioning? {
        logger.debug()
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


