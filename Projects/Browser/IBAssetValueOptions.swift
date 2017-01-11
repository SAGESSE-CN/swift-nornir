//
//  IBAssetValueOptions.swift
//  Browser
//
//  Created by sagesse on 22/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc public enum IBAssetValueStatus: Int {
    /// Indicates that the property status is unknown.
    case unknown
    /// Indicates that the property is not fully loaded.
    case loading
    /// Indicates that the property is ready for use.
    case loaded
    /// Indicates that the attempt to load the property failed.
    case failed
    /// Indicates that the attempt to load the property was cancelled.
    case cancelled
}

@objc public enum IBAssetValueVersion: Int {
    /// The value is thumbnail image
    case thumbnail
    /// The value is large image
    case large
    /// The value is original file
    case original
}

@objc open class IBAssetValueOptions: NSObject {
    
    /// Cretae instance with some options
    public  init(version: IBAssetValueVersion, targetSize: CGSize, contentMode: UIViewContentMode = .scaleAspectFit) {
        self.version = version
        self.targetSize = targetSize
        self.targetContentMode = contentMode
        super.init()
    }
    
    /// Requested the version
    open var version: IBAssetValueVersion
    
    /// Requested the size
    open var targetSize: CGSize
    /// Requested the content mode
    open var targetContentMode: UIViewContentMode
}
