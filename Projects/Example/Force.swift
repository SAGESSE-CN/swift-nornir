//
//  SIMHelper+Force.swift
//  TTTTT
//
//  Created by sagesse on 10/8/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit


extension NSObject {
    /// 自省
    public func scheck() {
        
        var ivarcnt: UInt32 = 0
        var propertycnt: UInt32 = 0
        var methodcnt: UInt32 = 0
        //var protocolcnt: UInt32 = 0
        
        let ivars = class_copyIvarList(type(of: self), &ivarcnt)
        let propertys = class_copyPropertyList(type(of: self), &propertycnt)
        let methods = class_copyMethodList(type(of: self), &methodcnt)
        //let protocols = class_copyProtocolList(self.dynamicType, &protocolcnt)
        
        let className = NSStringFromClass(type(of: self))
       
        for i in 0 ..< ivarcnt {
            let v = ivars?.advanced(by: Int(i)).pointee
            let name = NSString(utf8String: ivar_getName(v)) ?? "<Unknow>"
            let type = NSString(utf8String: ivar_getTypeEncoding(v)) ?? "<Unknow>"
            let offset = ivar_getOffset(v)
            print("[SCheck]: \(className).ivar: \(name)(\(offset)) => \(type)")
        }
        for i in 0 ..< propertycnt {
            let v = propertys?.advanced(by: Int(i)).pointee
            let name = NSString(utf8String: property_getName(v)) ?? "<Unknow>"
            let type = NSString(utf8String: property_getAttributes(v)) ?? "<Unknow>"
            print("[SCheck]: \(className).property: \(name) => \(type)")
        }
        for i in 0 ..< methodcnt {
            let v = methods?.advanced(by: Int(i)).pointee
            let name = NSStringFromSelector(method_getName(v))
            let type = NSString(utf8String: method_getTypeEncoding(v)) ?? "<Unknow>"
            print("[SCheck]: \(className).method: \(name) => \(type)")
        }
        
        //free(protocols)
        free(methods)
        free(propertys)
        free(ivars)
    }
}

extension UIView {
    public func scheckView() {
        print(value(forKey: "recursiveDescription") as! NSString)
    }
    public func viewController() -> UIViewController? {
        var sv: UIView? = self
        while sv != nil {
            if sv?.next?.isKind(of: UIViewController.self) ?? false {
                return sv?.next as? UIViewController
            }
            sv = sv?.superview
        }
        return nil
    }
}
