//
//  SIMChatMessageBody.swift
//  SIMChat
//
//  Created by sagesse on 10/20/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import Foundation

///
/// 抽象的消息内容协议.
///
public protocol SIMChatMessageBody: class {
}

/// 提供默认支持
extension NSObject: SIMChatMessageBody {
}