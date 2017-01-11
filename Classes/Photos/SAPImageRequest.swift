//
//  SAPImageRequest.swift
//  SAPhotos
//
//  Created by SAGESSE on 11/11/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos


class SAPImageRequest: NSObject {

    init(asset: PHAsset, size: CGSize, contentMode: PHImageContentMode = .default) {
        self.asset = asset
        self.targetSize = size
        self.targetContentMode = contentMode
        super.init()
    }
    
    var asset: PHAsset
    var requestId: PHImageRequestID = PHInvalidImageRequestID
    
    var targetSize: CGSize
    var targetContentMode: PHImageContentMode
    
    var version: PHImageRequestOptionsVersion = .current // version
    var deliveryMode: PHImageRequestOptionsDeliveryMode = .opportunistic // delivery mode. Defaults to PHImageRequestOptionsDeliveryModeOpportunistic
    
    var resizeMode: PHImageRequestOptionsResizeMode = .none // resize mode. Does not apply when size is PHImageManagerMaximumSize. Defaults to PHImageRequestOptionsResizeModeNone (or no resize)
    
    var normalizedCropRect: CGRect = .zero // specify crop rectangle in unit coordinates of the original image, such as a face. Defaults to CGRectZero (not applicable)
     
    var isNetworkAccessAllowed: Bool = false // if necessary will download the image from iCloud (client can monitor or cancel using progressHandler). Defaults to NO (see start/stopCachingImagesForAssets)
    var isSynchronous: Bool = false // return only a single result, blocking until available (or failure). Defaults to NO
}
