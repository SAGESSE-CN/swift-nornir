//
//  SIMChatNotificationCenter.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SIMChatNotificationCenter: NotificationCenter {
    // 默认的, 但不是系统的那个(不能用系统的那个. 严重影响效率)
    override class var `default`: SIMChatNotificationCenter { 
        return self.sharedInstance
    }
    // 应该是自动lazy的
    private static let sharedInstance = SIMChatNotificationCenter()
}

// MARK: - helper
extension SIMChatNotificationCenter {
    class func addObserver(_ observer: AnyObject, selector aSelector: Selector, name aName: String?, object anObject: AnyObject? = nil) {
        return self.default.addObserver(observer, selector: aSelector, name: aName.map { NSNotification.Name(rawValue: $0) }, object: anObject)
    }
    class func addObserverForName(_ name: String?, object obj: AnyObject?, queue: OperationQueue?, usingBlock block: @escaping (Notification) -> Void) -> NSObjectProtocol {
        return self.default.addObserver(forName: name.map { NSNotification.Name(rawValue: $0) }, object: obj, queue: queue, using: block)
    }
    
    class func removeObserver(_ observer: AnyObject) {
        return self.default.removeObserver(observer)
    }
    class func removeObserver(_ observer: AnyObject, name aName: String?, object anObject: AnyObject? = nil) {
        return self.default.removeObserver(observer, name: aName.map { NSNotification.Name(rawValue: $0) }, object: anObject)
    }
    
    class func postNotification(_ notification: Notification) {
        return self.default.post(notification)
    }
    class func postNotificationName(_ aName: String, object anObject: AnyObject?) {
        return self.default.post(name: Notification.Name(rawValue: aName), object: anObject)
    }
    class func postNotificationName(_ aName: String, object anObject: AnyObject?, userInfo aUserInfo: [NSObject : AnyObject]?) {
        return self.default.post(name: Notification.Name(rawValue: aName), object: anObject, userInfo: aUserInfo)
    }
}


