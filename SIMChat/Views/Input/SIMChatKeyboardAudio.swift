//
//  SIMChatKeyboardAudio.swift
//  SIMChat
//
//  Created by sagesse on 9/20/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 自定义键盘-音频
class SIMChatKeyboardAudio: SIMView {
    /// 初始化
    convenience init(delegate: SIMChatKeyboardAudioDelegate?) {
        self.init()
        self.delegate = delegate
    }
    /// 构建
    override func build() {
        super.build()
        
        self.pushTalkView.hidden = false
        self.playView.hidden = true
    }
    /// 固定大小
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(0, 216)
    }
    /// 代理
    weak var delegate: SIMChatKeyboardAudioDelegate?
    
    /// 录音的配置
    private lazy var recordDuration: NSTimeInterval = 0
    
    private lazy var playView: SIMChatKeyboardAudioPlayView = {
        let view = SIMChatKeyboardAudioPlayView()
        
        // config
        view.delegate = self
        view.backgroundColor = UIColor.clearColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // add view
        self.addSubview(view)
        
        // add constraints
        self.addConstraint(NSLayoutConstraintMake(view,   .Left,   .Equal, self, .Left))
        self.addConstraint(NSLayoutConstraintMake(view,   .Right,  .Equal, self, .Right))
        self.addConstraint(NSLayoutConstraintMake(view,   .Top,    .Equal, self, .Top))
        self.addConstraint(NSLayoutConstraintMake(view,   .Bottom, .Equal, self, .Bottom))
        
        return view
    }()
    private lazy var pushTalkView: SIMChatKeyboardAudioPushToTalkView = {
        let view = SIMChatKeyboardAudioPushToTalkView()
        
        // config
        view.delegate = self
        view.backgroundColor = UIColor.clearColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // add view
        self.addSubview(view)
        
        // add constraints
        self.addConstraint(NSLayoutConstraintMake(view,   .Left,   .Equal, self, .Left))
        self.addConstraint(NSLayoutConstraintMake(view,   .Right,  .Equal, self, .Right))
        self.addConstraint(NSLayoutConstraintMake(view,   .Top,    .Equal, self, .Top))
        self.addConstraint(NSLayoutConstraintMake(view,   .Bottom, .Equal, self, .Bottom))
        
        return view
    }()
    private lazy var toolbarView: UIView = {
        let view = UIView()
        let send = UIButton()
        let cancel = UIButton()
        
        // config
        
        view.backgroundColor = UIColor.clearColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        send.setTitle("发送", forState: .Normal)
        send.setTitleColor(UIColor(argb: 0xFF18B4ED), forState: .Normal)
        send.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_send_nor"), forState: .Normal)
        send.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_send_press"), forState: .Highlighted)
        send.translatesAutoresizingMaskIntoConstraints = false
        
        cancel.setTitle("取消", forState: .Normal)
        cancel.setTitleColor(UIColor(argb: 0xFF18B4ED), forState: .Normal)
        cancel.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_cancel_nor"), forState: .Normal)
        cancel.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_cancel_press"), forState: .Highlighted)
        cancel.translatesAutoresizingMaskIntoConstraints = false
        
        // add views
        view.addSubview(send)
        view.addSubview(cancel)
        self.addSubview(view)
        
        // add constraints
        view.addConstraint(NSLayoutConstraintMake(send,   .Width,  .Equal, cancel, .Width))
        view.addConstraint(NSLayoutConstraintMake(send,   .Top,    .Equal, view,   .Top))
        view.addConstraint(NSLayoutConstraintMake(send,   .Right,  .Equal, view,   .Right))
        view.addConstraint(NSLayoutConstraintMake(send,   .Bottom, .Equal, view,   .Bottom))
        view.addConstraint(NSLayoutConstraintMake(send,   .Left,   .Equal, cancel, .Right))
        view.addConstraint(NSLayoutConstraintMake(cancel, .Top,    .Equal, view,   .Top))
        view.addConstraint(NSLayoutConstraintMake(cancel, .Left,   .Equal, view,   .Left))
        view.addConstraint(NSLayoutConstraintMake(cancel, .Bottom, .Equal, view,   .Bottom))
        
        self.addConstraint(NSLayoutConstraintMake(view,   .Height, .Equal, nil,  .Height, 44))
        self.addConstraint(NSLayoutConstraintMake(view,   .Left,   .Equal, self, .Left))
        self.addConstraint(NSLayoutConstraintMake(view,   .Right,  .Equal, self, .Right))
        self.addConstraint(NSLayoutConstraintMake(view,   .Top,    .Equal, self, .Bottom))
        
        // add events
        send.addTarget(self, action: "chatKeyboardAudioViewDidFinish", forControlEvents: .TouchUpInside)
        cancel.addTarget(self, action: "chatKeyboardAudioViewDidCancel", forControlEvents: .TouchUpInside)
        
        // ok
        return view
    }()
    
    private lazy var am = SIMChatAudioManager.sharedManager
}

// MARK: - Type 
extension SIMChatKeyboardAudio {
    /// 播放
    private class SIMChatKeyboardAudioPlayView : SIMView, SIMChatSpectrumViewDelegate {
        /// 构建
        override func build() {
            super.build()
            
            // cinfig
            playButton.translatesAutoresizingMaskIntoConstraints = false
            playButton.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_background"), forState: .Normal)
            playButton.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_background"), forState: .Highlighted)
            playButton.sizeToFit()
            
            playProgress.lineWidth = 3.5
            playProgress.fillColor = nil
            playProgress.fillColor = nil
            playProgress.strokeColor = UIColor(argb: 0xFF18B4ED).CGColor
            playProgress.strokeStart = 0
            playProgress.strokeEnd = 0
            playProgress.frame = playButton.bounds
            playProgress.path = UIBezierPath(ovalInRect: playButton.bounds).CGPath
            playProgress.transform = CATransform3DMakeRotation((-90 / 180) * CGFloat(M_PI), 0, 0, 1)
            
            playButton.layer.addSublayer(playProgress)
            
            tipsLabel.text = "点击播放"
            tipsLabel.font = UIFont.systemFontOfSize(16)
            tipsLabel.textColor = UIColor(argb: 0xFF7B7B7B)
            tipsLabel.translatesAutoresizingMaskIntoConstraints = false
            
            spectrumView.color = UIColor(argb: 0xFFFB7A0D)
            spectrumView.hidden = true
            spectrumView.delegate = self
            spectrumView.translatesAutoresizingMaskIntoConstraints = false
            
            activityView.translatesAutoresizingMaskIntoConstraints = false
            activityView.hidesWhenStopped = true
            activityView.hidden = true
            
            // add views
            addSubview(playButton)
            addSubview(spectrumView)
            addSubview(tipsLabel)
            addSubview(activityView)
            
            /// add constraints
            addConstraint(NSLayoutConstraintMake(playButton, .Top,     .Equal, self, .Top, 51))
            addConstraint(NSLayoutConstraintMake(playButton, .CenterX, .Equal, self, .CenterX))
            
            addConstraint(NSLayoutConstraintMake(tipsLabel, .CenterX, .Equal, self, .CenterX))
            addConstraint(NSLayoutConstraintMake(tipsLabel, .Top,     .Equal, self, .Top, 20))
            
            addConstraint(NSLayoutConstraintMake(spectrumView, .CenterX, .Equal, tipsLabel, .CenterX))
            addConstraint(NSLayoutConstraintMake(spectrumView, .CenterY, .Equal, tipsLabel, .CenterY))
            
            addConstraint(NSLayoutConstraintMake(activityView, .CenterY, .Equal, tipsLabel, .CenterY))
            addConstraint(NSLayoutConstraintMake(activityView, .Right,   .Equal, tipsLabel, .Left,  -4))
            
            // add event
            playButton.addTarget(self, action: "onClicked:", forControlEvents: .TouchUpInside)
            
            // disable
            self.playing = false
            // 更新为默认状态
            self.update(0)
        }
        /// 正在播放
        private(set) var playing: Bool = true {
            willSet {
                // 如果没有任意改变, 那就不浪费资源了
                if newValue == self.playing {
                    return
                }
                if newValue {
                    // 正在播放
                    playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_stop_nor"), forState: .Normal)
                    playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_stop_press"), forState: .Highlighted)
                } else {
                    // 停止了
                    playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_play_nor"), forState: .Normal)
                    playButton.setImage(UIImage(named: "simchat_keyboard_voice_button_play_press"), forState: .Highlighted)
                }
                // duang
                let ani = CATransition()
                
                ani.duration = 0.25
                ani.fillMode = kCAFillModeBackwards
                ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                ani.type = kCATransitionFade
                ani.subtype = kCATransitionFromTop
                
                playButton.layer.addAnimation(ani, forKey: "s")
                
                // 更新频谱动画
                if newValue {
                    spectrumView.startAnimating()
                } else {
                    spectrumView.stopAnimating()
                }
            }
        }
        private dynamic func onTimer(sender: AnyObject) {
            // 计算当前进度
            let cur = CACurrentMediaTime() - self.startAt
            // 更新进度
            self.playProgress.strokeEnd = CGFloat(cur / max(self.duration, 0.1))
            // 完成了?
            if cur > self.duration + 0.1 {
                // ok 完成
                self.onStop()
            }
        }
        private dynamic func onClicked(sender: AnyObject) {
            if self.playing {
                // 正在播放, 那就停止
                self.onStop()
            } else {
                // 没有播放, 开始播放
                self.onPlay()
            }
        }
        
        /// 播放
        private dynamic func onPlay() {
            // 如果正在播放, 跳过
            guard self.timer == nil else {
                return
            }
            // 重置
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.playProgress.strokeEnd = 0
            CATransaction.commit()
            // 进入准备状态
            self.update(1)
            // 申请启动:)
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.chatKeyboardAudioViewDidStartPlay?()
            }
        }
        /// 停止
        private dynamic func onStop() {
            self.delegate?.chatKeyboardAudioViewDidStop?()
        }
        ///
        /// 更新状态
        /// - 0 空
        /// - 1 准备中(切换音频的时候会处于这个状态)
        /// - 2 播放
        /// - 3 错误
        ///
        private func update(flag: Int) {
            switch flag {
            case 0: // 无
                self.tipsLabel.text = "点击播放"
                self.spectrumView.hidden = true
                self.activityView.stopAnimating()
                self.activityView.hidden = true
            case 1: // 准备
                self.tipsLabel.text = "准备中"
                self.spectrumView.hidden = true
                self.activityView.hidden = false
                self.activityView.startAnimating()
            case 2: // 录音进行中
                let t = self.delegate?.chatKeyboardAudioViewCurrentTime?() ?? 0
                self.tipsLabel.text = String(format: "%0d:%02d", Int(t / 60), Int(t % 60))
                self.spectrumView.hidden = false
                self.activityView.stopAnimating()
                self.activityView.hidden = true
            case 3: // 错误
                self.tipsLabel.text = "播放错误!!"
                self.spectrumView.hidden = true
                self.activityView.stopAnimating()
                self.activityView.hidden = true
            default:
                break
            }
            
            self.tipsLabel.hidden = false
        }
        /// 开始播放
        func playStart() {
            // 己经在播放了
            if self.playing {
                return
            }
            // 重置状态
            self.playing = true
            self.playProgress.hidden = false
            // 获取
            self.duration = delegate?.chatKeyboardAudioViewDuration?() ?? 0
            // 检查
            SIMLog.debug("play duration: \(self.duration)s")
            // 开启定时器, 注意必须在主线程开
            dispatch_async(dispatch_get_main_queue()) {
                self.timer = NSTimer.scheduledTimerWithTimeInterval2(0.1, self, "onTimer:")
                self.startAt = CACurrentMediaTime()
                // 进入播放状态
                self.update(2)
            }
        }
        /// 停止播放
        func playStop() {
            // 并没有播放
            if !self.playing {
                self.update(0)
                return
            }
            self.timer?.invalidate()
            self.timer = nil
            // 重置
            self.update(0)
            self.playing = false
            self.playProgress.hidden = true
        }
        /// 播放错误
        func playFail(error: NSError?){
            self.update(3)
        }
        
        @objc func chatSpectrumViewWaveOfLeft(chatSpectrumView: SIMChatSpectrumView) -> Float {
            self.update(2)
            return self.delegate?.chatSpectrumViewWaveOfLeft?(chatSpectrumView) ?? 0
        }
        @objc func chatSpectrumViewWaveOfRight(chatSpectrumView: SIMChatSpectrumView) -> Float {
            return self.delegate?.chatSpectrumViewWaveOfRight?(chatSpectrumView) ?? 0
        }
        
        weak var delegate: SIMChatKeyboardAudioViewDelegate?
        
        private var timer: NSTimer?
        private var startAt: CFTimeInterval = 0
        private var duration: NSTimeInterval = 0
        
        private(set) lazy var tipsLabel = UILabel()
        private(set) lazy var spectrumView = SIMChatSpectrumView(frame: CGRectZero)
        private(set) lazy var activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        
        private var playButton = UIButton()
        private var playProgress = CAShapeLayer()
    }
    /// 按下说话
    private class SIMChatKeyboardAudioPushToTalkView : SIMView, SIMChatSpectrumViewDelegate {
        // 构建
        override func build() {
            super.build()
            
            // config
            operatorView.alpha = 0
            operatorView.backgroundColor = UIColor.clearColor()
            operatorView.translatesAutoresizingMaskIntoConstraints = false
            
            recordButton.setImage(UIImage(named: "simchat_keyboard_voice_icon_record"), forState: .Normal)
            recordButton.setImage(UIImage(named: "simchat_keyboard_voice_icon_record"), forState: .Highlighted)
            recordButton.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_button_nor"), forState: .Normal)
            recordButton.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_button_press"), forState: .Highlighted)
            recordButton.translatesAutoresizingMaskIntoConstraints = false
            
            tipsLabel.text = "-:--"
            tipsLabel.font = UIFont.systemFontOfSize(16)
            tipsLabel.textColor = UIColor(argb: 0xFF7B7B7B)
            tipsLabel.translatesAutoresizingMaskIntoConstraints = false
            
            spectrumView.color = UIColor(argb: 0xFFFB7A0D)
            spectrumView.hidden = true
            spectrumView.delegate = self
            spectrumView.translatesAutoresizingMaskIntoConstraints = false
            
            activityView.translatesAutoresizingMaskIntoConstraints = false
            activityView.hidesWhenStopped = true
            activityView.hidden = true
            
            // add view
            addSubview(operatorView)
            addSubview(recordButton)
            addSubview(spectrumView)
            addSubview(tipsLabel)
            addSubview(activityView)
            
            // add constraints
            addConstraint(NSLayoutConstraintMake(tipsLabel, .CenterX, .Equal, self, .CenterX))
            addConstraint(NSLayoutConstraintMake(tipsLabel, .Top,     .Equal, self, .Top, 20))
            
            addConstraint(NSLayoutConstraintMake(spectrumView, .CenterX, .Equal, tipsLabel, .CenterX))
            addConstraint(NSLayoutConstraintMake(spectrumView, .CenterY, .Equal, tipsLabel, .CenterY))
            
            addConstraint(NSLayoutConstraintMake(recordButton, .Top,     .Equal, self, .Top, 51))
            addConstraint(NSLayoutConstraintMake(recordButton, .CenterX, .Equal, self, .CenterX))
            
            addConstraint(NSLayoutConstraintMake(operatorView, .Left,    .Equal, self,      .Left,   20))
            addConstraint(NSLayoutConstraintMake(operatorView, .Right,   .Equal, self,      .Right, -20))
            addConstraint(NSLayoutConstraintMake(operatorView, .Top,     .Equal, tipsLabel, .Bottom, 16))
            
            addConstraint(NSLayoutConstraintMake(activityView, .CenterY, .Equal, tipsLabel, .CenterY))
            addConstraint(NSLayoutConstraintMake(activityView, .Right,   .Equal, tipsLabel, .Left,  -4))
            
            // add events
            recordButton.addTarget(self, action: "onDrag:withEvent:", forControlEvents: .TouchDragInside)
            recordButton.addTarget(self, action: "onDrag:withEvent:", forControlEvents: .TouchDragOutside)
            
            recordButton.addTarget(self, action: "onStart:", forControlEvents: .TouchDown)
            recordButton.addTarget(self, action: "onStop:", forControlEvents: .TouchUpInside)
            recordButton.addTarget(self, action: "onStop:", forControlEvents: .TouchUpOutside)
            recordButton.addTarget(self, action: "onInterrupt:", forControlEvents: .TouchCancel)
            
            self.update(0)
        }
        /// 事件
        private dynamic func onStart(sender: AnyObject) {
            // 正在录音呢
            if self.recording {
                return
            }
            // 先重置状态
            self.preplayView.highlighted = false
            self.preplayView2.highlighted = false
            self.precancelView.highlighted = false
            self.precancelView2.highlighted = false
            // 进入准备状态
            self.update(1)
            // 启动.
            // 完成了之后重新调用startRecord
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.chatKeyboardAudioViewDidStartRecord?()
            }
        }
        private dynamic func onStop(sender: AnyObject) {
            // 正在录音?
            if !self.recording {
                self.recordStop()
                self.delegate?.chatKeyboardAudioViewDidStop?()
                return
            }
            SIMLog.trace()
            // 完工.
            self.recordStop()
            // stop
            self.delegate?.chatKeyboardAudioViewDidStop?()
            // 检查状态
            if preplayView.highlighted {
                // 需要试听
                self.onListen(sender)
            } else if precancelView.highlighted {
                // 取消
                self.onCancel(sender)
            } else {
                // 完成
                self.onFinish(sender)
            }
        }
        private dynamic func onInterrupt(sender: AnyObject) {
            // 正在录音?
            guard self.recording else {
                // 没有, 跳过
                return
            }
            SIMLog.trace()
            // 如果中断了, 认为他是选择了试听
            self.preplayView.highlighted = true
            self.preplayView2.highlighted = true
            self.precancelView.highlighted = false
            self.precancelView2.highlighted = false
            self.preplayView.layer.transform = CATransform3DIdentity
            self.precancelView.layer.transform = CATransform3DIdentity
            // 走正常结束流程
            self.onStop(sender)
        }
        private dynamic func onDrag(sender: UIButton, withEvent event: UIEvent?) {
            // 正在录音?
            guard self.recording else {
                // 没有, 跳过
                return
            }
            // 一直维持高亮
            sender.highlighted = true
            // 检查触摸位置
            guard let touch = event?.allTouches()?.first else {
                // 并没有..
                return
            }
            
            var hl: Bool = false
            var hr: Bool = false
            var sl: CGFloat = 1.0
            var sr: CGFloat = 1.0
            let pt = touch.locationInView(recordButton)
            
            if pt.x < 0 {
                // 左边
                var pt2 = touch.locationInView(preplayView)
                pt2.x -= preplayView.bounds.width / 2
                pt2.y -= preplayView.bounds.height / 2
                let r = sqrt(pt2.x * pt2.x + pt2.y * pt2.y)
                // 是否高亮
                hl = r < preplayView.bounds.width / 2
                // 计算出左边的缩放
                sl = 1.0 + max((64 - r) / 64, 0) * 0.75
            
            } else if pt.x > recordButton.bounds.width {
                // 右边
                var pt2 = touch.locationInView(precancelView)
                pt2.x -= precancelView.bounds.width / 2
                pt2.y -= precancelView.bounds.height / 2
                let r = sqrt(pt2.x * pt2.x + pt2.y * pt2.y)
                // 是否高亮
                hr = r < precancelView.bounds.width / 2
                // 计算出右边的缩放
                sr = 1.0 + max((64 - r) / 64, 0) * 0.75
            }
            
            // 更新
            UIView.animateWithDuration(0.25) {
                self.preplayView.layer.transform = CATransform3DMakeScale(sl, sl, 1)
                self.precancelView.layer.transform = CATransform3DMakeScale(sr, sr, 1)
                self.preplayView.highlighted = hl
                self.preplayView2.highlighted = hl
                self.precancelView.highlighted = hr
                self.precancelView2.highlighted = hr
            }
        }
        
        private dynamic func onListen(sender: AnyObject) {
            self.delegate?.chatKeyboardAudioViewDidListen?()
        }
        private dynamic func onFinish(sender: AnyObject) {
            self.delegate?.chatKeyboardAudioViewDidFinish?()
        }
        private dynamic func onCancel(sender: AnyObject) {
            self.delegate?.chatKeyboardAudioViewDidCancel?()
        }
      
        ///
        /// 更新状态
        /// - 0 空
        /// - 1 准备中(切换音频的时候会处于这个状态)
        /// - 2 录音
        /// - 3 错误
        ///
        private func update(flag: Int) {
            switch flag {
            case 0: // 无
                self.tipsLabel.text = "按住说话"
                self.spectrumView.hidden = true
                self.activityView.hidden = true
                self.activityView.stopAnimating()
            case 1: // 准备中
                self.tipsLabel.text = "准备中"
                self.spectrumView.hidden = true
                self.activityView.hidden = false
                self.activityView.startAnimating()
            case 2: // 录音进行中
                if self.preplayView.highlighted {
                    self.tipsLabel.text = "松开试听"
                    self.spectrumView.hidden = true
                } else if self.precancelView.highlighted {
                    self.tipsLabel.text = "松开取消"
                    self.spectrumView.hidden = true
                } else {
                    let t = self.delegate?.chatKeyboardAudioViewCurrentTime?() ?? 0
                    self.tipsLabel.text = String(format: "%0d:%02d", Int(t / 60), Int(t % 60))
                    self.spectrumView.hidden = false
                }
                // 不允许显示的..
                self.activityView.hidden = true
                self.activityView.stopAnimating()
            case 3: // 错误
                self.tipsLabel.text = "录音错误"
                self.spectrumView.hidden = true
                self.activityView.hidden = true
                self.activityView.stopAnimating()
            default:
                break
            }
            
            self.tipsLabel.hidden = false
        }
        
        @objc func chatSpectrumViewWaveOfLeft(chatSpectrumView: SIMChatSpectrumView) -> Float {
            self.update(2)
            return self.delegate?.chatSpectrumViewWaveOfLeft?(chatSpectrumView) ?? 0
        }
        @objc func chatSpectrumViewWaveOfRight(chatSpectrumView: SIMChatSpectrumView) -> Float {
            return self.delegate?.chatSpectrumViewWaveOfRight?(chatSpectrumView) ?? 0
        }
        
        /// 开始录音
        func recordStart() {
            // 正在录音中, 重复调用了?
            if self.recording {
                return
            }
            
            SIMLog.trace()
            
            UIView.animateWithDuration(0.25) {
                self.operatorView.alpha = 1
                self.preplayView.layer.transform = CATransform3DIdentity
                self.precancelView.layer.transform = CATransform3DIdentity
            }
            
            // duang
            let ani = CAKeyframeAnimation(keyPath: "transform.scale")
            
            ani.duration = 0.25
            ani.values = [1,0.8,1.2,1]
            ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            
            self.recordButton.layer.addAnimation(ani, forKey: "start")
            
            // :)
            self.recording = true
            // 进入录音状态
            self.update(2)
        }
        /// 停止录音
        func recordStop() {
            // 没有正在录音中, 调用顺序错误了?
            if !self.recording {
                self.update(0)
                return
            }
            
            SIMLog.trace()
            
            // :)
            self.recording = false
            // 恢复状态
            self.update(0)
            
            // 隐藏就行了
            UIView.animateWithDuration(0.25) {
                self.operatorView.alpha = 0
                self.preplayView.layer.transform = CATransform3DIdentity
                self.precancelView.layer.transform = CATransform3DIdentity
            }
        }
        /// 错误
        func recordFail(error: NSError?) {
            self.update(3)
        }
        
        private(set) var recording: Bool = false {
            willSet {
                if newValue {
                    spectrumView.startAnimating()
                } else {
                    spectrumView.stopAnimating()
                }
            }
        }
       
        weak var delegate: SIMChatKeyboardAudioViewDelegate?
        
        private(set) lazy var tipsLabel = UILabel()
        private(set) lazy var spectrumView = SIMChatSpectrumView(frame: CGRectZero)
        private(set) lazy var activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        
        private lazy var listenButton = UIButton()
        private lazy var recordButton = UIButton()
        
        private lazy var preplayView = UIImageView()
        private lazy var preplayView2 = UIImageView()
        private lazy var precancelView = UIImageView()
        private lazy var precancelView2 = UIImageView()
        private lazy var operatorView: UIView = {
            let view = UIView()
            let line = UIImageView()
            
            // config
            line.image = UIImage(named: "simchat_keyboard_voice_line")
            line.translatesAutoresizingMaskIntoConstraints = false
            
            self.preplayView2.image = UIImage(named: "simchat_keyboard_voice_operate_listen_nor")
            self.preplayView2.highlightedImage = UIImage(named: "simchat_keyboard_voice_operate_listen_press")
            self.preplayView2.translatesAutoresizingMaskIntoConstraints = false
            
            self.precancelView2.image = UIImage(named: "simchat_keyboard_voice_operate_delete_nor")
            self.precancelView2.highlightedImage = UIImage(named: "simchat_keyboard_voice_operate_delete_press")
            self.precancelView2.translatesAutoresizingMaskIntoConstraints = false
            
            self.preplayView.image = UIImage(named: "simchat_keyboard_voice_operate_nor")
            self.preplayView.highlightedImage = UIImage(named: "simchat_keyboard_voice_operate_press")
            self.preplayView.translatesAutoresizingMaskIntoConstraints = false
            
            self.precancelView.image = UIImage(named: "simchat_keyboard_voice_operate_nor")
            self.precancelView.highlightedImage = UIImage(named: "simchat_keyboard_voice_operate_press")
            self.precancelView.translatesAutoresizingMaskIntoConstraints = false
            
            // add view
            view.addSubview(line)
            view.addSubview(self.preplayView)
            view.addSubview(self.precancelView)
            view.addSubview(self.preplayView2)
            view.addSubview(self.precancelView2)
            
            // add constraints
            view.addConstraint(NSLayoutConstraintMake(self.preplayView,   .Left,   .Equal, view, .Left))
            view.addConstraint(NSLayoutConstraintMake(self.preplayView,   .Top,    .Equal, view, .Top))
            view.addConstraint(NSLayoutConstraintMake(self.precancelView, .Top,    .Equal, view, .Top))
            view.addConstraint(NSLayoutConstraintMake(self.precancelView, .Right,  .Equal, view, .Right))
            
            view.addConstraint(NSLayoutConstraintMake(line, .Left,   .Equal, view, .Left,   3.5))
            view.addConstraint(NSLayoutConstraintMake(line, .Right,  .Equal, view, .Right, -3.5))
            view.addConstraint(NSLayoutConstraintMake(line, .Top,    .Equal, view, .Top,    14))
            view.addConstraint(NSLayoutConstraintMake(line, .Bottom, .Equal, view, .Bottom))
            
            view.addConstraint(NSLayoutConstraintMake(self.preplayView2,   .CenterX, .Equal, self.preplayView,   .CenterX))
            view.addConstraint(NSLayoutConstraintMake(self.preplayView2,   .CenterY, .Equal, self.preplayView,   .CenterY))
            view.addConstraint(NSLayoutConstraintMake(self.precancelView2, .CenterX, .Equal, self.precancelView, .CenterX))
            view.addConstraint(NSLayoutConstraintMake(self.precancelView2, .CenterY, .Equal, self.precancelView, .CenterY))
            
            return view
        }()
    }
}

/// MAKR: - /// Toolbar
extension SIMChatKeyboardAudio {
    /// 显示播放
    func onShowPlay() {
        SIMLog.trace()
        
        self.playView.hidden = false
        self.playView.alpha = 0
        self.playView.playStop()
        
        //self.pushTalkView.tipsLabel.hidden = true
        
        UIView.animateWithDuration(0.25, animations: {
            self.playView.alpha = 1
            self.pushTalkView.tipsLabel.alpha = 0
        })
    }
    /// 显示录音
    func onShowRecord() {
        SIMLog.trace()
        
        self.pushTalkView.recordStop()
        
        UIView.animateWithDuration(0.25, animations: {
            self.playView.alpha = 0
            self.pushTalkView.tipsLabel.alpha = 1
        }, completion: { b in
            self.playView.hidden = false
            if self.playView.playing {
                self.playView.onStop()
            }
        })
    }
    /// 显示工具栏
    func onShowToolbar() {
        SIMLog.trace()
        
        self.toolbarView.bringSubviewToFront(self)
        self.toolbarView.hidden = false
        self.toolbarView.alpha = 0
        self.toolbarView.layoutIfNeeded()
        
        UIView.animateWithDuration(0.25, animations: {
            self.toolbarView.alpha = 1
            self.toolbarView.layer.transform = CATransform3DMakeTranslation(0, -self.toolbarView.bounds.height, 0)
        })
    }
    /// 隐藏工具栏
    func onHideToolbar() {
        SIMLog.trace()
        // 并不需要隐藏
        if self.toolbarView.hidden {
            return
        }
        UIView.animateWithDuration(0.25, animations: {
            self.toolbarView.layer.transform = CATransform3DMakeTranslation(0, 0, 0)
        }, completion: { b in
            self.toolbarView.hidden = true
        })
    }
}

// MARK: - Manager
extension SIMChatKeyboardAudio : SIMChatAudioManagerDelegate {
    /// 开始录音
    func chatAudioManagerDidStartRecord(chatAudioManager: SIMChatAudioManager, param: AnyObject) {
        self.delegate?.chatKeyboardAudioDidBegin?(self)
        self.pushTalkView.recordStart()
    }
    /// 录音失败
    func chatAudioManagerRecordFail(chatAudioManager: SIMChatAudioManager, error: NSError?) {
        self.delegate?.chatKeyboardAudioDidEnd?(self)
        self.pushTalkView.recordFail(error)
    }
    /// 开始播放
    func chatAudioManagerDidStartPlay(chatAudioManager: SIMChatAudioManager, param: AnyObject) {
        self.playView.playStart()
    }
    /// 播放错误
    func chatAudioManagerPlayFail(chatAudioManager: SIMChatAudioManager, error: NSError?) {
        self.playView.playFail(error)
    }
}

// MARK: - Event
extension SIMChatKeyboardAudio : SIMChatKeyboardAudioViewDelegate {
    /// 试听
    func chatKeyboardAudioViewDidListen() {
        SIMLog.trace()
        
        self.onShowPlay()
        self.onShowToolbar()
    }
    /// 完成
    func chatKeyboardAudioViewDidFinish() {
        SIMLog.trace()
        
        // 如果正在播放, 必须先停止音频, ui再慢慢更新
        if self.playView.playing {
            self.chatKeyboardAudioViewDidStop()
        }
        
        self.onShowRecord()
        self.onHideToolbar()
        
        self.delegate?.chatKeyboardAudioDidEnd?(self)
        self.delegate?.chatKeyboardAudioDidFinish?(self, url: self.am.dynamicType.defaultRecordFile, duration: self.recordDuration)
    }
    /// 取消
    func chatKeyboardAudioViewDidCancel() {
        SIMLog.trace()
        
        // 如果正在播放, 必须先停止音频, ui再慢慢更新
        if self.playView.playing {
            self.chatKeyboardAudioViewDidStop()
        }
        
        self.onShowRecord()
        self.onHideToolbar()
        
        self.delegate?.chatKeyboardAudioDidEnd?(self)
        self.delegate?.chatKeyboardAudioDidCancel?(self, url: self.am.dynamicType.defaultRecordFile)
    }
    
    /// Info
    
    /// 持续时间
    func chatKeyboardAudioViewDuration() -> NSTimeInterval {
        return self.am.duration
    }
    /// 当前时间
    func chatKeyboardAudioViewCurrentTime() -> NSTimeInterval {
        let currentTime = self.am.currentTime
        // 如果是录音, 维持一个最大的录音时间
        if self.am.recording {
            self.recordDuration = currentTime
        }
        return currentTime
    }
    /// 当前音波(左)
    func chatSpectrumViewWaveOfLeft(chatSpectrumView: SIMChatSpectrumView) -> Float {
        return self.am.meter(0)
    }
    /// 当前音波(右)
    func chatSpectrumViewWaveOfRight(chatSpectrumView: SIMChatSpectrumView) -> Float {
        return self.am.meter(0)
    }
    
    /// Control
    
    /// 开始播放
    func chatKeyboardAudioViewDidStartPlay() {
        SIMLog.trace()
        self.am.delegate = self
        self.am.play(self.am.dynamicType.defaultRecordFile)
    }
    /// 开始录音
    func chatKeyboardAudioViewDidStartRecord() {
        SIMLog.trace()
        self.am.delegate = self
        self.am.record(self.am.dynamicType.defaultRecordFile)
    }
    /// 停止
    func chatKeyboardAudioViewDidStop() {
        SIMLog.trace()
        self.pushTalkView.recordStop()
        self.playView.playStop()
        self.am.stop()
    }
}

// MARK: - protocol

/// 内部代理.
@objc private protocol SIMChatKeyboardAudioViewDelegate : NSObjectProtocol, SIMChatSpectrumViewDelegate {
    
    optional func chatKeyboardAudioViewDuration() -> NSTimeInterval
    optional func chatKeyboardAudioViewCurrentTime() -> NSTimeInterval
    
    optional func chatKeyboardAudioViewDidStartPlay()
    optional func chatKeyboardAudioViewDidStartRecord()
    optional func chatKeyboardAudioViewDidStop()
    
    optional func chatKeyboardAudioViewDidCancel()
    optional func chatKeyboardAudioViewDidFinish()
    optional func chatKeyboardAudioViewDidListen()
}

/// 公开代理
@objc protocol SIMChatKeyboardAudioDelegate : NSObjectProtocol {
  
    optional func chatKeyboardAudioDidBegin(chatKeyboardAudio: SIMChatKeyboardAudio)
    optional func chatKeyboardAudioDidEnd(chatKeyboardAudio: SIMChatKeyboardAudio)
    
    optional func chatKeyboardAudioDidCancel(chatKeyboardAudio: SIMChatKeyboardAudio, url: NSURL)
    optional func chatKeyboardAudioDidFinish(chatKeyboardAudio: SIMChatKeyboardAudio, url: NSURL, duration: NSTimeInterval)
}

