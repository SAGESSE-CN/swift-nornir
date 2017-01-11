//
//  SACMessageTextContent.swift
//  SAChat
//
//  Created by sagesse on 05/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit
import YYText

open class SACMessageTextContent: NSObject, SACMessageContentType {
    
    public override init() {
        self.text = "The FFNN class contains a fully-connected, 3-layer feed-forward neural network. This neural net uses a standard backpropagation training algorithm (stochastic gradient descent), and is designed for flexibility and use in performance-critical applications."
        super.init()
    }
    public init(text: String) {
        self.text = text
        super.init()
    }
    
    open class var viewType: SACMessageContentViewType.Type {
        return SACMessageTextContentView.self
    }
    open var layoutMargins: UIEdgeInsets = .init(top: 4, left: 6, bottom: 4, right: 6)
    
    open var text: String
    open var attributedText: YYTextLayout?
    
    open func sizeThatFits(_ size: CGSize) -> CGSize {
        // +-+-------------+-+
        // | +-------------+ |
        // | |   Content   | |
        // | +-------------+ |
        // +-+-------------+-+
                         
        let attr = NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16) ])
        attributedText = YYTextLayout(containerSize: size, text: attr)
//        @property (nonatomic, readonly) NSRange visibleRange;
//        ///< Bounding rect (glyphs)
//        @property (nonatomic, readonly) CGRect textBoundingRect;
//        ///< Bounding size (glyphs and insets, ceil to pixel)
//        @property (nonatomic, readonly) CGSize textBoundingSize;
        return attributedText?.textBoundingSize ?? .zero
    }
}
