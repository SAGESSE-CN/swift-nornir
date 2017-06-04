//
//  PhotoContentView.swift
//  Ubiquity
//
//  Created by SAGESSE on 4/22/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

///
/// display photo resources
///
internal class PhotoContentView: AnimatedImageView, Displayable {

    
    var contents: AnyObject? {
        set { return image = newValue as? UIImage }
        get { return image }
    }
    
    // displayer delegate
    weak var displayerDelegate: DisplayableDelegate?
    
    // display asset
    func willDisplay(with asset: Asset, in library: Library, orientation: UIImageOrientation) {
        logger.trace?.write()
        
        // have any change?
        guard _asset !== asset else {
            return
        }
        // save context
        _asset = asset
        _library = library
        _donwloading = false
        
        // update image
        backgroundColor = .ub_init(hex: 0xf0f0f0)
        
        //image = item.image
        let size = CGSize(width: asset.ub_pixelWidth, height: asset.ub_pixelHeight)
        let options = CacheLibrary.Options(progressHandler: { [weak self, weak asset] progress, response in
            DispatchQueue.main.async {
                // if the asset is nil, the asset has been released
                guard let asset = asset else {
                    return
                }
                // update progress
                self?._updateContentsProgress(progress, response: response, asset: asset)
            }
        })
        
        // update default contents
        self.contents = (_library as? CacheLibrary)?.fastCache(for: asset) as? UIImage
        
        // request large image
        _request = library.ub_requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { [weak self, weak asset] image, response in
            // if the asset is nil, the asset has been released
            guard let asset = asset else {
                return
            }
            // update contents
            self?._updateContents(image, response: response, asset: asset)
        }
    }
    // end display asset
    func endDisplay(with asset: Asset, in library: Library) {
        logger.trace?.write()
        
        // if is requesting image, need to cancel
        _request.map { request in
            // cancel
            library.ub_cancelRequest(request)
        }
        
        // clear context
        _asset = nil
        _request = nil
        _library = nil
        
        // clear contents
        self.contents = nil
        
        // stop animation if needed
        stopAnimating()
    }
    
    private func _updateContents(_ contents: UIImage?, response: Response, asset: Asset) {
        // the current asset has been changed?
        guard _asset === asset else {
            // change, all reqeust is expire
            logger.debug?.write("\(asset.ub_localIdentifier) image is expire")
            return
        }
        logger.trace?.write("\(asset.ub_localIdentifier)")
        
        // update contents
        self.contents = contents ?? self.contents
        
    }
    private func _updateContentsProgress(_ progress: Double, response: Response, asset: Asset) {
        // the current asset has been changed?
        guard _asset === asset else {
            // change, all reqeust is expire
            logger.debug?.write("\(asset.ub_localIdentifier) progress is expire")
            return
        }
        // if the library required to download
        // if download completed start animation is an error
        if !_donwloading && progress < 1 {
            _donwloading = true
            // start downloading
            displayerDelegate?.displayer(self, didStartRequest: asset)
        }
        // only in the downloading  to update progress
        if (_donwloading) {
            // update donwload progress
            displayerDelegate?.displayer(self, didReceive: progress)
        }
        // if the donwload completed or an error occurred, end of the download
        if (_donwloading && progress >= 1) || (response.ub_error != nil) {
            _donwloading = false
            // complate download
            displayerDelegate?.displayer(self, didComplete: response.ub_error)
        }
    }
    
    private var _asset: Asset?
    private var _library: Library?
    
    private var _request: Request?
    
    private var _donwloading: Bool = false
}

