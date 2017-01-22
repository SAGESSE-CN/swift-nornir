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
        let text = "The FFNN class contains a fully-connected, 3-layer feed-forward neural network. This neural net uses a standard backpropagation training algorithm (stochastic gradient descent), and is designed for flexibility and use in performance-critical applications."
        self.text = NSAttributedString(string: text)
        super.init()
    }
    public init(text: String) {
        self.text = NSAttributedString(string: text)
        super.init()
    }
    public init(attributedText: NSAttributedString) {
        self.text = attributedText
        super.init()
    }
    
    open class var viewType: SACMessageContentViewType.Type {
        return SACMessageTextContentView.self
    }
    open var layoutMargins: UIEdgeInsets = .init(top: 9, left: 10, bottom: 9, right: 10)
    
    open var text: NSAttributedString
    open var attributedText: YYTextLayout?
    
    open func sizeThatFits(_ size: CGSize) -> CGSize {
        // +-+-------------+-+
        // | +-------------+ |
        // | |   Content   | |
        // | +-------------+ |
        // +-+-------------+-+
        
        let mattr = NSMutableAttributedString(attributedString: text)
        mattr.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 16), range: NSMakeRange(0, mattr.length))
        
                         
        attributedText = YYTextLayout(containerSize: size, text: mattr)
//        @property (nonatomic, readonly) NSRange visibleRange;
//        ///< Bounding rect (glyphs)
//        @property (nonatomic, readonly) CGRect textBoundingRect;
//        ///< Bounding size (glyphs and insets, ceil to pixel)
//        @property (nonatomic, readonly) CGSize textBoundingSize;
        let size = attributedText?.textBoundingSize ?? .zero
        
        return .init(width: max(size.width, 15), height: max(size.height, 15))
    }
}
