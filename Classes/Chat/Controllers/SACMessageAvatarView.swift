//
//  SACMessageAvatarView.swift
//  SAChat
//
//  Created by sagesse on 05/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

open class SACMessageAvatarView: UIView, SACMessageContentViewType {
   
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    open func apply(_ message: SACMessageType) {
    }
    
    private func _commonInit() {
        let image = UIImage.sac_init(named: "chat_avatar_unknow")
        
        layer.contents = image?.cgImage
        layer.cornerRadius = 20
        layer.masksToBounds = true
    }
}
