//
//  SIMChatBaseContent+Image.swift
//  SIMChat
//
//  Created by sagesse on 1/20/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit


extension SIMChatBaseContent {
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
        
        /// 是否己经加载了
        public var isLoaded: Bool {
            return false
        }
        /// 加载文件
        public func load() -> SIMChatRequest<String> {
            return SIMChatRequest.requestOnThread(dispatch_get_global_queue(0, 0)) {
                guard !self.isLoaded else {
                    // 己经下载了..
                    return $0.success("test")
                }
                // 如果并没有.
                $0
            }
        }
    }
}