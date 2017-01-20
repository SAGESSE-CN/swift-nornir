//
//  SACChatViewData.swift
//  SAChat
//
//  Created by sagesse on 09/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class SACChatViewData: NSObject {
    
    internal override init() {
        super.init()
    }
   
    
    var count: Int {
        return _elements.count
    }
    
    subscript(index: Int) -> SACMessageType {
        return _elements[index]
    }
    
    
    func subarray(with subrange: Range<Int>) -> Array<SACMessageType> {
        return Array(_elements[subrange])
    }
    
    func replaceSubrange(_ subrange: Range<Int>, with collection: Array<SACMessageType>)  {
        _elements.replaceSubrange(subrange, with: collection)
    }
    
    private weak var _chatView: SACChatView?
    internal lazy var _elements: [SACMessageType] = []
}
