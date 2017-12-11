//
//  SIMChatMediaAudioPlayer.swift
//  SIMChat
//
//  Created by sagesse on 2/23/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import AVFoundation

public class SIMChatMediaAudioPlayer: NSObject, SIMChatMediaPlayerProtocol, AVAudioPlayerDelegate {
    
    public init(_ resource: SIMChatResourceProtocol) {
        _resource = resource
        super.init()
        
//        NotificationCenter.default.addObserver(self,
//            selector: #selector(type(of: self).audioPlayerDidInterruption(_:)),
//            name: NSNotification.Name.AVAudioSessionInterruption,
//            object: nil)
        
        SIMLog.trace()
    }
    
    deinit {
        SIMLog.trace()
        
        if _isStarted || _isPlaying {
            _clear()
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    public var resource: SIMChatResourceProtocol { return _resource }
    
    public var playing: Bool { return _isPlaying }
    public var duration: TimeInterval { return _player?.duration ?? 0 }
    public var currentTime: TimeInterval { return _player?.currentTime ?? 0 }
    
    public weak var delegate: SIMChatMediaPlayerDelegate?
    
    public func prepare() {
        _prepare()
    }
    public func play() {
        _isStarted = true
        _prepare()
        _play()
    }
    public func stop() {
        _stop()
        _isStarted = false
    }
   
    public func meter(_ channel: Int) -> Float {
        _player?.updateMeters()
        return _player?.averagePower(forChannel: channel) ?? -60
    }
    
    private var _resource: SIMChatResourceProtocol
    private var _player: AVAudioPlayer?
    
    private var _isActive: Bool = false
    private var _isStarted: Bool = false
    
    private var _isPlaying: Bool { return _player?.isPlaying ?? false }
    private var _isPrepared: Bool { return _player != nil }
    private var _isPrepareing: Bool = false
    
    @inline(__always) private func _prepare() {
        guard !_isPrepared && !_isPrepareing else {
            return // 己经准备或正在准备
        }
        guard _shouldPrepare() else {
            return // 申请被拒绝
        }
        SIMLog.trace()
        _isPrepareing = true
        // 进入.
        SIMChatMediaAudioPlayer.retainInstance = self
//        // 下载文件.
//        SIMChatFileProvider.sharedInstance().loadResource(_resource, canCache: false) { [weak self] in
//            do {
//                guard let value = $0.value else {
//                    throw $0.error ?? NSError(domain: "Unknow Error", code: -1, userInfo: nil)
//                }
//                // 创建真实现的播放器
//                let player: AVAudioPlayer = try {
//                    switch value {
//                    case let data as Data:
//                        return try AVAudioPlayer(data: data)
//                    case let url as URL:
//                        return try AVAudioPlayer(contentsOf: url)
//                    default:
//                        throw NSError(domain: "Unsupport Content \(value)", code: -1, userInfo: nil)
//                    }
//                }()
//                player.delegate = self
//                player.isMeteringEnabled = true
//                // 真正的准备~
//                if !player.prepareToPlay() {
//                    throw NSError(domain: "Prepare Play Fail", code: -1, userInfo: nil)
//                }
//                dispatch_after_at_now(0.5, DispatchQueue.main) {
//                    self?._player = player
//                    self?._isPrepareing = false
//                    self?._didPrepare()
//                }
//            } catch let error as NSError {
//                self?._isPrepareing = false
//                self?._didErrorOccur(error)
//            }
//        }
    }
    @inline(__always) private func _active() throws {
        guard !_isActive else {
            return // 己经激活
        }
        SIMLog.trace()
        // 开启音频会话
        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
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
        dispatch_after_at_now(0.5, DispatchQueue.main) {
            guard session.category == category else {
                return // 别人使用了
            }
            guard !(SIMChatMediaAudioPlayer.retainInstance?.playing ?? false) else {
                return // 正在播放
            }
            SIMLog.trace()
            let _ = try? AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
        }
        _isActive = false
    }
    @inline(__always) private func _play() {
        guard _isStarted && _isPrepared else {
            return // 并没有准备好
        }
        do {
            guard let player = _player else {
                return // 并没有准备好
            }
            if !_shouldPlay() {
                _clear()
                return // 用户拒绝了该请求
            }
            SIMLog.trace()
            try _active()
            // 播放失败
            if !player.play() {
                throw NSError(domain: "Play Fail", code: -1, userInfo: nil)
            }
            _didPlay()
        } catch let error as NSError {
            _didErrorOccur(error)
        }
    }
    @inline(__always) private func _stop() {
        guard _isPrepared else {
            return // 并没有启动
        }
        SIMLog.trace()
        if _isStarted {
            _player?.stop()
        }
        _didStop()
        _deactive()
        _clear()
    }
    @inline(__always) private func _clear() {
        SIMLog.trace()
        
        _isStarted = false
        _player?.delegate = nil
        _player?.stop()
        _player = nil
        
        if SIMChatMediaAudioPlayer.retainInstance === self {
            SIMChatMediaAudioPlayer.retainInstance = nil
        }
    }
    
    @inline(__always) private func _shouldPrepare() -> Bool {
        SIMLog.trace()
        guard delegate?.playerShouldPrepare(self) ?? true else {
            return false
        }
        SIMChatNotificationCenter.postNotificationName(SIMChatMediaPlayerWillPrepare, object: self)
        return true
    }
    @inline(__always) private func _didPrepare() {
        SIMLog.trace()
        delegate?.playerDidPrepare(self)
        SIMChatNotificationCenter.postNotificationName(SIMChatMediaPlayerDidPrepare, object: self)
        // 继续启动
        if _isStarted {
            _play()
        }
    }
    @inline(__always) private func _shouldPlay() -> Bool {
        SIMLog.trace()
        guard delegate?.playerShouldPlay(self) ?? true else {
            return false
        }
        SIMChatNotificationCenter.postNotificationName(SIMChatMediaPlayerWillPlay, object: self)
        return true
    }
    @inline(__always) private func _didPlay() {
        SIMLog.trace()
        delegate?.playerDidPlay(self)
        SIMChatNotificationCenter.postNotificationName(SIMChatMediaPlayerDidPlay, object: self)
    }
    @inline(__always) private func _didStop() {
        SIMLog.trace()
        delegate?.playerDidStop(self)
        SIMChatNotificationCenter.postNotificationName(SIMChatMediaPlayerDidStop, object: self)
    }
    @inline(__always) private func _didFinish() {
        SIMLog.trace()
        delegate?.playerDidFinish(self)
        SIMChatNotificationCenter.postNotificationName(SIMChatMediaPlayerDidFinsh, object: self)
    }
    @inline(__always) private func _didErrorOccur(_ error: NSError) {
        SIMLog.error(error)
        delegate?.playerDidErrorOccur(self, error: error)
        SIMChatNotificationCenter.postNotificationName(SIMChatMediaPlayerDidErrorOccur, object: self, userInfo: ["Error" as NSObject: error])
        // 释放资源
        _isStarted = false
        _clear()
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        SIMLog.trace()
        _stop()
        _didFinish()
    }
//    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: NSError?) {
//        SIMLog.trace()
//        _stop()
//        _didErrorOccur(error ?? NSError(domain: "Unknow Error", code: -1, userInfo: nil))
//    }
//    public func audioPlayerDidInterruption(_ sender: Notification) {
//        SIMLog.trace()
//        guard _isPlaying else {
//            return
//        }
//        _stop()
//        _didErrorOccur(NSError(domain: "Interruption", code: -1, userInfo: nil))
//    }
    
    // 保存实例, 在播放完成后释放
    private static var retainInstance: SIMChatMediaAudioPlayer?
}

