//
//  SIMChatBaseMessageTimeLineContent.swift
//  SIMChat
//
//  Created by sagesse on 1/20/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation


///
/// 日期信息(抽象的)
///
public class SIMChatBaseMessageTimeLineContent: SIMChatMessageContentProtocol {
    ///
    /// 初始化
    ///
    public init(frontMessage: SIMChatMessageProtocol?, backMessage: SIMChatMessageProtocol?) {
        self.frontMessage = frontMessage
        self.backMessage = backMessage
    }
    
    /// 前面的消息
    public weak var frontMessage: SIMChatMessageProtocol?
    /// 后面的消息
    public weak var backMessage: SIMChatMessageProtocol?
}
