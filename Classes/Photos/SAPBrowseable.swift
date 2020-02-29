//
//  SAPBrowseable.swift
//  SAPhotos
//
//  Created by SAGESSE on 11/4/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos

///
/// 可浏览协议
///
@objc public protocol SAPBrowseable {
    
    var browseType: SAPBrowseableType { get }
    
    var browseSize: CGSize { get }
    var browseOrientation: UIImage.Orientation  { get }
    
    var browseImage: Progressiveable? { get }
    var browseContent: Progressiveable? { get }  // 这个参数只用于视频和音频
}

///
/// 可浏览对象类型
///
public typealias SAPBrowseableType = PHAssetMediaType
