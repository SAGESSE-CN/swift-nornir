//
//  SAPBrowseableProgressView.swift
//  SAPhotos
//
//  Created by SAGESSE on 11/1/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

// 44x44

open class SAPBrowseableProgressView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    // 0.0 .. 1.0, default is 0.0. values outside are pinned.
    open var progress: Double {
        set { return _updateOval(with: newValue, animated: false) }
        get { return _progress }
    }

    open var progressTintColor: UIColor? {
        willSet {
            _oval1.strokeColor = newValue?.cgColor ?? UIColor.gray.cgColor
            _oval2.strokeColor = newValue?.cgColor ?? UIColor.gray.cgColor
        }
    }
    
    open func setProgress(_ progress: Double, animated: Bool) {
        _updateOval(with: progress, animated: animated)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        _updateOval(with: _progress, animated: false)
    }
    
    private func _updateOval(with progress: Double, animated: Bool) {
        
        let st: CGFloat = 2
        let frame = bounds.inset(by: UIEdgeInsets(top: st, left: st, bottom: st, right: st))
        
        if _mask1.bounds.size != bounds.size {
            let path = UIBezierPath()
            
            path.append(UIBezierPath(roundedRect: frame, cornerRadius: frame.width / 2))
            
            _mask1.lineWidth = frame.width
            _mask1.frame = bounds
            _mask1.path = path.cgPath
        }
        if _oval1.bounds.size != bounds.size {
            
            let path = UIBezierPath()
            
            path.append(UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width / 2))
            path.append(UIBezierPath(roundedRect: frame, cornerRadius: frame.width / 2))
            
            _oval1.frame = bounds
            _oval1.path = path.cgPath
            _oval1.fillRule = CAShapeLayerFillRule.evenOdd
            
            _oval2.frame = bounds
            _oval2.path = UIBezierPath(roundedRect: frame, cornerRadius: frame.width / 2).cgPath
            
            let path2 = UIBezierPath()
            
            path2.move(to: CGPoint(x: bounds.midX, y: bounds.midY))
            path2.addLine(to: CGPoint(x: frame.midX, y: frame.minY - _line1.lineWidth / 2))
            
            _line1.frame = bounds
            _line2.frame = bounds
            _line1.path = path2.cgPath
            _line2.path = path2.cgPath
            
            _progress = -1
        }
        
        if _progress != progress {
            _progress = progress
            
            if progress > 0 {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                
                _line1.isHidden = false
                _line2.isHidden = false
                
                CATransaction.commit()
            }
            
            CATransaction.begin()
            
            CATransaction.setDisableActions(!animated)
            CATransaction.setCompletionBlock({ [weak self] in
                guard self?._progress == progress else {
                    return
                }
                
                if progress <= 0.000001 || progress >= 1 || fabs(1 - progress) <= 0.000001 {
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    self?._line1.isHidden = true
                    self?._line2.isHidden = true
                    CATransaction.commit()
                }
            })
            
            _mask1.strokeEnd = CGFloat(progress)
            _line2.transform = CATransform3DMakeRotation(CGFloat(2 * M_PI * progress), 0, 0, 1)
            
            CATransaction.commit()
        }
    }
    
    private func _init() {
        
        
        isUserInteractionEnabled = false
        
        _mask1.strokeColor = UIColor.white.cgColor
        _mask1.fillColor = UIColor.clear.cgColor
        
        _oval1.lineWidth = 1 / UIScreen.main.scale
        _oval2.lineWidth = 1 / UIScreen.main.scale * 2
        _line1.lineWidth = 1 / UIScreen.main.scale
        _line2.lineWidth = 1 / UIScreen.main.scale
        
        _oval1.strokeColor = UIColor.gray.cgColor
        _oval1.fillColor = UIColor.white.cgColor
        
        _oval2.strokeColor = UIColor.white.cgColor
        _oval2.fillColor = UIColor.white.cgColor
        _oval2.mask = _mask1
        
        _line1.strokeColor = UIColor.gray.cgColor
        _line2.strokeColor = UIColor.gray.cgColor
        
        layer.addSublayer(_oval1)
        layer.addSublayer(_oval2)
        layer.addSublayer(_line1)
        layer.addSublayer(_line2)
    }
    
    private var _progress: Double = 0
    
    private var _line1: CAShapeLayer = CAShapeLayer()
    private var _line2: CAShapeLayer = CAShapeLayer()
    private var _oval1: CAShapeLayer = CAShapeLayer()
    private var _oval2: CAShapeLayer = CAShapeLayer()
    private var _mask1: CAShapeLayer = CAShapeLayer()
}
