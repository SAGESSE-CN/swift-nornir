//
//  SACMessageTimeLineContentView.swift
//  SAChat
//
//  Created by sagesse on 06/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

open class SACMessageTimeLineContentView: UILabel, SACMessageContentViewType {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    open func apply(_ message: SACMessageType) {
        guard let content = message.content as? SACMessageTimeLineContent else {
            return
        }
        text = content.text
    }
    
    private func _commonInit() {
        
        font = UIFont.systemFont(ofSize: 11)
        
        textColor = UIColor(white: 0.48, alpha: 1)
        textAlignment = .center
    }
}
