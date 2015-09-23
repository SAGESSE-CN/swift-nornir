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
        
        self.pushTalkView.hidden = false
    }
    /// 固定大小
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(0, 216)
    }
    
    private lazy var playView: SIMChatKeyboardAudioPlayView = {
        let view = SIMChatKeyboardAudioPlayView()
        
        // config
        //view.delegate = self
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
        send.setTitleColor(UIColor(hex: 0x18B4ED), forState: .Normal)
        send.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_send_nor"), forState: .Normal)
        send.setBackgroundImage(UIImage(named: "simchat_keyboard_voice_more_send_press"), forState: .Highlighted)
        send.translatesAutoresizingMaskIntoConstraints = false
        
        cancel.setTitle("取消", forState: .Normal)
        cancel.setTitleColor(UIColor(hex: 0x18B4ED), forState: .Normal)
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
    
    private lazy var audioManager = SIMChatAudioManager()
}

/// MARK: - /// Type 
extension SIMChatKeyboardAudio {
    /// 播放
    class SIMChatKeyboardAudioPlayView : SIMView {
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
            playProgress.strokeColor = UIColor(hex: 0x18B4ED).CGColor
            playProgress.strokeStart = 0
            playProgress.strokeEnd = 0
            playProgress.frame = playButton.bounds
            playProgress.path = UIBezierPath(ovalInRect: playButton.bounds).CGPath
            playProgress.transform = CATransform3DMakeRotation((-90 / 180) * CGFloat(M_PI), 0, 0, 1)
            
            playButton.layer.addSublayer(playProgress)
            
            // add views
            addSubview(playButton)
            
            /// add constraints
            addConstraint(NSLayoutConstraintMake(playButton, .Top,     .Equal, self, .Top, 51))
            addConstraint(NSLayoutConstraintMake(playButton, .CenterX, .Equal, self, .CenterX))
            
            // add event
            playButton.addTarget(self, action: "onClicked:", forControlEvents: .TouchUpInside)
            
            // disable
            playing = false
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
            }
        }
        dynamic func onTimer(sender: AnyObject) {
            // 计算当前进度
            let cur = CACurrentMediaTime() - self.startAt
            // 更新进度
            self.playProgress.strokeEnd = CGFloat(cur / max(self.duration, 0.1))
            // 完成了?
            if cur > self.duration + 0.1 {
                self.onStop()
            }
        }
        dynamic func onClicked(sender: AnyObject) {
            if self.playing {
                // 正在播放, 那就停止
                self.onStop()
            } else {
                // 没有播放, 开始播放
                self.onPlay()
            }
        }
        
        dynamic func onPlay() {
            // 如果正在播放, 跳过
            if self.timer != nil {
                return
            }
            // 重置
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.playProgress.strokeEnd = 0
            CATransaction.commit()
            
            self.playing = true
            self.playProgress.hidden = false
            
            // 获取
            self.duration = delegate?.chatKeyboardAudioViewDuration?() ?? 0
            
            // 开启线程, 注意必须在主线程开
            dispatch_async(dispatch_get_main_queue()) {
                self.timer = NSTimer.scheduledTimerWithTimeInterval2(0.1, self, "onTimer:")
                self.startAt = CACurrentMediaTime()
            }
        }
        dynamic func onStop() {
            
            self.timer?.invalidate()
            self.timer = nil
            // 重置
            self.playing = false
            self.playProgress.hidden = true
        }
        
        weak var delegate: SIMChatKeyboardAudioViewDelegate?
        
        private var timer: NSTimer?
        private var startAt: CFTimeInterval = 0
        private var duration: NSTimeInterval = 0
        
        private var playButton = UIButton()
        private var playProgress = CAShapeLayer()
    }
    /// 按下说话
    private class SIMChatKeyboardAudioPushToTalkView : SIMView {
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
            
            tipsLabel.text = "按住说话"
            tipsLabel.textColor = UIColor(hex: 0x7B7B7B)
            tipsLabel.translatesAutoresizingMaskIntoConstraints = false
            
            activityView.translatesAutoresizingMaskIntoConstraints = false
            activityView.hidesWhenStopped = true
            activityView.hidden = true
            
            // add view
            addSubview(operatorView)
            addSubview(recordButton)
            addSubview(tipsLabel)
            addSubview(activityView)
            
            // add constraints
            addConstraint(NSLayoutConstraintMake(tipsLabel, .CenterX, .Equal, self, .CenterX))
            addConstraint(NSLayoutConstraintMake(tipsLabel, .Top,     .Equal, self, .Top, 20))
            
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
            
            recordButton.addTarget(self, action: "onBegin:", forControlEvents: .TouchDown)
            recordButton.addTarget(self, action: "onEnd:", forControlEvents: .TouchUpInside)
            recordButton.addTarget(self, action: "onEnd:", forControlEvents: .TouchUpOutside)
            recordButton.addTarget(self, action: "onInterrupt:", forControlEvents: .TouchCancel)
        }
        /// 事件
        dynamic func onBegin(sender: AnyObject) {
            /// 己经准备好了?
            guard self.delegate?.chatKeyboardAudioViewWillBeginRecord?() ?? false else {
                // 并没有
                return
            }
            SIMLog.trace()
            // 先重置状态
            self.preplayView.highlighted = false
            self.preplayView2.highlighted = false
            self.precancelView.highlighted = false
            self.precancelView2.highlighted = false
            
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
            
            recordButton.layer.addAnimation(ani, forKey: "start")
            
            // ok, 正式开工
            self.recording = true
            self.delegate?.chatKeyboardAudioViewDidBeginPlay?()
        }
        dynamic func onEnd(sender: AnyObject) {
            // 正在录音?
            guard self.recording else {
                // 没有, 跳过
                return
            }
            SIMLog.trace()
            // 完工.
            self.recording = false
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
            // 隐藏就行了
            UIView.animateWithDuration(0.25) {
                self.operatorView.alpha = 0
                self.preplayView.layer.transform = CATransform3DIdentity
                self.precancelView.layer.transform = CATransform3DIdentity
            }
        }
        dynamic func onInterrupt(sender: AnyObject) {
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
            self.onEnd(sender)
        }
        dynamic func onDrag(sender: UIButton, withEvent event: UIEvent?) {
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
                
                self.update()
                
                self.preplayView.layer.transform = CATransform3DMakeScale(sl, sl, 1)
                self.precancelView.layer.transform = CATransform3DMakeScale(sr, sr, 1)
                self.preplayView.highlighted = hl
                self.preplayView2.highlighted = hl
                self.precancelView.highlighted = hr
                self.precancelView2.highlighted = hr
            }
        }
        
        dynamic func onListen(sender: AnyObject) {
            self.delegate?.chatKeyboardAudioViewDidListen?()
        }
        dynamic func onFinish(sender: AnyObject) {
            self.delegate?.chatKeyboardAudioViewDidFinish?()
        }
        dynamic func onCancel(sender: AnyObject) {
            self.delegate?.chatKeyboardAudioViewDidCancel?()
        }
      
        private func update() {
            if self.preplayView.highlighted {
                tipsLabel.text = "松开播放"
            } else if self.precancelView.highlighted {
                tipsLabel.text = "松开取消"
            } else {
                tipsLabel.text = "录音中.."
            }
        }
        
        private(set) var recording: Bool = false
       
        weak var delegate: SIMChatKeyboardAudioViewDelegate?
        
        private lazy var tipsLabel = UILabel()
        private lazy var spectrumView = SIMChatSpectrumView(frame: CGRectZero)
        private lazy var activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        
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
        
        UIView.animateWithDuration(0.25) {
            self.playView.alpha = 1
        }
    }
    /// 显示录音
    func onShowRecord() {
        SIMLog.trace()
        
        UIView.animateWithDuration(0.25, animations: {
            self.playView.alpha = 0
        }, completion: { b in
            self.playView.hidden = false
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

/// MARK: - /// Event
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
        
        self.onShowRecord()
        self.onHideToolbar()
    }
    /// 取消
    func chatKeyboardAudioViewDidCancel() {
        SIMLog.trace()
        
        self.onShowRecord()
        self.onHideToolbar()
    }
    
    /// Info
    
    /// 持续时间
    func chatKeyboardAudioViewDuration() -> NSTimeInterval {
        return 8
    }
    /// 当前时间
    func chatKeyboardAudioViewCurrentTime() -> NSTimeInterval {
        return 0
    }
    /// 当前音波
    func chatKeyboardAudioViewMeter() -> Float {
        return 80
    }
    
    /// Control
    
    /// 将要开始播放
    func chatKeyboardAudioViewWillBeginPlay() -> Bool {
        SIMLog.trace()
        return true
    }
    /// 己经开始播放
    func chatKeyboardAudioViewDidBeginPlay() {
        SIMLog.trace()
    }
    /// 将要开始录音
    func chatKeyboardAudioViewWillBeginRecord() -> Bool {
        SIMLog.trace()
        return true
    }
    /// 己经开始录音
    func chatKeyboardAudioViewDidBeginRecord() {
        SIMLog.trace()
    }
    /// 己经停止
    func chatKeyboardAudioViewDidStop() {
        SIMLog.trace()
    }
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


/// MARK: - /// protocol
@objc protocol SIMChatKeyboardAudioViewDelegate : NSObjectProtocol {
    
    optional func chatKeyboardAudioViewMeter() -> Float
    optional func chatKeyboardAudioViewDuration() -> NSTimeInterval
    optional func chatKeyboardAudioViewCurrentTime() -> NSTimeInterval
    
    optional func chatKeyboardAudioViewWillBeginPlay() -> Bool
    optional func chatKeyboardAudioViewDidBeginPlay()
    
    optional func chatKeyboardAudioViewWillBeginRecord() -> Bool
    optional func chatKeyboardAudioViewDidBeginRecord()
    
    optional func chatKeyboardAudioViewDidStop()
    
    optional func chatKeyboardAudioViewDidCancel()
    optional func chatKeyboardAudioViewDidFinish()
    optional func chatKeyboardAudioViewDidListen()
}
