//
//  SACUser.swift
//  SAChat
//
//  Created by SAGESSE on 01/11/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

open class SACUser: NSObject, SACUserType {
    
    public init(name: String) {
        super.init()
        self.name = name
    }
    
    /// 用户ID(唯一标识符)
    public let identifier: String = UUID().uuidString
    
    /// 昵称
    open var name: String?
    /// 用户头像
    open var portrait: String?

}
