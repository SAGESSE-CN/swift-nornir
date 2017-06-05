//
//  Ubiquity.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 sagesse. All rights reserved.
//

import UIKit
import AVFoundation

/// Progress handler, called in an arbitrary serial queue. Only called when the data is not available locally and is retrieved from remote server.
public typealias RequestProgressHandler = (Double, Response) -> Void
/// A block to be called when image loading is complete, providing the requested asset or information about the status of the request.
public typealias RequestResultHandler<Result> = (Result?, Response) -> Void


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
    public static var photoPanorama: AssetMediaSubtype      = .init(rawValue: 1 << 0)
    /// The asset is a High Dynamic Range photo.
    public static var photoHDR: AssetMediaSubtype           = .init(rawValue: 1 << 1)
    /// The asset is an image captured with the device’s screenshot feature.
    public static var photoScreenshot: AssetMediaSubtype    = .init(rawValue: 1 << 2)

    // Video subtypes
    
    /// The asset is a video whose contents are always streamed over a network connection.
    public static var videoStreamed: AssetMediaSubtype      = .init(rawValue: 1 << 16)
    /// The asset is a high-frame-rate video.
    public static var videoHighFrameRate: AssetMediaSubtype = .init(rawValue: 1 << 17)
    /// The asset is a time-lapse video.
    public static var videoTimelapse: AssetMediaSubtype     = .init(rawValue: 1 << 18)
    
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

/// Options for fitting an image's aspect ratio to a requested size
public enum RequestContentMode: Int {
    
    /// Scales the image so that its larger dimension fits the target size.
    ///
    /// Use this option when you want the entire image to be visible, such as when presenting it in a view with the scaleAspectFit content mode.
    case aspectFit = 0

    /// Scales the image so that it completely fills the target size.
    ///
    /// Use this option when you want the image to completely fill an area, such as when presenting it in a view with the scaleAspectFill content mode.
    case aspectFill = 1
 
    /// Fits the image to the requested size using the default option, aspectFit.
    ///
    /// Use this content mode when requesting a full-sized image using the PHImageManagerMaximumSize value for the target size. In this case, the image manager does not scale or crop the image.
    static var `default`: RequestContentMode = .aspectFill
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
    
    /// The asset allows play operation
    var ub_allowsPlay: Bool { get }
    
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

/// Uniquely identify a cancellable async request
public protocol Request {
}

/// A set of options affecting the delivery of still image representations of Photos assets you request from an image manager.
public protocol RequestOptions {
    
    /// if necessary will download the image from reomte
    var isNetworkAccessAllowed: Bool { get }
    
    /// provide caller a way to be told how much progress has been made prior to delivering the data when it comes from remote server.
    var progressHandler: RequestProgressHandler? { get }
}

/// the request response
public protocol Response {
    
    /// An error that occurred when Photos attempted to load the image.
    var ub_error: Error? { get }
    
    /// The result image is a low-quality substitute for the requested image.
    var ub_degraded: Bool { get }
    /// The image request was canceled. 
    var ub_cancelled: Bool { get }
    /// The photo asset data is stored on the local device or must be downloaded from remote server
    var ub_downloading: Bool { get }
}

/// Provides methods for retrieving or generating preview thumbnails and full-size image or video data associated with Photos assets.
public protocol Library: class {
    
    /// Returns information about your app’s authorization for accessing the library.
    var ub_authorizationStatus: AuthorizationStatus { get }
    
    /// Requests the user’s permission, if needed, for accessing the library.
    func ub_requestAuthorization(_ handler: @escaping (AuthorizationStatus) -> Void)
    
    /// Get collections with type
    func ub_collections(with type: CollectionType) -> Array<Collection>
    
    
    /// Cancels an asynchronous request
    func ub_cancelRequest(_ requestID: Request)
    
    /// If the asset's aspect ratio does not match that of the given targetSize, contentMode determines how the image will be resized.
    @discardableResult
    func ub_requestImage(for asset: Asset, targetSize: CGSize, contentMode: RequestContentMode, options: RequestOptions?, resultHandler: @escaping RequestResultHandler<UIImage>) -> Request?
    
    // Playback only. The result handler is called on an arbitrary queue.
    @discardableResult
    func ub_requestPlayerItem(forVideo asset: Asset, options: RequestOptions?, resultHandler: @escaping RequestResultHandler<AVPlayerItem>) -> Request?
    
    /// Cancels all image preparation that is currently in progress.
    func ub_stopCachingImagesForAllAssets()
    
    /// Prepares image representations of the specified assets for later use.
    ///
    /// When you call this method, Photos begins to fetch image data and generates thumbnail images on a background thread. 
    /// At any time afterward, you can use the ub_requestImage(for:targetSize:contentMode:options:resultHandler:) method to request individual images from the cache. 
    /// If Photos has finished preparing a requested image, that method provides the image immediately.
    func ub_startCachingImages(for assets: [Asset], targetSize: CGSize, contentMode: RequestContentMode, options: RequestOptions?)

    /// Cancels image preparation for the specified assets and options.
    ///
    /// This method cancels image preparation for the specified assets with the specified options. 
    /// Use it when image preparation that might be in progress is no longer needed. 
    /// For example, if you prepare images for a collection view filled with photo thumbnails and then the user chooses a different thumbnail size for your collection view, 
    /// call this method to cancel generating thumbnail images at the old size.
    func ub_stopCachingImages(for assets: [Asset], targetSize: CGSize, contentMode: RequestContentMode, options: RequestOptions?)
}

/// can operate abstract protocol
internal protocol Operable: class {
    
    /// operate event callback delegate
    weak var operaterDelegate: OperableDelegate? { set get }
    
    /// play action, what must be after prepare otherwise this will not happen
    func play()
    /// stop action
    func stop()
    
    /// suspend action, if you go to the background or pause will automatically call the method
    func suspend()
    /// resume suspend
    func resume()
}
/// can operate abstract delegate
internal protocol OperableDelegate: class {
    
    /// if the data is prepared to do the call this method
    func operable(didPrepare operable: Operable, asset: Asset)
    
    /// if you start playing the call this method
    func operable(didStartPlay operable: Operable, asset: Asset)
    /// if take the initiative to stop the play call this method
    func operable(didStop operable: Operable, asset: Asset)
    
    /// if the interruption due to lack of enough data to invoke this method
    func operable(didStalled operable: Operable, asset: Asset)
    /// if play is interrupted call the method, example: pause, in background mode, in the call
    func operable(didSuspend operable: Operable, asset: Asset)
    /// if interrupt restored to call this method
    /// automatically restore: in background mode to foreground mode, in call is end
    func operable(didResume operable: Operable, asset: Asset)
    
    /// if play completed call this method
    func operable(didFinish operable: Operable, asset: Asset)
    /// if the occur error call the method
    func operable(didOccur operable: Operable, asset: Asset, error: Error?)
}

/// displayer protocol
internal protocol Displayable: class {
    
    /// displayer delegate
    weak var displayerDelegate: DisplayableDelegate? { set get }
    
    /// display content with item
    ///
    /// - parameter item: need display the item
    /// - parameter orientation: need display the orientation
    func willDisplay(with asset: Asset, in library: Library, orientation: UIImageOrientation)
    
    /// end display content with item
    ///
    /// - parameter item: need display the item
    func endDisplay(with asset: Asset, in library: Library)
}
/// displayer delegate
internal protocol DisplayableDelegate: class {
    
    /// Tell the delegate that the remote server requested.
    func displayer(_ displayer: Displayable, didStartRequest asset: Asset)
    
    /// Periodically informs the delegate of the progress.
    func displayer(_ displayer: Displayable, didReceive progress: Double)
    
    /// Tells the delegate that the task finished receive image.
    func displayer(_ displayer: Displayable, didComplete error: Error?)
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


internal extension Response {
    // the request complete status
    internal var ub_completed: Bool {
        return (ub_error == nil && !ub_degraded) || ub_cancelled
    }
}

