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

    var cacheImage: UIImage?
    var cacheOriginalImage: UIImage?
    
    
    ///
    /// 获取原图
    /// - parameter block 结果
    ///
    public func original(block: UIImage? -> Void) {
    }
    ///
    /// 获取屏幕大小的图片
    /// - parameter block 结果
    ///
    public func fullscreen(block: UIImage? -> Void) {
        // 如果己经加载了
        if let img = self.cacheOriginalImage {
            block(img)
            return
        }
        
        let lib = SIMChatPhotoLibrary.sharedLibrary()
        
        if #available(iOS 9.0, *) {
            if let v = self.data as? PHAsset {
                let op = PHImageRequestOptions()
                let size = CGSizeMake(UIScreen.mainScreen().bounds.size, scale: UIScreen.mainScreen().scale)
                
                op.synchronous = false
                op.resizeMode = .Fast
                
                lib.manager.requestImageForAsset(v, targetSize: size, contentMode: .AspectFill, options: nil) { [weak self]img, info in
                    self?.cacheOriginalImage = img
                    block(img)
                }
            }
        } else {
            if let v = self.data as? ALAsset {
                let img = UIImage(CGImage: v.defaultRepresentation().fullResolutionImage().takeUnretainedValue())
                self.cacheOriginalImage = img
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
        // 如果己经加载了
        if let img = self.cacheImage {
            block(img)
            return
        }
        
        let lib = SIMChatPhotoLibrary.sharedLibrary()
        let size = CGSizeMake(targetSize, scale: UIScreen.mainScreen().scale)
        
        if #available(iOS 9.0, *) {
            if let v = self.data as? PHAsset {
                
                lib.manager.requestImageForAsset(v, targetSize: size, contentMode: .AspectFill, options: nil) { [weak self]img, info in
                    self?.cacheImage = img
                    block(img)
                }
            }
        } else {
            if let v = self.data as? ALAsset {
                let img = UIImage(CGImage: v.thumbnail().takeUnretainedValue())
                self.cacheImage = img
                block(img)
            }
        }
    }
    
    public func originalIsLoaded() -> Bool {
        return cacheOriginalImage != nil
    }
    public func thumbnailIsLoaded() -> Bool {
        return cacheImage != nil
    }
    public func fullscreenIsLoaded() -> Bool {
        return cacheOriginalImage != nil
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
    
    private var data: AnyObject
}

func CGSizeMake(size: CGSize, scale: CGFloat) -> CGSize {
    return CGSizeMake(size.width * scale, size.height * scale)
}

