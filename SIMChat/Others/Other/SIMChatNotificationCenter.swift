//
//  SIMChatNotificationCenter.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SIMChatNotificationCenter: NSNotificationCenter {
    // 默认的, 但不是系统的那个(不能用系统的那个. 严重影响效率)
    override class func defaultCenter() -> SIMChatNotificationCenter {
        return self.sharedInstance
    }
    // 应该是自动lazy的
    private static let sharedInstance = SIMChatNotificationCenter()
}

// MARK: - helper
extension SIMChatNotificationCenter {
    class func addObserver(observer: AnyObject, selector aSelector: Selector, name aName: String?, object anObject: AnyObject? = nil) {
        return self.defaultCenter().addObserver(observer, selector: aSelector, name: aName, object: anObject)
    }
    class func addObserverForName(name: String?, object obj: AnyObject?, queue: NSOperationQueue?, usingBlock block: (NSNotification) -> Void) -> NSObjectProtocol {
        return self.defaultCenter().addObserverForName(name, object: obj, queue: queue, usingBlock: block)
    }
    
    class func removeObserver(observer: AnyObject) {
        return self.defaultCenter().removeObserver(observer)
    }
    class func removeObserver(observer: AnyObject, name aName: String?, object anObject: AnyObject? = nil) {
        return self.defaultCenter().removeObserver(observer, name: aName, object: anObject)
    }
    
    class func postNotification(notification: NSNotification) {
        return self.defaultCenter().postNotification(notification)
    }
    class func postNotificationName(aName: String, object anObject: AnyObject?) {
        return self.defaultCenter().postNotificationName(aName, object: anObject)
    }
    class func postNotificationName(aName: String, object anObject: AnyObject?, userInfo aUserInfo: [NSObject : AnyObject]?) {
        return self.defaultCenter().postNotificationName(aName, object: anObject, userInfo: aUserInfo)
    }
}


