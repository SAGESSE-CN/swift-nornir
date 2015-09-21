//
//  SIMChatContent+Text.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 纯文本消息
class SIMChatContentText: SIMChatContent {
    /// 初始化
    convenience init(text: String) {
        self.init()
        self.text = text
    }
    /// 提示
    var text: String?
}
