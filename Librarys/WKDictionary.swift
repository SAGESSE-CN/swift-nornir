//
//  WKDictionary.swift
//  SAPhotos
//
//  Created by SAGESSE on 11/8/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

public struct WKDictionary<Key: Hashable, Value: AnyObject>: ExpressibleByDictionaryLiteral {
    
    /// Creates an instance
    public init() {
    }
    
    /// Creates an instance initialized with the given key-value pairs.
    public init(dictionaryLiteral elements: (Key, Value)...) {
        elements.map { 
            _imp[$0] = WKDictionaryObject(v: $1)
        }
    }
    
    public subscript(key: Key) -> Value? {
        get { return _imp[key]?.v }
        set { return _imp[key] = WKDictionaryObject(v: newValue) }
    }
    
    public var isEmpty: Bool {
        return _imp.contains {
            $0.value.v != nil
        }
    }
    
    public func forEach(_ body: (Key, Value) throws -> Void) rethrows {
        try _imp.forEach { 
            guard let v = $1.v else {
                return
            }
            try body($0, v)
        }
    }
    
    private var _imp: Dictionary<Key, WKDictionaryObject<Value>> = [:]
}

private struct WKDictionaryObject<Value: AnyObject> {
    weak var v: Value?
}
