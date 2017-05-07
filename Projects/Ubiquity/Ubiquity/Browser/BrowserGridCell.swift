//
//  BrowserGridCell.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserGridCell: UICollectionViewCell, Displayable {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    private func _setup() {
        // set default background color
        contentView.backgroundColor = Browser.ub_backgroundColor
        
        _createBadgeView()
    }
    
    var orientation: UIImageOrientation = .up
//    var orientation: UIImageOrientation = .left
//    var orientation: UIImageOrientation = .down
//    var orientation: UIImageOrientation = .right
    
    
    var badgeView: BadgeView?
//
//    var asset: Browseable? {
//        willSet {
//            guard asset !== newValue else {
//                return
//            }
//            _previewView.backgroundColor = newValue?.backgroundColor
//            _previewView.image = newValue?.browseImage
//            
//            _badgeBar.backgroundImage = UIImage(named: "browse_background_gradient")
//            _badgeBar.leftBarItems = [.init(style: .video)]
//            //_badgeBar.rightBarItems = [.init(style: .loading)]
//            _badgeBar.rightBarItems = [.init(title: "9:99")]
//        }
//    }
//    
//    var previewView: UIImageView {
//        return _previewView
//    }
//    
//    private func _commonInit() {
//        
//        _previewView.contentMode = .scaleAspectFill
//        _previewView.frame = contentView.bounds
//        _previewView.clipsToBounds = true
//        _previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        
//        _badgeBar.frame = CGRect(x: 0, y: contentView.bounds.height - 20, width: contentView.bounds.width, height: 20)
//        _badgeBar.tintColor = .white
//        _badgeBar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
//        _badgeBar.isUserInteractionEnabled = false
//        
//        contentView.addSubview(_previewView)
//        contentView.addSubview(_badgeBar)
//    }
//    
//    private lazy var _previewView = UIImageView(frame: .zero)
//    private lazy var _badgeBar = IBBadgeBar(frame: .zero)
    
    ///
    /// display container content with item
    ///
    /// - parameter item: need display the item
    /// - parameter orientation: need display the orientation
    ///
    func display(with item: Item, orientation: UIImageOrientation) {
        
        //backgroundColor = item.backgroundColor
        
        if let imageView = contentView as? UIImageView {
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.image = item.image?.ub_withOrientation(orientation)
        }
        
        _contentSize = item.size
    }
    
    func _createBadgeView() {
        
        let view = BadgeView()
        
        view.frame = CGRect(x: 0, y: contentView.bounds.height - 20, width: contentView.bounds.width, height: 20)
        view.tintColor = .white
        view.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        view.isUserInteractionEnabled = false
        
        view.backgroundImage = BadgeView.ub_backgroundImage
        view.leftItems = [
            .video
//            .panorama
        ]
        view.rightItems = [
            //.downloading
            //.text("99:99")
            .text("04:21")
        ]
        
        addSubview(view)
        badgeView = view
    }
    
    fileprivate var _contentSize: CGSize = .zero
}

/// custom transition support
extension BrowserGridCell: TransitioningView {
    
    var ub_frame: CGRect {
        return convert(bounds, to: window)
    }
    var ub_bounds: CGRect {
        return contentView.bounds.ub_aligned(with: _contentSize)
    }
    var ub_transform: CGAffineTransform {
        return contentView.transform.rotated(by: orientation.ub_angle)
    }
    
    func ub_snapshotView(with context: TransitioningContext) -> UIView? {
        return contentView.snapshotView(afterScreenUpdates: context.ub_operation.appear)
    }
}

/// dynamic class support
internal extension BrowserGridCell {
    // dynamically generated class
    dynamic class func `dynamic`(with viewClass: AnyClass) -> AnyClass {
        let name = "\(NSStringFromClass(self))<\(NSStringFromClass(viewClass))>"
        // if the class has been registered, ignore
        if let newClass = objc_getClass(name) as? AnyClass {
            return newClass
        }
        // if you have not registered this, dynamically generate it
        let newClass: AnyClass = objc_allocateClassPair(self, name, 0)
        let method: Method = class_getClassMethod(self, #selector(getter: contentViewClass))
        objc_registerClassPair(newClass)
        // because it is a class method, it can not used class, need to use meta class
        guard let metaClass = objc_getMetaClass(name) as? AnyClass else {
            return newClass
        }
        let getter: @convention(block) () -> AnyClass = {
            return viewClass
        }
        // add class method
        class_addMethod(metaClass, #selector(getter: contentViewClass), imp_implementationWithBlock(unsafeBitCast(getter, to: AnyObject.self)), method_getTypeEncoding(method))
        return newClass
    }
    // provide content view of class
    dynamic class var contentViewClass: AnyClass {
        return CanvasView.self
    }
    // provide content view of class, iOS 8+
    fileprivate dynamic class var _contentViewClass: AnyClass {
        return contentViewClass
    }
}
