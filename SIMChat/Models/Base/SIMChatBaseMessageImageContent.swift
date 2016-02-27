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
public class SIMChatBaseMessageImageContent: SIMChatMessageContentProtocol {
    /// 使用本地链接创建内容
    public init(originPath: String, thumbnailPath: String? = nil, size: CGSize) {
        let o = SIMChatFileProviderSource.Local(path: originPath).URL
        let t = SIMChatFileProviderSource.Local(path: thumbnailPath ?? originPath).URL
        
        self.size = size
        self.localURL = o
        self.remoteURL = o
        self.thumbnailURL = t
    }
    /// 使用服务器链接创建内容
    public init(remoteURL: NSURL, thumbnailURL: NSURL? = nil, size: CGSize) {
        let o = SIMChatFileProviderSource.Network(address: remoteURL).URL
        let t = SIMChatFileProviderSource.Network(address: thumbnailURL ?? remoteURL).URL
        
        self.size = size
        self.localURL = nil
        self.remoteURL = o
        self.thumbnailURL = t
    }
    
    /// 图片实际大小
    public let size: CGSize
    
    /// 图片在本地的路径, 只有在需要上传的时候这个值才会存在
    public let localURL: NSURL?
    /// 图片在服务器上的路径
    public let remoteURL: NSURL
    /// 缩略图在服务器上的路径
    public let thumbnailURL: NSURL
    
    /// 上传进度/操作
}
