//
//  SACMessageNoticeContent.swift
//  SAChat
//
//  Created by sagesse on 06/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit
import YYText

open class SACMessageNoticeContent: NSObject, SACMessageContentType {
    
    open var layoutMargins: UIEdgeInsets = .zero
    
    open class var viewType: SACMessageContentViewType.Type {
        return SACMessageNoticeContentView.self
    }
    
    
    public init(text: String) {
        self.text = text
        super.init()
    }
    
    open var text: String
    open var attributedText: YYTextLayout?
    
    open func sizeThatFits(_ size: CGSize) -> CGSize {
        let attr = NSMutableAttributedString(string: text, attributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: 12),
            NSForegroundColorAttributeName: UIColor(white: 0.48, alpha: 1),
            ])
        attributedText = YYTextLayout(containerSize: size, text: attr)
        return attributedText?.textBoundingSize ?? .zero
    }
    
    
    open static let unsupport: SACMessageNoticeContent = SACMessageNoticeContent(text: "The message does not support")
}
