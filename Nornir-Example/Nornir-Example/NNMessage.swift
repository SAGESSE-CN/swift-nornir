//
//  NNMessage.swift
//  Nornir
//
//  Created by SAGESSE on 12/13/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

open class NNMessage: NSObject, Message {
    
    /// The messge unique identifier.
    open var identifier: String = "Test"//UUID().uuidString
    
    /// The message sender.
    open var sender: User = NNUser()
    /// The message reciver.
    open var reciver: User = NNUser()
    
    /// The message display style.
    open var style: MessageStyle = .prominent
}
