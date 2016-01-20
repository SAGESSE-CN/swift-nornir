//
//  SIMChatBaseContent+Date.swift
//  SIMChat
//
//  Created by sagesse on 1/20/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation


extension SIMChatBaseContent {
    ///
    /// 日期信息
    ///
    public class Date: SIMChatContentProtocol {
        ///
        /// 初始化
        ///
        public init(content: NSDate) {
            self.content = content
        }
        /// 内容
        public let content: NSDate
    }
}