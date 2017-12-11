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
            PHPhotoLibrary.shared().register(self)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(type(of: self).assetsLibraryDidChange(_:)), name: NSNotification.Name.ALAssetsLibraryChanged, object: nil)
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
    func albums(_ finish: (([SIMChatPhotoAlbum]?) -> Void)?) {
        // iOS 8.x 是同步获取的
        // TODO: no imp
//        if #available(iOS 9.0, *) {
//            // 遍历， 这是异步的
//            DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes(rawValue: UInt64(0))).async {
//                
//                var rs1: [SIMChatPhotoAlbum] = []
//                var rs2: [SIMChatPhotoAlbum] = []
//                
//                let c1 = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
//                for i in 0 ..< c1.count {
//                    if let v = c1[i] as? PHAssetCollection {
//                        let album = SIMChatPhotoAlbum(v)
//                        if album.count > 0 {
//                            rs1.append(album)
//                        }
//                    }
//                }
//                
//                let c2 = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
//                for i in 0 ..< c2.count {
//                    if let v = c2[i] as? PHAssetCollection {
//                        let album = SIMChatPhotoAlbum(v)
//                        if album.count > 0 {
//                            rs2.append(album)
//                        }
//                    }
//                }
//                
//                SIMLog.trace("finish")
//                // 合并
//                rs1.append(contentsOf: rs2)
//                finish?(rs1)
//            }
//        } else {
//            var rs: [SIMChatPhotoAlbum] = []
//            // 遍历， 这是异步的
//            library.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: { group, stop in
//                // ok
//                guard let group = group else {
//                    // 完成?
//                    finish?(rs)
//                    return
//                }
//                
//                group.setAssetsFilter(ALAssetsFilter.allAssets())
//                
//                rs.append(SIMChatPhotoAlbum(group))
//                
//                // 完成?
//            }, failureBlock: { error in
//                finish?(nil)
//            })
//        }
    }
    
    ///
    /// 单例
    ///
    class func sharedLibrary() -> SIMChatPhotoLibrary {
        return self.sharedInstance
    }
    
    private(set) lazy var caches = NSCache<AnyObject, AnyObject>()
    private(set) lazy var assetCahces = NSMutableDictionary()
    
    @available(iOS, introduced: 8.0) lazy var manager = PHImageManager()
    @available(iOS, introduced: 4.0, deprecated: 9.0) lazy var library = ALAssetsLibrary()
    
    
    private static var sharedInstance = SIMChatPhotoLibrary()
    
    public struct Images {
        static let markSelect = UIImage(named: "photo_picker_mark_select")?.withRenderingMode(.alwaysTemplate)
        static let markDeselect = UIImage(named: "photo_picker_mark_deselect")?.withRenderingMode(.alwaysTemplate)
        static let markSelectSmall = UIImage(named: "photo_picker_mark_select_sm")?.withRenderingMode(.alwaysTemplate)
        static let markDeselectSmall = UIImage(named: "photo_picker_mark_null_sm")?.withRenderingMode(.alwaysTemplate)
        static let iconVideo = UIImage(named: "photo_picker_icon_video")
        static let iconPhone = UIImage(named: "photo_picker_icon_phone")
    }
}

// MARK: - PHPhotoLibraryChangeObserver & ALAssetsLibraryChangedNotification
extension SIMChatPhotoLibrary : PHPhotoLibraryChangeObserver {
    
    /// 图片改变
    public func assetsLibraryDidChange(_ sender: Notification) {
        SIMLog.trace(sender)
        NotificationCenter.default.post(name: Notification.Name(rawValue: SIMChatPhotoLibraryDidChangedNotification), object: self)
    }
    
    /// 图片改变
    @available(iOS 8.0, *)
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        SIMLog.trace(changeInstance)
        NotificationCenter.default.post(name: Notification.Name(rawValue: SIMChatPhotoLibraryDidChangedNotification), object: self)
    }
}

// 通知
public let SIMChatPhotoLibraryDidChangedNotification = "SIMChatPhotoLibraryDidChangedNotification"
