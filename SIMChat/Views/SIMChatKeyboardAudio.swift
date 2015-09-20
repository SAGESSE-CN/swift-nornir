//
//  SIMChatKeyboardAudio.swift
//  SIMChat
//
//  Created by sagesse on 9/20/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SIMChatKeyboardAudio: SIMView {
    
    enum State : Int {
        case Normal
        case Ready
        case Play
        case Record
        case Cancel
        case Error
    }
    
//    convenience init(delegate: SIMChatInputAudioViewDelegate?) {
//        self.init()
//        self.delegate = delegate
//    }
    
    /// 构建
    override func build() {
        super.build()
    }
    
//    func buildUI() {
//        
//        addSubview(preoperator)
//        addSubview(tips)
//        addSubview(activity)
//        addSubview(record)
//        
//        addSubview(play)
//        addSubview(cancelButton)
//        addSubview(finishButton)
//        
//        let vs = ["vr": record,
//                  "vt": tips,
//                  "va": activity,
//                  "vo": preoperator,
//                  "vac": cancelButton,
//                  "vas": finishButton]
//        
//        let addConstraint = self.addConstraint
//        let addConstraints = self.addConstraints
//        let cm = NSLayoutConstraint.constraintsWithVisualFormat
//        let cm2 = { (v1: AnyObject, a1: NSLayoutAttribute, r: NSLayoutRelation, v2: AnyObject?, a2: NSLayoutAttribute, c: CGFloat, m: CGFloat, p: UILayoutPriority) -> NSLayoutConstraint in
//            let c = NSLayoutConstraint(item: v1, attribute: a1, relatedBy: r, toItem: v2, attribute: a2, multiplier: m, constant: c)
//            c.priority = p
//            return c
//        }
//        
//        addConstraint(cm2(self, .CenterX, .Equal, record, .CenterX, 0, 1, 1000))
//        addConstraint(cm2(self, .CenterX, .Equal, tips, .CenterX, 0, 1, 1000))
//        addConstraint(cm2(activity, .CenterY, .Equal, tips, .CenterY, 0, 1, 1000))
//        addConstraint(cm2(record, .CenterX, .Equal, play, .CenterX, 0, 1, 1000))
//        addConstraint(cm2(record, .CenterY, .Equal, play, .CenterY, 0, 1, 1000))
//        
//        addConstraint(cm2(self, .Bottom, .Equal, cancelButton, .Top, 0, 1, 1000))
//        addConstraint(cm2(self, .Bottom, .Equal, finishButton, .Top, 0, 1, 1000))
//        
//        addConstraints(cm("H:|-20-[vo]-20-|", options: .allZeros, metrics: nil, views: vs))
//        addConstraints(cm("H:[va]-8-[vt]", options: .allZeros, metrics: nil, views: vs))
//        addConstraints(cm("V:|-51-[vr]", options: .allZeros, metrics: nil, views: vs))
//        addConstraints(cm("V:|-20-[vt(16)]-[vo]", options: .allZeros, metrics: nil, views: vs))
//        addConstraints(cm("H:|[vac(vas)][vas]|", options: .allZeros, metrics: nil, views: vs))
//        addConstraints(cm("V:[vac(39)]", options: .allZeros, metrics: nil, views: vs))
//        addConstraints(cm("V:[vas(39)]", options: .allZeros, metrics: nil, views: vs))
//        
//        // add events
//        record.addTarget(self, action: "touchDragOfRecord:withEvent:", forControlEvents: .TouchDragOutside)
//        record.addTarget(self, action: "touchDragOfRecord:withEvent:", forControlEvents: .TouchDragInside)
//        
//        record.addTarget(self, action: "touchUpOfRecord", forControlEvents: .TouchUpInside)
//        record.addTarget(self, action: "touchUpOfRecord", forControlEvents: .TouchUpOutside)
//        record.addTarget(self, action: "touchDownOfRecord", forControlEvents: .TouchDown)
//        
//        play.addTarget(self, action: "touchUpOfAudition", forControlEvents: .TouchUpInside)
//        cancelButton.addTarget(self, action: "touchUpOfCancel", forControlEvents: .TouchUpInside)
//        finishButton.addTarget(self, action: "touchUpOfSend", forControlEvents: .TouchUpInside)
//    }
//
//    override func intrinsicContentSize() -> CGSize {
//        return CGSizeMake(0, 216)
//    }
//    
//
//    weak var delegate: SIMChatInputAudioViewDelegate?
//    
//    var state = State.Normal {
//        willSet {
//            // 有所改变
//            if newValue != state {
//                // ..
//                switch newValue {
//                case .Ready:        activity.hidden = false; tips.text = "准备中"       
//                case .Play:         activity.hidden = true;  tips.text = "松开试听"
//                case .Cancel:       activity.hidden = true;  tips.text = "松开取消"
//                case .Normal:       activity.hidden = true;  tips.text = "按住说话"
//                case .Error:        activity.hidden = true;
//                case .Record:       break
//                }
//                
//                // 检查有没有开启动画
//                if !activity.hidden && !activity.isAnimating() {
//                    activity.startAnimating()
//                }
//            }
//        }
//    }
//    var recording: Bool = false {
//        willSet {
//            if recording == newValue {
//                return
//            }
//                
//            UIView.animateWithDuration(0.25) {
//                
//                self.preoperator.alpha = newValue ? 1 : 0
//                                    
//                self.preplay1.layer.transform = CATransform3DIdentity 
//                self.precancel1.layer.transform = CATransform3DIdentity
//                self.preplay1.highlighted = false
//                self.preplay2.highlighted = false
//                self.precancel1.highlighted = false
//                self.precancel2.highlighted = false
//            }
//        }
//    }
//    var playing: Bool = false {
//        willSet {
//            if playing == newValue {
//                return
//            }
//            if newValue {
//                play.setImage(UIImage(named: "aio_record_stop_nor"), forState: .Normal)
//                play.setImage(UIImage(named: "aio_record_stop_press"), forState: .Highlighted)
//            } else {
//                play.setImage(UIImage(named: "aio_record_play_nor"), forState: .Normal)
//                play.setImage(UIImage(named: "aio_record_play_press"), forState: .Highlighted)
//            }
//        }
//    }
//    var hiddenAudition: Bool = true {
//        willSet {
//            if hiddenAudition == newValue {
//                return
//            }
//            
//            if !newValue {
//                
//                play.hidden = false
//                play.alpha = 0
//                
//                UIView.animateWithDuration(0.25, animations: {
//                    self.play.alpha = 1
//                    self.cancelButton.layer.transform = CATransform3DMakeTranslation(0, -self.cancelButton.bounds.height, 0)
//                    self.finishButton.layer.transform = CATransform3DMakeTranslation(0, -self.finishButton.bounds.height, 0)
//                    }, completion: { b in
//                        self.record.hidden = true
//                })
//                
//            } else {
//                
//                record.hidden = false
//                
//                UIView.animateWithDuration(0.25, animations: {
//                    self.play.alpha = 0
//                    self.cancelButton.layer.transform = CATransform3DMakeTranslation(0, 0, 0)
//                    self.finishButton.layer.transform = CATransform3DMakeTranslation(0, 0, 0)
//                    }, completion: { b in
//                        self.play.hidden = true
//                })
//            }
//        }
//    }
//    
//    
//    private(set) lazy var record: UIButton = {
//        
//        let v = UIButton()
//        
//        v.setImage(UIImage(named: "aio_voice_button_icon"), forState: .Normal)
//        v.setImage(UIImage(named: "aio_voice_button_icon"), forState: .Highlighted)
//        v.setBackgroundImage(UIImage(named: "aio_voice_button_nor"), forState: .Normal)
//        v.setBackgroundImage(UIImage(named: "aio_voice_button_press"), forState: .Highlighted)
//        
//        v.setTranslatesAutoresizingMaskIntoConstraints(false)
//        
//        return v
//    }()
//    private(set) lazy var play: UIButton = {
//        let v = UIButton()
//        
//        v.setImage(UIImage(named: "aio_record_play_nor"), forState: .Normal)
//        v.setImage(UIImage(named: "aio_record_play_press"), forState: .Highlighted)
//        v.setBackgroundImage(UIImage(named: "aio_record_finish_button"), forState: .Normal)
//        v.setBackgroundImage(UIImage(named: "aio_record_finish_button"), forState: .Highlighted)
//        v.setTranslatesAutoresizingMaskIntoConstraints(false)
//        v.sizeToFit()
//        
//        v.layer.masksToBounds = true
//        v.layer.cornerRadius = v.bounds.width / 2.0
//        v.hidden = true
//        
//        let s = self.progress
//        
//        v.layer.addSublayer(s)
//        
//        s.frame = v.bounds
//        s.path = UIBezierPath(ovalInRect: s.bounds).CGPath
//        s.transform = CATransform3DMakeRotation((-90 / 180) * CGFloat(M_PI), 0, 0, 1)
//        
//        return v
//    }()
//    
//    private(set) lazy var tips: UILabel = {
//        let v = UILabel()
//        v.text = "按住说话"
//        v.textColor = UIColor(white: 0x80 / 255.0, alpha: 1)
//        v.setTranslatesAutoresizingMaskIntoConstraints(false)
//        return v
//    }()
//    private(set) lazy var activity: UIActivityIndicatorView = {
//        let v = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
//        v.setTranslatesAutoresizingMaskIntoConstraints(false)
//        v.hidesWhenStopped = true
//        v.hidden = true
//        return v
//    }()
//    private(set) lazy var progress: CAShapeLayer = {
//        let s = CAShapeLayer()
//        
//        s.lineWidth = 3.5
//        s.fillColor = nil
//        s.strokeColor = UIColor(red: 24/255.0, green: 180/255.0, blue: 237/255.0, alpha: 1).CGColor
//        s.strokeStart = 0
//        s.strokeEnd = 0
//        
//        return s
//    }()
//    
//    private(set) lazy var cancelButton: UIButton = {
//        let v = UIButton()
//        v.setTitle("取消", forState: .Normal)
//        v.setTitleColor(UIColor(red: 24/255.0, green: 180/255.0, blue: 237/255.0, alpha: 1), forState: .Normal)
//        v.setBackgroundImage(UIImage(named: "aio_record_cancel_button"), forState: .Normal)
//        v.setBackgroundImage(UIImage(named: "aio_record_cancel_button_press"), forState: .Highlighted)
//        v.setTranslatesAutoresizingMaskIntoConstraints(false)
//        return v
//    }()
//    private(set) lazy var finishButton: UIButton = {
//        let v = UIButton()
//        v.setTitle("发送", forState: .Normal)
//        v.setTitleColor(UIColor(red: 24/255.0, green: 180/255.0, blue: 237/255.0, alpha: 1), forState: .Normal)
//        v.setBackgroundImage(UIImage(named: "aio_record_send_button"), forState: .Normal)
//        v.setBackgroundImage(UIImage(named: "aio_record_send_button_press"), forState: .Highlighted)
//        v.setTranslatesAutoresizingMaskIntoConstraints(false)
//        return v
//    }()
//    
//    private(set) lazy var preplay1: UIImageView = {
//        let v = UIImageView()
//        //
//        v.image = UIImage(named: "aio_voice_operate_nor")
//        v.highlightedImage = UIImage(named: "aio_voice_operate_press")
//        v.setTranslatesAutoresizingMaskIntoConstraints(false)
//        //
//        return v
//    }()
//    private(set) lazy var preplay2: UIImageView = {
//        let v = UIImageView()
//        //
//        v.image = UIImage(named: "aio_voice_operate_listen_nor")
//        v.highlightedImage = UIImage(named: "aio_voice_operate_listen_press")
//        v.setTranslatesAutoresizingMaskIntoConstraints(false)
//        //
//        return v
//    }()
//    private(set) lazy var precancel1: UIImageView = {
//        let v = UIImageView()
//        //
//        v.image = UIImage(named: "aio_voice_operate_nor")
//        v.highlightedImage = UIImage(named: "aio_voice_operate_press")
//        v.setTranslatesAutoresizingMaskIntoConstraints(false)
//        //
//        return v
//    }()
//    private(set) lazy var precancel2: UIImageView = {
//        let v = UIImageView()
//        //
//        v.image = UIImage(named: "aio_voice_operate_delete_nor")
//        v.highlightedImage = UIImage(named: "aio_voice_operate_delete_press")
//        v.setTranslatesAutoresizingMaskIntoConstraints(false)
//        //
//        return v
//    }()
//    private(set) lazy var preoperator: UIView = {
//        let v = UIView()
//        let line = UIImageView()
//        
//        v.addSubview(line)
//        v.addSubview(self.preplay1)
//        v.addSubview(self.precancel1)
//        v.addSubview(self.preplay2)
//        v.addSubview(self.precancel2)
//        
//        let addConstraint = v.addConstraint
//        let addConstraints = v.addConstraints
//        let cm = NSLayoutConstraint.constraintsWithVisualFormat
//        let cm2 = { (v1: AnyObject, a1: NSLayoutAttribute, r: NSLayoutRelation, v2: AnyObject?, a2: NSLayoutAttribute, c: CGFloat, m: CGFloat, p: UILayoutPriority) -> NSLayoutConstraint in
//            let c = NSLayoutConstraint(item: v1, attribute: a1, relatedBy: r, toItem: v2, attribute: a2, multiplier: m, constant: c)
//            c.priority = p
//            return c
//        }
//        let vs = ["vp1": self.preplay1, 
//                  "vc1": self.precancel1,
//                  "vl": line]
//        
//        //v.hidden = true
//        v.alpha = 0
//        v.setTranslatesAutoresizingMaskIntoConstraints(false)
//        
//        line.image = UIImage(named: "aio_voice_line")
//        line.setTranslatesAutoresizingMaskIntoConstraints(false)
//        
//        addConstraints(cm("H:|[vp1]-(>=0)-[vc1]|", options: .allZeros, metrics: nil, views: vs))
//        addConstraints(cm("V:|[vp1]", options: .allZeros, metrics: nil, views: vs))
//        addConstraints(cm("V:|[vc1]", options: .allZeros, metrics: nil, views: vs))
//        addConstraints(cm("H:|-3.5-[vl]-3.5-|", options: .allZeros, metrics: nil, views: vs))
//        addConstraints(cm("V:|-14-[vl]|", options: .allZeros, metrics: nil, views: vs))
//        
//        addConstraint(cm2(self.preplay1, .CenterX, .Equal, self.preplay2, .CenterX, 0, 1, 1000))
//        addConstraint(cm2(self.preplay1, .CenterY, .Equal, self.preplay2, .CenterY, 0, 1, 1000))
//        addConstraint(cm2(self.precancel1, .CenterX, .Equal, self.precancel2, .CenterX, 0, 1, 1000))
//        addConstraint(cm2(self.precancel1, .CenterY, .Equal, self.precancel2, .CenterY, 0, 1, 1000))
//        
//        return v
//    }()
//
//    private var timer: NSTimer?
}

//extension SIMChatInputAudioView {
//    
//    /// 开始计时
//    func startTimer() {
//        if self.timer != nil {
//            return
//        }
//        dispatch_async(dispatch_get_main_queue()) {
//            if self.timer != nil {
//                return
//            }
//            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: "interruptOfTimer", userInfo: nil, repeats: true)
//        }
//    }
//    
//    /// 停止计时
//    func stopTimer() {
//        self.timer?.invalidate()
//        self.timer = nil
//    }
//    
//    /// 开始试听.
//    func startAudition() {
//        // 允许播放?
//        if !(delegate?.chatInputAudioViewShouldPlay?(self) ?? false) {
//            return
//        }
//        // 动画代理
//        class SFAnimationDelegateToBlock : NSObject {
//            init(block: (Bool)->()) {
//                self.block = block 
//                super.init()
//            }
//            private var block: (Bool)->() 
//            private override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
//                block(flag)
//            }
//        }
//        
//        // 创建动画
//        let ani = CABasicAnimation(keyPath: "strokeEnd")
//        
//        // 开始
//        self.delegate?.chatInputAudioViewDidPlay?(self)
//        
//        ani.fromValue = 0
//        ani.toValue = 1
//        ani.duration = (delegate?.chatInputAudioViewDuration?(self) ?? 0) + 0.1
//        ani.delegate = SFAnimationDelegateToBlock { [weak self] b in
//            if b {
//                // 完成.
//                self?.stopAudition()
//            }
//        }
//        
//        // ..
//        self.updateMeter()
//        self.startTimer()
//        self.progress.addAnimation(ani, forKey: "SE")
//        self.playing = true
//    }
//    
//    /// 停止试听
//    func stopAudition() {
//        if self.playing && delegate?.chatInputAudioViewShouldStop?(self) ?? true {
//            
//            // 清除动画
//            self.stopTimer()
//            self.progress.removeAllAnimations()
//            self.playing = false
//            
//            delegate?.chatInputAudioViewDidStop?(self)
//        }
//    }
//
//    /// 开始录音
//    func startRecord() {
//        // 允许录音?
//        if !(delegate?.chatInputAudioViewShouldRecord?(self) ?? false) {
//            // 错误了。。
//            self.tips.text = "未准备好"
//            self.state = .Error
//            return
//        }
//        // 启动录音
//        self.delegate?.chatInputAudioViewDidRecord?(self)
//        
//        self.startTimer()
//        self.state = .Record
//        self.recording = true
//    }
//    
//    /// 停止录音
//    func stopRecord() {
//        if self.recording && delegate?.chatInputAudioViewShouldStop?(self) ?? true {
//            // 停止录音
//            self.stopTimer()
//            self.recording = false
//            
//            delegate?.chatInputAudioViewDidStop?(self)
//        }
//    }
//    
//    // 完成录音
//    func finishRecord() {
//        if delegate?.chatInputAudioViewShouldSend?(self) ?? true {
//            // 更新状态
//            self.state = .Normal
//            //
//            delegate?.chatInputAudioViewDidSend?(self)
//        }
//    }
//    
//    /// 取消录音.
//    func cancelRecord() {
//        if delegate?.chatInputAudioViewShouldCancel?(self) ?? true {
//            // 更新状态
//            self.state = .Normal
//        
//            delegate?.chatInputAudioViewDidCancel?(self)
//        }
//    }
//
//    /// 更新音频信息
//    func updateMeter() {
//        
//        let time = delegate?.chatInputAudioViewCurrentTime?(self) ?? 0
//        let meter = delegate?.chatInputAudioViewMeter?(self) ?? 0
//        
//        self.tips.text = String(format: "%d:%02d", Int(time / 60), Int(time % 60))
//        self.activity.hidden = true
//    }
//}
//
//extension SIMChatInputAudioView {
//    
//    /// 中断
//    func interruptOfTimer() {
//        
//        // 检查是否需要更新
//        if !self.playing && !(self.recording && self.state == .Record) {
//            return
//        }
//        
//        self.updateMeter()
//    }
//    
//    /// 弹起.
//    func touchUpOfAudition() {
//        if !self.playing {
//            self.startAudition()
//        } else {
//            self.stopAudition()
//        }
//    }
//    
//    /// 取消
//    func touchUpOfCancel() {
//        self.stopAudition()
//        self.hiddenAudition = true
//        self.cancelRecord()
//    }
//    
//    /// 发送
//    func touchUpOfSend() {
//        self.stopAudition()
//        self.hiddenAudition = true
//        self.finishRecord()
//    }
//    
//    /// 弹起
//    func touchUpOfRecord() {
//        
//        // 选停止录音
//        self.stopRecord()
//        
//        if self.state != .Error {
//            // 检查状态。
//            if state == .Cancel {
//                self.cancelRecord()
//            } else if state == .Play {
//                self.hiddenAudition = false
//            } else {
//                self.finishRecord()
//            }
//        } else {
//            // 重置状态
//            self.state = .Normal
//        }
//    }
//    
//    /// 按下.
//    func touchDownOfRecord() {
//        
//        // 更新状态
//        self.state = .Ready
//        
//        // 开始录音
//        self.startRecord()
//    }
//    
//    /// 拖动
//    func touchDragOfRecord(sender: UIButton, withEvent event: UIEvent) {
//        // 长期高亮
//        record.highlighted = true
//        
//        // 录音中
//        if !self.recording {
//            return
//        }
//        
//        // 检查触摸位置
//        if let touch = event.allTouches()?.first as? UITouch {
//            
//            var hl: Bool = false
//            var hr: Bool = false
//            var sl: CGFloat = 1.0
//            var sr: CGFloat = 1.0
//            
//            var pt = touch.locationInView(record)
//            
//            // 左边
//            if pt.x < 0 {
//                
//                var pt2 = touch.locationInView(self.preplay1)
//                
//                pt2.x -= preplay1.bounds.width / 2
//                pt2.y -= preplay1.bounds.height / 2
//                
//                let r = sqrt(pt2.x * pt2.x + pt2.y * pt2.y)
//                
//                // 是否高亮
//                hl = r < preplay1.bounds.width / 2
//                
//                // 计算出左边的缩放
//                sl = 1.0 + max((64 - r) / 64, 0) * 0.75
//                
//            // 右边
//            } else if pt.x > record.bounds.width {
//                
//                var pt2 = touch.locationInView(self.precancel1)
//                
//                pt2.x -= precancel1.bounds.width / 2
//                pt2.y -= precancel1.bounds.height / 2
//                
//                let r = sqrt(pt2.x * pt2.x + pt2.y * pt2.y)
//                
//                // 是否高亮
//                hr = r < precancel1.bounds.width / 2
//                
//                // 计算出右边的缩放
//                sr = 1.0 + max((64 - r) / 64, 0) * 0.75
//            }
//            
//            // ..
//            self.state = hl ? .Play : hr ? .Cancel : .Record
//            
//            // 更新
//            UIView.animateWithDuration(0.25) {
//                
//                self.preplay1.layer.transform = CATransform3DMakeScale(sl, sl, 1)
//                self.precancel1.layer.transform = CATransform3DMakeScale(sr, sr, 1) 
//                self.preplay1.highlighted = hl
//                self.preplay2.highlighted = hl
//                self.precancel1.highlighted = hr
//                self.precancel2.highlighted = hr
//            }
//        }
//    }
//}
//    
//@objc protocol SIMChatInputAudioViewDelegate : NSObjectProtocol {
//    
//    optional func chatInputAudioViewShouldRecord(chatInputAudioView: SIMChatInputAudioView) -> Bool
//    optional func chatInputAudioViewDidRecord(chatInputAudioView: SIMChatInputAudioView)
//    
//    optional func chatInputAudioViewShouldPlay(chatInputAudioView: SIMChatInputAudioView) -> Bool
//    optional func chatInputAudioViewDidPlay(chatInputAudioView: SIMChatInputAudioView)
//    
//    optional func chatInputAudioViewShouldStop(chatInputAudioView: SIMChatInputAudioView) -> Bool
//    optional func chatInputAudioViewDidStop(chatInputAudioView: SIMChatInputAudioView)
//    
//    optional func chatInputAudioViewMeter(chatInputAudioView: SIMChatInputAudioView) -> Float
//    optional func chatInputAudioViewDuration(chatInputAudioView: SIMChatInputAudioView) -> NSTimeInterval
//    optional func chatInputAudioViewCurrentTime(chatInputAudioView: SIMChatInputAudioView) -> NSTimeInterval
//    
//    optional func chatInputAudioViewShouldSend(chatInputAudioView: SIMChatInputAudioView) -> Bool
//    optional func chatInputAudioViewDidSend(chatInputAudioView: SIMChatInputAudioView)
//    
//    optional func chatInputAudioViewShouldCancel(chatInputAudioView: SIMChatInputAudioView) -> Bool
//    optional func chatInputAudioViewDidCancel(chatInputAudioView: SIMChatInputAudioView)
//}
