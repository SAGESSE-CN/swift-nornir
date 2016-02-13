//
//  SIMChatMediaProvider.swift
//  SIMChat
//
//  Created by sagesse on 1/21/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation


public class SIMChatMediaProvider {
    
    public init(fileProvider: SIMChatFileProvider) {
        self.fileProvider = fileProvider
    }
    
    public func playWithMessage(message: SIMChatMessageProtocol) {
        let center = SIMChatNotificationCenter.self
        // 如果是音频
        if let content = message.content as? SIMChatBaseMessageAudioContent {
            let isLoaded = fileProvider.cached(content.remote)
            if !isLoaded {
                center.postNotificationName(SIMChatAudioManagerWillLoadNotification, object: message)
            }
            fileProvider.download(content.remote)
                .response { r in
                    if !isLoaded {
                        center.postNotificationName(SIMChatAudioManagerDidLoadNotification, object: message)
                    }
                    SIMLog.debug(r.error)
                    SIMLog.debug(r.value)
                    center.postNotificationName(SIMChatAudioManagerWillPlayNotification, object: message)
                    
                    dispatch_after_at_now(1, dispatch_get_main_queue()) {
                        center.postNotificationName(SIMChatAudioManagerDidPlayNotification, object: message)
                        dispatch_after_at_now(4, dispatch_get_main_queue()) {
                            center.postNotificationName(SIMChatAudioManagerWillStopNotification, object: message)
                            center.postNotificationName(SIMChatAudioManagerDidStopNotification, object: message)
                        }
                    }
                }
        }
        
    }
    
    /// 关联的文件提供者
    private var fileProvider: SIMChatFileProvider
}