//
//  Ubiquity.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 sagesse. All rights reserved.
//

import UIKit

///
/// displayable the item abstract class
///
public protocol Item {
}

///
/// displayable the container abstract class
///
public protocol Container {
    
//    var view: UIView { get }
    var viewController: UIViewController { get }
}

///
/// Provide the container display support
///
//public extension UIView {
//    public func addSubview(_ container: Container) {
//        addSubview(container.view)
//    }
//}

///
/// Provide the container display support
///
public extension UIViewController {
//    public func show(_ container: Container, sender: Any?) {
//        show(container.viewController, sender: sender)
//    }
    public func present(_ container: Container, animated flag: Bool, completion: (() -> Swift.Void)? = nil) {
        let nav = UINavigationController(navigationBarClass: nil, toolbarClass: ExtendedToolbar.self)
        nav.viewControllers = [container.viewController]
        nav.isToolbarHidden = false
        nav.isNavigationBarHidden = false
        present(nav, animated: flag, completion: completion)
    }
}

///
/// Provide the container display support
///
public extension UINavigationController {
//    public convenience init(rootViewController container: Container)  {
//        self.init(rootViewController: container.viewControllerIfLoaded())
//    }
    public func pushViewController(_ container: Container, animated: Bool) {
        pushViewController(container.viewController, animated: animated)
    }
}

