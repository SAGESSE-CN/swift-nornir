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
        
        let thumbSize = BrowserAlbumLayout.thumbnailItemSize
        let thumbOptions = DataSourceOptions()
        let largeSize = CGSize(width: asset.ub_pixelWidth, height: asset.ub_pixelHeight)
        let largeOptions = DataSourceOptions(progressHandler: { [weak self, weak asset] progress, response in
            DispatchQueue.main.async {
                // if the asset is nil, the asset has been released
                guard let asset = asset else {
                    return
                }
                // update progress
                self?._updateContentsProgress(progress, response: response, asset: asset)
            }
        })
        
        _requests = [
            // request thumb iamge
            library.ub_requestImage(for: asset, targetSize: thumbSize, contentMode: .aspectFill, options: thumbOptions) { [weak self, weak asset] contents, response in
                // if the asset is nil, the asset has been released
                guard let asset = asset else {
                    return
                }
                // the request is complete?
                if self?._asset === asset && response.ub_completed {
                    self?._requests?[0] = nil
                }
                // the image is vaild?
                guard (self?.image?.size.width ?? 0) < (contents?.size.width ?? 0) else {
                    return
                }
                // update contents
                self?._updateContents(contents, response: response, asset: asset)
                
                
                
            },
            // request large image
            library.ub_requestImage(for: asset, targetSize: largeSize, contentMode: .aspectFill, options: largeOptions) { [weak self, weak asset] contents, response in
                // if the asset is nil, the asset has been released
                guard let asset = asset else {
                    return
                }
                // the request is complete?
                if self?._asset === asset && response.ub_completed {
                    self?._requests?[1] = nil
                }
                // the image is vaild?
                guard (self?.image?.size.width ?? 0) < (contents?.size.width ?? 0) else {
                    return
                }
                // update contents
                self?._updateContents(contents, response: response, asset: asset)
            }
        ]
    }
    // end display asset
    func endDisplay(with asset: Asset, in library: Library) {
        logger.trace?.write()
        
        // when are requesting an image, please cancel it
        _requests?.forEach { request in
            request.map { request in
                // reveal cancel
                library.ub_cancelRequest(request)
            }
        }
        
        // clear context
        _asset = nil
        _requests = nil
        _library = nil
        
        // clear contents
        self.image = nil
        
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
        logger.trace?.write("\(asset.ub_localIdentifier) => \(contents?.size ?? .zero)")
        
        // update contents
        ub_setImage(contents ?? self.image, animated: true)
        
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
    private var _requests: [Request?]?
    private var _donwloading: Bool = false
}

