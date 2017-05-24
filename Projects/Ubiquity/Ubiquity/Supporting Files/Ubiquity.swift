//
//  Ubiquity.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 sagesse. All rights reserved.
//

import UIKit
import AVFoundation

/// Constants identifying the general type of an asset, such as image or video.
public enum AssetMediaType: Int {
    
    /// The asset’s type is unknown.
    case unknown = 0
    /// The asset is a photo or other static image.
    case image = 1
    /// The asset is a video file.
    case video = 2
    /// The asset is an audio file.
    case audio = 3
}

/// Constants identifying specific variations of asset media, such as panorama or screenshot photos and time lapse or high frame rate video.
public struct AssetMediaSubtype: OptionSet {
    
    // Photo subtypes
    
    /// The asset is a large-format panorama photo.
    public static var photoPanorama: AssetMediaSubtype = .init(rawValue: 0)
    
    /// The asset is a High Dynamic Range photo.
    public static var photoHDR: AssetMediaSubtype = .init(rawValue: 0)

    /// The asset is an image captured with the device’s screenshot feature.
    public static var photoScreenshot: AssetMediaSubtype = .init(rawValue: 0)

    // Video subtypes
    
    /// The asset is a video whose contents are always streamed over a network connection.
    public static var videoStreamed: AssetMediaSubtype = .init(rawValue: 0)

    /// The asset is a high-frame-rate video.
    public static var videoHighFrameRate: AssetMediaSubtype = .init(rawValue: 0)

    /// The asset is a time-lapse video.
    public static var videoTimelapse: AssetMediaSubtype = .init(rawValue: 0)
    
    /// The element type of the option set.
    public let rawValue: UInt
    /// Creates a new option set from the given raw value.
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

/// Major distinctions between kinds of asset collections
public enum CollectionType : Int {
    
    /// all albums
    case regular = 1
    /// A moment in the Photos app.
    case moment = 3
    /// A smart album whose contents update dynamically.
    case recentlyAdded = 2
}

/// Minor distinctions between kinds of asset collections
public enum CollectionSubtype : Int {

    /// A smart album of no more specific subtype.
    ///
    /// This subtype applies to smart albums synced to the device from iPhoto.
    case smartAlbumGeneric = 200

    /// A smart album that groups all panorama photos in the photo library.
    case smartAlbumPanoramas = 201

    /// A smart album that groups all video assets in the photo library.
    case smartAlbumVideos = 202

    /// A smart album that groups all assets that the user has marked as favorites.
    case smartAlbumFavorites = 203

    /// A smart album that groups all time-lapse videos in the photo library.
    case smartAlbumTimelapses = 204

    /// A smart album that groups all assets hidden from the Moments view in the Photos app.
    case smartAlbumAllHidden = 205

    /// A smart album that groups assets that were recently added to the photo library.
    case smartAlbumRecentlyAdded = 206

    /// A smart album that groups all burst photo sequences in the photo library.
    case smartAlbumBursts = 207

    /// A smart album that groups all Slow-Mo videos in the photo library.
    case smartAlbumSlomoVideos = 208

    /// A smart album that groups all assets that originate in the user’s own library (as opposed to assets from iCloud Shared Albums).
    case smartAlbumUserLibrary = 209

    /// A smart album that groups all photos and videos captured using the device’s front-facing camera.
    case smartAlbumSelfPortraits = 210

    /// A smart album that groups all images captured using the device’s screenshot function.
    case smartAlbumScreenshots = 211
}

/// information about your app’s authorization to access the user’s library
public enum AuthorizationStatus : Int {
    
    /// User has not yet made a choice with regards to this application
    case notDetermined = 0 
    /// This application is not authorized to access photo data.
    case restricted = 1
    /// User has explicitly denied this application access to photos data.
    case denied = 2
    /// User has authorized this application to access photos data.
    case authorized = 3
}

/// A representation of an image, video
public protocol Asset: class {
    
    /// A unique string that persistently identifies the object.
    var ub_localIdentifier: String { get }
    
    /// The width, in pixels, of the asset’s image or video data.
    var ub_pixelWidth: Int { get }
    /// The height, in pixels, of the asset’s image or video data.
    var ub_pixelHeight: Int { get }
    
    /// The duration, in seconds, of the video asset.
    /// For photo assets, the duration is always zero.
    var ub_duration: TimeInterval { get }
    
    /// The type of the asset, such as video or audio.
    var ub_mediaType: AssetMediaType { get }
    /// The subtypes of the asset, identifying special kinds of assets such as panoramic photo or high-framerate video.
    var ub_mediaSubtypes: AssetMediaSubtype { get }
}

/// A photos asset collections and collection lists.
public protocol Collection: class {
    
    /// The localized name of the collection.
    var ub_localizedTitle: String? { get }
    
    /// A unique string that persistently identifies the object.
    var ub_localIdentifier: String { get }
    
    /// The type of the asset collection, such as an album or a moment.
    var ub_collectionType: CollectionType { get }
    /// The subtype of the asset collection.
    var ub_collectionSubtype: CollectionSubtype { get }
    
    /// The number of assets in the asset collection.
    var ub_assetCount: Int { get }
    /// Retrieves assets from the specified asset collection.
    func ub_asset(at index: Int) -> Asset?
    func ub_assets(at range: Range<Int>) -> Array<Asset>
}


/// Provides methods for retrieving or generating preview thumbnails and full-size image or video data associated with Photos assets.
public protocol Library: class {
    
    
    /// Returns information about your app’s authorization for accessing the library.
    var ub_authorizationStatus: AuthorizationStatus { get }
    
    /// Requests the user’s permission, if needed, for accessing the library.
    func ub_requestAuthorization(_ handler: @escaping (AuthorizationStatus) -> Void)
    
    /// Get collections with type
    func ub_collections(with type: CollectionType) -> Array<Collection>
    
    
    
//    /// Cancels an asynchronous request
//    ///
//    /// When you perform an asynchronous request for image data using the requestImage(for:targetSize:contentMode:options:resultHandler:) method, or for a video object using one of the methods listed in Requesting Video Objects, the image manager returns a numeric identifier for the request. To cancel the request before it completes, provide this identifier when calling the cancelImageRequest(_:) method.
//    /// - parameter requestID: The numeric identifier of the request to be canceled.
//    func cancelRequest(_ requestID: Int)
//    
//    // If the asset's aspect ratio does not match that of the given targetSize, contentMode determines how the image will be resized.
//    //      PHImageContentModeAspectFit: Fit the asked size by maintaining the aspect ratio, the delivered image may not necessarily be the asked targetSize (see PHImageRequestOptionsDeliveryMode and PHImageRequestOptionsResizeMode)
//    //      PHImageContentModeAspectFill: Fill the asked size, some portion of the content may be clipped, the delivered image may not necessarily be the asked targetSize (see PHImageRequestOptionsDeliveryMode && PHImageRequestOptionsResizeMode)
//    //      PHImageContentModeDefault: Use PHImageContentModeDefault when size is PHImageManagerMaximumSize (though no scaling/cropping will be done on the result)
//    // If -[PHImageRequestOptions isSynchronous] returns NO (or options is nil), resultHandler may be called 1 or more times.
//    //     Typically in this case, resultHandler will be called asynchronously on the main thread with the requested results.
//    //     However, if deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic, resultHandler may be called synchronously on the calling thread if any image data is immediately available. If the image data returned in this first pass is of insufficient quality, resultHandler will be called again, asychronously on the main thread at a later time with the "correct" results.
//    //     If the request is cancelled, resultHandler may not be called at all.
//    // If -[PHImageRequestOptions isSynchronous] returns YES, resultHandler will be called exactly once, synchronously and on the calling thread. Synchronous requests cannot be cancelled. 
//    // resultHandler for asynchronous requests, always called on main thread
//    
//    func requestImage(for asset: Asset, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> Int
//    //open func requestImage(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?
//
////    
////    // Request largest represented image as data bytes, resultHandler is called exactly once (deliveryMode is ignored).
////    //     If PHImageRequestOptionsVersionCurrent is requested and the asset has adjustments then the largest rendered image data is returned
////    //     In all other cases then the original image data is returned
////    // resultHandler for asynchronous requests, always called on main thread
////    open func requestImageData(for asset: PHAsset, options: PHImageRequestOptions?, resultHandler: @escaping (Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Swift.Void) -> PHImageRequestID
////    
////    /// Requests a live photo representation of the asset. With PHImageRequestOptionsDeliveryModeOpportunistic (or if no options are specified), the resultHandler block may be called more than once (the first call may occur before the method returns). The PHImageResultIsDegradedKey key in the result handler's info parameter indicates when a temporary low-quality live photo is provided.
////    @available(iOS 9.1, *)
////    open func requestLivePhoto(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, options: PHLivePhotoRequestOptions?, resultHandler: @escaping (PHLivePhoto?, [AnyHashable : Any]?) -> Swift.Void) -> PHImageRequestID
////
////    
////    // Playback only. The result handler is called on an arbitrary queue.
//    func requestPlayerItem(forVideo asset: Asset, options: Any?, resultHandler: @escaping (AVPlayerItem?, [AnyHashable : Any]?) -> Void) -> Int
//    
////    // Everything else. The result handler is called on an arbitrary queue.
////    func requestAVAsset(forVideo asset: Asset, options: Any?, resultHandler: @escaping (AVAsset?, AVAudioMix?, [AnyHashable : Any]?) -> Swift.Void) -> Int
//    
////
////
////    // Export. The result handler is called on an arbitrary queue.
////    open func requestExportSession(forVideo asset: PHAsset, options: PHVideoRequestOptions?, exportPreset: String, resultHandler: @escaping (AVAssetExportSession?, [AnyHashable : Any]?) -> Swift.Void) -> PHImageRequestID
////
////    
}

/// can operate abstract protocol
internal protocol Operable: class {
    
    /// to prepare data you need
    func prepare(with item: Asset)
    
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
    func operable(didPrepare operable: Operable, item: Asset)
    
    /// if you start playing the call this method
    func operable(didStartPlay operable: Operable, item: Asset)
    /// if take the initiative to stop the play call this method
    func operable(didStop operable: Operable, item: Asset)
    
    /// if the interruption due to lack of enough data to invoke this method
    func operable(didStalled operable: Operable, item: Asset)
    /// if play is interrupted call the method, example: pause, in background mode, in the call
    func operable(didSuspend operable: Operable, item: Asset)
    /// if interrupt restored to call this method
    /// automatically restore: in background mode to foreground mode, in call is end
    func operable(didResume operable: Operable, item: Asset)
    
    /// if play completed call this method
    func operable(didFinish operable: Operable, item: Asset)
    /// if the occur error call the method
    func operable(didOccur operable: Operable, item: Asset, error: Error?)
}

/// can display abstract protocol
internal protocol Displayable {
    ///
    /// display content with item
    ///
    /// - parameter item: need display the item
    /// - parameter orientation: need display the orientation
    ///
    func willDisplay(with item: Asset, orientation: UIImageOrientation)
    ///
    /// end display content with item
    ///
    /// - parameter item: need display the item
    ///
    func endDisplay(with item: Asset)
}


/// Provide the container display support
//public extension UIView {
//    public ub_func addSubview(_ container: Container) {
//        addSubview(container.view)
//    }
//}

/// Provide the collection icons support
internal extension BadgeView.Item {
    // create item with collection sub type
    static func ub_init(subtype: CollectionSubtype) -> BadgeView.Item? {
        // check the collection sub type
        switch subtype {
            
        case .smartAlbumBursts: return .burst
        case .smartAlbumPanoramas: return .panorama
        case .smartAlbumScreenshots: return .screenshots
            
        case .smartAlbumSlomoVideos: return .slomo
        case .smartAlbumTimelapses: return .timelapse
        case .smartAlbumVideos: return .video
            
        case .smartAlbumSelfPortraits: return .selfies
        case .smartAlbumFavorites: return .favorites
            
        case .smartAlbumRecentlyAdded: return .recently
            
        case .smartAlbumGeneric: return nil
        case .smartAlbumAllHidden: return nil
        case .smartAlbumUserLibrary: return nil
        }
    }
}

///// Provide the container display support
//public extension UIViewController {
//    
//    public func ub_present(_ container: Container, animated flag: Bool, completion: (() -> Swift.Void)? = nil) {
//        logger.trace?.write()
//        // present operator must with NavigationController
//        let nav = NavigationController(navigationBarClass: nil, toolbarClass: ExtendedToolbar.self)
//        nav.viewControllers = [container.viewController]
//        nav.isToolbarHidden = false
//        nav.isNavigationBarHidden = false
//        
//        present(nav, animated: flag, completion: completion)
//    }
//}
//
///// Provide the container display support
//public extension UINavigationController {
//    
//    public func ub_pushViewController(_ container: Container, animated: Bool) {
//        logger.trace?.write()
//        // change toolbar to ExtendedToolbar, if need
//        pushViewController(container.viewController, animated: animated)
//    }
//}
//
