//
//  SIMChatMessageContent+Image.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 图片消息
class SIMChatMessageContentImage: SIMChatMessageContent {
    /// 初始化
    convenience init(origin: UIImage?, thumbnail: UIImage? = nil) {
        self.init()
        self.origin ~> origin
        self.originSize = origin?.size ?? CGSizeZero
        self.thumbnail ~> (thumbnail ?? origin)
        self.thumbnailSize = (thumbnail ?? origin)?.size ?? CGSizeZero
    }
    // 图片(允许)
    var origin = SIMAsyncLazyAttr<UIImage?>()
    var thumbnail = SIMAsyncLazyAttr<UIImage?>()
    // 图片配置
    var originSize = CGSizeZero
    var thumbnailSize = CGSizeZero
    // 远端路径
    var originPath: String?
    var thumbnailPath: String?
}
