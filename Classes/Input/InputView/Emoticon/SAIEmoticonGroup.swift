//
//  SAIEmoticonGroup.swift
//  SAC
//
//  Created by SAGESSE on 9/15/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

public enum SAIEmoticonType: Int {
    
    case small = 0
    case large = 1
    
    public var isSmall: Bool { return self == .small }
    public var isLarge: Bool { return self == .large }
}

open class SAIEmoticonGroup: NSObject {
    
    open lazy var id: String = UUID().uuidString
    
    open var title: String?
    open var thumbnail: UIImage?
    
    open var type: SAIEmoticonType = .small
    open var emoticons: [SAIEmoticon] = []
}

