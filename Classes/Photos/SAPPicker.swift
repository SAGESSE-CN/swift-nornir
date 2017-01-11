//
//  SAPPicker.swift
//  SAC
//
//  Created by SAGESSE on 9/21/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos

///
/// 图片选择器预览选项
///
@objc public class SAPPickerOptions: NSObject {
    
    public init(album: SAPAlbum, default: SAPAsset? = nil, ascending: Bool = true) {
        super.init()
        self.ascending = ascending
        self.`default` = `default`
        self.album = album
    }
    public init(photos: Array<SAPAsset>, default: SAPAsset? = nil, ascending: Bool = true) {
        super.init()
        self.ascending = ascending
        self.`default` = `default`
        self.photos = photos
    }
    
    public var `default`: SAPAsset?
    public var ascending: Bool = true
    
    public var album: SAPAlbum?
    public var photos: Array<SAPAsset>?
    
    public weak var previewingDelegate: SAPPreviewableDelegate?
}

///
/// 图片选择器代理
///
@objc public protocol SAPPickerDelegate: NSObjectProtocol {
    
    
    // data bytes lenght change
    @objc optional func picker(_ picker: SAPPicker, didChangeBytes bytes: Int)
    
    // check whether item can select
    @objc optional func picker(_ picker: SAPPicker, shouldSelectItemFor photo: SAPAsset) -> Bool
    @objc optional func picker(_ picker: SAPPicker, didSelectItemFor photo: SAPAsset)
    
    // check whether item can deselect
    @objc optional func picker(_ picker: SAPPicker, shouldDeselectItemFor photo: SAPAsset) -> Bool
    @objc optional func picker(_ picker: SAPPicker, didDeselectItemFor photo: SAPAsset)
    
    @objc optional func picker(_ picker: SAPPicker, canConfrim photos: Array<SAPAsset>) -> Bool
    
    @objc optional func picker(_ picker: SAPPicker, confrim photos: Array<SAPAsset>)
    @objc optional func picker(_ picker: SAPPicker, cancel photos: Array<SAPAsset>)
    
    // tap item
    @objc optional func picker(_ picker: SAPPicker, tapItemFor photo: SAPAsset, with sender: Any)
    
    // dispaly
    @objc optional func picker(_ picker: SAPPicker, willShow animated: Bool)
    @objc optional func picker(_ picker: SAPPicker, willDismiss animated: Bool)
    @objc optional func picker(_ picker: SAPPicker, didShow animated: Bool)
    @objc optional func picker(_ picker: SAPPicker, didDismiss animated: Bool)
    
}


///
/// 图片选择器
///
@objc public class SAPPicker: UIViewController {
    
    ///
    /// 创建一个图片选择器, 默认显示第一个相册
    ///
    public dynamic init() {
        fatalError()
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    ///
    /// 创建一个图片选择器, 并显示指定的相册
    ///
    /// NOTE: 和pick(with:)不同的时, 点击返回将dismiss
    ///
    public dynamic convenience init(pick album: SAPAlbum) {
        fatalError()
    }
    ///
    /// 创建一个图片选择器(预览)
    ///
    /// NOTE: 和preview(with:)不同的时, 点击返回将dismiss
    ///
    public dynamic convenience init(preview options: SAPPickerOptions) {
        fatalError()
    }
    
    /// 是否允许编辑图片, 默认值为false
    public dynamic var allowsEditing: Bool
    /// 是否允许多选, 默认值为true
    public dynamic var allowsMultipleSelection: Bool
    
    /// 选中的图片
    public dynamic var selectedPhotos: Array<SAPAsset>
    /// 是否使用原图, 默认值为false
    public dynamic var alwaysSelectOriginal: Bool
    
    /// 选择器的代理
    public dynamic weak var delegate: SAPPickerDelegate?  {
        @objc(delegater) get { fatalError() }
        @objc(setDelegater:) set { fatalError() }
    }
    
    ///
    /// 显示一个相册
    ///
    /// - parameter album: 相册
    /// - parameter animated: 是否使用转场动画
    ///
    public dynamic func pick(with album: SAPAlbum, animated: Bool) {
        fatalError()
    }
    ///
    /// 显示预览
    ///
    /// - parameter options: 一些选项
    /// - parameter animated: 是否使用转场动画
    ///
    public dynamic func preview(with options: SAPPickerOptions, animated: Bool) {
        fatalError()
    }
    
    ///
    /// 类初始化
    ///
    public override class func initialize() {
        // 替换类方法
        guard let metaClass = objc_getMetaClass(NSStringFromClass(self).cString(using: .utf8)) as? AnyClass else {
            return
        }
        let s1 = Selector(String("allocWithZone:"))
        let s2 = Selector(String("_allocWithZone:"))
        
        let m1 = class_getClassMethod(self, s1)
        let m2 = class_getClassMethod(self, s2)
        
        class_replaceMethod(metaClass, s1, method_getImplementation(m2), method_getTypeEncoding(m1))
    }
    /// 创建方法
    private dynamic class func _alloc(zone: NSZone) -> AnyObject? {
        // 使用的是类簇
        let s1 = Selector(String("allocWithZone:"))
        let ret = SAPPickerInternal.perform(s1, with: zone)
        return ret?.takeRetainedValue()
    }
}

