//
//  SIMChatBaseContent+Audio.swift
//  SIMChat
//
//  Created by sagesse on 1/20/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation


///
/// 音频
///
public class SIMChatBaseMessageAudioContent: SIMChatMessageContentProtocol {
    /// 使用本地链接创建内容
    public init(local: String, duration: NSTimeInterval) {
        let l = local.stringByAddingPercentEncodingWithAllowedCharacters(.URLFragmentAllowedCharacterSet())!
        
        self.local = NSURL(string: "chat-audio://\(l)")!
        self.remote = NSURL(string: "chat-audio://\(l)")!
        
        self.duration = duration
    }
    /// 使用服务器链接创建内容
    public init(remote: String, duration: NSTimeInterval) {
        let r = remote.stringByAddingPercentEncodingWithAllowedCharacters(.URLFragmentAllowedCharacterSet())!
        
        self.local = NSURL(string: "chat-audio://\(r)")!
        self.remote = NSURL(string: "chat-audio://\(r)")!
        
        self.duration = duration
    }
    
    /// 音频在本地的路径, 只有在需要上传的时候这个值才会存在
    public let local: NSURL?
    /// 音频在服务器上的路径
    public let remote: NSURL
    /// 持续时间
    public let duration: NSTimeInterval
}
