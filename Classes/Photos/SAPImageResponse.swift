//
//  SAPImageResponse.swift
//  SAPhotos
//
//  Created by SAGESSE on 11/11/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos

class SAPImageResponse: NSObject {
    
    init(request: SAPImageRequest, image: UIImage?, info: [AnyHashable: Any]?) {
        
        self.request = request
        self.requestId = info?[PHImageResultRequestIDKey] as? PHImageRequestID ?? PHInvalidImageRequestID
        self.isDegraded = (info?[PHImageResultIsDegradedKey] as? AnyObject)?.boolValue ?? false
        self.isCancelled = (info?[PHImageCancelledKey] as? AnyObject)?.boolValue ?? false
        self.isInCloud = (info?[PHImageResultIsInCloudKey] as? AnyObject)?.boolValue ?? true
        
        super.init()
        
        self.data = image
        self.error = info?[PHImageErrorKey] as? NSError
    }
    
    let request: SAPImageRequest
    
    // result
    var data: UIImage?
    // NSFileManager or iCloud Photo Library errors
    var error: NSError?
    
    // Request ID of the request for this result
    var requestId: PHImageRequestID
    
    // result is in iCloud, meaning a new request will need to get issued (with networkAccessAllowed set) to get the result
    var isInCloud: Bool
    
    // result  is a degraded image (only with async requests), meaning other images will be sent unless the request is cancelled in the meanwhile (note that the other request may fail if, for example, data is not available locally and networkAccessAllowed was not specified)
    var isDegraded: Bool
    // result is not available because the request was cancelled
    var isCancelled: Bool
}
