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
    
    /// Returns information about your app’s authorization for accessing the library.
    var ub_authorizationStatus: Ubiquity.AuthorizationStatus {
        return Ubiquity.AuthorizationStatus(rawValue: PHPhotoLibrary.authorizationStatus().rawValue) ?? .notDetermined
    }
    
    /// Requests the user’s permission, if needed, for accessing the library.
    func ub_requestAuthorization(_ handler: @escaping (Ubiquity.AuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization {
            // convert authorization status
            handler(Ubiquity.AuthorizationStatus(rawValue: $0.rawValue) ?? .notDetermined)
        }
    }
    
    /// Get collections with type
    func ub_collections(with type: Ubiquity.CollectionType) -> Array<Ubiquity.Collection> {
        return _fetchCollections()
    }
    
    private func _fetchCollections() -> Array<PhotoCollection> {
        
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
    private func _fetchCollections(with type: PHAssetCollectionType, subtype: PHAssetCollectionSubtype, options: PHFetchOptions? = nil, canEmpty: Bool = true) -> Array<PhotoCollection> {
        var albums: [PhotoCollection] = []
        PHAssetCollection.fetchAssetCollections(with: type, subtype: subtype, options: nil).enumerateObjects({
            //let album = SAPAlbum(collection: $0.0)
            guard canEmpty || $0.0.canContainAssets else {
                return
            }
            albums.append(PhotoCollection(collection:$0.0))
        })
        return albums
    }
    
//    fileprivate static func _fetchAssetCollections(with type: PHAssetCollectionType, subtype: PHAssetCollectionSubtype, options: PHFetchOptions? = nil, canEmpty: Bool = true) -> [SAPAlbum] {
//        var albums: [SAPAlbum] = []
//        PHAssetCollection.fetchAssetCollections(with: type, subtype: subtype, options: nil).enumerateObjects({
//            let album = SAPAlbum(collection: $0.0)
//            guard canEmpty || album.count != 0 else {
//                return
//            }
//            albums.append(album)
//        })
//        return albums
//    }
    
//    fileprivate static func _fetchAssetCollections() -> [SAPAlbum] {
//        var types: [(PHAssetCollectionType, PHAssetCollectionSubtype, Bool)] = []
//        
//        // smart album -> user
//        types.append((.smartAlbum, .smartAlbumUserLibrary, true))
//        types.append((.smartAlbum, .smartAlbumFavorites, false))
//        types.append((.smartAlbum, .smartAlbumGeneric, false))
//            
//        // smart album -> recently
//        types.append((.smartAlbum, .smartAlbumRecentlyAdded, false))
//            
//        // smart album -> video
//        types.append((.smartAlbum, .smartAlbumPanoramas, false))
//        types.append((.smartAlbum, .smartAlbumVideos, false))
//        types.append((.smartAlbum, .smartAlbumSlomoVideos, false))
//        types.append((.smartAlbum, .smartAlbumTimelapses, false))
//        
//        // smart album -> screenshots
//        if #available(iOS 9.0, *) { 
//            types.append((.smartAlbum, .smartAlbumScreenshots, false))
//            //types.append((.smartAlbum, .smartAlbumSelfPortraits))
//        }
//        
//        // album -> share
//        types.append((.album, .albumMyPhotoStream, false))
//        types.append((.album, .albumCloudShared, false))
//        
//        // album -> user
//        types.append((.album, .albumRegular, true))
//        types.append((.album, .albumSyncedAlbum, false))
//        types.append((.album, .albumImported, false))
//        types.append((.album, .albumSyncedFaces, false))
//        
//        return types.reduce([]) {
//            $0 + _fetchAssetCollections(with: $1.0, subtype: $1.1, canEmpty: $1.2)
//        }
//    }
//    fileprivate static func _fetchAssetCollections(with type: PHAssetCollectionType, subtype: PHAssetCollectionSubtype, options: PHFetchOptions? = nil, canEmpty: Bool = true) -> [SAPAlbum] {
//        var albums: [SAPAlbum] = []
//        PHAssetCollection.fetchAssetCollections(with: type, subtype: subtype, options: nil).enumerateObjects({
//            let album = SAPAlbum(collection: $0.0)
//            guard canEmpty || album.count != 0 else {
//                return
//            }
//            albums.append(album)
//        })
//        return albums
//    }
}


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

class PhotoCollection: Ubiquity.Collection {
    
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


