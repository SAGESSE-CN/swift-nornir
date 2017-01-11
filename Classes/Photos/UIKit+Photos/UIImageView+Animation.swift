//
//  UIImageView+Animation.swift
//  SAPhotos
//
//  Created by SAGESSE on 11/7/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

extension UIImageView {
    
    
    open func setImage(_ image: UIImage?, animated: Bool) {
        let newValue = image
        let oldValue = self.image
        
        self.image = newValue
        
        guard newValue !== oldValue && animated else {
            return
        }
        // 添加内容变更
        let ani = CABasicAnimation(keyPath: "contents")
        
        ani.fromValue = oldValue?.cgImage ?? _makeEmptyImage(with: newValue?.size ?? .zero)?.cgImage
        ani.toValue = newValue?.cgImage ?? _makeEmptyImage(with: oldValue?.size ?? .zero)?.cgImage
        ani.duration = 0.35
        
        layer.add(ani, forKey: "contents")
    }
    
    private func _makeEmptyImage(with size: CGSize) -> UIImage? {
        guard size.width != 0 && size.height != 0 else {
            return nil
        }
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let color = backgroundColor ?? .clear
        
        UIGraphicsBeginImageContext(size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
