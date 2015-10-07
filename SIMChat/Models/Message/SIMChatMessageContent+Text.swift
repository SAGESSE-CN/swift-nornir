//
//  SIMChatMessageContent+Text.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 纯文本消息
class SIMChatMessageContentText: SIMChatMessageContent {
    /// 初始化
    convenience init(text: String) {
        self.init()
        self.text = text
        self.attributedText = self.dynamicType.makeAttribText(text)
    }
    /// 文本
    var text: String? {
        willSet {
            // 必须有改变
            guard newValue != text else {
                return
            }
            self.attributedText = self.dynamicType.makeAttribText(newValue)
        }
    }
    /// 带属性的文本
    var attributedText: NSAttributedString?
}

// MARK: - Emoji
extension SIMChatMessageContentText {
    /// 生成
    class func makeAttribText(text: String?) -> NSAttributedString? {
        // 必须有内容
        guard let text = text else {
            return nil
        }
        // :)
        let mas = NSMutableAttributedString(string: text)
        
//        let ta = SIMChatEmojiAttachment(emoji: "he", attributedText: mas)
//        
//        mas.insertAttributedString(NSAttributedString(attachment: ta), atIndex: 0)
        
        // {xxx-xxx}
        
        return mas
    }
}