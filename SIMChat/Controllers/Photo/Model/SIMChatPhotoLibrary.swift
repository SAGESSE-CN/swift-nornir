//
//  SIMChatPhotoLibrary.swift
//  SIMChat
//
//  Created by sagesse on 11/22/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary

///
/// 图库
///
public class SIMChatPhotoLibrary: NSObject {
    /// 初始化
    override init() {
        super.init()
        
        // 添加监听
        if #available(iOS 9.0, *) {
            PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        } else {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "assetsLibraryDidChange:", name: ALAssetsLibraryChangedNotification, object: nil)
        //PHPhotoLibraryChangeObserver
        //            // Register observer
        //            [[NSNotificationCenter defaultCenter] addObserver:self
        //                selector:@selector(assetsLibraryChanged:)
        //            name:ALAssetsLibraryChangedNotification
        //            object:nil];
        //        
        //        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        
        }
        
        caches.evictsObjectsWithDiscardedContent = true
    }
    
    ///
    /// 获取图集
    ///
    func albums(finish: ([SIMChatPhotoAlbum]? -> Void)?) {
        
        var rs: [SIMChatPhotoAlbum] = []
        
        // iOS 8.x 是同步获取的
        if #available(iOS 9.0, *) {
            
            let r1 = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .Any, options: nil)
            let r2 = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: nil)
            
            for i in 0 ..< r1.count {
                if let v = r1[i] as? PHAssetCollection {
                    rs.append(SIMChatPhotoAlbum(v))
                }
            }
            for i in 0 ..< r2.count {
                if let v = r2[i] as? PHAssetCollection {
                    rs.append(SIMChatPhotoAlbum(v))
                }
            }
            
            finish?(rs)
            
        } else {
            // 遍历， 这是异步的
            library.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: { group, stop in
                // ok
                guard let group = group else {
                    // 完成?
                    finish?(rs)
                    return
                }
                
                group.setAssetsFilter(ALAssetsFilter.allAssets())
                
                rs.append(SIMChatPhotoAlbum(group))
                
                // 完成?
            }, failureBlock: { error in
                finish?(nil)
            })
        }
    }
    
    ///
    /// 单例
    ///
    class func sharedLibrary() -> SIMChatPhotoLibrary {
        return self.sharedInstance
    }
    
    private(set) lazy var caches = NSCache()
    private(set) lazy var assetCahces = NSMutableDictionary()
    
    let selectImage =  UIImage(named: "image_select")
    let deselectImage =  UIImage(named: "image_deselect")
    
    
    @available(iOS, introduced=8.0) lazy var manager = PHImageManager()
    @available(iOS, introduced=4.0, deprecated=9.0) lazy var library = ALAssetsLibrary()
    
    private static var sharedInstance = SIMChatPhotoLibrary()
}

// MARK: - PHPhotoLibraryChangeObserver & ALAssetsLibraryChangedNotification
extension SIMChatPhotoLibrary : PHPhotoLibraryChangeObserver {
    
    /// 图片改变
    public func assetsLibraryDidChange(sender: NSNotification) {
        SIMLog.trace(sender)
        NSNotificationCenter.defaultCenter().postNotificationName(SIMChatPhotoLibraryDidChangedNotification, object: self)
    }
    
    /// 图片改变
    @available(iOS 8.0, *)
    public func photoLibraryDidChange(changeInstance: PHChange) {
        SIMLog.trace(changeInstance)
        NSNotificationCenter.defaultCenter().postNotificationName(SIMChatPhotoLibraryDidChangedNotification, object: self)
    }
}

// 通知
public let SIMChatPhotoLibraryDidChangedNotification = "SIMChatPhotoLibraryDidChangedNotification"