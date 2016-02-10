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
    public init(local: String, thumbnail: String? = nil, size: CGSize) {
        let l = local.stringByAddingPercentEncodingWithAllowedCharacters(.URLFragmentAllowedCharacterSet())!
        let t = thumbnail?.stringByAddingPercentEncodingWithAllowedCharacters(.URLFragmentAllowedCharacterSet()) ?? l
        
        self.size = size
        
        self.local = NSURL(string: "chat-image://\(l)")!
        self.remote = NSURL(string: "chat-image://\(l)")!
        self.thumbnail = NSURL(string: "chat-image://\(t)")!
    }
    /// 使用服务器链接创建内容
    public init(remote: String, thumbnail: String? = nil, size: CGSize) {
        let r = remote.stringByAddingPercentEncodingWithAllowedCharacters(.URLFragmentAllowedCharacterSet())!
        let t = thumbnail?.stringByAddingPercentEncodingWithAllowedCharacters(.URLFragmentAllowedCharacterSet()) ?? r
        
        self.size = size
        
        self.local = nil
        self.remote = NSURL(string: "chat-image://\(r)")!
        self.thumbnail = NSURL(string: "chat-image://\(t)")!
    }
    
    /// 图片在本地的路径, 只有在需要上传的时候这个值才会存在
    public let local: NSURL?
    /// 图片在服务器上的路径
    public let remote: NSURL
    /// 缩略图在服务器上的路径
    public let thumbnail: NSURL
    
    /// 图片实际大小
    public let size: CGSize
    
    /// 上传进度/操作
}
