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
        selectedItems.addObject(asset)
    }
    
    /// 取消选择
    public func deselectItem(asset: SIMChatPhotoAsset?) {
        guard let asset = asset else {
            return
        }
        SIMLog.trace(asset.identifier)
        selectedItems.removeObject(asset)
    }
    
    /// 检查是否是选择
    public func checkItem(asset: SIMChatPhotoAsset?) -> Bool {
        guard let asset = asset else {
            return false
        }
        return selectedItems.containsObject(asset)
    }
}

