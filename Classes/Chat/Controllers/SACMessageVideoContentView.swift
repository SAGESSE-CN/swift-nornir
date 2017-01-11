//
//  SACMessageVideoContentView.swift
//  SAChat
//
//  Created by sagesse on 05/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

open class SACMessageVideoContentView: UIView, SACMessageContentViewType {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _logger.trace()
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _logger.trace()
        _commonInit()
    }
    deinit {
        _logger.trace()
    }
    
    open func apply(_ message: SACMessageType) {
    }
    
    private func _commonInit() {
        
        backgroundColor = .random
    }
}
