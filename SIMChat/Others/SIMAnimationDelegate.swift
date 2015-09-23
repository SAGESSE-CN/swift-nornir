//
//  SIMAnimationDelegate.swift
//  SIMChat
//
//  Created by sagesse on 9/23/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SIMAnimationEndDelegate : NSObject {
    init(block: (Bool)->()) {
        self.block = block 
        super.init()
    }
    
    private var block: (Bool)->()
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        block(flag)
    }
}
