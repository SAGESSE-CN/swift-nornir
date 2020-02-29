//
//  Progressiveable.swift
//  SAC
//
//  Created by SAGESSE on 10/13/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

///
/// progressiveable display protocol
///
@objc public protocol Progressiveable {
    
    var content: Any? { get }
    var progress: Double { get }
    
    ///
    /// Registers the observer object to receive KVO notifications for progressive value
    ///
    /// An object that calls this method must also eventually call either the
    /// removeProgressiveObserver(_:forKeyPath:) method to unregister the observer when participating in KVO.
    ///
    /// - Parameters:
    ///   - observer: The object to register for KVO notifications. 
    ///   - context: The context
    ///
    func addProgressiveChangeObserver(_ observer: ProgressiveChangeObserver, context: String)
    ///
    /// Stops the observer object from receiving change notifications for progressive value.
    ///
    /// It is an error to call removeProgressiveObserver(_:forKeyPath:) for 
    /// an object that has not previously been registered as an observer.
    ///
    /// - Parameters:
    ///   - observer: The object to remove as an observer.
    ///   - context: The context
    ///
    func removeProgressiveChangeObserver(_ observer: ProgressiveChangeObserver, context: String)
}

///
/// progressiveable change observer protocol
///
@objc public protocol ProgressiveChangeObserver: NSObjectProtocol {
    
    func progressiveValue(_ progressiveValue: Progressiveable?, didChangeContent value: Any?, context: String)
    func progressiveValue(_ progressiveValue: Progressiveable?, didChangeProgress value: Any?, context: String)
}

///
/// Provide progressive object store support
///
public extension NSObject {
    
    open dynamic func progressiveValue(forKey key: String) -> Progressiveable? {
        return _progressiveValues[key]
    }
    open dynamic func progressiveValue(forKeyPath keyPath: String) -> Progressiveable? {
        // split property
        guard let r = keyPath.range(of: "."), !r.isEmpty else {
            // no children propertys, read the current progressiveValue
            return self.progressiveValue(forKey: keyPath)
        }
        let sk = keyPath.substring(to: r.lowerBound)
        let skp = keyPath.substring(from: r.upperBound)
        // read children propertys
        let ob = self.value(forKey: sk) as? NSObject
        return ob?.progressiveValue(forKeyPath: skp)
    }
    
    open dynamic func setProgressiveValue(_ value: Progressiveable?, forKey key: String) {
        _progressiveValues[key] = value
    }
    open dynamic func setProgressiveValue(_ value: Progressiveable?, forKeyPath keyPath: String) {
        // split property
        guard let r = keyPath.range(of: "."), !r.isEmpty else {
            return self.setProgressiveValue(value, forKey: keyPath)
        }
        let sk = keyPath.substring(to: r.lowerBound)
        let skp = keyPath.substring(from: r.upperBound)
        // read children propertys
        let ob = self.value(forKey: sk) as? NSObject
        ob?.setProgressiveValue(value, forKeyPath: skp)
    }
    
    private static var _progressiveValuesKey: String = "_progressiveValuesKey"
    private var _progressiveValues: ProgressiveChangeObserveDictionary {
        return objc_getAssociatedObject(self, &NSObject._progressiveValuesKey) as? ProgressiveChangeObserveDictionary ?? {
            let dic = ProgressiveChangeObserveDictionary(observer: self)
            objc_setAssociatedObject(self, &NSObject._progressiveValuesKey, dic, .OBJC_ASSOCIATION_RETAIN)
            return dic
        }()
    }
}

///
/// Provide progressive object default imp support
///
public extension NSObject {
    
    @objc open dynamic func addProgressiveChangeObserver(_ observer: ProgressiveChangeObserver, context: String) {
        guard let _ = self as? Progressiveable else {
            return
        }
        let index = _progressiveObservers.indexOfObject { (asset, _, _) in
            guard let ob = asset as? ProgressiveChangeObserverTarget else {
                return false
            }
            guard ob.observer !== observer && ob.context != context else {
                return true // is added
            }
            return false
        }
        guard index == NSNotFound else {
            return // is added
        }
        _progressiveObservers.add(ProgressiveChangeObserverTarget(observer, context))
    }
    @objc open dynamic func removeProgressiveChangeObserver(_ observer: ProgressiveChangeObserver, context: String) {
        guard let _ = self as? Progressiveable else {
            return
        }
        let indexes = _progressiveObservers.indexesOfObjects { (asset, _, _) in
            guard let ob = asset as? ProgressiveChangeObserverTarget else {
                return false
            }
            guard ob.observer !== nil else {
                return true // is release
            }
            guard ob.observer !== observer && ob.context != context else {
                return true // is removed
            }
            return false
        }
        _progressiveObservers.removeObjects(at: indexes)
    }
    
    open dynamic func didChangeProgressiveContent() {
        guard let `self` = self as? Progressiveable else {
            return
        }
        let value = self.content
        _progressiveObservers.forEach {
            guard let ob = $0 as? ProgressiveChangeObserverTarget else {
                return
            }
            ob.observer?.progressiveValue(self, didChangeContent: value, context: ob.context)
        }
    }
    open dynamic func didChangeProgressiveProgress() {
        guard let `self` = self as? Progressiveable else {
            return
        }
        let value = self.progress
        _progressiveObservers.forEach {
            guard let ob = $0 as? ProgressiveChangeObserverTarget else {
                return
            }
            ob.observer?.progressiveValue(self, didChangeProgress: value, context: ob.context)
        }
    }
    
    
    // Ivar
    
    private static var _progressiveObserversKey: String = "_progressiveObserversKey"
    private var _progressiveObservers: NSMutableArray {
        return objc_getAssociatedObject(self, &NSObject._progressiveObserversKey) as? NSMutableArray ?? {
            let dic = NSMutableArray(capacity: 4)
            objc_setAssociatedObject(self, &NSObject._progressiveObserversKey, dic, .OBJC_ASSOCIATION_RETAIN)
            return dic
        }()
    }
}

///
/// Provide progressive object change observer default support
///
extension NSObject: ProgressiveChangeObserver {
    
    open dynamic func progressiveValue(_ progressiveValue: Progressiveable?, didChangeContent value: Any?, context: String) {
        setValue(value, forKeyPath: context)
    }
    
    open dynamic func progressiveValue(_ progressiveValue: Progressiveable?, didChangeProgress value: Any?, context: String) {
    }
}

private class ProgressiveChangeObserverTarget: NSObject {
    
    init(_ observer: ProgressiveChangeObserver, _ context: String) {
        self.context = context
        super.init()
        self.observer = observer
    }
    
    var context: String
    weak var observer: ProgressiveChangeObserver?
}

private class ProgressiveChangeObserveDictionary: NSObject {
    
    init(observer: ProgressiveChangeObserver) {
        super.init()
        // forward to observer
        _observer = observer
    }
    deinit {
        // clear observer
        _imp.forEach { 
            guard let key = $0 as? String, let ob = $1 as? Progressiveable else {
                return
            }
            ob.removeProgressiveChangeObserver(self, context: key)
        }
    }
    
    subscript(key: String) -> Progressiveable? {
        get {
            return _imp[key] as? Progressiveable
        }
        set { 
            let newValue = newValue
            let oldValue = _imp[key] as? Progressiveable
            // value is change?
            guard newValue !== oldValue else {
                return
            }
            
            oldValue?.removeProgressiveChangeObserver(self, context: key)
            
            _imp[key] = newValue
            
            progressiveValue(newValue, didChangeContent: newValue?.content, context: key)
            progressiveValue(newValue, didChangeProgress: newValue?.progress, context: key)
            newValue?.addProgressiveChangeObserver(self, context: key)
        }
    }
    
    override func progressiveValue(_ progressiveValue: Progressiveable?, didChangeContent value: Any?, context: String) {
        _observer?.progressiveValue(progressiveValue, didChangeContent: value, context: context)
    }
    override func progressiveValue(_ progressiveValue: Progressiveable?, didChangeProgress value: Any?, context: String) {
        _observer?.progressiveValue(progressiveValue, didChangeProgress: value, context: context)
    }
    
    private lazy var _imp: NSMutableDictionary = NSMutableDictionary(capacity: 4)
    private weak var _observer: ProgressiveChangeObserver?
}

