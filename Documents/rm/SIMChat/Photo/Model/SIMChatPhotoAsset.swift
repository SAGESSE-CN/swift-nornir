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
    case unknown = 0
    case image
    case video
    case audio
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
    public func original(_ block: (UIImage?) -> Void) {
        block(nil)
    }
    ///
    /// 获取屏幕大小的图片
    /// - parameter block 结果
    ///
    public func fullscreen(_ block: @escaping (UIImage?) -> Void) {
        fullscreen(false, block: block)
    }
    ///
    /// 获取屏幕大小的图片
    /// - parameter synchronous 是否等待(true只有一次结果)
    /// - parameter block 结果
    ///
    public func fullscreen(_ synchronous: Bool, block: @escaping (UIImage?) -> Void) {
        // 如果己经加载了
        if let img = fullscreenCache {
            block(img)
            return
        }
        // 检查cache
        let lib = SIMChatPhotoLibrary.sharedLibrary()
        let imgKey = "\(identifier).fullscreen"
        if let img = lib.caches.object(forKey: imgKey) as? UIImage {
            // 预读
            fullscreenCache = img
            block(img)
            return
        }
        /// 开始加载
        if #available(iOS 9.0, *) {
            if let v = self.data as? PHAsset {
                let op = PHImageRequestOptions()
                let size = CGSizeMake(UIScreen.main.bounds.size, scale: UIScreen.main.scale)
                
                if synchronous {
                    op.deliveryMode = .highQualityFormat
                }
                op.isSynchronous = synchronous
                op.resizeMode = .fast
                
                lib.manager.requestImage(for: v, targetSize: size, contentMode: .aspectFill, options: op) { [weak self]img, info in
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
                let img = UIImage(cgImage: v.defaultRepresentation().fullResolutionImage().takeUnretainedValue())
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
    public func thumbnail(_ targetSize: CGSize, block: @escaping (UIImage?) -> Void) {
        // 如果己经预读了
        if let img = thumbnailCache {
            block(img)
            return
        }
        // 检查cache
        let lib = SIMChatPhotoLibrary.sharedLibrary()
        let imgKey = "\(identifier).thumbnail"
        if let img = lib.caches.object(forKey: imgKey) as? UIImage {
            // 预读
            thumbnailCache = img
            block(img)
            return
        }
        /// 开始加载
        if #available(iOS 9.0, *) {
            if let v = self.data as? PHAsset {
                let size = CGSizeMake(targetSize, scale: UIScreen.main.scale)
                lib.manager.requestImage(for: v, targetSize: size, contentMode: .aspectFill, options: nil) { [weak self]img, info in
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
                let img = UIImage(cgImage: v.thumbnail().takeUnretainedValue())
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
                case .unknown:  return .unknown
                case .image:    return .image
                case .video:    return .video
                case .audio:    return .audio
                }
            }
        }
        return .unknown
    }
    
    /// 媒体持续时间, 针对Video/Audio
    public var mediaDuration: TimeInterval {
        if #available(iOS 9.0, *) {
            if let v = self.data as? PHAsset {
                return v.duration
            }
        }
        return 0
    }
    
            // TODO: no imp
//    /// 比较
//    public override func isEqual(_ object: AnyObject?) -> Bool {
//        if let object = object as? SIMChatPhotoAsset {
//            return object.identifier == identifier
//        }
//        return super.isEqual(object)
//    }
    
    /// 提供一个唯一标识, 用于NSSet
    public private(set) lazy var identifier: String = {
        if #available(iOS 9.0, *) {
            if let v = self.data as? PHAsset {
                return v.localIdentifier
            }
        } else {
            if let v = self.data as? ALAsset {
                if let url = v.value(forProperty: ALAssetPropertyAssetURL) as? URL {
                    return url.absoluteString
                }
            }
        }
        return UUID().uuidString
    }()
    
    public override var hash: Int { return identifier.hashValue }
    public override var hashValue: Int { return identifier.hashValue }
    
    // 缓存的图片(使用这个是因为如果NSCache只清除了这个元素, 但这个元素正在使用, 这就不需要重新加载了)
    private weak var originalCache: UIImage?
    private weak var thumbnailCache: UIImage?
    private weak var fullscreenCache: UIImage?
    
    private var data: AnyObject
}

func CGSizeMake(_ size: CGSize, scale: CGFloat) -> CGSize {
    return CGSize(width: size.width * scale, height: size.height * scale)
}

