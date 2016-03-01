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
    ///
    /// 使用本地链接创建内容
    ///
    /// - parameter path: 音频文件地址
    /// - parameter duration: 音频文件时长
    ///
    public init(path: String, duration: NSTimeInterval) {
        let parser = SIMChatBaseFileParser.sharedInstance()
        
        let originURL = parser.encode(path)
        
        self.localURL = originURL
        self.remoteURL = originURL
        
        self.duration = duration
    }
    ///
    /// 使用服务器链接创建内容
    ///
    /// - parameter path: 音频文件地址
    /// - parameter duration: 音频文件时长
    ///
    public init(URL: NSURL,duration: NSTimeInterval) {
        let parser = SIMChatBaseFileParser.sharedInstance()
        
        let originURL = parser.encode(URL)
        
        self.localURL = originURL
        self.remoteURL = originURL
        
        self.duration = duration
    }
    
    public var played: Bool = false
    public var playing: Bool = false
    //public var downloaded: Bool = false
    public var downloading: Bool = false
    
    /// 音频在本地的路径, 只有在需要上传的时候这个值才会存在
    public let localURL: NSURL?
    
    /// 持续时间
    public let duration: NSTimeInterval
    /// 音频在服务器上的路径
    public let remoteURL: NSURL
}

public let SIMChatMessageAudioContentType = "simchat.audio"