//
//  SIMChatIConversation.swift
//  SIMChat
//
//  Created by sagesse on 10/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 会放接口
protocol SIMChatIConversation {
    
    func query(count: Int, last: SIMChatMessage?, finish: ([SIMChatMessage] -> Void)?, fail: (NSError -> Void)?)
    
    func send(m: SIMChatMessage, isResend: Bool, finish: (Void -> Void)?, fail: (NSError -> Void)?)
    func remove(m: SIMChatMessage, finish: (Void -> Void)?, fail: (NSError -> Void)?)
    func update(m: SIMChatMessage, finish: (Void -> Void)?, fail: (NSError -> Void)?)
    
    func reciveForRemote(m: SIMChatMessage)
    func removeForRemote(m: SIMChatMessage)
    func updateForRemote(m: SIMChatMessage)
}
