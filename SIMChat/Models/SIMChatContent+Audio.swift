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
    convenience init(data: NSData?, duration: NSTimeInterval) {
        self.init()
        self.data ~> data
        self.duration = duration
    }
    // 音频
    var data = SIMAsyncLazyAttr<NSData?>()
    // 配置
    var played = false
    var playing = false
    var duration = NSTimeIntervalSince1970
}

extension SIMChatContentAudio {
    var durationText: String {
        if self.duration < 60 {
            return String(format: "%.0lf''", self.duration % 60)
        }
        return String(format: "%.0f'%02.0f''", self.duration / 60, self.duration % 60)
    }
}