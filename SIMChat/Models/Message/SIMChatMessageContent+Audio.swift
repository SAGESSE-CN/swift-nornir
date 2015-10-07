//
//  SIMChatMessageContent+Audio.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 音频消息
class SIMChatMessageContentAudio: SIMChatMessageContent {
    /// 初始化
    convenience init(url: NSURL, duration: NSTimeInterval) {
        self.init()
        
        self.url ~> url
        self.duration = duration
    }
    
    // 配置
    var played = false
    var playing = false
    
    var url = SIMAsyncLazyAttr<NSURL?>()
    var duration = NSTimeIntervalSince1970
}

extension SIMChatMessageContentAudio {
    var durationText: String {
        if self.duration < 60 {
            return String(format: "%d''", Int(self.duration % 60))
        }
        return String(format: "%d'%02d''", Int(self.duration / 60), Int(self.duration % 60))
    }
}