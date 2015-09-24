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
    /// 准备播放
    func prepareToPlay(data: NSData) -> Bool {
        SIMLog.trace()
        // 一定要先停止.
        stop()
        // 允许播放?
        if delegate?.audioManagerWillPlay?(self, data: data) ?? true {
            // 配置..
            let _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            let _ = try? AVAudioSession.sharedInstance().setActive(true)
            // 加载
            player = try? AVAudioPlayer(data: data)
            player?.delegate = self
            player?.meteringEnabled = true
            // 通知
            SIMNotificationCenter.postNotificationName(SIMChatAudioManagerWillPlayNotification, object: player)
            // 真正的准备
            return player?.prepareToPlay() ?? false
        }
        return false
    }
    /// 准备播放
    func prepareToPlay(url url: NSURL) -> Bool {
        if let data = NSData(contentsOfURL: url) {
            return prepareToPlay(data)
        }
        return false
    }
    /// 准备录音
    func prepareToRecord(url: NSURL = SIMChatAudioManager.defaultRecordFile) -> Bool {
        SIMLog.trace()
        // 一定要先停止.
        stop()
        // 允许录音?
        if delegate?.audioManagerWillRecord?(self, url: url) ?? true {
            // 配置..
            let _ = try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            let _ = try! AVAudioSession.sharedInstance().setActive(true)
            // 删除这个文件
            let _ = try! NSFileManager.defaultManager().removeItemAtURL(url)
            // 加载
            recorder = try! AVAudioRecorder(URL: url, settings: self.recordSettings)
            recorder?.delegate = self
            recorder?.meteringEnabled = true
            // 通知
            SIMNotificationCenter.postNotificationName(SIMChatAudioManagerWillRecordNotification, object: recorder)
            // 真正的准备
            return recorder?.prepareToRecord() ?? false
        }
        // ..
        return false
    }
    /// 播放(需要准备)
    func play() {
        // 检查一下有没有准备好
        if player == nil {
            delegate?.audioManagerDidPlayFail?(self, error: NSError(domain: "没有准备好", code: 1, userInfo: nil))
            return
        }
        SIMLog.trace()
        // 调用播放
        player?.play()
        // 通知.
        delegate?.audioManagerDidPlay?(self, data: player!.data!)
        // ..
        SIMNotificationCenter.postNotificationName(SIMChatAudioManagerDidPlayNotification, object: player)
    }
    /// 录音(需要准备)
    func record() {
        // 检查一下有没有准备好
        if recorder == nil {
            delegate?.audioManagerDidRecordFail?(self, error: NSError(domain: "没有准备好", code: 1, userInfo: nil))
            return
        }
        SIMLog.trace()
        // 调用录音
        recorder?.record()
        // 通知
        delegate?.audioManagerDidRecord?(self, url: recorder!.url)
        // ..
        SIMNotificationCenter.postNotificationName(SIMChatAudioManagerDidRecordNotification, object: recorder)
    }
    /// 完成
    func finish() {
        if player != nil {
            player?.stop()
            player?.delegate = nil
            player = nil
        }
        if recorder != nil {
            recorder?.stop()
            // 等待完成
            while recorder != nil {
                NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.05))
            }
        }
    }
    /// 操作
    func stop() {
        // 需要停止?
        if player == nil && recorder == nil {
            return
        }
        SIMLog.trace()
        SIMNotificationCenter.postNotificationName(SIMChatAudioManagerWillStopNotification, object: nil)
        // 终止播放
        player?.stop()
        player?.delegate = nil
        player = nil
        // 终止录音
        recorder?.stop()
        recorder?.delegate = nil
        recorder = nil
        // 通知
        SIMNotificationCenter.postNotificationName(SIMChatAudioManagerDidStopNotification, object: nil)
    }
    /// 波形
    func meter(channel: Int) -> Float {
        if playing {
            // 首先要更新一下才能获取到
            player?.updateMeters()
            // 去看看
            return player?.averagePowerForChannel(channel) ?? 0
        }
        if recording {
            // 首先要更新一下才能获取到
            recorder?.updateMeters()
            // 去看看
            return recorder?.averagePowerForChannel(channel) ?? 0
        }
        return 0
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
    weak var delegate: SIMAudioManagerDelegate?
    
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

/// MARK: - /// Player
extension SIMChatAudioManager : AVAudioPlayerDelegate {
    /// 完成播放
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.audioManagerDidPlayFinish?(self)
        stop()
    }
    /// 未能完成
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        delegate?.audioManagerDidPlayFail?(self, error: error)
        stop()
    }
}

/// MARK: - /// Recorder
extension SIMChatAudioManager : AVAudioRecorderDelegate {
    /// 录音完成
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        SIMLog.trace()
        delegate?.audioManagerDidRecordFinish?(self)
        stop()
    }
    /// 录音失败
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        SIMLog.trace()
        delegate?.audioManagerDidRecordFail?(self, error: error)
        stop()
    }
    
}

/// MARK: - /// Interruption
extension SIMChatAudioManager {
    /// 中断
    func interruption(sender: NSNotification) {
        SIMLog.debug(sender)
    }
}


/// MARK: - /// Delegate
@objc protocol SIMAudioManagerDelegate : NSObjectProtocol {
    
    optional func audioManagerWillPlay(audioManager: SIMChatAudioManager, data: NSData) -> Bool
    optional func audioManagerDidPlay(audioManager: SIMChatAudioManager, data: NSData)
    
    optional func audioManagerWillRecord(audioManager: SIMChatAudioManager, url: NSURL) -> Bool
    optional func audioManagerDidRecord(audioManager: SIMChatAudioManager, url: NSURL)
    
    optional func audioManagerDidRecordFinish(audioManager: SIMChatAudioManager)
    optional func audioManagerDidRecordFail(audioManager: SIMChatAudioManager, error: NSError?)
    
    optional func audioManagerDidPlayFinish(audioManager: SIMChatAudioManager)
    optional func audioManagerDidPlayFail(audioManager: SIMChatAudioManager, error: NSError?)
    
    optional func audioManagerWillStop(audioManager: SIMChatAudioManager) -> Bool
    optional func audioManagerDidStop(audioManager: SIMChatAudioManager)
    
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
