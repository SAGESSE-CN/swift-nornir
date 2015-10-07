//
//  SIMChatMessageContent+Tips.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 提示消息
class SIMChatMessageContentTips: SIMChatMessageContent {
    /// 初始化
    convenience init(tips: String) {
        self.init()
        self.tips = tips
    }
    /// 提示
    var tips: String?
}
