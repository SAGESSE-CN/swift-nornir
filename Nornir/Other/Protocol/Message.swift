//
//  Message.swift
//  Nornir
//
//  Created by sagesse on 13/12/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import Foundation

public enum MessageStyle: Hashable {
    
    /// The is a normal message.
    /// Reference by QQ, WeChat, Discord.
    case prominent
    
    /// The is a normal message whitout `name`.
    /// Reference by QQ.
    case minimal
    
    /// The is a system message.
    case notice
    
    /// The is a custom message.
    case custom(String)
    
    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int {
        switch self {
        case .prominent:
            return 1
            
        case .minimal:
            return 2
            
        case .notice:
            return 3
            
        case .custom(let identifier):
            return identifier.hashValue
        }
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    public static func ==(lhs: MessageStyle, rhs: MessageStyle) -> Bool {
        switch (lhs, rhs) {
        case (.prominent, .prominent):
            return true
            
        case (.minimal, .minimal):
            return true
            
        case (.notice, .notice):
            return true
            
        case (.custom(let lhs), .custom(let rhs)):
            return lhs == rhs
            
        default:
            return false
        }
    }
}

public protocol Message {
    
    /// The messge unique identifier.
    var identifier: String { get }
    
    /// The message sender.
    var sender: User { get }
    /// The message reciver.
    var reciver: User { get }
    
    /// The message display style.
    var style: MessageStyle { get }
}
