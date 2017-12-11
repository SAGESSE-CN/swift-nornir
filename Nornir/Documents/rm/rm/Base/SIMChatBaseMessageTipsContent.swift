//
//  SIMChatBaseContent+Tips.swift
//  SIMChat
//
//  Created by sagesse on 1/20/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation


///
/// 提示信息
///
public class SIMChatBaseMessageTipsContent: SIMChatMessageBody {
    ///
    /// 初始化
    ///
    public init(content: String) {
        self.content = content
    }
    /// 内容
    public let content: String
}
