//
//  SAPProgressiveItem.swift
//  SAPhotos
//
//  Created by SAGESSE on 05/11/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos

open class SAPProgressiveItem: NSObject, Progressiveable {
    
    public init(size: CGSize) {
        self.size = size
        super.init()
    }
    deinit {
        guard requestId != PHInvalidImageRequestID else {
            return
        }
        SAPLibrary.shared.cancelImageRequest(requestId)
    }
    
    open dynamic var thumb: SAPProgressiveItem?
    open dynamic var requestId: PHImageRequestID = PHInvalidImageRequestID
    
    open dynamic var size: CGSize
    open dynamic var contentSize: CGSize {
        return (content as? UIImage)?.size ?? .zero
    }
    
    open dynamic var content: Any? {
        didSet {
            didChangeProgressiveContent()
        }
    }
    open dynamic var progress: Double = 0 {
        didSet {
            didChangeProgressiveProgress()
        }
    }
}
