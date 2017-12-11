//
//  SIMChatPhotoPicker.swift
//  SIMChat
//
//  Created by sagesse on 11/22/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

// TODO: 还要预加载没有优化
// TODO: 系统图片加载有问题
// TODO: 显示大图有内存泄露

import UIKit

///
/// 图片选择(多选, 代理)
///
@objc public protocol SIMChatPhotoPickerDelegate : NSObjectProtocol {
    
    ///
    /// 是否取消选择
    ///
    @objc optional func pickerShouldCancel(_ picker: SIMChatPhotoPicker) -> Bool
    ///
    /// 取消选择
    ///
    @objc optional func pickerDidCancel(_ picker: SIMChatPhotoPicker)
    
    ///
    /// 是否选择完成
    ///
    @objc optional func picker(_ picker: SIMChatPhotoPicker, shouldFinishPickingAssets assets: [SIMChatPhotoAsset]) -> Bool
    ///
    /// 选择完成
    ///
    @objc optional func picker(_ picker: SIMChatPhotoPicker, didFinishPickingAssets assets: [SIMChatPhotoAsset])
    
    ///
    /// 是否允许选择图像
    ///
    @objc optional func picker(_ picker: SIMChatPhotoPicker, canSelectAsset asset: SIMChatPhotoAsset) -> Bool
    ///
    /// 是否允许选择图像
    ///
    @objc optional func picker(_ picker: SIMChatPhotoPicker, shouldSelectAsset asset: SIMChatPhotoAsset) -> Bool
    ///
    /// 选择图像
    ///
    @objc optional func picker(_ picker: SIMChatPhotoPicker, didSelectAsset asset: SIMChatPhotoAsset)
    ///
    /// 取消选择
    ///
    @objc optional func picker(_ picker: SIMChatPhotoPicker, didDeselectAsset asset: SIMChatPhotoAsset)
}

///
/// 图片选择(多选)
///
public class SIMChatPhotoPicker: UINavigationController {
    
    ///
    /// 是否允许多选
    ///
    public var allowsMultipleSelection = true
    ///
    /// 最小选择数量, 默认为0,
    /// 如果为0, 不限制
    ///
    public var minimumNumberOfSelection = 0
    ///
    /// 最大选择数量, 默认为0,
    /// 如果为0, 不限制
    ///
    public var maximumNumberOfSelection = 0
    ///
    /// 是否要示使用原图
    ///
    public var requireOrigin = false
    ///
    /// 选择的图片
    ///
    public var selectedItems = NSMutableOrderedSet()
    
    /// 初始化
    convenience init(){
        self.init(nibName: nil, bundle: nil)
    }
    /// 初始化
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
    
    public override func viewWillAppear(_ animated: Bool) {
        SIMLog.trace()
        super.viewWillAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        SIMLog.trace()
        super.viewWillDisappear(animated)
        
    }
    
    ///
    /// 代理(因为原来有一个delegate, 暂时没有找到很好的解决方法)
    ///
   public weak var delegate2: SIMChatPhotoPickerDelegate?
    
    // 根控制器
    private var rootViewController: SIMChatPhotoPickerAlbums!
}

// MARK: - Select Event
extension SIMChatPhotoPicker {
    
    /// 选择图片
    internal func selectItem(_ asset: SIMChatPhotoAsset?) -> Bool {
        guard let asset = asset else {
            return false
        }
        SIMLog.trace(asset.identifier)
        // 检查是否允许选择
        guard delegate2?.picker?(self, shouldSelectAsset: asset) ?? true else {
            return false
        }
        let count = selectedItems.count
        selectedItems.add(asset)
        // 检查数量是否有改变
        if count != selectedItems.count {
            // 减少调用数量
            
            type(of: self).cancelPreviousPerformRequests(withTarget: self, selector: #selector(countDidChanged(_:)), object: self)
            self.perform(#selector(countDidChanged(_:)), with: self, afterDelay: 0.1)
        }
        // 通知
        delegate2?.picker?(self, didSelectAsset: asset)
        // 成功
        return true
    }
    
    /// 取消选择
    internal func deselectItem(_ asset: SIMChatPhotoAsset?) {
        guard let asset = asset else {
            return
        }
        SIMLog.trace(asset.identifier)
        
        let count = selectedItems.count
        selectedItems.remove(asset)
        // 检查数量是否有改变
        if count != selectedItems.count {
            // 减少调用数量
            type(of: self).cancelPreviousPerformRequests(withTarget: self, selector: #selector(type(of: self).countDidChanged(_:)), object: self)
            self.perform(#selector(type(of: self).countDidChanged(_:)), with: self, afterDelay: 0.01)
        }
        // 通知
        delegate2?.picker?(self, didDeselectAsset: asset)
    }
    
    /// 检查是否可以选择图片
    internal func canSelectItem(_ asset: SIMChatPhotoAsset?) -> Bool {
        guard let asset = asset else {
            return false
        }
        // 检查
        return delegate2?.picker?(self, canSelectAsset: asset) ?? true
    }
    
    /// 检查是否是选择
    internal func checkItem(_ asset: SIMChatPhotoAsset?) -> Bool {
        guard let asset = asset else {
            return false
        }
        return selectedItems.contains(asset)
    }
    
    /// 数量改变
    private dynamic func countDidChanged(_ sender: AnyObject) {
        let count = selectedItems.count
        SIMLog.trace("\(count)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: SIMChatPhotoPickerCountDidChangedNotification), object: count)
    }
    
    ///
    /// 取消
    ///
    public func cancel() {
        SIMLog.trace()
        if delegate2?.pickerShouldCancel?(self) ?? true {
            dismiss(animated: true, completion: nil)
            delegate2?.pickerDidCancel?(self)
        }
    }
    
    ///
    /// 确认
    ///
    public func confirm() {
        guard let rs = selectedItems.array as? [SIMChatPhotoAsset] else {
            return
        }
        SIMLog.trace()
        if delegate2?.picker?(self, shouldFinishPickingAssets: rs) ?? true {
            // 必须选回调, 再消失
            delegate2?.picker?(self, didFinishPickingAssets: rs)
            dismiss(animated: true, completion: nil)
        }
    }
}

// 通知
public let SIMChatPhotoPickerCountDidChangedNotification = "SIMChatPhotoPickerCountDidChangedNotification"
