//
//  SIMChatLine.swift
//  SIMChat
//
//  Created by sagesse on 9/20/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SIMChatLine : UIView {
    /// 自定义子层布局
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        var nframe = bounds
        
        switch contentMode {
        case .left:
            nframe.size.width = lineWith
            nframe.origin.x = 0
        case .right:
            nframe.origin.x = bounds.size.width - lineWith
            nframe.size.width = lineWith
        case .top:
            nframe.size.height = lineWith
            nframe.origin.y = 0
        case .bottom:
            nframe.origin.y = bounds.size.height - lineWith
            nframe.size.height = lineWith
        default:
            nframe.size.height = lineWith
        }
        
        lineLayer.frame = nframe
    }
    /// 线的layer
    lazy var lineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        
        layer.anchorPoint = CGPoint.zero
        layer.backgroundColor = self.tintColor.cgColor
        
        self.layer.addSublayer(layer)
        
        return layer
    }()
    /// 线宽
    @IBInspectable var lineWith: CGFloat = 0.5 {
        willSet { 
            self.setNeedsLayout()  
        }
    }
    /// 线的颜色
    @IBInspectable var lineColor: UIColor? {
        set { return lineLayer.backgroundColor = newValue?.cgColor }
        get { return lineLayer.backgroundColor == nil ? nil : UIColor(cgColor: lineLayer.backgroundColor!) }
    }
    ///      Top
    ///      +--+
    /// Left |  | Right
    ///      +--+
    ///     Bottom
    override var contentMode: UIViewContentMode {
        willSet {
            super.contentMode = newValue
            self.setNeedsLayout()
        }
    }
}
