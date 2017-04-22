//
//  EventCenter.swift
//  Ubiquity
//
//  Created by SAGESSE on 4/20/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class EventCenter: NSObject {
    fileprivate class EventItem: NSObject {
        init(target: AnyObject, action: Selector, event: UIControlEvents) {
            self.target = target
            self.action = action
            self.event = event
            super.init()
        }
        var event: UIControlEvents
        var action: Selector
        weak var target: AnyObject?
    }
    
    func apply(_ control: UIControl) {
        logger.trace?.write(type(of: control))
        
        let oldValue = _control
        let newValue = control
        guard oldValue  !== newValue else {
            return
        }
        _control = newValue
        _items.forEach {
            oldValue?.removeTarget($0.target, action: $0.action, for: $0.event)
            newValue.addTarget($0.target, action: $0.action, for: $0.event)
        }
    }
    
    // add target/action for particular event. you can call this multiple times and you can specify multiple target/actions for a particular event.
    // the action cannot be NULL. Note that the target is not retained.
    func addTarget(_ target: AnyObject, action: Selector, for controlEvents: UIControlEvents) {
        logger.trace?.write()
        
        let item = EventItem(target: target, action: action, event: controlEvents)
        _items.append(item)
        _control?.addTarget(target, action: action, for: controlEvents)
    }
    
    // remove the target/action for a set of events. pass in NULL for the action to remove all actions for that target
    func removeTarget(_ target: AnyObject?, action: Selector?, for controlEvents: UIControlEvents) {
        logger.trace?.write()
        
        _items = _items.filter {
            guard controlEvents.contains($0.event) else {
                return false
            }
            guard target == nil || $0.target === target else {
                return false
            }
            guard action == nil || $0.action == action else {
                return false
            }
            return true
        }
        _control?.removeTarget(target, action: action, for: controlEvents)
    }
    
    private lazy var _items: [EventItem] = []
    private weak var _control: UIControl?
}
