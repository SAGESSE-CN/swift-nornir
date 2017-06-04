//
//  CacheLibrary.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/25/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit
import AVFoundation


internal class CacheLibrary: NSObject, Library {
    // request options
    internal class Options: RequestOptions {
        
        init(progressHandler: RequestProgressHandler? = nil) {
            self.progressHandler = progressHandler
        }
        
        /// if necessary will download the image from reomte
        var isNetworkAccessAllowed: Bool = true
        
        /// provide caller a way to be told how much progress has been made prior to delivering the data when it comes from remote.
        var progressHandler: RequestProgressHandler? = nil
    }
    
    init(library: Library) {
        _library = library
        // super
        super.init()
    }
    
    /// Returns information about your app’s authorization for accessing the library.
    var ub_authorizationStatus: AuthorizationStatus {
        
        // forward
        return _library.ub_authorizationStatus
    }
    
    /// Requests the user’s permission, if needed, for accessing the library.
    func ub_requestAuthorization(_ handler: @escaping (AuthorizationStatus) -> Void) {
        logger.debug?.write()
        
        // forward
        return _library.ub_requestAuthorization(handler)
    }
    
    /// Get collections with type
    func ub_collections(with type: CollectionType) -> Array<Collection> {
        logger.debug?.write(type)
        
        // forward
        return _library.ub_collections(with: type)
    }
    
    /// Cancels an asynchronous request
    func ub_cancelRequest(_ request: Request) {
        //logger.trace?.write(request)
        
        _library.ub_cancelRequest(request)
    }
    
    /// If the asset's aspect ratio does not match that of the given targetSize, contentMode determines how the image will be resized.
    func ub_requestImage(for asset: Asset, targetSize: CGSize, contentMode: RequestContentMode, options: RequestOptions?, resultHandler: @escaping RequestResultHandler<UIImage>) -> Request? {
        //logger.trace?.write(asset.ub_localIdentifier, targetSize)
        
        // forward
        return _library.ub_requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { contents, response in
            resultHandler(contents, response)
        }
    }
    
    
    /// Playback only. The result handler is called on an arbitrary queue.
    func ub_requestPlayerItem(forVideo asset: Asset, options: RequestOptions?, resultHandler: @escaping RequestResultHandler<AVPlayerItem>) -> Request? {
        //logger.debug?.write(asset.ub_localIdentifier)
        
        // forward
        return _library.ub_requestPlayerItem(forVideo:asset, options:options, resultHandler:resultHandler)
    }
    
    /// Cancels all image preparation that is currently in progress.
    func ub_stopCachingImagesForAllAssets() {
        return _library.ub_stopCachingImagesForAllAssets()
    }
    /// Prepares image representations of the specified assets for later use.
    func ub_startCachingImages(for assets: [Asset], targetSize: CGSize, contentMode: RequestContentMode, options: RequestOptions?) {
        return _library.ub_startCachingImages(for: assets, targetSize: targetSize, contentMode: contentMode, options: options)
    }
    /// Cancels image preparation for the specified assets and options.
    func ub_stopCachingImages(for assets: [Asset], targetSize: CGSize, contentMode: RequestContentMode, options: RequestOptions?) {
        return _library.ub_stopCachingImages(for: assets, targetSize: targetSize, contentMode: contentMode, options: options)
    }
    
    //
    internal func fastCache(for asset: Asset, contents: AnyObject?) {
        // save cache with asset
        _fastCacheAsset = asset
        _fastCacheContents = contents
    }
    internal func fastCache(for asset: Asset) -> AnyObject? {
        // match asset
        guard _fastCacheAsset === asset else {
            return nil
        }
        return _fastCacheContents
    }
    
    private weak var _fastCacheAsset: Asset?
    private weak var _fastCacheContents: AnyObject?

    private var _library: Library
}

internal extension Asset {
    // the size rating
    internal func ub_format(with size: CGSize, mode: RequestContentMode) -> Int {
        // scale level
        let scale: CGFloat
        
        switch mode {
        case .aspectFill: scale = max(size.width / .init(ub_pixelWidth), size.height / .init(ub_pixelHeight))
        case .aspectFit: scale = min(size.width / .init(ub_pixelWidth), size.height / .init(ub_pixelHeight))
        }
        
        return .init(scale * 1000)
    }
}

internal extension Library {
    /// generate support cache the library
    internal var ub_cache: Library {
        // if already support, to return
        if let library  = self as? CacheLibrary {
            return library
        }
        // add a cache layer
        return CacheLibrary(library: self)
    }
}

internal extension Response {
    // the request complete status
    internal var ub_completed: Bool {
        return ub_error == nil && !ub_degraded
    }
}

internal extension DispatchQueue {
    
    internal func ub_merge(execute work: @escaping () -> Void) {
        
        // if has a merge queue, use it
        if let tasks = ub_merged {
            tasks.add(work)
            return
        }
        // create a merge queue
        let tasks = NSMutableArray(object: work)
        
        // save context & perform tasks
        self.ub_merged = tasks
        self.async { [weak self] in
            self?.ub_merged = nil
            tasks.forEach {
                ($0 as? () -> Void)?()
            }
        }
    }
    
    internal var ub_merged: NSMutableArray? {
        set { return objc_setAssociatedObject(self, &__ub_merged, newValue, .OBJC_ASSOCIATION_RETAIN) }
        get { return objc_getAssociatedObject(self, &__ub_merged) as? NSMutableArray }
    }
    
}
//private func _synchronized<Result>(token: Any, invoking body: () throws -> Result) rethrows -> Result {
//    objc_sync_enter(token)
//    defer {
//        objc_sync_exit(token)
//    }
//    return try body()
//}
private var __ub_merged = "__ub_merged"

