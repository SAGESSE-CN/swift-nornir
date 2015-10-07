//
//  SIMChatMessageContent+Time.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 日期消息
class SIMChatMessageContentDate: SIMChatMessageContent {
    /// 初始化
    convenience init(date: NSDate) {
        self.init()
        self.date = date
    }
    /// 日期
    var date: NSDate = .zero
}
