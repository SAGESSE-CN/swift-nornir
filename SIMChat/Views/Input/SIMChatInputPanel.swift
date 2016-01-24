//
//  SIMChatInputPanel.swift
//  SIMChat
//
//  Created by sagesse on 1/22/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

public class SIMChatInputPanel: UIView {
    /// 面板样式
    public enum Style: Int {
        case None   = 0
        case Emoji
        case Tool
        case Audio
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .redColor()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .redColor()
    }
    
    /// 面板样式
    public var style: Style = .None {
        didSet {
        }
    }
}

extension SIMChatInputPanel {
    public override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(0, 216)
    }
}
