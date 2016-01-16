//
//  SIMChatPhotoAsset.swift
//  SIMChat
//
//  Created by sagesse on 11/22/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary

///
/// 媒体类型
///
public enum SIMChatPhotoType : Int {
    case Unknown = 0
    case Image
    case Video
    case Audio
}

///
/// 图片
///
public class SIMChatPhotoAsset: NSObject {
    /// 初始化
    init(_ data: AnyObject) {
        self.data = data
        super.init()
    }

    ///
    /// 获取原图
    /// - parameter block 结果
    ///
    public func original(block: UIImage? -> Void) {
        block(nil)
    }
    ///
    /// 获取屏幕大小的图片
    /// - parameter block 结果
    ///
    public func fullscreen(block: UIImage? -> Void) {
        fullscreen(false, block: block)
    }
    ///
    /// 获取屏幕大小的图片
    /// - parameter synchronous 是否等待(true只有一次结果)
    /// - parameter block 结果
    ///
    public func fullscreen(synchronous: Bool, block: UIImage? -> Void) {
        // 如果己经加载了
        if let img = fullscreenCache {
            block(img)
            return
        }
        // 检查cache
        let lib = SIMChatPhotoLibrary.sharedLibrary()
        let imgKey = "\(identifier).fullscreen"
        if let img = lib.caches.objectForKey(imgKey) as? UIImage {
            // 预读
            fullscreenCache = img
            block(img)
            return
        }
        /// 开始加载
        if #available(iOS 9.0, *) {
            if let v = self.data as? PHAsset {
                let op = PHImageRequestOptions()
                let size = CGSizeMake(UIScreen.mainScreen().bounds.size, scale: UIScreen.mainScreen().scale)
                
                if synchronous {
                    op.deliveryMode = .HighQualityFormat
                }
                op.synchronous = synchronous
                op.resizeMode = .Fast
                
                lib.manager.requestImageForAsset(v, targetSize: size, contentMode: .AspectFill, options: op) { [weak self]img, info in
                    if let img = img {
                        // 加载成功, 计算价值
                        let cost = Int(img.size.width * img.size.height)
                        // 缓存
                        lib.caches.setObject(img, forKey: imgKey, cost: cost)
                    }
                    self?.fullscreenCache = img
                    block(img)
                }
            }
        } else {
            if let v = self.data as? ALAsset {
                let img = UIImage(CGImage: v.defaultRepresentation().fullResolutionImage().takeUnretainedValue())
                // 加载成功, 计算价值
                let cost = Int(img.size.width * img.size.height)
                // 缓存
                lib.caches.setObject(img, forKey: imgKey, cost: cost)
                self.fullscreenCache = img
                block(img)
            }
        }
    }
    ///
    /// 获取缩略图
    /// - parameter targetSize 目标
    /// - parameter block 结果
    ///
    public func thumbnail(targetSize: CGSize, block: UIImage? -> Void) {
        // 如果己经预读了
        if let img = thumbnailCache {
            block(img)
            return
        }
        // 检查cache
        let lib = SIMChatPhotoLibrary.sharedLibrary()
        let imgKey = "\(identifier).thumbnail"
        if let img = lib.caches.objectForKey(imgKey) as? UIImage {
            // 预读
            thumbnailCache = img
            block(img)
            return
        }
        /// 开始加载
        if #available(iOS 9.0, *) {
            if let v = self.data as? PHAsset {
                let size = CGSizeMake(targetSize, scale: UIScreen.mainScreen().scale)
                lib.manager.requestImageForAsset(v, targetSize: size, contentMode: .AspectFill, options: nil) { [weak self]img, info in
                    if let img = img {
                        // 加载成功, 计算价值
                        let cost = Int(img.size.width * img.size.height)
                        // 缓存
                        lib.caches.setObject(img, forKey: imgKey, cost: cost)
                    }
                    self?.thumbnailCache = img
                    block(img)
                }
            }
        } else {
            if let v = self.data as? ALAsset {
                let img = UIImage(CGImage: v.thumbnail().takeUnretainedValue())
                // 加载成功, 计算价值
                let cost = Int(img.size.width * img.size.height)
                // 缓存
                lib.caches.setObject(img, forKey: imgKey, cost: cost)
                self.thumbnailCache = img
                block(img)
            }
        }
    }
    
    public func originalIsLoaded() -> Bool {
        return originalCache != nil
    }
    public func thumbnailIsLoaded() -> Bool {
        return thumbnailCache != nil
    }
    public func fullscreenIsLoaded() -> Bool {
        return fullscreenCache != nil
    }
    
    // 媒体类型
    public var mediaType: SIMChatPhotoType {
        if #available(iOS 9.0, *) {
            if let v = self.data as? PHAsset {
                switch v.mediaType {
                case .Unknown:  return .Unknown
                case .Image:    return .Image
                case .Video:    return .Video
                case .Audio:    return .Audio
                }
            }
        }
        return .Unknown
    }
    
    /// 媒体持续时间, 针对Video/Audio
    public var mediaDuration: NSTimeInterval {
        if #available(iOS 9.0, *) {
            if let v = self.data as? PHAsset {
                return v.duration
            }
        }
        return 0
    }
    
    /// 比较
    public override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? SIMChatPhotoAsset {
            return object.identifier == identifier
        }
        return super.isEqual(object)
    }
    
    /// 提供一个唯一标识, 用于NSSet
    public private(set) lazy var identifier: String = {
        if #available(iOS 9.0, *) {
            if let v = self.data as? PHAsset {
                return v.localIdentifier
            }
        } else {
            if let v = self.data as? ALAsset {
                if let url = v.valueForProperty(ALAssetPropertyAssetURL) as? NSURL {
                    return url.absoluteString
                }
            }
        }
        return NSUUID().UUIDString
    }()
    
    public override var hash: Int { return identifier.hashValue }
    public override var hashValue: Int { return identifier.hashValue }
    
    // 缓存的图片(使用这个是因为如果NSCache只清除了这个元素, 但这个元素正在使用, 这就不需要重新加载了)
    private weak var originalCache: UIImage?
    private weak var thumbnailCache: UIImage?
    private weak var fullscreenCache: UIImage?
    
    private var data: AnyObject
}

func CGSizeMake(size: CGSize, scale: CGFloat) -> CGSize {
    return CGSizeMake(size.width * scale, size.height * scale)
}

