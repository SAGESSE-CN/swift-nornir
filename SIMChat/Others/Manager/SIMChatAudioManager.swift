//
//  SIMChatAudioManager.swift
//  SIMChat
//
//  Created by sagesse on 9/22/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit
import AVFoundation

/// 音频管理
class SIMChatAudioManager: NSObject {
    /// 初始化
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "interruption:", name: AVAudioSessionInterruptionNotification, object: nil)
    }
    /// 释放
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    ///
    /// 播放(优先用文件吧, 低内存占用)
    ///
    func play(url: NSURL) {
        SIMLog.trace()
        // 一定要先停止.
        self.stop()
        // 允许播放?
        if !(self.delegate?.chatAudioManagerWillStartPlay?(self, param: url) ?? true) {
            // 不允许
            return
        }
        // 通知:)
        SIMChatNotificationCenter.postNotificationName(SIMChatAudioManagerWillPlayNotification, object: url)
        
        do {
           
            // create
            self.player = try AVAudioPlayer(contentsOfURL: url)
            self.player?.delegate = self
            self.player?.meteringEnabled = true
            // config
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            // prepare 
            if !(self.player?.prepareToPlay() ?? false) {
                self.player = nil
                throw NSError(domain: "requeset player prepare fail!", code: -2, userInfo: nil)
            }
            // start
            self.player?.play()
            // 己经启动
            self.delegate?.chatAudioManagerDidStartPlay?(self, param: url)
            // 通知
            SIMChatNotificationCenter.postNotificationName(SIMChatAudioManagerDidPlayNotification, object: url)
            
        } catch let error as NSError  {
                
            SIMLog.error(error)
            // 回调
            self.delegate?.chatAudioManagerPlayFail?(self, error: error)
            
        }
    }
    ///
    /// 播放
    ///
    func playWithData(data: NSData) {
        SIMLog.trace()
        // 一定要先停止.
        self.stop()
        // 允许播放?
        if !(self.delegate?.chatAudioManagerWillStartPlay?(self, param: data) ?? true) {
            // 不允许
            return
        }
        // 通知:)
        SIMChatNotificationCenter.postNotificationName(SIMChatAudioManagerWillPlayNotification, object: data)
        
        do {
           
            // create
            self.player = try AVAudioPlayer(data: data)
            self.player?.delegate = self
            self.player?.meteringEnabled = true
            // config
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            // prepare 
            if !(self.player?.prepareToPlay() ?? false) {
                self.player = nil
                throw NSError(domain: "requeset player prepare fail!", code: -2, userInfo: nil)
            }
            // start
            self.player?.play()
            // 己经启动
            self.delegate?.chatAudioManagerDidStartPlay?(self, param: data)
            // 通知
            SIMChatNotificationCenter.postNotificationName(SIMChatAudioManagerDidPlayNotification, object: data)
            
        } catch let error as NSError  {
                
            SIMLog.error(error)
            // 回调
            self.delegate?.chatAudioManagerPlayFail?(self, error: error)
            
        }
    }
    
    /// 准备播放
    func prepareToPlay() -> SIMChatRequest<Void> {
        let url = self.dynamicType.defaultRecordFile
        return SIMChatRequest.request { e in
            do {
                
                // create
                self.player = try AVAudioPlayer(contentsOfURL: url)
                self.player?.delegate = self
                self.player?.meteringEnabled = true
                // config
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                // prepare 
                if !(self.player?.prepareToPlay() ?? false) {
                    self.player = nil
                    throw NSError(domain: "requeset player prepare fail!", code: -2, userInfo: nil)
                }
                e.success()
            } catch let error as NSError  {
                e.failure(error)
            }
        }
    }
    
    /// 准备录音
    func prepareToRecord() -> SIMChatRequest<Void> {
        let url = self.dynamicType.defaultRecordFile
        return SIMChatRequest.request { e in
            // 首先请求录音权限
            AVAudioSession.sharedInstance().requestRecordPermission { hasPermission in
                do {
                    // 检查有没有权限
                    guard hasPermission else {
                        throw NSError(domain: "requeset record permission fail!", code: -1, userInfo: nil)
                    }
                    let _ = try? NSFileManager.defaultManager().removeItemAtURL(url)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
                    try AVAudioSession.sharedInstance().setActive(true)
                    
                    self.recorder = try AVAudioRecorder(URL: url, settings: self.recordSettings)
                    self.recorder?.delegate = self
                    self.recorder?.meteringEnabled = true
                    
                    // prepare
                    if !(self.recorder?.prepareToRecord() ?? false) {
                        self.recorder = nil
                        throw NSError(domain: "requeset record prepare fail!", code: -2, userInfo: nil)
                    }
                    
                    e.success()
                } catch let error as NSError  {
                    e.failure(error)
                }
            }
        }
    }
    
    func play() {
        SIMLog.trace()
        let url = self.dynamicType.defaultRecordFile
        // start
        self.player?.play()
        // 己经启动
        self.delegate?.chatAudioManagerDidStartPlay?(self, param: url)
        // 通知
        SIMChatNotificationCenter.postNotificationName(SIMChatAudioManagerDidPlayNotification, object: url)
    }
    
    ///
    /// 录音
    ///
    func record() {
        SIMLog.trace()
        let url = self.dynamicType.defaultRecordFile
//        // 一定要先停止.
//        self.stop()
//        // 允许录音? 问过之后才请求权限
//        if !(self.delegate?.chatAudioManagerWillStartRecord?(self, param: url) ?? true) {
//            // 不允许.
//            return
//        }
//        // 通知:)
//        SIMChatNotificationCenter.postNotificationName(SIMChatAudioManagerWillRecordNotification, object: url)
//        // :)
//        self.recordStarted = true
//        // 请求录音权限
//        AVAudioSession.sharedInstance().requestRecordPermission { hasPermission in
//            do {
//                // 己经取消了该请求?
//                if !self.recordStarted {
//                    return
//                }
//                // 请求失败
//                if !hasPermission {
//                    throw NSError(domain: "requeset record permission fail!", code: -1, userInfo: nil)
//                }
//                // clean
//                let _ = try? NSFileManager.defaultManager().removeItemAtURL(url)
//                // config
//                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
//                try AVAudioSession.sharedInstance().setActive(true)
//                // create
//                self.recorder = try AVAudioRecorder(URL: url, settings: self.recordSettings)
//                self.recorder?.delegate = self
//                self.recorder?.meteringEnabled = true
//                // prepare 
//                if !(self.recorder?.prepareToRecord() ?? false) {
//                    self.recorder = nil
//                    throw NSError(domain: "requeset record prepare fail!", code: -2, userInfo: nil)
//                }
                // start
                self.recorder?.record()
                // 己经启动了录音.
                self.delegate?.chatAudioManagerDidStartRecord?(self, param: url)
                // 通知用户
                SIMChatNotificationCenter.postNotificationName(SIMChatAudioManagerWillRecordNotification, object: url)
//                
//            } catch let error as NSError  {
//                
//                SIMLog.error(error)
//                // 回调
//                self.delegate?.chatAudioManagerRecordFail?(self, error: error)
//                
//            }
//        }
    }
    ///
    /// 停止
    ///
    func stop() {
        self.recordStarted = false
        // 需要停止?
        if player == nil && recorder == nil {
            return
        }
        SIMLog.trace()
        SIMChatNotificationCenter.postNotificationName(SIMChatAudioManagerWillStopNotification, object: nil)
        // 终止播放
        player?.stop()
        player?.delegate = nil
        player = nil
        // 终止录音
        recorder?.stop()
        recorder?.delegate = nil
        recorder = nil
        // 通知
        SIMChatNotificationCenter.postNotificationName(SIMChatAudioManagerDidStopNotification, object: nil)
        // 延迟0.5s再恢复, 不然给人一种毛燥的感觉
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(500 * NSEC_PER_MSEC)), dispatch_get_main_queue()) {
            // 如果正在使用就不要取消激活了
            if self.playing || self.recording {
                return
            }
            /// 取消激活
            let _ = try? AVAudioSession.sharedInstance().setActive(false, withOptions: .NotifyOthersOnDeactivation)
        }
    }
    /// 波形
    func meter(channel: Int) -> Float {
        if playing {
            // 首先要更新一下才能获取到
            player?.updateMeters()
            // 去看看
            return player?.averagePowerForChannel(channel) ?? -160
        }
        if recording {
            // 首先要更新一下才能获取到
            recorder?.updateMeters()
            // 去看看
            return recorder?.averagePowerForChannel(channel) ?? -160
        }
        return -160
    }
    /// 正在播放
    var playing: Bool {
        return player?.playing ?? false
    }
    /// 正在录音
    var recording: Bool {
        return recorder?.recording ?? false
    }
    /// 持续时间
    var duration: NSTimeInterval {
        if playing {
            return player?.duration ?? 0
        }
        if recording {
            return recorder?.currentTime ?? 0
        }
        return 0
    }
    /// 当前时间
    var currentTime: NSTimeInterval {
        if playing {
            return player?.currentTime ?? 0
        }
        if recording {
            return recorder?.currentTime ?? 0
        }
        return 0
    }
    /// 代理
    weak var delegate: SIMChatAudioManagerDelegate?
   
    private var recordStarted = false
    
    private(set) lazy var player: AVAudioPlayer? = nil
    private(set) lazy var recorder: AVAudioRecorder? = nil
    private(set) lazy var recordSettings: [String : AnyObject] = {
        return [AVFormatIDKey: Int(kAudioFormatLinearPCM),               // 设置录音格式  AVFormatIDKey == kAudioFormatLinearPCM
                AVSampleRateKey: 44100,                                  // 设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
                AVNumberOfChannelsKey: 1,                                // 录音通道数  1 或 2
                AVLinearPCMBitDepthKey: 16,                              // 线性采样位数  8、16、24、32
                AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue   // 录音的质量
        ]
    }()
    
    /// 单例
    static let sharedManager = SIMChatAudioManager()
    static let defaultRecordFile = NSURL(fileURLWithPath: NSTemporaryDirectory() + "/record_tmp.acc")
}

// MARK: - Player
extension SIMChatAudioManager : AVAudioPlayerDelegate {
    /// 完成播放
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        SIMLog.trace()
        delegate?.chatAudioManagerPlayFinish?(self)
        stop()
    }
    /// 未能完成
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        SIMLog.trace()
        delegate?.chatAudioManagerPlayFail?(self, error: error)
        stop()
    }
}

// MARK: - Recorder
extension SIMChatAudioManager : AVAudioRecorderDelegate {
    /// 录音完成
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        SIMLog.trace()
        delegate?.chatAudioManagerRecordFinish?(self)
        stop()
    }
    /// 录音失败
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        SIMLog.trace()
        delegate?.chatAudioManagerRecordFail?(self, error: error)
        stop()
    }
    
}

// MARK: - Interruption
extension SIMChatAudioManager {
    /// 中断
    func interruption(sender: NSNotification) {
        SIMLog.debug(sender)
    }
}

// MARK: - Delegate
@objc protocol SIMChatAudioManagerDelegate : NSObjectProtocol {
    
    optional func chatAudioManagerWillStartPlay(chatAudioManager: SIMChatAudioManager, param: AnyObject) -> Bool
    optional func chatAudioManagerDidStartPlay(chatAudioManager: SIMChatAudioManager, param: AnyObject)
    
    optional func chatAudioManagerWillStartRecord(chatAudioManager: SIMChatAudioManager, param: AnyObject) -> Bool
    optional func chatAudioManagerDidStartRecord(chatAudioManager: SIMChatAudioManager, param: AnyObject)
    
    optional func chatAudioManagerWillStop(chatAudioManager: SIMChatAudioManager) -> Bool
    optional func chatAudioManagerDidStop(chatAudioManager: SIMChatAudioManager)
    
    optional func chatAudioManagerRecordFinish(chatAudioManager: SIMChatAudioManager)
    optional func chatAudioManagerRecordFail(chatAudioManager: SIMChatAudioManager, error: NSError?)
    
    optional func chatAudioManagerPlayFinish(chatAudioManager: SIMChatAudioManager)
    optional func chatAudioManagerPlayFail(chatAudioManager: SIMChatAudioManager, error: NSError?)
}

/// 停止
let SIMChatAudioManagerWillStopNotification = "SIMChatAudioManagerWillStopNotification"
let SIMChatAudioManagerDidStopNotification = "SIMChatAudioManagerDidStopNotification"

/// 播放
let SIMChatAudioManagerWillPlayNotification = "SIMChatAudioManagerWillPlayNotification"
let SIMChatAudioManagerDidPlayNotification = "SIMChatAudioManagerDidPlayNotification"

/// 录音
let SIMChatAudioManagerWillRecordNotification = "SIMChatAudioManagerWillRecordNotification"
let SIMChatAudioManagerDidRecordNotification = "SIMChatAudioManagerDidRecordNotification"

// 加载
let SIMChatAudioManagerWillLoadNotification = "SIMChatAudioManagerWillLoadNotification"
let SIMChatAudioManagerDidLoadNotification = "SIMChatAudioManagerDidLoadNotification"
