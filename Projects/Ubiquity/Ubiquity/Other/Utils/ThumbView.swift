//
//  ThumbView.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/5/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class ThumbView: UIView {

    // 缩图图, 0-3张
    var images: [UIImage?]? {
        didSet {
            _update(at: images)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // recompute all subview offset
        imageViews.enumerated().forEach { index, imageView in
            // compute offset
            let top = _inset.top * .init(index)
            let left = _inset.left * .init(index)
            let right = _inset.right * .init(index)
            let bottom = _inset.bottom * .init(index) + top * 2
            // update layout
            imageView.frame = UIEdgeInsetsInsetRect(bounds, .init(top: -top, left: left, bottom: bottom, right: right))
        }
    }
    
    
    private func _update(at images: [UIImage?]?) {
        
        // if the images is empty, show empty photo album
        guard let images = images, !images.isEmpty else {
            // show image of photo albums
            imageViews.forEach { imageView in
                imageView.image = _emptyImage
                imageView.isHidden = false
            }
            return
        }
        // show iamge
        imageViews.enumerated().forEach { index, imageView in
            // get the current thumbnails
            imageView.image = images.ub_get(at: index) ?? nil
            imageView.isHidden = !(index < images.count)
        }
    }
    
    private func _setup() {
        
        // setup layer
        (0 ..< 3).forEach { index in
            
            let imageView = ThumbImageView()
            
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.backgroundColor = nil
            imageView.layer.borderWidth = 0.5
            imageView.layer.borderColor = UIColor.white.cgColor
            
            insertSubview(imageView, at: 0)
            imageViews.append(imageView)
        }
    }
    
    lazy var imageViews: [UIImageView] = []
    
    private var _inset: UIEdgeInsets = .init(top: 2, left: 2, bottom: 2, right: 2)
    
    private var __emptyImage: UIImage?
    private var _emptyImage: UIImage? {
        // image has been cache?
        if let image = __emptyImage ?? __sharedEmptyImage {
            // update cache
            __emptyImage = image
            __sharedEmptyImage = image
        
            return image
        }
        
        let rect = CGRect(x: 0, y: 0, width: 70, height: 70)
        let tintColor = UIColor.ub_init(hex: 0xb4b3b9)
        let backgroundColor = Browser.ub_backgroundColor
        // begin draw
        UIGraphicsBeginImageContextWithOptions(rect.size, true, UIScreen.main.scale)
        // check the current context
        if let context = UIGraphicsGetCurrentContext() {
            // set the background color
            backgroundColor?.setFill()
            context.fill(rect)
            // draw icon
            if let image = UIImage.ub_init(named: "ubiquity_icon_empty_album") {
                // generate tint image with tint color
                UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
                let context = UIGraphicsGetCurrentContext()
                
                tintColor.setFill()
                context?.fill(.init(origin: .zero, size: image.size))
                image.draw(at: .zero, blendMode: .destinationIn, alpha: 1)
                
                let image2 = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                // draw to main context
                image2?.draw(at: .init(x: rect.midX - image.size.width / 2, y: rect.midY - image.size.height / 2))
            }
            
            __emptyImage = UIGraphicsGetImageFromCurrentImageContext()
            __sharedEmptyImage = __emptyImage
        }
        // end draw
        UIGraphicsEndImageContext()
        
        return __emptyImage
    }
}


internal class ThumbImageView: UIImageView {
    override var backgroundColor: UIColor? {
        set { return super.backgroundColor = Browser.ub_backgroundColor }
        get { return super.backgroundColor }
    }
}

private weak var __sharedEmptyImage: UIImage?
