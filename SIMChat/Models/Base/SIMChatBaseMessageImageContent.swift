//
//  SIMChatBaseContent+Image.swift
//  SIMChat
//
//  Created by sagesse on 1/20/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit


public class SIMChatBaseMessageFileContent: SIMChatMessageContentProtocol {
}

///
/// 图片
///
public class SIMChatBaseMessageImageContent: SIMChatMessageContentProtocol, SIMChatMediaProtocol {
    ///
    /// 使用本地链接创建内容
    ///
    /// - parameter originPath: 原图地址
    /// - parameter thumbnailPath: 缩略图地址, 如果为空, 使用原图
    /// - parameter size: 图片大小
    ///
    public init(originPath: String, thumbnailPath: String? = nil, size: CGSize) {
        let parser = SIMChatBaseFileParser.sharedInstance()
        
        let o = parser.encode(originPath)
        let t = parser.encode(thumbnailPath ?? originPath)
        
        self.size = size
        self.localURL = o
        self.originalURL = o
        self.thumbnailURL = t
    }
    ///
    /// 使用服务器链接创建内容
    ///
    /// - parameter originURL: 原图地址
    /// - parameter thumbnailURL: 缩略图地址, 如果为空, 使用原图
    /// - parameter size: 图片大小
    ///
    public init(originURL: NSURL, thumbnailURL: NSURL? = nil, size: CGSize) {
        let parser = SIMChatBaseFileParser.sharedInstance()
        
        let o = parser.encode(originURL)
        let t = parser.encode(thumbnailURL ?? originURL)
        
        self.size = size
        self.localURL = nil
        self.originalURL = o
        self.thumbnailURL = t
    }
    
    /// 图片在本地的路径, 只有在需要上传的时候这个值才会存在
    public let localURL: NSURL?
    
    /// 图片实际大小
    public let size: CGSize
    /// 图片在服务器上的路径
    public let originalURL: NSURL
    /// 缩略图在服务器上的路径
    public let thumbnailURL: NSURL
    
    /// 上传进度/操作
}
