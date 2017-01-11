//
//  SAPPreviewableView.swift
//  SAC
//
//  Created by SAGESSE on 10/13/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit


internal class SAPPreviewableView: UIView {
    
    dynamic var image: UIImage? {
        willSet {
            // 添加切换动画
            UIView.performWithoutAnimation {
                presentationView.alpha = 0
                presentationView.image = contentView.image
            }
            presentationView.alpha = 0
            
            //contentView.setProgressiveValue(<#T##value: Progressiveable?##Progressiveable?#>, forKey: <#T##String#>)
            contentView.image = newValue//?.withOrientation(.up)
        }
    }
    var imageSize: CGSize = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    var imageOrientation: UIImageOrientation = .up {
        didSet {
            setNeedsLayout()
            
            transform = CGAffineTransform(rotationAngle: angle(orientation: imageOrientation))
        }
    }
    var imageContentMode: UIViewContentMode = .scaleToFill {
        didSet {
            setNeedsLayout()
        }
    }
    
    var previewing: SAPPreviewable? {
        willSet {
            setNeedsLayout()
            
            imageOrientation = newValue?.previewingContentOrientation ?? .up
            
            setProgressiveValue(newValue?.previewingContent, forKey: "image")
            
            imageContentMode = newValue?.previewingContentMode ?? .scaleToFill
            imageSize = newValue?.previewingContentSize ?? .zero
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = align(bounds, to: imageSize, with: imageContentMode)
    }
    
    func align(_ rect: CGRect, to size: CGSize, with contentMode: UIViewContentMode) -> CGRect {
        // if contentMode is scale is used in all rect
        if contentMode == .scaleToFill {
            return rect
        }
        var x = rect.minX
        var y = rect.minY
        var width = size.width
        var height = size.height
        // if contentMode is aspect scale to fit, calculate the zoom ratio
        if contentMode == .scaleAspectFit {
            let scale = min(rect.width / max(size.width, 1), rect.height / max(size.height, 1))
            
            width = size.width * scale
            height = size.height * scale
        }
        // if contentMode is aspect scale to fill, calculate the zoom ratio
        if contentMode == .scaleAspectFill {
            let scale = max(rect.width / max(size.width, 1), rect.height / max(size.height, 1))
            
            width = size.width * scale
            height = size.height * scale
        }
        // horizontal alignment
        if [.left, .topLeft, .bottomLeft].contains(contentMode) {
            // align left
            x += (0)
            
        } else if [.right, .topRight, .bottomRight].contains(contentMode) {
            // align right
            x += (rect.width - width)
            
        } else {
            // algin center
            x += (rect.width - width) / 2
        }
        // vertical alignment
        if [.top, .topLeft, .topRight].contains(contentMode) {
            // align top
            y += (0)
            
        } else if [.bottom, .bottomLeft, .bottomRight].contains(contentMode) {
            // align bottom
            y += (rect.height - width)
            
        } else {
            // algin center
            y += (rect.height - height) / 2
        }
        return CGRect(x: x, y: y, width: width, height: height)
    }
    func angle(orientation: UIImageOrientation) -> CGFloat {
        switch orientation {
        case .up, .upMirrored:  return 0 * CGFloat(M_PI_2)
        case .right, .rightMirrored: return 1 * CGFloat(M_PI_2)
        case .down, .downMirrored: return 2 * CGFloat(M_PI_2)
        case .left, .leftMirrored: return 3 * CGFloat(M_PI_2)
        }
    }
    func reset(_ image: UIImage?) -> UIImage? {
        guard let cgimage = image?.cgImage, image?.imageOrientation != .up else {
            return image
        }
        return UIImage(cgImage: cgimage, scale: image?.scale ?? 1, orientation: .up)
    }
    
    init() {
        super.init(frame: .zero)
        
        clipsToBounds = true
        
        presentationView.contentMode = .scaleAspectFill
        presentationView.alpha = 0
        presentationView.frame = contentView.bounds
        presentationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //contentView.backgroundColor = .random
        contentView.contentMode = .scaleAspectFill
        contentView.addSubview(presentationView)
        
        addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not support")
    }
    
    private lazy var contentView: UIImageView = UIImageView()
    private lazy var presentationView: UIImageView = UIImageView()
}
