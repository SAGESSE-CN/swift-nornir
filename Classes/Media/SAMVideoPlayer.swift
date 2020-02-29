//
//  SAMVideoPlayer.swift
//  SAMedia
//
//  Created by SAGESSE on 27/10/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import AVFoundation

open class SAMVideoPlayer: NSObject, SAMPlayerProtocol {
    
    public override init() {
        super.init()
        _addObservers()
    }
    
    public convenience init(item: AVPlayerItem) {
        self.init()
        self.item = item
    }
    
    public convenience init(contentsOf url: URL) {
        self.init(item: AVPlayerItem(url: url))
    }
    
    deinit {
        _removeObservers()
    }
    
    // MARK: - Properties
    
    open var item: AVPlayerItem? {
        set {
            
            item?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
            item?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
            
            newValue?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: .new, context: nil)
            newValue?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: .new, context: nil)
            
            // 强制停止播放
            stop()
            
            return _item = newValue
        }
        get {
            return _item
        }
    }
    open var player: AVPlayer {
        return _player
    }
    
    // the player status
    open var status: SAMVideoPlayerStatus {
        return _status
    }
    
    // the duration of the media.
    open var duration: TimeInterval {
        guard let item = _player.currentItem else {
            return 0
        }
        return TimeInterval(CMTimeGetSeconds(item.duration))
    }
    
    // If the media is playing, currentTime is the offset into the media of the current playback position.
    // If the media is not playing, currentTime is the offset into the media where playing would start.
    open var currentTime: TimeInterval {
        guard let item = _player.currentItem else {
            return 0
        }
        return TimeInterval(CMTimeGetSeconds(item.currentTime()))
    }
    
    // This property provides a collection of time ranges for which the download task has media data already downloaded and playable.
    open var loadedTime: TimeInterval {
        guard let range = _player.currentItem?.loadedTimeRanges.first?.timeRangeValue else {
            return 0
        }
        return TimeInterval(CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration))
    }
   
    // This property provides a collection of time ranges for which the download task has media data already downloaded and playable.
    // The ranges provided might be discontinuous.
    open var loadedTimeRanges: Array<NSValue>? {
        return _player.currentItem?.loadedTimeRanges
    }
    
    // an delegate
    open weak var delegate: SAMVideoPlayerDelegate? {
        set { return _delegate = newValue}
        get { return _delegate }
    }
    
    
    // MARK: - Transport Control
    
    
    // prepare media the resources needed and active audio session
    // methods that return BOOL return YES on success and NO on failure.
    @discardableResult open func prepare() -> Bool {
        return _performForPrepare(with: nil)
    }
    
    // play a media, if it is not ready to complete, will be ready to complete the automatic playback.
    @discardableResult open func play() -> Bool {
        return _performForPlay(with: { [weak _player] in
            _player?.play()
            return true
        })
    }
    @discardableResult open func play(at time: TimeInterval) -> Bool {
        let scale = _player.currentTime().timescale
        let tm = CMTimeMakeWithSeconds(Float64(trunc(time * 10) / 10), preferredTimescale: scale)
        // 如果正在播放
        guard !_status.isPlayed else {
            _player.pause()
            _player.seek(to: tm)
            _player.play()
            return true
        }
        return _performForPlay(with: { [weak _player] in
            _player?.pause()
            _player?.seek(to: tm, completionHandler: { b in
                _player?.play()
            })
            return true
        })
    }
    
    @discardableResult open func seek(to time: TimeInterval) -> Bool {
        guard !_status.isStoped else {
            return false
        }
        let scale = _player.currentTime().timescale
        let tm = CMTimeMakeWithSeconds(Float64(trunc(time * 10) / 10), preferredTimescale: scale)
        _player.seek(to: tm)
        return true
    }
    
    // pause play
    open func pause() {
        
        guard _status.isPlayed || _status == .loading else {
            return
        }
        
        _player.pause()
        _status = .pauseing
        _deactive()
        
        _delegate?.player?(didPause: self)
    }
    
    open func stop() {
        
        guard !_status.isStoped else {
            return
        }
        
        _item?.seek(to: CMTimeMake(value: 0, timescale: 1))
        _player.replaceCurrentItem(with: nil)
        
        _status = .stop
        _deactive()
        
        _delegate?.player?(didStop: self)
    }
    
    // MARK: - Method
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            
            if _status.isPlayed {
                if _player.status == .readyToPlay {
                    // 进入了后台, 然后再次切回来了
                    _player.play()
                } else {
                    _status = .pauseing
                    _delegate?.player?(didPause: self)
                }
                return
            }
            if _status == .preparing {
                _ = _prepareTask?()
                _prepareTask = nil
                return
            }
            
            return
        }
        if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
            guard let ranges = _player.currentItem?.loadedTimeRanges else {
                return
            }
            playerDidChangeLoadedRanges(ranges)
            return
        }
        
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    // 播放器发生错误
    @objc open func playerDecodeErrorDidOccur(_ sender: Notification) {
        // 检查是不是自己的通知
        guard let item = sender.object as? AVPlayerItem, item === player.currentItem else {
            return
        }
        _item?.seek(to: CMTimeMake(value: 0, timescale: 1))
        _player.replaceCurrentItem(with: nil)
        _status = .error
        _deactive()
        
        let error = sender.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? NSError
        
        _delegate?.player?(didOccur: self, error: error)
    }
    // 播入完成
    @objc open func playerDidFinishPlaying(_ sender: Notification) {
        // 检查是不是自己的通知
        guard let item = sender.object as? AVPlayerItem, item === player.currentItem else {
            return
        }
        _item?.seek(to: CMTimeMake(value: 0, timescale: 1))
        _player.replaceCurrentItem(with: nil)
        _status = .stop
        _deactive()
        
        _delegate?.player?(didFinishPlaying: self, successfully: true)
    }
    // 加载新的内容
    open func playerDidChangeLoadedRanges(_ ranges: Array<NSValue>) {
        // 检查是不是自己的通知
        guard let range = ranges.first?.timeRangeValue else {
            return
        }
        
        let start = CMTimeGetSeconds(range.start)
        let duration = CMTimeGetSeconds(range.duration)
        
        let time = TimeInterval(start + duration)
        
        // 加载进度改变了, 通知用户
        _delegate?.player?(didChange: self, loadedTime: time)
        _delegate?.player?(didChange: self, loadedTimeRanges: ranges)
        
        // 如果可以恢复的话
        guard duration > 3 || time >= self.duration  else {
            return
        }
        // 如果是加载中, 恢复播放状态
        guard _status == .loading else {
            return
        }
        guard _delegate?.player?(shouldRestorePlaying: self) ?? true else {
            return
        }
        
        _player.play()
        _status = .playing
        _delegate?.player?(didRestorePlaying: self)
    }
    // 播放中断(网络原因)
    @objc open func playerDidStalled(_ sender: Notification) {
        // 检查是不是自己的通知
        guard let item = sender.object as? AVPlayerItem, item === player.currentItem else {
            return
        }
        
        _status = .loading
        _delegate?.player?(didStalled: self)
    }
    // 播放中断(系统原因)
    @objc open func sessionDidInterruption(_ sender: Notification) {
        
        _status = .interruptioning
        _deactive()
        
        _delegate?.player?(didInterruption: self)
    }
    
    // MARK: - ivar
    
    fileprivate var _item: AVPlayerItem?
    fileprivate var _status: SAMVideoPlayerStatus = .stop
    
    fileprivate var _isActived: Bool = false
    
    fileprivate weak var _delegate: SAMVideoPlayerDelegate?
    
    fileprivate var _changeTask: Any?
    fileprivate var _prepareTask: (() -> Bool)?
    
    fileprivate lazy var _player: AVPlayer = AVPlayer()
}

private extension SAMVideoPlayer {
    
    func _addObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionDidInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDecodeErrorDidOccur(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidStalled(_:)), name: .AVPlayerItemPlaybackStalled, object: nil)
        
        _changeTask = _player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: .main) { [weak self](time) in
            guard let `self` = self else {
                return
            }
            self._delegate?.player?(didChange: self, currentTime: TimeInterval(CMTimeGetSeconds(time)))
        }
    }
    func _removeObservers() {
        
        // 必须调用, 用于清除observer
        item = nil
        
        if let task = _changeTask {
            _player.removeTimeObserver(task)
            _changeTask = nil
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @discardableResult func _active() -> Bool {
        guard !_isActived else {
            return true
        }
        _isActived = true
        do {
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().sm_setActive(true, context: self)
            return true
        } catch {
            return false
        }
        
    }
    @discardableResult func _deactive() -> Bool {
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
    
    
    func _performForPrepare(with handler: (() -> Bool)?) -> Bool {
        // 己经准备过了?
        guard !_status.isPrepared else {
            return handler?() ?? true
        }
        let taskItem = _item
        let task: () -> Bool = { [weak self] in
            // 防止在闭包其间self被释放掉
            guard let `self` = self else {
                return false
            }
            guard let item = self._item, item === taskItem else {
                // 如果任务己经取消掉了, 忽略
                return false
            }
            guard self._player.status == .readyToPlay else {
                // 出现了错误
                self._status = .error
                self._delegate?.player?(didOccur: self, error: item.error)
                
                return false
            }
            
            // 准备好了
            self._status = .prepared
            self._prepareTask = nil
            self._delegate?.player?(didPreparing: self)
            
            // 处理外部事件
            return handler?() ?? true
        }
        guard _status != .preparing else {
            _prepareTask = task
            return false
        }
        guard let item = _item else {
            // 没有Item不能播放
            return false
        }
        guard _delegate?.player?(shouldPreparing: self) ?? true else {
            // 用户没有准备好, 取消操作
            _prepareTask = nil
            return false
        }
        
        // 替换掉item
        _player.replaceCurrentItem(with: item)
        
        guard item.status == .readyToPlay else {
            // 未准备好, 等待事件
            _status = .preparing
            _prepareTask = task
            return false
        }
        
        return task()
    }
    func _performForPlay(with handler: (() -> Bool)?) -> Bool {
        guard _status != .playing else {
            // 如果是正在播放中, 忽略
            return true
        }
        return _performForPrepare { [weak self] in
            // 防止在闭包其间self被释放掉
            guard let `self` = self else {
                return false
            }
            guard self._status.isPrepared else {
                // 并没有准备完成
                return false
            }
            guard self.delegate?.player?(shouldPlaying: self) ?? true else {
                // 用户取消了播放, 忽略该操作
                return false
            }
            guard self._active() else {
                // 激活失败
                self._performForError(with: -1, message: "Can't active session")
                return false
            }
            guard handler?() ?? true else {
                // 播放失败, 恢复现场
                self._performForError(with: -1, message: "can't play")
                return false
            }
            
            self._status = .playing
            self._delegate?.player?(didPlaying: self)
            
            return true
        }
    }
    func _performForError(with code: Int, message: String) {
        
        _status = .error
        
        _deactive()
        _delegate?.player?(didOccur: self, error: nil)
    }
}
