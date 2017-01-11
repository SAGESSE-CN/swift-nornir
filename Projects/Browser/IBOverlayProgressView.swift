//
//  IBOverlayProgressView.swift
//  Browser
//
//  Created by sagesse on 12/9/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

open class IBOverlayProgressView: UIControl {
   
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    open var fillColor: UIColor? {
        willSet {
            _layer.fillColor = newValue?.cgColor
        }
    }
    open var strokeColor: UIColor? {
        willSet {
            _layer.strokeColor = newValue?.cgColor
        }
    }
    
    open var radius: CGFloat {
        set { return setRaidus(newValue, animated: false) }
        get { return _layer.radius }
    }
    open var progress: Double {
        set { return setProgress(newValue, animated: false) }
        get { return _layer.progress }
    }
    
    open func setRaidus(_ radius: CGFloat, animated: Bool) {
        _layer.radius = radius
        guard !animated else {
            return
        }
        let ani = CABasicAnimation(keyPath: "radius")
        ani.toValue = radius
        _layer.add(ani, forKey: "radius")
    }
    open func setProgress(_ progress: Double, animated: Bool) {
        _layer.progress = progress
        guard !animated else {
            return
        }
        let ani = CABasicAnimation(keyPath: "progress")
        ani.toValue = progress
        _layer.add(ani, forKey: "progress")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard progress < -0.000001 else {
            return false
        }
        return super.point(inside: point, with: event)
    }
    
    open override class var layerClass: AnyClass { 
        return IBOverlayProgressLayer.self
    }
    
    private func _commonInit() {
        
        backgroundColor = .clear
        
        _layer.radius = 3
        _layer.lineWidth = 1 / UIScreen.main.scale
        
        _layer.fillColor = fillColor?.cgColor
        _layer.strokeColor = strokeColor?.cgColor
    }
    
    private lazy var _layer: IBOverlayProgressLayer = {
        return self.layer as! IBOverlayProgressLayer
    }()
}

