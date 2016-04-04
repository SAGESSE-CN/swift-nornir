//
//  SIMChatBaseContent+Text.swift
//  SIMChat
//
//  Created by sagesse on 1/20/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation


///
/// 文本
///
public class SIMChatBaseMessageTextContent: SIMChatMessageBody {
    ///
    /// 初始化
    ///
    public init(content: String) {
        self.content = content
    }
    /// 内容
    public let content: String
}
