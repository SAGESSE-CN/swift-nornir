//
//  ImageView.swift
//  Ubiquity
//
//  Created by SAGESSE on 4/22/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

///
/// display images resources
///
internal class ImageView: UIImageView, ItemContainer {
    ///
    /// update container content with item
    ///
    /// - parameter item: resource abstract of item
    /// - parameter orientation: item display orientation
    ///
    func apply(with item: Item, orientation: UIImageOrientation) {
        logger.trace?.write()
        
        // update image
        image = item.image?.ub_withOrientation(orientation)
    }
    
    ///
    /// generate quick snapshot, if there is time synchronous display
    ///
    override func snapshotView(afterScreenUpdates afterUpdates: Bool) -> UIView? {
        let imageView = UIImageView(frame: frame)
        imageView.image = image
        imageView.backgroundColor = backgroundColor
        return imageView
    }
}
