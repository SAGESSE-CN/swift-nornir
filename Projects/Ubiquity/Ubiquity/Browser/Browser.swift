//
//  Browser.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

///
/// a media browser
///
public class Browser: NSObject, Container {
    
    public var viewController: UIViewController {
        return BrowserListController(container: self)
    }
    
    static var colors: Array<UIColor> = (0 ..< 1400).map { _ in .random }
}

///
/// data fetch & update
///
public extension Browser {
    
    public weak var dataSource: AnyObject? {
        set { return }
        get { return nil }
    }
    public weak var delegate: AnyObject? {
        set { return }
        get { return nil }
    }
    
    public func register(_ cls1: AnyClass, _ cls2: AnyClass) {
    }
    public func reloadData() {
    }
    
    public func insertItems(at indexPaths: Array<IndexPath>) {
    }
    public func reloadItems(at indexPaths: Array<IndexPath>) {
    }
    public func deleteItems(at indexPaths: Array<IndexPath>) {
    }
}

///
/// transition display support
///
public extension Browser {
    weak var transitioningDelegate: AnyObject? {
        set { return }
        get { return nil }
    }
}


//public class Ubiquity: BrowseDataSource, BrowseDelegate {
//    
//    public func numberOfSections(in browser: Any) -> Int {
//        return 1
//    }
//    public func browser(_ browser: Any, numberOfItemsInSection section: Int) -> Int {
//        return _assets.count
//    }
//    public func browser(_ browser: Any, assetForItemAt indexPath: IndexPath) -> Browseable {
//        return _assets[indexPath.item]
//    }
//    
//    lazy var _assets:[Browseable] = {
//        return (0 ..< 2800).map{ _ in
//            return LocalImageAsset()
//        }
//    }()
//    
//    static let displayQueue = DispatchQueue(label: "Ubiquity.Display.Queue")
//}
//
//public protocol BrowseDelegate: class {
//}
//
//public protocol BrowseDataSource: class {
//    
//    func numberOfSections(in browser: Any) -> Int 
//    
//    func browser(_ browser: Any, numberOfItemsInSection section: Int) -> Int
//    
//    func browser(_ browser: Any, assetForItemAt indexPath: IndexPath) -> Browseable 
//}

//let browser = Browser()
//
//browser.register(UIView.self, UIView.self)
//browser.dataSource = nil
//browser.delegate = nil
//
//browser.reloadData()
//browser.insertItems(at: [])
//browser.reloadItems(at: [])
//browser.deleteItems(at: [])
//
//browser.transitioningDelegate = nil
//UIViewController().show(browser, sender: indexPath)
