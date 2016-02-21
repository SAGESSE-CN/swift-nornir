//
//  SIMChatMediaProvider.swift
//  SIMChat
//
//  Created by sagesse on 1/21/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation


public class SIMChatMediaProvider {
    
    // 当前正在播放的
    var playing: SIMChatMessageContentProtocol?
    
    public init(fileProvider: SIMChatFileProvider) {
        self.fileProvider = fileProvider
    }
    
    public func isMedia(content: SIMChatMessageContentProtocol) -> Bool {
        return content is SIMChatBaseMessageAudioContent
    }
    public func isPlaying(content: SIMChatMessageContentProtocol) -> Bool {
        return playing === content
    }
    
    public func playMedia(content: SIMChatMessageContentProtocol) {
        let center = SIMChatNotificationCenter.self
        // 如果是音频
        if let content = content as? SIMChatBaseMessageAudioContent {
            // 如果正在下载/正在播放, 忽略该次操作
            guard !content.downloading && !content.playing else {
                return
            }
            let isLoaded = fileProvider.cached(content.remote)
            if !isLoaded {
                center.postNotificationName(SIMChatAudioManagerWillLoadNotification, object: content)
            }
            content.downloading = true
            fileProvider.download(content.remote)
                .response { r in
                    if !isLoaded {
                        center.postNotificationName(SIMChatAudioManagerDidLoadNotification, object: content)
                    }
                    SIMLog.debug(r.error)
                    SIMLog.debug(r.value)
                    
                    content.downloading = false
                    content.playing = true
                    center.postNotificationName(SIMChatAudioManagerWillPlayNotification, object: content)
                    
                    dispatch_after_at_now(0.5, dispatch_get_main_queue()) {
                        content.played = true
                        center.postNotificationName(SIMChatAudioManagerDidPlayNotification, object: content)
                        dispatch_after_at_now(4, dispatch_get_main_queue()) {
                            content.playing = false
                            center.postNotificationName(SIMChatAudioManagerWillStopNotification, object: content)
                            center.postNotificationName(SIMChatAudioManagerDidStopNotification, object: content)
                        }
                    }
            }
        }
    }
    
//    public func playWithMessage(message: SIMChatMessageProtocol) {
//        let center = SIMChatNotificationCenter.self
//        // 如果是音频
//        if let content = message.content as? SIMChatBaseMessageAudioContent {
//            let isLoaded = fileProvider.cached(content.remote)
//            if !isLoaded {
//                center.postNotificationName(SIMChatAudioManagerWillLoadNotification, object: message)
//            }
//            fileProvider.download(content.remote)
//                .response { r in
//                    if !isLoaded {
//                        center.postNotificationName(SIMChatAudioManagerDidLoadNotification, object: message)
//                    }
//                    SIMLog.debug(r.error)
//                    SIMLog.debug(r.value)
//                    center.postNotificationName(SIMChatAudioManagerWillPlayNotification, object: message)
//                    
//                    dispatch_after_at_now(0.5, dispatch_get_main_queue()) {
//                        center.postNotificationName(SIMChatAudioManagerDidPlayNotification, object: message)
//                        dispatch_after_at_now(4, dispatch_get_main_queue()) {
//                            center.postNotificationName(SIMChatAudioManagerWillStopNotification, object: message)
//                            center.postNotificationName(SIMChatAudioManagerDidStopNotification, object: message)
//                        }
//                    }
//                }
//        }
//    }
    
    /// 关联的文件提供者
    private var fileProvider: SIMChatFileProvider
}