//
//  SIMChatMediaAudioRecorder.swift
//  SIMChat
//
//  Created by sagesse on 2/23/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation
import AVFoundation

public class SIMChatMediaAudioRecorder: NSObject, SIMChatMediaRecorderProtocol, AVAudioRecorderDelegate {
    
    public init(URL: NSURL) {
        _url = URL
        super.init()
        
        SIMChatMediaAudioRecorder.retainInstance = self
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "audioRecorderDidInterruption:",
            name: AVAudioSessionInterruptionNotification,
            object: nil)
        
        SIMLog.trace()
    }

    deinit {
        SIMLog.trace()

        if _isStarted || _isRecording {
            _clear()
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public var URL: NSURL { return _url }
    public var recording: Bool { return false }
    public var currentTime: NSTimeInterval {
        if let time = _recorder?.currentTime where _recorder?.recording ?? false {
           _currentTime = time
        }
        return _currentTime
    }
    
    public weak var delegate: SIMChatMediaRecorderDelegate?
    
    public func prepare() {
        _prepare()
    }
    public func record() {
        _isStarted = true
        _prepare()
        _record()
    }
    public func stop() {
        _stop(false)
        _isStarted = false
    }
    public func cancel() {
        _stop(true)
        _isStarted = false
    }
    
    public func meter(channel: Int) -> Float {
        _recorder?.updateMeters()
        return _recorder?.averagePowerForChannel(channel) ?? -60
    }
    
    private var _url: NSURL
    private var _recorder: AVAudioRecorder?
    private var _currentTime: NSTimeInterval = 0
    
    private static let _settings: Dictionary<String, AnyObject> = [
        AVFormatIDKey: Int(kAudioFormatLinearPCM),               // 设置录音格式: kAudioFormatLinearPCM
        AVSampleRateKey: 44100,                                  // 设置录音采样率(Hz): 8000/44100/96000(影响音频的质量)
        AVNumberOfChannelsKey: 1,                                // 录音通道数: 1/2
        AVLinearPCMBitDepthKey: 16,                              // 线性采样位数: 8/16/24/32
        AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue   // 录音的质量
    ]
    
    private var _isActive: Bool = false
    private var _isStarted: Bool = false
    
    private var _isRecording: Bool { return _recorder?.recording ?? false }
    private var _isPrepared: Bool { return _recorder != nil }
    private var _isPrepareing: Bool = false
    
    @inline(__always) private func _prepare() {
        guard !_isPrepared && !_isPrepareing else {
            return // 己经准备或正在准备
        }
        guard _shouldPrepare() else {
            return // 申请被拒绝
        }
        SIMLog.trace()
        let url = _url
        _isPrepareing = true
        // 首先请求录音权限
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] hasPermission in
            do {
                // 检查有没有权限
                guard hasPermission else {
                    throw NSError(domain: "record permission fail!", code: -1, userInfo: nil)
                }
                // 删除旧的文件
                let _ = try? NSFileManager.defaultManager().removeItemAtURL(url)
                let recorder = try AVAudioRecorder(URL: url, settings: SIMChatMediaAudioRecorder._settings)
                recorder.delegate = self
                recorder.meteringEnabled = true
                
                if !recorder.prepareToRecord() {
                    throw NSError(domain: "Prepare Record Fail!", code: -1, userInfo: nil)
                }
                dispatch_after_at_now(0.5, dispatch_get_main_queue()) {
                    self?._recorder = recorder
                    self?._isPrepareing = false
                    self?._didPrepare()
                }
            } catch let error as NSError  {
                self?._isPrepareing = false
                self?._didErrorOccur(error)
            }
        }
    }
    @inline(__always) private func _active() throws {
        guard !_isActive else {
            return // 己经激活
        }
        SIMLog.trace()
        // 开启音频会话
        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
        try AVAudioSession.sharedInstance().setActive(true)
        
        _isActive = true
    }
    @inline(__always) private func _deactive() {
        guard _isActive else {
            return // 没有激活
        }
        let session = AVAudioSession.sharedInstance()
        let category = session.category
        // 延迟0.5s再恢复, 不然给人一种毛燥的感觉
        dispatch_after_at_now(0.5, dispatch_get_main_queue()) {
            guard session.category == category else {
                return // 别人使用了
            }
            guard !(SIMChatMediaAudioRecorder.retainInstance?.recording ?? false) else {
                return // 正在播放
            }
            SIMLog.trace()
            let _ = try? AVAudioSession.sharedInstance().setActive(false, withOptions: .NotifyOthersOnDeactivation)
        }
        _isActive = false
    }
    @inline(__always) private func _record() {
        guard _isStarted && _isPrepared else {
            return // 并没有准备好
        }
        do {
            guard let record = _recorder else {
                return // 并没有准备好
            }
            if !_shouldRecord() {
                _clear()
                return // 用户拒绝了该请求
            }
            SIMLog.trace()
            try _active()
            // 播放失败
            if !record.record() {
                throw NSError(domain: "Play Fail", code: -1, userInfo: nil)
            }
            _didRecord()
        } catch let error as NSError {
            _didErrorOccur(error)
        }
    }
    @inline(__always) private func _stop(isCancel: Bool) {
        guard _isPrepared else {
            return // 并没有启动
        }
        SIMLog.trace()
        if !isCancel {
            let isRecording = _isRecording
            _currentTime = currentTime
            _recorder?.stop()
            _didStop()
            _deactive()
            // 等待完成通知再清除
            if !isRecording {
                _clear()
            }
        } else {
            // 取消
            _currentTime = currentTime
            _recorder?.stop()
            _didStop()
            _didCancel()
            _deactive()
            _clear()
        }
    }
    @inline(__always) private func _clear() {
        SIMLog.trace()
        
        _isStarted = false
        _recorder?.delegate = nil
        _recorder?.stop()
        _recorder = nil
        
        if SIMChatMediaAudioRecorder.retainInstance === self {
            SIMChatMediaAudioRecorder.retainInstance = nil
        }
    }
    
    @inline(__always) private func _shouldPrepare() -> Bool {
        SIMLog.trace()
        guard delegate?.recorderShouldPrepare(self) ?? true else {
            return false
        }
        SIMChatNotificationCenter.postNotificationName(SIMChatMediaRecorderWillPrepare, object: self)
        return true
    }
    @inline(__always) private func _didPrepare() {
        SIMLog.trace()
        delegate?.recorderDidPrepare(self)
        SIMChatNotificationCenter.postNotificationName(SIMChatMediaRecorderDidPrepare, object: self)
        // 继续启动
        if _isStarted {
            _record()
        }
    }
    @inline(__always) private func _shouldRecord() -> Bool {
        SIMLog.trace()
        guard delegate?.recorderShouldRecord(self) ?? true else {
            return false
        }
        SIMChatNotificationCenter.postNotificationName(SIMChatMediaRecorderWillRecord, object: self)
        return true
    }
    @inline(__always) private func _didRecord() {
        SIMLog.trace()
        delegate?.recorderDidRecord(self)
        SIMChatNotificationCenter.postNotificationName(SIMChatMediaRecorderDidRecord, object: self)
    }
    @inline(__always) private func _didStop() {
        SIMLog.trace()
        delegate?.recorderDidStop(self)
        SIMChatNotificationCenter.postNotificationName(SIMChatMediaRecorderDidStop, object: self)
    }
    @inline(__always) private func _didCancel() {
        SIMLog.trace()
        delegate?.recorderDidCancel(self)
        SIMChatNotificationCenter.postNotificationName(SIMChatMediaRecorderDidFinsh, object: self)
    }
    @inline(__always) private func _didFinish() {
        SIMLog.trace()
        delegate?.recorderDidFinish(self)
        SIMChatNotificationCenter.postNotificationName(SIMChatMediaRecorderDidCancel, object: self)
    }
    @inline(__always) private func _didErrorOccur(error: NSError) {
        SIMLog.error(error)
        delegate?.recorderDidErrorOccur(self, error: error)
        SIMChatNotificationCenter.postNotificationName(SIMChatMediaRecorderDidErrorOccur, object: self, userInfo: ["Error": error])
        // 释放资源
        _isStarted = false
        _clear()
    }
    
    public func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        dispatch_after_at_now(0.5, dispatch_get_main_queue()) {
            SIMLog.trace()
            self._didFinish()
            self._clear()
        }
    }
    public func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        SIMLog.trace()
        _stop(true)
        _didErrorOccur(error ?? NSError(domain: "Unknow Error", code: -1, userInfo: nil))
    }
    public func audioRecorderDidInterruption(sender: NSNotification) {
        SIMLog.trace()
        guard _isRecording else {
            return
        }
        _stop(true)
        _didErrorOccur(NSError(domain: "Interruption", code: -1, userInfo: nil))
    }
    
    // 保存实例, 在录音完成后释放
    private static var retainInstance: SIMChatMediaAudioRecorder?
}