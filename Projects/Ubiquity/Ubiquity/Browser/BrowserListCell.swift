//
//  BrowserListCell.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserListCell: UICollectionViewCell {
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        _commonInit()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        _commonInit()
//    }
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
}

/// dynamic class support
internal extension BrowserListCell {
    // dynamically generated class
    internal dynamic class func `dynamic`(with viewClass: AnyClass) -> AnyClass {
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
    internal dynamic class var contentViewClass: AnyClass {
        return CanvasView.self
    }
    // provide content view of class, iOS 8+
    fileprivate dynamic class var _contentViewClass: AnyClass {
        return contentViewClass
    }
}
