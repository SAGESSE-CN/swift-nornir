//
//  Browser.swift
//  Browser
//
//  Created by sagesse on 11/13/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

public class Browser: BrowseDataSource, BrowseDelegate {
    
    public func numberOfSections(in browser: Any) -> Int {
        return 1
    }
    public func browser(_ browser: Any, numberOfItemsInSection section: Int) -> Int {
        return _assets.count
    }
    public func browser(_ browser: Any, assetForItemAt indexPath: IndexPath) -> Browseable {
        return _assets[indexPath.item]
    }
    
    lazy var _assets:[Browseable] = {
        return (0 ..< 2800).map{ _ in
            return LocalImageAsset()
        }
    }()
    
    static let displayQueue = DispatchQueue(label: "Browser.Display.Queue")
}

public protocol BrowseDelegate: class {
}

public protocol BrowseDataSource: class {
    
    func numberOfSections(in browser: Any) -> Int 
    
    func browser(_ browser: Any, numberOfItemsInSection section: Int) -> Int
    
    func browser(_ browser: Any, assetForItemAt indexPath: IndexPath) -> Browseable 
}
