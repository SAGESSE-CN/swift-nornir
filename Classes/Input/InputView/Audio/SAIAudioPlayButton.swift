//
//  SAIAudioPlayButton.swift
//  SAC
//
//  Created by SAGESSE on 9/18/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

internal class SAIAudioPlayButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard _progressLayer.frame != bounds else {
            return
        }
        let edg = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        
        _progressLayer.frame = bounds
        _progressLayer.path = UIBezierPath(ovalIn: bounds.inset(by: edg)).cgPath
    }
    
    func setProgress(_ progress: CGFloat, animated: Bool) {
        _updateProgress(progress, animated: animated)
    }
    
    var progress: CGFloat = 0 {
        willSet {
            _updateProgress(newValue, animated: false)
        }
    }
    
    var progressLineWidth: CGFloat = 2
    var progressColor: UIColor? {
        willSet {
            _progressLayer.strokeColor = newValue?.cgColor
        }
    }
    
    private func _updateProgress(_ newValue: CGFloat, animated: Bool) {
        _progressLayer.strokeEnd = newValue
        guard !animated else {
            return
        }
        _progressLayer.removeAllAnimations()
    }
    
    private func _init() {
        _logger.trace()
        
        _progressLayer.lineWidth = progressLineWidth
        _progressLayer.fillColor = nil
        _progressLayer.strokeColor = progressColor?.cgColor
        _progressLayer.strokeStart = 0
        _progressLayer.strokeEnd = 0
        _progressLayer.transform = CATransform3DMakeRotation((-90 / 180) * CGFloat(M_PI), 0, 0, 1)
        
        layer.addSublayer(_progressLayer)
    }
    
    private lazy var _progressLayer: CAShapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
