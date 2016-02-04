//
//  SIMChatSpectrumView.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 频谱
///
class SIMChatSpectrumView: SIMView {
    /// 建构
    override func build() {
        super.build()
   
        let x = intrinsicContentSize().width / 2
        let y = intrinsicContentSize().height / 2
        
        for i in 0 ..< 10 {
            let l = CALayer()
            let r = CALayer()
            
            l.anchorPoint = CGPointMake(0.5, 0.5)
            r.anchorPoint = CGPointMake(0.5, 0.5)
            l.position = CGPointMake((x - CGFloat(i * (2 + 2)) - 24), y)
            r.position = CGPointMake((x + CGFloat(i * (2 + 2)) + 24), y)
            l.bounds = CGRectMake(0, 0, 2, 3)
            r.bounds = CGRectMake(0, 0, 2, 3)
            
            leftLayers.append(l)
            rightLayers.append(r)
            
            layer.addSublayer(l)
            layer.addSublayer(r)
        }
    }
    /// 大小
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(120, 24)
    }
    
    /// 频谱颜色
    var color: UIColor? {
        didSet {
            (leftLayers + rightLayers).forEach {
                $0.backgroundColor = self.color?.CGColor
            }
        }
    }
    /// 代理
    weak var delegate: SIMChatSpectrumViewDelegate?
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        if newWindow == nil && isAnimating() {
            stopAnimating()
        }
    }
    
    /// 启动
    func startAnimating() {
        // 如果不为空, skip
        guard self.timer == nil else {
            return
        }
        // 启动停止器
        dispatch_async(dispatch_get_main_queue()) {
            self.timer = NSTimer.scheduledTimerWithTimeInterval2(0.1, self, "onTimer:")
        }
    }
    /// 停止
    func stopAnimating() {
        guard timer != nil else {
            return
        }
        
        timer?.invalidate()
        timer = nil
        
        // 清0
        CATransaction.begin()
        
        (leftLayers + rightLayers).forEach {
            $0.bounds = CGRectMake(0, 0, 2, 2)
        }
        
        CATransaction.commit()
    }
    /// 正在进行中?
    func isAnimating() -> Bool {
        return timer != nil
    }
   
    /// 定时事件
    private dynamic func onTimer(sender: AnyObject) {
        // 更新波形
        let wl = self.delegate?.chatSpectrumViewWaveOfLeft?(self)
        let wr = self.delegate?.chatSpectrumViewWaveOfRight?(self)
      
        let wl1 = CGFloat(wl ?? wr ?? -160)
        let wr1 = CGFloat(wr ?? wl ?? -160)
        
        // 小于-40一律视为静音
        let sl = CGFloat(decibelsToLevel(Double(wl1)))
        let sr = CGFloat(decibelsToLevel(Double(wr1)))
        
        //SIMLog.debug("left: \(wl1) => \(sl)")
        //SIMLog.debug("right: \(wr1) => \(sr)")
      
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        var pbl = CGRectMake(0, 0, 2, 2 + round(sl * 8) * 2)
        var pbr = CGRectMake(0, 0, 2, 2 + round(sr * 8) * 2)
        
        leftLayers.forEach {
            swap(&$0.bounds, &pbl)
        }
        rightLayers.forEach {
            swap(&$0.bounds, &pbr)
        }
        
        CATransaction.commit()
    }
    
    /// 分贝转为等级
    func decibelsToLevel(decibels: Double) -> Double {
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
    
    private var timer: NSTimer?
    
    private lazy var leftLayers = [CALayer]()
    private lazy var rightLayers = [CALayer]()
}

@objc protocol SIMChatSpectrumViewDelegate : NSObjectProtocol {
    
   optional func chatSpectrumViewWaveOfLeft(chatSpectrumView: SIMChatSpectrumView) -> Float
   optional func chatSpectrumViewWaveOfRight(chatSpectrumView: SIMChatSpectrumView) -> Float
    
}