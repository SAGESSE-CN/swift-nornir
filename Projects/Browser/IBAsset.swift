//
//  IBAsset.swift
//  Browser
//
//  Created by sagesse on 22/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


@objc open class IBAsset: NSObject {
    
    public override init() {
        super.init()
    }
    
    open func statusOfValue(for options: IBAssetValueOptions, error outError: NSErrorPointer) -> IBAssetValueStatus {
        return .unknown
    }
    open func loadValuesAsynchronously(for options: IBAssetValueOptions, completionHandler handler: ((Any?, Error?) -> Swift.Void)? = nil) {
        
        let level = Int(options.targetSize.width)
        
        // 偿试读取缓存
        if let value = _cacheValues[options.version]?[level] {
            handler?(value, nil)
            return
        }
        
        
        
        // 检查有没有缓存, 如果有使用之, 如果没有使用resourceloader加载
        resourceLoader.loadValuesAsynchronously(for: options, completionHandler: handler)
    }
    
    /// Cancels the loading of all values for all observers.
    open func cancelLoading() {
    }
    
    /// A asset resource loader
    open lazy var resourceLoader: IBAssetResourceLoader = IBAssetResourceLoader(asset: self)
    
    
    private lazy var _cacheValues: [IBAssetValueVersion: [Int: Any]] = [:]
}


