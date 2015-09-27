//
//  SIMAttr.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import Foundation

prefix operator * {}

///
/// 抽象属性
///
class SIMAttr <T> {
    
    convenience init(value: T) {
        self.init()
        self.storage = value
    }
    
    func set(v: T) {
        self.willSet?(v)
        self.setter?(v)
        self.storage = v
        self.didSet?(v)
    }
    func get() -> T? {
        if let v = self.storage {
            self.getter?(v)
        }
        return self.storage
    }
    
    func setter(op: (T -> Void)?) -> Self {
        self.setter = op
        return self
    }
    func getter(op: (T -> Void)?) -> Self {
        self.getter = op
        return self
    }
    
    func willSet(op: (T? -> Void)?) -> Self {
        self.willSet = op
        return self
    }
    func didSet(op: (T? -> Void)?) -> Self {
        self.didSet = op
        return self
    }
    
    func clean() {
        self.setter = nil
        self.getter = nil
        self.willSet = nil
        self.didSet = nil
    }
    
    var storaged: Bool { 
        return self.storage != nil 
    }
    
    var storage: T?
    
    private(set) var setter: (T -> Void)?
    private(set) var getter: (T -> Void)?
    
    private(set) var willSet: (T? -> Void)?
    private(set) var didSet: (T? -> Void)?
}

///
/// 懒加载(同步)
///
class SIMLazyAttr <T> : SIMAttr <T> {
    
    convenience init(lazyer: Void -> T) {
        self.init()
        self.lazyer(lazyer)
    }
    
    override func get() -> T? {
        // 需要加载并且未加载
        if !self.storaged && self.lazyer != nil {
            self.willSet?(self.storage)
            let v = self.lazyer!()
            self.lazyer = nil
            self.setter?(v)
            self.storage = v
            self.didSet?(v)
        }
        return super.get()
    }
    
    func lazyer(op: Void -> T) -> Self {
        self.lazyer = op
        self.storage = nil
        return self
    }
    
    private(set) var lazyer: (Void -> T)?
}

///
/// 懒加载(异步)
///
class SIMAsyncLazyAttr <T> : SIMAttr <T> {
    
    convenience init(lazyer: (T -> Void) -> Void) {
        self.init()
        self.lazyer(lazyer)
    }
    
    override func get() -> T? {
        // 需要加载并且未加载
        if !self.storaged && !self.storaging {
            self.willSet?(self.storage)
            self.storaging = true
            self.lazyer! { [weak self] v in
                self?.setter?(v)
                self?.storage = v
                self?.didSet?(v)
                self?.lazyer = nil
                self?.storaging = false
            }
        }
        return super.get()
    }
    
    func lazyer(op: (T -> Void) -> Void) -> Self {
        self.lazyer = op
        self.storage = nil
        self.storaging = false
        return self
    }
    
    private var storaging = false
    private(set) var lazyer: ((T -> Void) -> Void)?
}


func ~><T>(lhs: SIMAttr<T>, rhs: T) {
    lhs.set(rhs)
}
func ~><T>(lhs: SIMAttr<T?>, rhs: T) {
    lhs.set(rhs)
}
func ~><T, B>(lhs: SIMAttr<T>?, rhs: B) {
    if let lhs = lhs {
        lhs ~> rhs
    }
}
func ~><T>(lhs: SIMLazyAttr<T>, rhs: Void -> T) {
    lhs.lazyer(rhs)
}
func ~><T>(lhs: SIMAsyncLazyAttr<T>, rhs: (T -> Void) -> Void) {
    lhs.lazyer(rhs)
}


prefix func *<T>(lhs: SIMLazyAttr<T>) -> T {
    return lhs.get()!
}
prefix func *<T>(lhs: SIMAsyncLazyAttr<T>) -> T {
    return lhs.get()!
}