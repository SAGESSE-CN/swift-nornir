//
//  SIMChatImagePickerController.swift
//  SIMChat
//
//  Created by sagesse on 11/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

import Photos
import AssetsLibrary

/// 图片
class SIMChatImageAsset : NSObject {
    /// 初始化
    init(_ data: AnyObject) {
        self.data = data
        super.init()
    }

    var cacheImage: UIImage?
    
    func s(handler: (UIImage? -> Void)?) {
        // 如果己经加载了
        if let img = self.cacheImage {
            handler?(img)
            return
        }
        if #available(iOS 9.0, *) {
            
            if let v = self.data as? PHAsset {
                SIMChatImageLibrary.sharedLibrary().manager.requestImageForAsset(v, targetSize: CGSizeMake(70 * 2, 70 * 2), contentMode: .AspectFill, options: nil) { [weak self]img, info in
                    self?.cacheImage = img
                    handler?(img)
                }
            }
        } else {
            if let v = self.data as? ALAsset {
                let img = UIImage(CGImage: v.thumbnail().takeUnretainedValue())
                self.cacheImage = img
                handler?(img)
            }
        }
    }
    
    private var data: AnyObject
}
/// 图片图集
class SIMChatImageAlbum : NSObject {
    /// 初始化
    init(_ data: AnyObject) {
        self.data = data
        super.init()
    }

    /// 图集标题
    var title: String? {
        if #available(iOS 9.0, *) {
            return self.collection.localizedTitle
        } else {
            return self.group.valueForProperty(ALAssetsGroupPropertyName) as? String
        }
    }
    /// 图片数量
    var count: Int {
        if #available(iOS 9.0, *) {
            // 如果没有加载, 请求第一张.
            if !self.isLoading {
                self.asset(0, complete: nil)
            }
            // 然后就ok了
            return self.assets.count
        } else {
            return self.group.numberOfAssets()
        }
    }
    
    // iOS 8.x and later
    @available(iOS, introduced=8.0) var collection: PHAssetCollection {
        return self.data as! PHAssetCollection
    }
    // iOS 6.x, iOS 7.x
    @available(iOS, introduced=4.0, deprecated=9.0) var group: ALAssetsGroup {
        return self.data as! ALAssetsGroup
    }
    
    func asset(index: Int, complete: (SIMChatImageAsset? -> Void)?) {
        // 加锁， 防止修改assets
        objc_sync_enter(self)
        // 如果己经存在，直接回调
        if index < self.assets.count {
            let asset = self.assets[index]
            
            // 必须要先取出来再解锁
            objc_sync_exit(self)
            
            return complete?(asset) ?? Void()
        }
        // 添加到等待队列
        if let complete = complete {
            if self.waitQueues[index] == nil {
                self.waitQueues[index] = [complete]
            } else {
                self.waitQueues[index]?.append(complete)
            }
        }
        // 解锁必须的。。
        objc_sync_exit(self)
        
        // 正在加载中?
        guard !self.isLoading else {
            return
        }
        // 如果没有加载, 请求加载
        self.isLoading = true
        
        // iOS 8.x是同步的, iOS 7.x是异步的
        if #available(iOS 9.0, *) {
            // 查询图片
            let op = PHFetchOptions()
            op.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let assets = PHAsset.fetchAssetsInAssetCollection(self.collection, options: op)
            
            // 加锁assets
            objc_sync_enter(self)
            
            // 处理
            for index in 0 ..< assets.count {
                // 创建
                let sa = assets[index] as! PHAsset
                let asset = SIMChatImageAsset(sa)
                
                // 更新
                self.assets.append(asset)
                // 取出并清除正在等待的
                let queue = self.waitQueues[index]
                self.waitQueues.removeValueForKey(index)
                
                // 通知
                queue?.forEach { $0(asset) }
            }
            
            self.waitQueues.removeAll()
            
            objc_sync_exit(self)
        } else {
            // 这是异步的
            self.group.enumerateAssetsUsingBlock { sa, index, stop in
                // 创建
                guard let sa = sa else {
                    // 清空
                    objc_sync_enter(self)
                    self.waitQueues.removeAll()
                    objc_sync_exit(self)
                    return
                }
                let asset = SIMChatImageAsset(sa)
                
                // 加锁assets
                objc_sync_enter(self)
                
                // 更新
                self.assets.append(asset)
                // 取出并清除正在等待的
                let queue = self.waitQueues[index]
                self.waitQueues.removeValueForKey(index)
                
                // 解锁必须的。。
                objc_sync_exit(self)
                
                // 通知
                queue?.forEach { $0(asset) }
            }
        }
    }
    
    /// 内部数据
    private var data: AnyObject
    
    private lazy var assets = Array<SIMChatImageAsset>()
    private lazy var isLoading = false
    private lazy var waitQueues = Dictionary<Int, [SIMChatImageAsset? -> Void]>()
    
}
/// 图片库
class SIMChatImageLibrary : NSObject {
    
    ///
    /// 获取图集
    ///
    func albums(finish: ([SIMChatImageAlbum]? -> Void)?) {
        
        var rs: [SIMChatImageAlbum] = []
        
        // iOS 8.x 是同步获取的
        if #available(iOS 9.0, *) {
            
            let r1 = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .Any, options: nil)
            let r2 = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: nil)
            
            for i in 0 ..< r1.count {
                if let v = r1[i] as? PHAssetCollection {
                    rs.append(SIMChatImageAlbum(v))
                }
            }
            for i in 0 ..< r2.count {
                if let v = r2[i] as? PHAssetCollection {
                    rs.append(SIMChatImageAlbum(v))
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
                
                rs.append(SIMChatImageAlbum(group))
                
                // 完成?
            }, failureBlock: { error in
                finish?(nil)
            })
        }
    }
    
    ///
    /// 单例
    ///
    class func sharedLibrary() -> SIMChatImageLibrary {
        return self.sharedInstance
    }
    
    lazy var caches = NSCache()
    //lazy var
    
    @available(iOS, introduced=8.0) lazy var manager = PHImageManager()
    @available(iOS, introduced=4.0, deprecated=9.0) lazy var library = ALAssetsLibrary()
    
    private static var sharedInstance = SIMChatImageLibrary()
}


///
/// 图片选择(多选)
///
class SIMChatImagePickerController: UINavigationController {
    
    /// 初始化
    convenience init(){
        self.init(nibName: nil, bundle: nil)
    }
    /// 初始化
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.rootViewController = SIMChatImageAlbumsViewController()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        // 可能需要直接转到指定页面
        self.viewControllers = [self.rootViewController]
    }
    /// 反序列化
    required init?(coder aDecoder: NSCoder) {
        self.rootViewController = SIMChatImageAlbumsViewController()
        super.init(coder: aDecoder)
        
        // 可能需要直接转到指定页面
        self.viewControllers = [self.rootViewController]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(rootViewController != nil, "root must created!")
    }
    
    private var rootViewController: SIMChatImageAlbumsViewController!
}

