//
//  SIMChatPhotoAlbum.swift
//  SIMChat
//
//  Created by sagesse on 11/22/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary

///
/// 图集
///
public class SIMChatPhotoAlbum: NSObject {
    /// 初始化
    init(_ data: AnyObject) {
        self.data = data
        super.init()
    }

    /// 图集标题
    public var title: String? {
        if #available(iOS 9.0, *) {
            return self.collection.localizedTitle
        } else {
            return self.group.valueForProperty(ALAssetsGroupPropertyName) as? String
        }
    }
    /// 图片数量
    public var count: Int {
        if #available(iOS 9.0, *) {
            // 如果没有加载
            if !isLoaded && !isLoading {
                loadIfNeed(nil)
            }
            // 然后就ok了
            return self.assets.count
        } else {
            return self.group.numberOfAssets()
        }
    }
    
    ///
    /// 准备(预加载)
    ///
    public func prepare() {
    }
    
    // iOS 8.x and later
    @available(iOS, introduced=8.0) var collection: PHAssetCollection {
        return self.data as! PHAssetCollection
    }
    // iOS 6.x, iOS 7.x
    @available(iOS, introduced=4.0, deprecated=9.0) var group: ALAssetsGroup {
        return self.data as! ALAssetsGroup
    }
    
    public func asset(index: Int, complete: (SIMChatPhotoAsset? -> Void)?) {
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
        // 加载
        loadIfNeed(nil)
    }
    
    /// 加载
    public func loadIfNeed(complete: (Void -> Void)?) {
        objc_sync_enter(self)
        // 正在加载中?
        guard !isLoading && !isLoaded else {
            objc_sync_exit(self)
            // 直接完成
            complete?()
            return
        }
        // 如果没有加载, 请求加载
        self.isLoading = true
        self.isLoaded = false
        objc_sync_exit(self)
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
                let asset = self.assetMakeOrCache(sa)
                
                // 更新
                self.assets.append(asset)
                // 取出并清除正在等待的
                let queue = self.waitQueues[index]
                self.waitQueues.removeValueForKey(index)
                
                // 通知
                queue?.forEach { $0(asset) }
            }
            
            self.waitQueues.removeAll()
            self.isLoading = false
            self.isLoaded = true
            
            objc_sync_exit(self)
            
            // 完成
            complete?()
        } else {
            // 这是异步的
            self.group.enumerateAssetsUsingBlock { sa, index, stop in
                // 创建
                guard let sa = sa else {
                    // 清空
                    objc_sync_enter(self)
                    self.waitQueues.removeAll()
                    objc_sync_exit(self)
                    // 完成
                    complete?()
                    return
                }
                let asset = self.assetMakeOrCache(sa)
                
                // 加锁assets
                objc_sync_enter(self)
                
                // 更新
                self.assets.append(asset)
                // 取出并清除正在等待的
                let queue = self.waitQueues[index]
                self.waitQueues.removeValueForKey(index)
                
                self.isLoading = false
                self.isLoaded = true
                
                // 解锁必须的。。
                objc_sync_exit(self)
                
                // 通知
                queue?.forEach { $0(asset) }
            }
        }
    }
    
    /// 获取图片, 为了减少实例
    private func assetMakeOrCache(data: AnyObject) -> SIMChatPhotoAsset {
        let lib = SIMChatPhotoLibrary.sharedLibrary()
        let asset = SIMChatPhotoAsset(data)
        // 检查有没有缓存
        if let asset = lib.assetCahces[asset.identifier] as? SIMChatPhotoAsset {
            return asset
        }
        // 没有, 缓存起来
        lib.assetCahces[asset.identifier] = asset
        
        return asset
    }
    
    /// 内部数据
    private var data: AnyObject
    
    private lazy var assets = Array<SIMChatPhotoAsset>()
    private lazy var waitQueues = Dictionary<Int, [SIMChatPhotoAsset? -> Void]>()
    private dynamic var isLoaded = false
    private dynamic var isLoading = false
}

