//
//  SIMChatGroup.swift
//  SIMChat
//
//  Created by sagesse on 10/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 普通群组
class SIMChatGroup: NSObject, SIMChatIResponder {
    /// 初始化
    init(identifier: String, name: String? = nil, portrait: String? = nil) {
        self.name = name
        self.portrait = portrait
        self.identifier = identifier
        super.init()
    }
    var name: String?
    var portrait: String?
    
    /// 附加数据
    var extra: AnyObject?
    
    /// 响应者唯一标识符
    let identifier: String
    /// 响应者类型
    var type: Int {
        return 2 // 群组 
    }
}
