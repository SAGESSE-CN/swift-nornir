//
//  IBAssetResourceLoadingRequest.swift
//  Browser
//
//  Created by sagesse on 22/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


@objc open class IBAssetResourceLoadingRequest: NSObject {
    
    public init(asset: IBAsset, options: IBAssetValueOptions) {
        self.asset = asset
        self.options = options
        super.init()
    }
    
    
    // MARK: Accessing the Request Data
    
    /// The requested of asset
    open var asset: IBAsset
    
    /// The requested of options
    open var options: IBAssetValueOptions
    
    // MARK: Reporting the Result of the Request
    
    /// A Boolean value that indicates whether the request has been cancelled.
    open var isCancelled: Bool = false
    
    /// A Boolean value that indicates whether loading of the resource has finished.
    open var isFinished: Bool = false
    
    /// Provides data to the loading request.
    open func respond(with data: Any) {
    }
    
    /// Provides progress info to the loading request.
    open func progress(with progress: Double) {
    }
    
    /// Causes the receiver to treat the processing of the request as complete.
    open func finishLoading() {
    }
    
    /// Causes the receiver to handle the failure to load a resource for which a resource loader’s delegate took responsibility.
    open func finishLoading(with error: Error?) {
    }
}
