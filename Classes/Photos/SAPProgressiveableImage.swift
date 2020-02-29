//
//  ProgressiveableImage.swift
//  SAC
//
//  Created by SAGESSE on 10/15/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

/////
///// 支持渐进式更新的图片
/////
//public class ProgressiveableImage: UIImage, Progressiveable {
//    
//    /// 真正的内容
//    public var content: Any? {
//        set {
//            if let newValue = newValue as? UIImage {
//                _content = newValue.withOrientation(_orientation)
//            }
//            _notify(_content)
//        }
//        get {
//            return _content
//        }
//    }
//    
//    public override var size: CGSize {
//        return _content?.size ?? .zero
//    }
//    public override var imageOrientation: UIImage.Orientation {
//        return _orientation
//    }
//    
//    ///
//    /// 添加监听者
//    ///
//    /// - Parameter observer: 监听者, 这是weak
//    ///
//    public func addObserver(_ observer: ProgressiveableObserver) {
//        _observers.add(observer)
//    }
//    ///
//    /// 移除监听者(如果有)
//    ///
//    /// - Parameter observer: 监听者
//    ///
//    public func removeObserver(_ observer: ProgressiveableObserver) {
//        _observers.remove(observer)
//    }
//    
//    
//    private func _mutableCopy() -> ProgressiveableImage {
//        let image = ProgressiveableImage()
//        
//        image._parent = self
//        image._content = _content
//        image._orientation = _orientation
//        
//        // 添加
//        _replicaes.add(image)
//        
//        return image
//    }
//    
//    private func _notify(_ image: UIImage?) {
//        //_logger.trace()
//        
//        _observers.allObjects.forEach {
//            $0.progressiveable(self, didChangeContent: image)
//        }
//        _replicaes.allObjects.forEach { 
//            $0.content = image
//        }
//    }
//    
//    deinit {
//        _parent = nil
//    }
//    
//    public override func withOrientation(_ orientation: UIImage.Orientation) -> UIImage? {
//        guard imageOrientation != orientation else {
//            return self
//        }
//        let image = _parent?._mutableCopy() ?? _mutableCopy()
//        
//        image._orientation = orientation
//        image._content = _content?.withOrientation(orientation)
//        
//        return image
//    }
//    
//    public override class func initialize() {
//        
//        let m1 = class_getInstanceMethod(UIImageView.self, #selector(getter: UIImageView.image))
//        let m2 = class_getInstanceMethod(UIImageView.self, #selector(UIImageView.sap_image))
//        
//        let m3 = class_getInstanceMethod(UIImageView.self, #selector(setter: UIImageView.image))
//        let m4 = class_getInstanceMethod(UIImageView.self, #selector(UIImageView.sap_setImage(_:)))
//        
//        method_exchangeImplementations(m1, m2)
//        method_exchangeImplementations(m3, m4)
//    }
//    
//    private var _parent: ProgressiveableImage?  // 如果不强引用, 当parent释放后就获取不到通知了
//    
//    private var _orientation: UIImage.Orientation = .up
//    private var _content: UIImage?
//    
//    private let _observers = NSHashTable<ProgressiveableObserver>.weakObjects()
//    private let _replicaes = NSHashTable<ProgressiveableImage>.weakObjects()
//}
//
/////
///// 使UIImage支持方向切换
/////
//extension UIImage {
//    
//    public func withOrientation(_ orientation: UIImage.Orientation) -> UIImage? {
//        guard imageOrientation != orientation else {
//            return self
//        }
//        if let image = cgImage {
//            return UIImage(cgImage: image, scale: scale, orientation: orientation)
//        }
//        if let image = ciImage {
//            return UIImage(ciImage: image, scale: scale, orientation: orientation)
//        }
//        return nil
//    }
//}
//
/////
///// 使UIImageView支持渐进式更新
/////
//extension UIImageView: ProgressiveableObserver {
// 
//    ///
//    /// 内容发生改变
//    ///
//    public func progressiveable(_ progressiveable: Progressiveable, didChangeContent content: Any?) {
//        sap_setImage(content as? UIImage)
//    }
//    
//    internal dynamic func sap_setImage(_ newValue: UIImage?) {
//        guard let image = newValue as? ProgressiveableImage else {
//            sap_progressiveImage = nil
//            sap_setImage(newValue)
//            return
//        }
//        sap_progressiveImage = image
//        sap_setImage(image.content as? UIImage)
//    }
//    internal dynamic func sap_image() -> UIImage? {
//        guard let image = sap_progressiveImage else {
//            return sap_image()
//        }
//        return image
//    }
//    
//    internal dynamic var sap_progressiveImage: ProgressiveableImage? {
//        set {
//            let oldValue = sap_progressiveImage
//            guard oldValue !== newValue else {
//                return // no change
//            }
//            
//            oldValue?.removeObserver(self)
//            newValue?.addObserver(self)
//            
//            return objc_setAssociatedObject(self, &_UIImageViewProgressiveImage, newValue, .OBJC_ASSOCIATION_RETAIN) 
//        }
//        get { 
//            return objc_getAssociatedObject(self, &_UIImageViewProgressiveImage) as? ProgressiveableImage 
//        }
//    }
//}
//
//private var _UIImageViewProgressiveImage = "_UIImageViewProgressiveImage"
