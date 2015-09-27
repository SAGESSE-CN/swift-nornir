//
//  SIMChatContent+Audio.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 音频消息
class SIMChatContentAudio: SIMChatContent {
    /// 初始化
    convenience init(url: NSURL, duration: NSTimeInterval) {
        self.init()
        
        self.url ~> { f in
            // TODO: 模拟1s的加载时间
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1000 * NSEC_PER_MSEC)), dispatch_get_main_queue()) {
                f(url)
            }
        }
        self.duration = duration
    }
    
    // 配置
    var played = false
    var playing = false
    
    var url = SIMAsyncLazyAttr<NSURL?>()
    var duration = NSTimeIntervalSince1970
}

extension SIMChatContentAudio {
    var durationText: String {
        if self.duration < 60 {
            return String(format: "%d''", Int(self.duration % 60))
        }
        return String(format: "%d'%02d''", Int(self.duration / 60), Int(self.duration % 60))
    }
}