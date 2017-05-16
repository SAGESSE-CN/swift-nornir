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
internal class ImageView: AnimatedImageView, Displayable {
    ///
    /// display container content with item
    ///
    /// - parameter item: need display the item
    /// - parameter orientation: need display the orientation
    ///
    func willDisplay(with item: Item, orientation: UIImageOrientation) {
        logger.trace?.write()
        
        // update image
        image = item.image
        backgroundColor = Browser.ub_backgroundColor
    }
    ///
    /// end display content with item
    ///
    /// - parameter item: need display the item
    ///
    func endDisplay(with item: Item) {
        logger.trace?.write()
        
        // stop animation if needed
        stopAnimating()
    }
}

