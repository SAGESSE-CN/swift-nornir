//
//  VideoView.swift
//  Ubiquity
//
//  Created by SAGESSE on 4/22/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

///
/// display video resources
///
internal class VideoView: UIView, ItemContainer {
    ///
    /// update container content with item
    ///
    /// - parameter item: resource abstract of item
    /// - parameter orientation: item display orientation
    ///
    func apply(with item: Item, orientation: UIImageOrientation) {
        logger.trace?.write()
        
        // update image
    }
    
    ///
    /// generate quick snapshot, if there is time synchronous display
    ///
    override func snapshotView(afterScreenUpdates afterUpdates: Bool) -> UIView? {
        let imageView = UIImageView(frame: frame)
        imageView.backgroundColor = backgroundColor
        return imageView
    }
}
