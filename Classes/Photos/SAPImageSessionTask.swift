//
//  SAPImageSessionTask.swift
//  SAPhotos
//
//  Created by SAGESSE on 11/11/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos

class SAPImageSessionTask: NSObject, Progressiveable {
   
    init(request: SAPImageRequest) {
        super.init()
        self.request = request
    }
    
    deinit {
        cancel()
    }
    
    var data: UIImage?
    var error: Error?
    var progress: Double = 1
    
    var content: Any? {
        return data
    }
    
    var request: SAPImageRequest? 
    var response: SAPImageResponse?
    
    var thumbTask: SAPImageSessionTask?
    weak var session: SAPImageSession?
    
    func updateTask(_ image: UIImage?, _ response: SAPImageResponse?) {
        //_logger.trace(image)
        
        self.data = image
        self.response = response ?? self.response
        
        self.didChangeProgressiveContent()
    }
    func updateProgress(_ progress: Double) {
        //_logger.trace(progress)
        
        self.progress = progress
        
        self.didChangeProgressiveProgress()
    }
    
    func finishTask(_ image: UIImage?, _ response: SAPImageResponse) {
        //_logger.trace(image)
        
        self.data = image
        self.response = response
        self.progress = 1
        
        self.didChangeProgressiveContent()
        self.didChangeProgressiveProgress()
    }
    
    func cancel() {
        if let request = request {
            session?.cancelRequest(with: request)
        }
        thumbTask?.cancel()
    }
}

//6C8DD58E-5EF8-41A3-8BDA-20597B72F760/L0/001  respond image  (234.0, 234.0) Optional(<UIImage: 0x1473ca3c0>, {60, 45}) Optional([AnyHashable("PHImageResultRequestIDKey"): 562, AnyHashable("PHImageResultDeliveredImageFormatKey"): 4031, AnyHashable("PHImageResultIsDegradedKey"): 1, AnyHashable("PHImageFileOrientationKey"): 0, AnyHashable("PHImageResultWantedImageFormatKey"): 5003])
//C5AFB90D-DE9F-456C-9CB1-69A780868F04/L0/001 request image with (234.0, 234.0)
//C5AFB90D-DE9F-456C-9CB1-69A780868F04/L0/001  respond image  (234.0, 234.0) Optional(<UIImage: 0x1472db280>, {60, 45}) Optional([AnyHashable("PHImageResultRequestIDKey"): 563, AnyHashable("PHImageResultDeliveredImageFormatKey"): 4031, AnyHashable("PHImageResultIsDegradedKey"): 1, AnyHashable("PHImageFileOrientationKey"): 0, AnyHashable("PHImageResultWantedImageFormatKey"): 5003])
//C5AFB90D-DE9F-456C-9CB1-69A780868F04/L0/001  respond image  (234.0, 234.0) Optional(<UIImage: 0x1473f8840>, {312, 234}) Optional([AnyHashable("PHImageResultRequestIDKey"): 563, AnyHashable("PHImageResultIsDegradedKey"): 0, AnyHashable("PHImageResultImageTypeKey"): 0, AnyHashable("PHImageResultDeliveredImageFormatKey"): 5003])
