//
//  SAIAudioSpectrumMiniView.swift
//  SAC
//
//  Created by SAGESSE on 9/20/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

@objc
public protocol SAIAudioSpectrumMiniViewDataSource: NSObjectProtocol {
    
    func spectrumMiniView(_ spectrumMiniView: SAIAudioSpectrumMiniView, peakPowerFor channel: Int) -> Float
    func spectrumMiniView(_ spectrumMiniView: SAIAudioSpectrumMiniView, averagePowerFor channel: Int) -> Float
    
    @objc optional func spectrumMiniView(willUpdateMeters spectrumMiniView: SAIAudioSpectrumMiniView)
    @objc optional func spectrumMiniView(didUpdateMeters spectrumMiniView: SAIAudioSpectrumMiniView)
}


open class SAIAudioSpectrumMiniView: UIView {
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: _size.width, height: 24)
    }
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        guard newWindow == nil else {
            return
        }
        stopAnimating()
    }
    
    open var color: UIColor? {
        willSet { 
            _layers.forEach {
                $0.backgroundColor = newValue?.cgColor
            }
        }
    }
    
    weak var dataSource: SAIAudioSpectrumMiniViewDataSource?
    
    open var isAnimating: Bool {
        return false
    }
    open func startAnimating() {
        guard _link == nil else {
            return
        }
        //_logger.trace()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let pbl = CGRect(x: 0, y: 0, width: 2, height: 0)
        _layers.forEach {
            $0.bounds = pbl
        }
        CATransaction.commit()
        
        _link = CADisplayLink(target: self, selector: #selector(tack(_:)))
        _link?.frameInterval = 3
        _link?.add(to: .main, forMode: .commonModes)
        
    }
    open func stopAnimating() {
        guard _link != nil else {
            return
        }
        //_logger.trace()
        
        _link?.remove(from: .main, forMode: .commonModes)
        _link = nil
    }
    
    @objc func tack(_ sender: AnyObject) {
        
        dataSource?.spectrumMiniView?(willUpdateMeters: self)
        
        // 读取波形
        let wl = Double(dataSource?.spectrumMiniView(self, averagePowerFor: 0) ?? -160)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let sl = CGFloat(_decibelsToLevel(wl))
        
        var pbl = CGRect(x: 0, y: 0, width: 2, height: 2 + trunc(sl * 8) * 2)
        
        _layers.forEach {
            swap(&$0.bounds, &pbl)
        }
        
        CATransaction.commit()
        
        dataSource?.spectrumMiniView?(didUpdateMeters: self)
    }
    
    @inline(__always)
    private func _decibelsToLevel(_ decibels: Double) -> Double {
        // Link: http://stackoverflow.com/questions/9247255/am-i-doing-the-right-thing-to-convert-decibel-from-120-0-to-0-120/16192481#16192481
        
        var level = 0.0 // The linear 0.0 .. 1.0 value we need.
        let minDecibels = -80.0 // Or use -60dB, which I measured in a silent room.
        
        if decibels < minDecibels {
            level = 0.0
        } else if decibels >= 0.0 {
            level = 1.0
        } else {
            let root = 2.0
            let minAmp = pow(10, 0.05 * minDecibels)
            let inverseAmpRang = 1 / (1 - minAmp)
            let amp = pow(10, 0.05 * decibels)
            let adjAmp = (amp - minAmp) * inverseAmpRang
            
            level = pow(adjAmp, 1 / root)
        }
        return level
    }
    
    private func _init() {
        
        let s: CGFloat = 2
        let w: CGFloat = 2
        
        var x: CGFloat = 0
        let y: CGFloat = intrinsicContentSize.height / 2
        
        x -= s
        for _ in 0 ..< 6 {
            let l = CALayer()
            
            l.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            l.position = CGPoint(x: x + s + w, y: y)
            l.bounds = CGRect(x: 0, y: 0, width: 2, height: 2)
            
            _layers.append(l)
            
            layer.addSublayer(l)
            
            x = x + s + w
        }
        x += s
        
        color = UIColor(colorLiteralRed: 0xfb / 255.0, green: 0x7a / 255.0, blue: 0x0d / 255.0, alpha: 1.0)
        _size.width = x
    }
    
    private var _link: CADisplayLink?
    private var _size: CGSize = .zero
    
    private lazy var _layers = [CALayer]()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
}
