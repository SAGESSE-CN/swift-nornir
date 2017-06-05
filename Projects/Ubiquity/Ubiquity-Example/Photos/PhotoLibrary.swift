//
//  PhotoLibrary.swift
//  Ubiquity-Example
//
//  Created by SAGESSE on 5/23/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos
import Ubiquity

internal class PhotoLibrary: NSObject, Ubiquity.Library {
    
    override init() {
        _manager = PHCachingImageManager.default() as! PHCachingImageManager
        _cacheQueue = .init(label: "ubiquity-image-cache")
        super.init()
    }
    
    /// Returns information about your app’s authorization for accessing the library.
    var ub_authorizationStatus: Ubiquity.AuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus().ub_authorizationStatus
    }
    
    /// Requests the user’s permission, if needed, for accessing the library.
    func ub_requestAuthorization(_ handler: @escaping (Ubiquity.AuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization {
            // convert authorization status
            handler($0.ub_authorizationStatus)
        }
    }
    
    /// Cancels an asynchronous request
    func ub_cancelRequest(_ request: Ubiquity.Request) {
        //
        guard let request = request as? PHImageRequestID else {
            return
        }
        _manager.cancelImageRequest(request)
    }
    
    /// If the asset's aspect ratio does not match that of the given targetSize, contentMode determines how the image will be resized.
    func ub_requestImage(for asset: Ubiquity.Asset, targetSize: CGSize, contentMode: Ubiquity.RequestContentMode, options: Ubiquity.RequestOptions?, resultHandler: @escaping Ubiquity.RequestResultHandler<UIImage>) -> Ubiquity.Request? {
        // must with PHAsset
        guard let asset = asset as? PHAsset else {
            return nil
        }
        
        let newContentMode = PHImageContentMode(contentMode: contentMode)
        let newOptions = PHImageRequestOptions(options: options)
        
        // send image request
        return _manager.requestImage(for: asset, targetSize: targetSize, contentMode: newContentMode, options: newOptions) { image, info in
            // convert result info to response
            let response = Response(info: info)
            // callback
            resultHandler(image, response)
        }
    }
        
    func ub_requestPlayerItem(forVideo asset: Ubiquity.Asset, options: Ubiquity.RequestOptions?, resultHandler: @escaping Ubiquity.RequestResultHandler<AVPlayerItem>) -> Ubiquity.Request? {
        guard let asset = asset as? PHAsset else {
            return nil
        }
        
        let newOptions = PHVideoRequestOptions(options: options)
        
        // send player item request
        return _manager.requestPlayerItem(forVideo: asset, options: newOptions) { item, info in
            // convert result info to response
            let response = Response(info: info)
            // callback
            resultHandler(item, response)
        }
    }
    
    /// Cancels all image preparation that is currently in progress.
    func ub_stopCachingImagesForAllAssets() {
//        // forward
//        DispatchQueue.main.async { [_manager] in
//            _manager.stopCachingImagesForAllAssets()
//        }
    }
    /// Prepares image representations of the specified assets for later use.
    func ub_startCachingImages(for assets: [Asset], targetSize: CGSize, contentMode: RequestContentMode, options: RequestOptions?) {
        guard let assets = assets as? [PHAsset] else {
            return
        }
        // forward
        DispatchQueue.main.async { [_manager] in
            _manager.startCachingImages(for: assets, targetSize: targetSize, contentMode: .default, options: nil)
        }
    }
    /// Cancels image preparation for the specified assets and options.
    func ub_stopCachingImages(for assets: [Asset], targetSize: CGSize, contentMode: RequestContentMode, options: RequestOptions?) {
//        guard let assets = assets as? [PHAsset] else {
//            return
//        }
//        // forward
//        DispatchQueue.main.async { [_manager] in
//            // NOTE: high speed scrolling can cause deadlock
//            _manager.stopCachingImages(for: assets, targetSize: targetSize, contentMode: .default, options: nil)
//        }
    }
    
    /// Get collections with type
    func ub_collections(with type: Ubiquity.CollectionType) -> Array<Ubiquity.Collection> {
        return _fetchCollections()
    }
    
    private func _fetchCollections() -> Array<Collection> {
        
        var types = [(PHAssetCollectionType, PHAssetCollectionSubtype, Bool)]()

        // smart album -> user
        types.append((.smartAlbum, .smartAlbumUserLibrary, true))
        types.append((.smartAlbum, .smartAlbumFavorites, false))
        types.append((.smartAlbum, .smartAlbumGeneric, false))
            
        // smart album -> recently
        //types.append((.smartAlbum, .smartAlbumRecentlyAdded, false))
            
        // smart album -> video
        types.append((.smartAlbum, .smartAlbumPanoramas, false))
        types.append((.smartAlbum, .smartAlbumVideos, false))
        types.append((.smartAlbum, .smartAlbumSlomoVideos, false))
        types.append((.smartAlbum, .smartAlbumTimelapses, false))
        
        // smart album -> screenshots
        if #available(iOS 9.0, *) { 
            types.append((.smartAlbum, .smartAlbumScreenshots, false))
            //types.append((.smartAlbum, .smartAlbumSelfPortraits))
        }
        
        // album -> share
        types.append((.album, .albumMyPhotoStream, false))
        types.append((.album, .albumCloudShared, false))
        
        // album -> user
        types.append((.album, .albumRegular, true))
        types.append((.album, .albumSyncedAlbum, false))
        types.append((.album, .albumImported, false))
        types.append((.album, .albumSyncedFaces, false))
        
        return types.reduce([]) {
            $0 + _fetchCollections(with: $1.0, subtype: $1.1, canEmpty: $1.2)
        }
    }
    private func _fetchCollections(with type: PHAssetCollectionType, subtype: PHAssetCollectionSubtype, options: PHFetchOptions? = nil, canEmpty: Bool = true) -> Array<Collection> {
        var albums: [Collection] = []
        PHAssetCollection.fetchAssetCollections(with: type, subtype: subtype, options: nil).enumerateObjects({
            //let album = SAPAlbum(collection: $0.0)
            guard canEmpty || $0.0.canContainAssets else {
                return
            }
            albums.append(Collection(collection:$0.0))
        })
        return albums
    }
    
    
    private var _manager: PHCachingImageManager
    private var _cacheQueue: DispatchQueue
}

internal extension PhotoLibrary {
    
    class Response: Ubiquity.Response {
        
        init(info: [AnyHashable: Any]?) {
            ub_error = info?[PHImageErrorKey] as? NSError
            ub_degraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
            ub_cancelled = info?[PHImageCancelledKey] as? Bool ?? false
            ub_downloading = info?[PHImageResultIsInCloudKey] as? Bool ?? false
        }
        
        /// An error that occurred when Photos attempted to load the image.
        var ub_error: Error?
        
        /// The result image is a low-quality substitute for the requested image.
        var ub_degraded: Bool
        /// The image request was canceled. 
        var ub_cancelled: Bool
        /// The photo asset data is stored on the local device or must be downloaded from remote servicer
        var ub_downloading: Bool
    }
    
    class Collection: Ubiquity.Collection {
        
        init(collection: PHAssetCollection) {
            _collection = collection
        }
        
        public var ub_localizedTitle: String? {
            return _collection.localizedTitle
        }
        
        public var ub_localIdentifier: String {
            return _collection.localIdentifier
        }
        
        public var ub_collectionType: Ubiquity.CollectionType {
            return .regular
        }
        public var ub_collectionSubtype: Ubiquity.CollectionSubtype {
            return Ubiquity.CollectionSubtype(rawValue: _collection.assetCollectionSubtype.rawValue) ?? .smartAlbumGeneric
        }
        
        public var ub_assetCount: Int {
            return _result.count
        }
        public func ub_asset(at index: Int) -> Ubiquity.Asset? {
            return _result.object(at: index)
        }
        public func ub_assets(at range: Range<Int>) -> Array<Ubiquity.Asset> {
            var assets: [PHAsset] = []
            _result.enumerateObjects(at: .init(integersIn: range), options: []) { asset, _, _ in
                assets.append(asset)
            }
            return assets
        }
        
        private var __result: PHFetchResult<PHAsset>?
        private var _result: PHFetchResult<PHAsset> {
            if let result = __result {
                return result
            }
            let result = PHAsset.fetchAssets(in: _collection, options: nil)
            __result = result
            return result
        }
        
        private var _collection: PHAssetCollection
    }
}

extension PHAuthorizationStatus {
    
    var ub_authorizationStatus: Ubiquity.AuthorizationStatus {
        switch self {
        case .authorized: return .authorized
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        }
    }
}

extension PHImageRequestID: Ubiquity.Request {
}

extension PHImageContentMode {
    
    init(contentMode: Ubiquity.RequestContentMode) {
        switch contentMode {
        case .aspectFill: self = .aspectFill
        case .aspectFit: self = .aspectFit
        }
    }
    
}
extension PHImageRequestOptions {
    
    convenience init?(options: Ubiquity.RequestOptions?) {
        // if the option is nil, create a failure
        guard let options = options else {
            return nil
        }
        self.init()
        self.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        guard let progressHandler = options.progressHandler else {
            return
        }
        self.progressHandler = { progress, _, _, info in
            // convert result info to response
            let response = PhotoLibrary.Response(info: info)
            // callback
            progressHandler(progress, response)
        }
    }
}
extension PHVideoRequestOptions {
    
    convenience init?(options: Ubiquity.RequestOptions?) {
        // if the option is nil, create a failure
        guard let options = options else {
            return nil
        }
        self.init()
        self.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        guard let progressHandler = options.progressHandler else {
            return
        }
        self.progressHandler = { progress, _, _, info in
            // convert result info to response
            let response = PhotoLibrary.Response(info: info)
            // callback
            progressHandler(progress, response)
        }
    }
}


//

extension PHAsset: Ubiquity.Asset {
    
    public var ub_localIdentifier: String {
        return localIdentifier
    }
    
    public var ub_pixelWidth: Int {
        return pixelWidth
    }
    public var ub_pixelHeight: Int {
        return pixelHeight
    }
    
    public var ub_allowsPlay: Bool {
        return mediaType == .video
    }
    public var ub_duration: TimeInterval {
        return duration
    }
    
    public var ub_mediaType: Ubiquity.AssetMediaType {
        return Ubiquity.AssetMediaType(rawValue: mediaType.rawValue) ?? .unknown
    }
    public var ub_mediaSubtypes: Ubiquity.AssetMediaSubtype {
        return Ubiquity.AssetMediaSubtype(rawValue: mediaSubtypes.rawValue) 
    }
}
