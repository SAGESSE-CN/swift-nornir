//
//  SIMChatIResponder.swift
//  SIMChat
//
//  Created by sagesse on 10/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 响应者
protocol SIMChatIResponder {
    /// 响应者类型
    var type: Int { get }
    /// 响应者唯一标识符
    var identifier: String { get }
}
