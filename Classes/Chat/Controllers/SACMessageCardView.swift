//
//  SACMessageCardView.swift
//  SAChat
//
//  Created by sagesse on 05/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

//
// +--------+
// |  Name  |
// +--------+
//       

open class SACMessageCardView: UILabel, SACMessageContentViewType {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    open func apply(_ message: SACMessageType) {
        
        let isRight = message.options.alignment == .right
        
        text = message.name
        textAlignment = isRight ? .right : .left
    }
    
    private func _commonInit() {
        
        font = UIFont.systemFont(ofSize: 14)
        textColor = UIColor(white: 0.48, alpha: 1)
    }
}

