//
//  Ubiquity.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 sagesse. All rights reserved.
//

import UIKit

public enum ItemType: Int {
    case image
    case video
}

/// resource abstract of item
public protocol Group: class {
    var title: String? { get }
}

/// resource abstract of item
public protocol Item: class {
    var size: CGSize { get }
    var image: UIImage? { get }
    
    var type: ItemType { get }
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
    
    /// to prepare data you need
    func prepare(with item: Item)
    
    /// play action, what must be after prepare otherwise this will not happen
    func play()
    /// stop action
    func stop()
    
    /// suspend action, if you go to the background or pause will automatically call the method
    func suspend()
    /// resume suspend
    func resume()
    
    /// operate event callback delegate
    weak var delegate: OperableDelegate? { set get }
}
/// can operate abstract delegate
internal protocol OperableDelegate: class {
    
    /// if the data is prepared to do the call this method
    func operable(didPrepare operable: Operable, item: Item)
    
    /// if you start playing the call this method
    func operable(didStartPlay operable: Operable, item: Item)
    /// if take the initiative to stop the play call this method
    func operable(didStop operable: Operable, item: Item)
    
    /// if the interruption due to lack of enough data to invoke this method
    func operable(didStalled operable: Operable, item: Item)
    /// if play is interrupted call the method, example: pause, in background mode, in the call
    func operable(didSuspend operable: Operable, item: Item)
    /// if interrupt restored to call this method
    /// automatically restore: in background mode to foreground mode, in call is end
    func operable(didResume operable: Operable, item: Item)
    
    /// if play completed call this method
    func operable(didFinish operable: Operable, item: Item)
    /// if the occur error call the method
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
    func willDisplay(with item: Item, orientation: UIImageOrientation)
    ///
    /// end display content with item
    ///
    /// - parameter item: need display the item
    ///
    func endDisplay(with item: Item)
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
        let nav = NavigationController(navigationBarClass: nil, toolbarClass: ExtendedToolbar.self)
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


