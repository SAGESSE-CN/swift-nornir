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
    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        
        var nframe = bounds
        
        switch contentMode {
        case .Left:
            nframe.size.width = lineWith
            nframe.origin.x = 0
        case .Right:
            nframe.origin.x = bounds.size.width - lineWith
            nframe.size.width = lineWith
        case .Top:
            nframe.size.height = lineWith
            nframe.origin.y = 0
        case .Bottom:
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
        
        layer.anchorPoint = CGPointZero
        layer.backgroundColor = self.tintColor.CGColor
        
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
        set { return lineLayer.backgroundColor = newValue?.CGColor }
        get { return lineLayer.backgroundColor == nil ? nil : UIColor(CGColor: lineLayer.backgroundColor!) }
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
