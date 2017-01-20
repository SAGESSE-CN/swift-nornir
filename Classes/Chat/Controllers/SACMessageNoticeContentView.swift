//
//  SACMessageNoticeContentView.swift
//  SAChat
//
//  Created by sagesse on 06/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit
import YYText

open class SACMessageNoticeContentView: YYLabel, SACMessageContentViewType {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }

    
    open func apply(_ message: SACMessageType) {
        guard let content = message.content as? SACMessageNoticeContent else {
            return
        }
        textLayout = content.attributedText
    }
    
    private func _commonInit() {
        
        numberOfLines = 0
    }
}
