//
//  Browseable.swift
//  Ubiquity
//
//  Created by sagesse on 11/13/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

public enum KeyValueStatus : Int {
    
    case unknown
    case loading
    case loaded
    case failed
    case cancelled
}

//var isPlayable: Bool { get }
//var isExportable: Bool { get }
//var isReadable: Bool { get }
//var isComposable: Bool { get }

public enum IBAssetType: Int {
    case unknow
    case image
    case video
}
public enum IBAssetSubtype: Int {
    case unknow
    case hdr
    //case gif
}

public protocol Browseable: class {
    
    var backgroundColor: UIColor? { get }
    
    var browseContentSize: CGSize { get }
    
    // test
    var browseImage: UIImage? { get }
    
    var browseType: IBAssetType { get }
    var browseSubtype: IBAssetSubtype { get }
    
//    
//    func statusOfValue(forKey key: String, error outError: NSErrorPointer) -> KeyValueStatus
//    func loadValuesAsynchronously(forKeys keys: [String], completionHandler handler: (() -> Void)?)
}
