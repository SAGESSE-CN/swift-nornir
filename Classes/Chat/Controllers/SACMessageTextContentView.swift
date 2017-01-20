//
//  SACMessageTextContentView.swift
//  SAChat
//
//  Created by sagesse on 05/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit
import YYText

open class SACMessageTextContentView: YYLabel, SACMessageContentViewType {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    open func apply(_ message: SACMessageType) {
        guard let content = message.content as? SACMessageTextContent else {
            return
        }
        textLayout = content.attributedText
        textColor = message.options.alignment == .right ? UIColor.white : UIColor.black
    }
    
    private func _commonInit() {
        
        numberOfLines = 0
    }
}
