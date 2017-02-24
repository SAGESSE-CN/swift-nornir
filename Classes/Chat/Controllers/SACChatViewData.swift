//
//  SACChatViewData.swift
//  SAChat
//
//  Created by sagesse on 09/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class SACChatViewData: NSObject, NSCopying {
    
    internal override init() {
        self.elements = []
        super.init()
    }
    internal init(elements: [SACMessageType]) {
        self.elements = elements
        super.init()
    }
   
    internal var count: Int {
        return elements.count
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return SACChatViewData(elements: self.elements)
    }
    
    
    internal subscript(index: Int) -> SACMessageType {
        return elements[index]
    }
    
    
    internal func subarray(with subrange: Range<Int>) -> Array<SACMessageType> {
        return Array(elements[subrange])
    }
    
    internal func replaceSubrange(_ subrange: Range<Int>, with collection: Array<SACMessageType>)  {
        elements.replaceSubrange(subrange, with: collection)
    }
    
    
    internal var elements: [SACMessageType] 
}
