//
//  SIMChatBaseContent+Image.swift
//  SIMChat
//
//  Created by sagesse on 1/20/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit


public class SIMChatBaseMessageFileContent: SIMChatMessageBody {
}

///
/// 图片
///
public class SIMChatBaseMessageImageContent: SIMChatMessageBody, SIMChatMediaProtocol {
    ///
    /// 创建图片内容
    ///
    /// - parameter origin: 原图
    /// - parameter thumbnail: 缩略图, 如果为空, 使用原图
    /// - parameter size: 图片大小
    ///
    public init(origin: SIMChatResourceProtocol, thumbnail: SIMChatResourceProtocol? = nil, size: CGSize) {
        self.size = size
        self.origin = origin
        self.thumbnail = thumbnail ?? origin
    }
    
    /// 图片在本地的路径, 只有在需要上传的时候这个值才会存在
    public var localURL: NSURL?
    
    /// 实际大小
    public let size: CGSize
    /// 原文件
    public let origin: SIMChatResourceProtocol
    /// 缩略图
    public let thumbnail: SIMChatResourceProtocol
    
    /// 上传进度/操作
}
