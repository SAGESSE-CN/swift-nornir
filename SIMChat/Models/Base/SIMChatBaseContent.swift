//
//  SIMChatBaseContent.swift
//  SIMChat
//
//  Created by sagesse on 1/16/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit


///
/// 打包起来
///
public struct SIMChatBaseContent {}

// MARK: - Base

extension SIMChatBaseContent {
    ///
    /// 文本
    ///
    public class Text: SIMChatContentProtocol {
        ///
        /// 初始化
        ///
        public init(content: String) {
            self.content = content
        }
        /// 内容
        public let content: String
    }
    ///
    /// 图片
    ///
    public class Image: SIMChatContentProtocol {
        ///
        /// 初始化
        ///
        public init(content: String) {
            self.content = content
        }
        
        public var size: CGSize = CGSizeZero
        public var image: UIImage?
        /// 内容(本地路径)
        public let content: String
    }
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

// MARK: - Util

extension SIMChatBaseContent {
    ///
    /// 提示信息
    ///
    public class Tips: SIMChatContentProtocol {
        ///
        /// 初始化
        ///
        public init(content: String) {
            self.content = content
        }
        /// 内容
        public let content: String
    }
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