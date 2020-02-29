//
//  SAPAsset.swift
//  SAPhotos
//
//  Created by SAGESSE on 31/10/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos

public class SAPAsset: NSObject {
    
    public var identifier: String {
        if let identifier = _identifier {
            return identifier
        }
        let identifier = asset.localIdentifier
        _identifier = identifier
        return identifier
    }
    
    public var pixelWidth: Int { 
        return asset.pixelWidth
    }
    public var pixelHeight: Int { 
        return asset.pixelHeight
    }

    public var creationDate: Date? { 
        return asset.creationDate
    }
    public var modificationDate: Date? { 
        return asset.modificationDate
    }
    
    public var mediaType: PHAssetMediaType { 
        return asset.mediaType
    }
    public var mediaSubtypes: PHAssetMediaSubtype { 
        return asset.mediaSubtypes
    }

    public var location: CLLocation? { 
        return asset.location
    }
    
    public var duration: TimeInterval { 
        return asset.duration
    }
    
    public var isHidden: Bool { 
        return asset.isHidden
    }
    public var isFavorite: Bool { 
        return asset.isFavorite
    }
    
    public var burstIdentifier: String? { 
        return asset.burstIdentifier
    }
    public var burstSelectionTypes: PHAssetBurstSelectionType { 
        return asset.burstSelectionTypes
    }
    
    public var representsBurst: Bool { 
        return asset.representsBurst
    }
    
    public override var hash: Int {
        return identifier.hash
    }
    public override var description: String {
        return asset.description
    }
    
    public var size: CGSize {
        return CGSize(width: pixelWidth, height: pixelHeight)
    }
    public func size(with orientation: UIImage.Orientation) -> CGSize {
        switch orientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            return CGSize(width: pixelHeight, height: pixelWidth)
            
        case .up, .upMirrored, .down, .downMirrored:
            return CGSize(width: pixelWidth, height: pixelHeight)
        }
    }
    
    public func imageTask(with options: SAPRequestOptions) -> SAPProgressiveItem? {
        return SAPLibrary.shared.imageTask(with: self, options: options)
    }
    
    public var imageItem: Progressiveable? {
//        let options = SAPRequestOptions(size: size)
//        return SAPLibrary.shared.requestImageItem(with: self, options: options)
        return SAPLibrary.shared.imageItem(with: self, size: self.size)
    }
    public func imageItem(with size: CGSize) -> Progressiveable? {
        return SAPLibrary.shared.imageItem(with: self, size: size)
    }
    
    public var playerItem: SAPProgressiveItem? {
        return SAPLibrary.shared.playerItem(with: self)
    }
    
    public var data: Data?
    public func data(with handler: @escaping (Data?) -> Void)  {
        if let data = data {
            return handler(data)
        }
        return SAPLibrary.shared.data(with: self) { [weak self](data, dataUTI, orientation, info) in
            self?.data = data
            handler(data)
        }
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let photo = object as? SAPAsset else {
            return false
        }
        return identifier == photo.identifier
    }
    
    public let asset: PHAsset
    public let album: SAPAlbum
    
    public init(asset: PHAsset, album: SAPAlbum) {
        self.asset = asset
        self.album = album
        super.init()
    }
    
    private var _identifier: String?
}

extension SAPAsset: SAPBrowseable {
    
    public var browseType: SAPBrowseableType {
        return mediaType
    }
    
    public var browseSize: CGSize {
        return size
    }
    public var browseOrientation: UIImage.Orientation  {
        return .up
    }
    
    public var browseImage: Progressiveable? {
        return imageItem
    }
    // 这个参数只用于视频和音频
    public var browseContent: Progressiveable? {
        return playerItem
    } 
}


public func SAPStringForDuration(_ duration: TimeInterval) -> String {
    let s = Int(duration) % 60
    let m = Int(duration / 60)
    return String(format: "%02zd:%02zd", m, s)
}

public func SAPStringForBytesLenght(_ len: Int) -> String {
    if len <= 999 {
        // 只显示1B-999B
        return String(format: "%zdB", len)
    }
    if len <= 999 * 1024 {
        // 只显示1k-999k
        return String(format: "%zdK", len / 1024)
    }
    return String(format: "%.1lfM", Double(len) / 1024 / 1024)
}
