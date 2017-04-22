//
//  ImageView.swift
//  Ubiquity
//
//  Created by SAGESSE on 4/22/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class ImageView: UIImageView, ItemContainer {
    ///
    /// update container content with item
    ///
    /// - parameter item: resource abstract of item
    ///
    func apply(with item: Item) {
        image = item.image
    }
    
    override func snapshotView(afterScreenUpdates afterUpdates: Bool) -> UIView? {
        let imageView = UIImageView(frame: frame)
        imageView.image = image
        imageView.backgroundColor = backgroundColor
        return imageView
    }
}
