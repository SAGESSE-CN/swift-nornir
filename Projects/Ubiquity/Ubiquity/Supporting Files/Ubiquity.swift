//
//  Ubiquity.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 sagesse. All rights reserved.
//

import UIKit

/// resource abstract of item
public protocol Group: class {
    var title: String? { get }
}

/// resource abstract of item
public protocol Item: class {
    var size: CGSize { get }
    var image: UIImage? { get }
}

/// displayable the container abstract class
public protocol Container: class {
    
    var numberOfSections: Int { get }
    func numberOfItems(inSection section: Int) -> Int
    
    func item(at indexPath: IndexPath) -> Item
    
    var view: UIView { get }
    var viewController: UIViewController { get }
}

/// can operate abstract protocol
internal protocol Operable: class {
    
    /// operate event callback delegate
    weak var delegate: OperableDelegate? { set get }
    
    func play()
    func stop()
    
    func suspend()
    func resume()
    
    func prepare(with item: Item)
}
/// can operate abstract delegate
internal protocol OperableDelegate: class {
    
    func operable(didPrepare operable: Operable, item: Item)
    func operable(didStartPlay operable: Operable, item: Item)
    func operable(didStop operable: Operable, item: Item)
    
    func operable(didSuspend operable: Operable, item: Item)
    func operable(didResume operable: Operable, item: Item)
    
    func operable(didFinish operable: Operable, item: Item)
    func operable(didOccur operable: Operable, item: Item, error: Error?)
}

/// can display abstract protocol
internal protocol Displayable {
    ///
    /// display content with item
    ///
    /// - parameter item: need display the item
    /// - parameter orientation: need display the orientation
    ///
    func display(with item: Item, orientation: UIImageOrientation)
}


/// Provide the container display support
//public extension UIView {
//    public ub_func addSubview(_ container: Container) {
//        addSubview(container.view)
//    }
//}

/// Provide the container display support
public extension UIViewController {
    
    public func ub_present(_ container: Container, animated flag: Bool, completion: (() -> Swift.Void)? = nil) {
        logger.trace?.write()
        // present operator must with NavigationController
        let nav = UINavigationController(navigationBarClass: nil, toolbarClass: ExtendedToolbar.self)
        nav.viewControllers = [container.viewController]
        nav.isToolbarHidden = false
        nav.isNavigationBarHidden = false
        
        present(nav, animated: flag, completion: completion)
    }
}

/// Provide the container display support
public extension UINavigationController {
    
    public func ub_pushViewController(_ container: Container, animated: Bool) {
        logger.trace?.write()
        // change toolbar to ExtendedToolbar, if need
        pushViewController(container.viewController, animated: animated)
    }
}


