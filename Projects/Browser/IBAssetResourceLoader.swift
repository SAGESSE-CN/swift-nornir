//
//  IBAssetResourceLoader.swift
//  Browser
//
//  Created by sagesse on 22/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc open class IBAssetResourceLoader: NSObject {
    
    public init(asset: IBAsset) {
        self.asset = asset
        super.init()
    }
    
    
    open unowned var asset: IBAsset
    
    // The delegate object to use when handling resource requests.
    open var delegate: IBAssetResourceLoaderDelegate?
    
    open func loadValuesAsynchronously(for options: IBAssetValueOptions, completionHandler handler: ((Any?, Error?) -> Swift.Void)? = nil) {
        // 检查有没有缓存, 如果有直接返回, 如果没有加载之
        
        // 折分加载
        
        let request = IBAssetResourceLoadingRequest(asset: asset, options: options)
        
        guard delegate?.resourceLoader?(self, shouldWaitForLoadingOfRequestedResource: request) ?? false else {
            // 创建失败
            return
        }
        _allRequests.append(request)
    }
    open func cancelLoading() {
        // all request cancel
        
        _allRequests.forEach { loadingRequest in
            loadingRequest.isCancelled = true
            delegate?.resourceLoader?(self, didCancel: loadingRequest)
        }
        _allRequests.removeAll(keepingCapacity: true)
    }
    
    
    private lazy var _allRequests: [IBAssetResourceLoadingRequest] = []
}

@objc public protocol IBAssetResourceLoaderDelegate: class {
    
    /// Asks the delegate if it wants to load the requested resource.
    @objc optional func resourceLoader(_ resourceLoader: IBAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: IBAssetResourceLoadingRequest) -> Bool
    
    /// Invoked to inform the delegate that a prior loading request has been cancelled
    @objc optional func resourceLoader(_ resourceLoader: IBAssetResourceLoader, didCancel loadingRequest: IBAssetResourceLoadingRequest)
    
}
