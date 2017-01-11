//
//  SAPLibrary.swift
//  SAC
//
//  Created by SAGESSE on 9/20/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos

public enum SAPhotoStatus {
   
    case notPermission
    case notData
    case notError
}


public class SAPRequestOptions: NSObject {
    
    init(size: CGSize, contentMode: PHImageContentMode = .default) {
        self.targetSize = size
        self.targetContentMode = contentMode
        super.init()
    }
    
    var targetSize: CGSize
    var targetContentMode: PHImageContentMode
    
    var version: PHImageRequestOptionsVersion = .current // version
    var deliveryMode: PHImageRequestOptionsDeliveryMode = .opportunistic // delivery mode. Defaults to PHImageRequestOptionsDeliveryModeOpportunistic
    
    var resizeMode: PHImageRequestOptionsResizeMode = .none // resize mode. Does not apply when size is PHImageManagerMaximumSize. Defaults to PHImageRequestOptionsResizeModeNone (or no resize)
    
    var normalizedCropRect: CGRect = .zero // specify crop rectangle in unit coordinates of the original image, such as a face. Defaults to CGRectZero (not applicable)
     
    var isNetworkAccessAllowed: Bool = false // if necessary will download the image from iCloud (client can monitor or cancel using progressHandler). Defaults to NO (see start/stopCachingImagesForAssets)
    var isSynchronous: Bool = false // return only a single result, blocking until available (or failure). Defaults to NO
    
    var progressHandler: PHAssetImageProgressHandler? // provide caller a way to be told how much progress has been made prior to delivering the data when it comes from iCloud. Defaults to nil, shall be set by caller
    var resultHandler: ((UIImage?, [AnyHashable : Any]?) -> Void)?
}


public class SAPLibrary: NSObject {
   
    
    public func isExists(of photo: SAPAsset) -> Bool {
        return PHAsset.fetchAssets(withLocalIdentifiers: [photo.identifier], options: nil).count != 0
    }
    
    public func register(_ observer: PHPhotoLibraryChangeObserver) {
        let lib = PHPhotoLibrary.shared()
        lib.register(observer)
    }
    public func unregisterChangeObserver(_ observer: PHPhotoLibraryChangeObserver) {
        let lib = PHPhotoLibrary.shared()
        lib.unregisterChangeObserver(observer)
    }
    
    
    public func imageItem(with asset: SAPAsset, size: CGSize) -> Progressiveable? {
        let request = SAPImageRequest(asset: asset.asset, size: size)
        
        request.isNetworkAccessAllowed = true
        
        return _session.imageTask(with: request)
//        _logger.trace("\(asset.identifier) - \(size)")
//        
//        let key = asset.identifier
//        let name = "\(Int(size.width))x\(Int(size.height)).png"
//        // 读取缓存
//        if let item = _allCaches[key]?[name]?.object {
//            return item
//        }
//        let item = SAPProgressiveItem(size: size)
//        let options = PHImageRequestOptions()
//        
//        item.progress = 1 // 默认是1, 只有在progressHandler回调的时候才会出现进度
//        item.content = _cachedImage(with: asset, size: size) // 获取最接近的一张图片
//        
//        //options.deliveryMode = .highQualityFormat //.fastFormat//opportunistic
//        options.deliveryMode = .opportunistic
//        options.resizeMode = .fast
//        options.isNetworkAccessAllowed = true
//        options.progressHandler = { [weak item](progress, error, stop, info) in
//            print(asset.identifier, "update progress", info, error)
//            _SAPhotoQueueTasksAdd(.main) {
//                item?.progress = progress
//            }
//        }
//        // 创建缓冲池
//        if _allCaches.index(forKey: asset.identifier) == nil {
//            _allCaches[key] = [:]
//        }
//        _allCaches[key]?[name] = SAPWKObject(object: item)
//        // 异步请求
//        _queue.async {
//            print(asset.identifier, "request image with", size)
//            item.requestId = self._requestImage(asset, size, .aspectFill, options) {  [weak item](img, info) in
//                // 读取字典
//                let isError = (info?[PHImageErrorKey] as? NSError) != nil
//                let isCancel = (info?[PHImageCancelledKey] as? Int) != nil
//                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Int) == 1
//                let isInClound = (info?[PHImageResultIsInCloudKey] as? Int) == 1
//                
//                let os = (item?.content as? UIImage)?.size ?? .zero
//                let ns = img?.size ?? .zero
//                // 新加载的图片必须比当前的图片大
//                print(asset.identifier, " respond image ",  size, img, info)
//                guard ns.width >= os.width && ns.height >= os.height else {
//                    return
//                }
//                // 添加任务到主线程
//                _SAPhotoQueueTasksAdd(.main) {
//                    guard item != nil else {
//                        return
//                    }
//                    let os = (item?.content as? UIImage)?.size ?? .zero
//                    let ns = img?.size ?? .zero
//                    // 新加载的图片必须比当前的图片大
//                    if ns.width >= os.width && ns.height >= os.height {
//                        // 更新内容
//                        item?.content = img
//                    }
//                    // 检查是否己经载完成
//                    if isError || isCancel || !isDegraded {
//                        // 更新进度
//                        item?.progress = 1
//                        item?.requestId = PHInvalidImageRequestID
//                    } else if isInClound {
//                        // 图片还在在iClound上, 重置进度
//                        guard (item?.progress ?? 0) > 0.999999 else {
//                            return
//                        }
//                        item?.progress = 0
//                    }
//                }
//            }
//        }
//        
//        return item
    }
    public func playerItem(with asset: SAPAsset) -> SAPProgressiveItem? {
        //_logger.trace()
        
        let item = SAPProgressiveItem(size: asset.size)
        let options = PHVideoRequestOptions()
        
        options.isNetworkAccessAllowed = true
        
        _requestPlayerItem(asset, options) { (pitem, info) in
            item.content = pitem
            item.progress = 1
        }
        
        return item
    }
    
    private func _cachedImage(with asset: SAPAsset, size: CGSize) -> UIImage? {
        // is cache?
        guard let caches = _allCaches[asset.identifier] else {
            return nil
        }
        var image: UIImage?
        
        // 查找
        caches.forEach {
            guard let item = $1.object else {
                return
            }
            // 当前找到的最符合的图片大小
            let crs = image?.size ?? .zero
            // 当前item的图片大小
            let cis = (item.content as? UIImage)?.size ?? .zero
            // 必须小于或者等于size
            guard (cis.width <= size.width && cis.height <= size.height) || (size == SAPhotoMaximumSize) else {
                return
            }
            // 必须大于当前的图片
            guard (cis.width >= crs.width && cis.height >= crs.height) else {
                return
            }
            image = item.content as? UIImage
        }
        
        return image
    }
    
    public func data(with photo: SAPAsset, resultHandler: @escaping (Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Void) {
        //_logger.trace(photo.identifier)
        
        _requestImageData(photo, nil, resultHandler: resultHandler)
    }
    
    public func playerItem(with photo: SAPAsset, resultHandler: @escaping (AVPlayerItem?, [AnyHashable : Any]?) -> Void) {
        
        //@interface PHVideoRequestOptions : NSObject
        //@property (nonatomic, assign, getter=isNetworkAccessAllowed) BOOL networkAccessAllowed;
        //@property (nonatomic, assign) PHVideoRequestOptionsVersion version;
        //@property (nonatomic, assign) PHVideoRequestOptionsDeliveryMode deliveryMode;
        //@property (nonatomic, copy, nullable) PHAssetVideoProgressHandler progressHandler;
        //@end
        
        _requestPlayerItem(photo, nil, resultHandler: resultHandler)
    }
    
    
    func clearInvaildCaches() {
        guard !_needsClearCaches else {
            return
        }
        //_logger.trace()
        
        _needsClearCaches = true
        
        DispatchQueue.main.async {
            self._needsClearCaches = false
            self._clearCachesOnMainThread()
        }
    }
    
    private func _clearCachesOnMainThread() {
        //_logger.trace()
        
        _allCaches.keys.forEach { key in
            let keys: [String]? = _allCaches[key]?.flatMap {
                if $1.object == nil {
                    return $0
                }
                return nil
            }
            guard keys?.count != _allCaches[key]?.count else {
                _allCaches.removeValue(forKey: key)
                return
            }
            keys?.forEach {
                _ = _allCaches[key]?.removeValue(forKey: $0)
            }
        }
    }
    
//    public func requestImage(for photo: SAPAsset, targetSize: CGSize, contentMode: PHImageContentMode = .default, options: PHImageRequestOptions? = nil, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
//        let im = PHCachingImageManager.default()
//        return im.requestImage(for: photo.asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: resultHandler)
//    }
//    public static func requestImageData(for photo: SAPAsset, options: PHImageRequestOptions? = nil, resultHandler: @escaping (Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Swift.Void) {
//        let im = PHCachingImageManager.default()
//        im.requestImageData(for: photo.asset, options: options, resultHandler: resultHandler)
//    }
    
    open func cancelImageRequest(_ requestId: PHImageRequestID) {
        let im = PHCachingImageManager.default()
        im.cancelImageRequest(requestId)
    }
    
    private func _requestImage(_ photo: SAPAsset, _ size: CGSize, _ contentMode: PHImageContentMode, _ options: PHImageRequestOptions?, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
        
        // asset + contentMode + targetSize = format
        
//        let requestTotal = size.width * size.height
//        let thumbnilTotal = _SAPhotoMinimumThumbnailSize.width * _SAPhotoMinimumThumbnailSize.height
//        
//        // 只处理opportunistic模式
//        guard options?.deliveryMode == .opportunistic && requestTotal > thumbnilTotal else {
//            return
//        }
        
        // 请求图片=>所请求的图片大于缩略图=>查找缩略图(内存)=>所请求的图片大于缩略图的2倍=>延迟n秒后请求缩略图=>合并结果
        // PS1: 如果在这期间获取到了原图, 取消缩略图请求
        // PS2: n=加载己缓存的图片耗时*2
        
        let im = PHCachingImageManager.default()
        
//        if requestTotal > thumbnilTotal {
//            let options = PHImageRequestOptions()
//            
//            options.deliveryMode = .opportunistic
//            options.resizeMode = .fast
//            options.isNetworkAccessAllowed = true
//            
//            //startCachingImages(for: [photo], targetSize: _SAPhotoMinimumThumbnailSize, contentMode: .aspectFill, options: options)
//        }
        //PHImageResultDeliveredImageFormatKey
        
        return im.requestImage(for: photo.asset, targetSize: size, contentMode: contentMode, options: options, resultHandler: resultHandler)
    }
    
    public func imageTask(with asset: SAPAsset, options: SAPRequestOptions) -> SAPProgressiveItem? {
        return _requestImageItem(with: asset, options: options)
    }
    
    
    private func _requestImageItem(with asset: SAPAsset, options: SAPRequestOptions) -> SAPProgressiveItem? {
        let format = _SAPhotoFormat(asset.asset, options.targetSize)
        _logger.trace("\(format)|\(asset.identifier) => \(options.targetSize)")
        // 检查有没有创建, 如果有直接返回
        if let item = _cacheImageItem(with: asset, format: format) {
            _logger.trace("\(format)|\(asset.identifier) hit cache")
            return item
        }
        // 没找到需要创建
        let im = PHCachingImageManager.default()
        let opt = PHImageRequestOptions()
        let item = _makeImageItem(with: asset, format: format)
        
        item.progress = 1
        
        opt.deliveryMode = options.deliveryMode
        opt.resizeMode = options.resizeMode
        opt.version = options.version
        opt.normalizedCropRect = options.normalizedCropRect
        opt.isNetworkAccessAllowed = options.isNetworkAccessAllowed
        opt.isSynchronous = options.isSynchronous
        opt.progressHandler = { [weak item](progress, error, stop, info) in
            item?.progress = progress
            options.progressHandler?(progress, error, stop, info)
        }
        // 查找一个比较接近的图片
        item.thumb = _cacheImageItem(with: asset, target: options.targetSize)
        // 如果没有找到接近的图片检查是否需要加载缩略图
        // 请求图片=>所请求的图片大于缩略图=>查找缩略图(内存)=>所请求的图片大于缩略图的2倍=>延迟n秒后请求缩略图=>合并结果
        // PS1: 如果在这期间获取到了原图, 取消缩略图请求
        // PS2: n=加载己缓存的图片耗时*2
        let mts = _SAPhotoMinimumThumbnailSize
        if item.thumb == nil && options.targetSize.width * options.targetSize.height > mts.width * mts.height {
//            let n: TimeInterval = 0.5
//            _loadQueue.asyncAfter(deadline: .now() + .milliseconds(Int(n * 1000))) { [weak item] in
//                if item != nil && item?.thumb == nil && item?.content == nil {
//                    return
//                }
//                let opt2 = SAPRequestOptions(size: _SAPhotoMinimumThumbnailSize)
//                
//                item?.thumb = self._requestImageItem(with: asset, options: opt2)
//            }
        }
        // 请求这个图片
        _logger.trace("\(format)|\(asset.identifier) request new image")
        _loadQueue.async {
            item.requestId = im.requestImage(for: asset.asset, targetSize: options.targetSize, contentMode: options.targetContentMode, options: opt) { [weak item]img, info in
                // 读取字典
                let isError = (info?[PHImageErrorKey] as? NSError) != nil
                let isCancel = (info?[PHImageCancelledKey] as? Int) != nil
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Int) == 1
                let isInClound = (info?[PHImageResultIsInCloudKey] as? Int) == 1
                
                if item != nil {
                    self._cacheImageItem(with: asset, format: format, image: img)
                }
                
                options.resultHandler?(img, info)
            }
        }
        return item
    }
    
    @discardableResult
    func _makeImageItem(with asset: SAPAsset, format: Int) -> SAPProgressiveItem {
        if _allImageItems[asset.identifier] == nil {
            _allImageItems[asset.identifier] = [:]
        }
        if let item = _allImageItems[asset.identifier]?[format] {
            return item
        }
        let item = SAPProgressiveItem(size: asset.size)
        _allImageItems[asset.identifier]?[format] = item
        return item
    }
    
    func _cacheImageItem(with asset: SAPAsset, format: Int, image: UIImage?, progress: Double = 1) {
        _makeImageItem(with: asset, format: format)
        _allImageItems[asset.identifier]?.forEach { 
            guard $0 >= format else {
                return
            }
            $1.content = image
            guard $0 == format else {
                return
            }
            $1.progress = progress
        }
    }
    func _cacheImageItem(with asset: SAPAsset, format: Int) -> SAPProgressiveItem? {
        return _allImageItems[asset.identifier]?[format]
    }
    func _cacheImageItem(with asset: SAPAsset, target size: CGSize) -> SAPProgressiveItem? {
        return nil
    }
    
    private lazy var _allImageItems: Dictionary<String, WKDictionary<Int, SAPProgressiveItem>> = [:]
    private lazy var _loadQueue: DispatchQueue = DispatchQueue(label: "SAPhotoImageLoadQueue")
    
    
    private func _requestPlayerItem(_ photo: SAPAsset, _ options: PHVideoRequestOptions?, resultHandler: @escaping (AVPlayerItem?, [AnyHashable : Any]?) -> Void) {
        let im = PHCachingImageManager.default()
        im.requestPlayerItem(forVideo: photo.asset, options: options, resultHandler: resultHandler)
    }
    
    private func _requestImageData(_ photo: SAPAsset, _ options: PHImageRequestOptions?, resultHandler: @escaping (Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Void) {
        let im = PHCachingImageManager.default()
        im.requestImageData(for: photo.asset, options: options, resultHandler: resultHandler)
    }
    
//        // Asynchronous image preheating (aka caching), note that only image sources are cached (no crop or exact resize is ever done on them at the time of caching, only at the time of delivery when applicable).
//        // The options values shall exactly match the options values used in loading methods. If two or more caching requests are done on the see asset using different options or different targetSize the first
//        // caching request will have precedence (until it is stopped)
    public func startCachingImages(for assets: [SAPAsset], targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) {
        let im = PHCachingImageManager.default() as! PHCachingImageManager
        let ass = assets.map {
            return $0.asset
        }
        im.startCachingImages(for: ass, targetSize: targetSize, contentMode: contentMode, options: options)
    }
    public func stopCachingImages(for assets: [SAPAsset], targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) {
        let im = PHCachingImageManager.default() as! PHCachingImageManager
        let ass = assets.map {
            return $0.asset
        }
        im.stopCachingImages(for: ass, targetSize: targetSize, contentMode: contentMode, options: options)
    }
    public func stopCachingImagesForAllAssets() {
        let im = PHCachingImageManager.default() as! PHCachingImageManager
        im.stopCachingImagesForAllAssets()
    }
    
    //public static func cancelImageRequest(_ requestID: PHImageRequestID) { }
    
    public func requestAuthorization(clouser: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { permission in
            DispatchQueue.main.async {
                clouser(permission == .authorized)
            }
        }
    }
    
    public static var shared: SAPLibrary = {
        let lib = SAPLibrary()
        PHPhotoLibrary.shared().register(lib)
        return lib
    }()
    
    
    private lazy var _session: SAPImageSession = SAPImageSession()
    
    private var _needsClearCaches: Bool = false
    
    private lazy var _queue: DispatchQueue = DispatchQueue(label: "SAPhotoImageLoadQueue")
    private lazy var _allCaches: [String: [String: SAPWKObject<SAPProgressiveItem>]] = [:]
}

extension SAPLibrary: PHPhotoLibraryChangeObserver {
    // This callback is invoked on an arbitrary serial queue. If you need this to be handled on a specific queue, you should redispatch appropriately
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        // TODO: 合并请求减少计算量
    }
}

private func _SAPhotoResouceId(_ photo: SAPAsset, size: CGSize) -> UInt {
    guard size != SAPhotoMaximumSize else {
        return UInt.max
    }
    return UInt(size.width) / 16
}
private func _SAPhotoResouceSize(_ photo: SAPAsset, size: CGSize) -> CGSize {
    let id = _SAPhotoResouceId(photo, size: size)
//    guard id != .max else {
//        return SAPhotoMaximumSize
//    }
//    let ratio = CGFloat(photo.pixelWidth) / CGFloat(photo.pixelHeight)
//    let width = CGFloat(id + 1) * 16
//    let height = round(width / ratio)
    return size
    //return CGSize(width: width, height: height)
}

private var _SAPhotoQueueTasks: Array<() -> Void>?
private func _SAPhotoQueueTasksAdd(_ queue: DispatchQueue, task: @escaping () -> Void) {
    // 合并任务, 减少线程唤醒次数
    objc_sync_enter(SAPLibrary.self)
    
    var isstart = _SAPhotoQueueTasks != nil
    if _SAPhotoQueueTasks == nil {
        _SAPhotoQueueTasks = [task]
    } else {
        _SAPhotoQueueTasks?.append(task)
    }
    
    objc_sync_exit(SAPLibrary.self)
    
    guard !isstart else {
        return
    }
    // 开启线程
    queue.async {
        objc_sync_enter(SAPLibrary.self)
        let tasks = _SAPhotoQueueTasks
        _SAPhotoQueueTasks = nil
        objc_sync_exit(SAPLibrary.self)
        
        tasks?.forEach {
            $0()
        }
    }
}


private func _SAPhotoFormat(_ asset: PHAsset, _ targetSize: CGSize, _ contentMode: PHImageContentMode = .default) -> Int {
    guard targetSize.width != 0 && targetSize.height != 0 && asset.pixelWidth != 0 && asset.pixelHeight != 0 else {
        return 0
    }
    
    let w = CGFloat(asset.pixelWidth) 
    let h = CGFloat(asset.pixelHeight)
    
    let tmf: (CGFloat, CGFloat) -> CGFloat = (contentMode == .aspectFit) ? max : min
    let scale: CGFloat = tmf(targetSize.width / w, targetSize.height / h)
    
    return Int(w * scale)
}


public let SAPhotoMaximumSize = PHImageManagerMaximumSize

private let _SAPhotoMinimumThumbnailSize = CGSize(width: 240, height: 240)

