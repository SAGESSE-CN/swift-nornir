//
//  ChatViewLayoutAttributes.swift
//  Nornir
//
//  Created by sagesse on 15/12/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

open class ChatViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var message: Message?
    
    var conversation: Conversation?
    
    var preferredLayout: ComputedCustomLayout?
}
