//
//  UIImageView+Animation.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/25/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal extension UIImageView {
    
    /// update iamge with animation
    func ub_setImage(_ newImage: UIImage?, animated: Bool) {
        guard newImage !== image else {
            return
        }
        // update content
        let oldImage = image
        image = newImage
        layer.removeAnimation(forKey: "contents")
        // if needed animation
        guard animated else {
            return
        }
        UIView.animate(withDuration: 0.25) {
            guard let ani = self.layer.action(forKey: #keyPath(backgroundColor)) as? CABasicAnimation else {
                return
            }
            ani.keyPath = "contents"
            ani.fromValue = oldImage?.cgImage
            ani.toValue = nil
            // add animation
            self.layer.add(ani, forKey: "contents")
        }
    }
}
