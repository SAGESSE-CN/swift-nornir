//
//  SIMChatBaseContent+Audio.swift
//  SIMChat
//
//  Created by sagesse on 1/20/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation


extension SIMChatBaseContent {
    ///
    /// 音频
    ///
    public class Audio: SIMChatContentProtocol {
        ///
        /// 初始化
        ///
        public init(content: String) {
            self.content = content
        }
        /// 内容(本地路径)
        public let content: String
    }
}