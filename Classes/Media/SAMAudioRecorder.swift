//
//  SAMAudioRecorder.swift
//  SAMedia
//
//  Created by SAGESSE on 27/10/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import AVFoundation

///
/// 音频录音器
///
open class SAMAudioRecorder: NSObject, AVAudioRecorderDelegate {
    
    // The file type to record is inferred from the file extension. Will overwrite a file at the specified url if a file exists
    public init(contentsOf url: URL, settings: [String : Any]? = nil) throws {
        super.init()
        self.avrecorder = try AVAudioRecorder(url: url, settings: settings ?? [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),              // 设置录音格式: kAudioFormatLinearPCM
            AVSampleRateKey: 44100,                                 // 设置录音采样率(Hz): 8000/44100/96000(影响音频的质量)
            AVNumberOfChannelsKey: 1,                               // 录音通道数: 1/2
            AVLinearPCMBitDepthKey: 16,                             // 线性采样位数: 8/16/24/32
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue  // 录音的质量
        ])
        self.addObservers()
    }
    
    deinit {
        // must clear delegate, otherwise it will also present memory access exceptions.
        self.avrecorder.delegate = nil
        self.stop()
        self.removeObservers()
    }
    
    // MARK: - Transport Control

    // methods that return BOOL return YES on success and NO on failure.
    // creates the file and gets ready to record. happens automatically on record.
    @discardableResult
    open func prepareToRecord() -> Bool {
        return performForPrepare(with: nil)
    }

    // start or resume recording to file.
    @discardableResult
    open func record() -> Bool {
        return performForRecord {
            self.avrecorder.record()
        }
    }

    // start recording at specified time in the future. time is an absolute time based on and greater than deviceCurrentTime.
    @discardableResult
    open func record(atTime time: TimeInterval) -> Bool {
        return performForRecord {
            self.avrecorder.record(atTime: time)
        }
    }
    
    // record a file of a specified duration. the recorder will stop when it has recorded this length of audio
    @discardableResult
    open func record(forDuration duration: TimeInterval) -> Bool  {
        return performForRecord {
            self.avrecorder.record(forDuration: duration)
        }
    }

    // record a file of a specified duration starting at specified time. time is an absolute time based on and greater than deviceCurrentTime.
    @discardableResult
    open func record(atTime time: TimeInterval, forDuration duration: TimeInterval) -> Bool {
        return performForRecord {
            self.avrecorder.record(atTime: time, forDuration: duration)
        }
    }
    
    // pause recording
    open func pause() {
        
        // if there is playing, pause it
        if _isRecording {
            _isRecording = false
            
            avrecorder.pause()
            delegate?.audioRecorder?(didPause: self)
        }
        // must be restored to session
        deactive()
    }

    // stops recording. closes the file.
    open func stop() {
        
        // if there is playing, stop it
        if _isPrepared  {
            _isRecording = false
            _isPrepared = false
            
            avrecorder.stop()
            delegate?.audioRecorder?(didStop: self)
        }
        // must be restored to session
        deactive()
    }

    // delete the recorded file. recorder must be stopped. returns NO on failure.
    @discardableResult
    open func deleteRecording() -> Bool {
        return avrecorder.deleteRecording()
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionDidInterruption(_:)), name: .AVAudioSessionInterruption, object: nil)
    }
    fileprivate func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func performForPrepare(with handler: ((Bool) -> Bool)?) -> Bool {
        // is preared?
        guard !self._isPrepared else {
            return handler?(_isPrepared) ?? true
        }
        guard self.delegate?.audioRecorder?(shouldPreparing: self) ?? true else {
            return false // reject
        }
        let handler2: (Bool) -> Bool = { hasPermission in
            
            // check has permission?
            guard hasPermission else {
                self.performForError(-1, "Not permission")
                return false
            }
            _ = self.avrecorder.deleteRecording()
            // check can active session?
            guard self.active() else {
                self.performForError(-3, "Can't active session")
                return false
            }
            guard self.avrecorder.prepareToRecord() else {
                self.performForError(-4, "Can't prepare to record")
                return false
            }
            self._isPrepared = true
            self.avrecorder.delegate = self
            
            self.delegate?.audioRecorder?(didPreparing: self)
            
            // continue process
            return handler?(hasPermission) ?? true
        }
        let recordPermission = AVAudioSession.sharedInstance().recordPermission()
        // is ask user?
        guard recordPermission == .undetermined else {
            return handler2(recordPermission == .granted)
        }
        // ask user
        AVAudioSession.sharedInstance().requestRecordPermission { hasPermission in
            DispatchQueue.main.async {
                _ = handler2(hasPermission)
            }
        }
        return false
    }
    
    fileprivate func performForRecord(with handler: @escaping () -> Bool) -> Bool {
        
        // is recording
        guard !_isRecording else {
            return true
        }
        // if there is no prepare, call prepareToPlay
        return performForPrepare { isPrepared in
            guard isPrepared else {
                return false// reject
            }
            guard self.active() else {
                return false
            }
            guard self.delegate?.audioRecorder?(shouldRecording: self) ?? true else {
                self.deactive()
                return false// reject
            }
            guard handler() else {
                self.performForError(-5, "Can't Start Record")
                return false
            }
            self._isRecording = true
            
            self.delegate?.audioRecorder?(didRecording: self)
            
            return true
        }
    }
    
    fileprivate func performForError(_ code: Int, _ error: String) {
        let error = NSError(domain: "SAMAudioDoMain", code: code, userInfo: [NSLocalizedFailureReasonErrorKey: error])
        
        _isPrepared = false
        _isRecording = false
        
        avrecorder.delegate = nil
        avrecorder.stop()
        
        deactive()
        delegate?.audioRecorder?(didOccur: self, error: error)
    }
    
    @discardableResult
    fileprivate func active() -> Bool {
        guard !_isActived else {
            return true
        }
        _isActived = true
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
            try AVAudioSession.sharedInstance().sm_setActive(true, context: self)
            return true
        } catch {
            return false
        }
        
    }
    @discardableResult
    fileprivate func deactive() -> Bool {
        guard _isActived else {
            return true
        }
        _isActived = false
        do {
            try AVAudioSession.sharedInstance().sm_setActive(false, with: .notifyOthersOnDeactivation, context: self)
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Properties
    
    
    // is it recording or not?
    open var isRecording: Bool {
        return avrecorder.isRecording
    }
    
    // URL of the recorded file
    open var url: URL? {
        return avrecorder.url
    }
    

    // get the current time of the recording - only valid while recording
    open var currentTime: TimeInterval {
        return avrecorder.currentTime
    }

     // get the device current time - always valid
    open var deviceCurrentTime: TimeInterval {
        return avrecorder.deviceCurrentTime
    }
    
    // returns a settings dictionary with keys as described in AVAudioSettings.h
    open var settings: [String : Any] {
        return avrecorder.settings
    }
    
     // the delegate will be sent messages from the SAMAudioRecorderDelegate protocol
    open weak var delegate: SAMAudioRecorderDelegate?
    
    
    // MARK: - Metering
    
    // turns level metering on or off. default is off.
    open var isMeteringEnabled: Bool {
        set { return avrecorder.isMeteringEnabled = newValue }
        get { return avrecorder.isMeteringEnabled }
    }
    
    // call to refresh meter values
    open func updateMeters()  {
        return avrecorder.updateMeters()
    }
    
    // returns peak power in decibels for a given channel
    open func peakPower(forChannel channelNumber: Int) -> Float  {
        return avrecorder.peakPower(forChannel: channelNumber)
    }
    
    // returns average power in decibels for a given channel
    open func averagePower(forChannel channelNumber: Int) -> Float  {
        return avrecorder.averagePower(forChannel: channelNumber)
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    open func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {

        _isRecording = false
        _isPrepared = false
        
        deactive()
        delegate?.audioRecorder?(didFinishRecording: self, successfully: flag)
    }
    
    open func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {

        _isRecording = false
        _isPrepared = false
        
        deactive()
        delegate?.audioRecorder?(didOccur: self, error: error)
    }
    
    open func audioSessionDidInterruption(_ sender: Notification) {
        
        _isRecording = false
        _isPrepared = false
        
        deactive()
        delegate?.audioRecorder?(didInterruption: self)
    }
    
    
    // MARK: - iVar
    
    private var _isPrepared: Bool = false
    private var _isRecording: Bool = false
    private var _isActived: Bool = false
    
    internal var avrecorder: AVAudioRecorder!
}



///
/// 音频播放器代理
///
@objc public protocol SAMAudioRecorderDelegate {

    @objc optional func audioRecorder(shouldPreparing audioRecorder: SAMAudioRecorder) -> Bool
    @objc optional func audioRecorder(didPreparing audioRecorder: SAMAudioRecorder)
    
    @objc optional func audioRecorder(shouldRecording audioRecorder: SAMAudioRecorder) -> Bool
    @objc optional func audioRecorder(didRecording audioRecorder: SAMAudioRecorder)
    
    @objc optional func audioRecorder(didPause audioRecorder: SAMAudioRecorder)
    
    @objc optional func audioRecorder(didStop audioRecorder: SAMAudioRecorder)
    @objc optional func audioRecorder(didInterruption audioRecorder: SAMAudioRecorder)
    
    // audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. 
    @objc optional func audioRecorder(didFinishRecording audioRecorder: SAMAudioRecorder, successfully flag: Bool)
    
    // if an error occurs will be reported to the delegate.
    @objc optional func audioRecorder(didOccur audioRecorder: SAMAudioRecorder, error: Error?)
}
