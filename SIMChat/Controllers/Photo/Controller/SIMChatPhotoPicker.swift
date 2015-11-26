//
//  SIMChatPhotoPicker.swift
//  SIMChat
//
//  Created by sagesse on 11/22/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 图片选择(多选)
///
public class SIMChatPhotoPicker: UINavigationController {
    
    /// 初始化
    convenience init(){
        self.init(nibName: nil, bundle: nil)
    }
    /// 初始化
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.rootViewController = SIMChatPhotoPickerAlbums(self)
        // 可能需要直接转到指定页面
        self.viewControllers = [self.rootViewController]
    }
    /// 反序列化
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.rootViewController = SIMChatPhotoPickerAlbums(self)
        // 可能需要直接转到指定页面
        self.viewControllers = [self.rootViewController]
    }
    /// 释放
    deinit {
        autoreleasepool {
            let lib = SIMChatPhotoLibrary.sharedLibrary()
            // 清除所有缓存
            lib.assetCahces.removeAllObjects()
            lib.caches.removeAllObjects()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        assert(rootViewController != nil, "root must created!")
    }
    
    public override func viewWillAppear(animated: Bool) {
        SIMLog.trace()
        super.viewWillAppear(animated)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        SIMLog.trace()
        super.viewWillDisappear(animated)
    }
    
    /// 只读, NSMutableOrderedSet<SIMChatPhotoAsset>
    private(set) var selectedItems = NSMutableOrderedSet()
    
    // 根控制器
    private var rootViewController: SIMChatPhotoPickerAlbums!
}

// MARK: - Select Event
extension SIMChatPhotoPicker {
   
    /// 选择图片
    public func selectItem(asset: SIMChatPhotoAsset?) {
        guard let asset = asset else {
            return
        }
        SIMLog.trace(asset.identifier)
        
        let count = selectedItems.count
        selectedItems.addObject(asset)
        // 检查数量是否有改变
        if count != selectedItems.count {
            // 减少调用数量
            self.dynamicType.cancelPreviousPerformRequestsWithTarget(self, selector: "countDidChanged:", object: self)
            self.performSelector("countDidChanged:", withObject: self, afterDelay: 0.1)
        }
    }
    
    /// 取消选择
    public func deselectItem(asset: SIMChatPhotoAsset?) {
        guard let asset = asset else {
            return
        }
        SIMLog.trace(asset.identifier)
        let count = selectedItems.count
        selectedItems.removeObject(asset)
        // 检查数量是否有改变
        if count != selectedItems.count {
            // 减少调用数量
            self.dynamicType.cancelPreviousPerformRequestsWithTarget(self, selector: "countDidChanged:", object: self)
            self.performSelector("countDidChanged:", withObject: self, afterDelay: 0.01)
        }
    }
    
    /// 检查是否是选择
    public func checkItem(asset: SIMChatPhotoAsset?) -> Bool {
        guard let asset = asset else {
            return false
        }
        return selectedItems.containsObject(asset)
    }
    
    /// 数量改变
    private dynamic func countDidChanged(sender: AnyObject) {
        let count = selectedItems.count
        SIMLog.trace("\(count)")
        NSNotificationCenter.defaultCenter().postNotificationName(SIMChatPhotoPickerCountDidChangedNotification, object: count)
    }
}

// 通知
public let SIMChatPhotoPickerCountDidChangedNotification = "SIMChatPhotoPickerCountDidChangedNotification"