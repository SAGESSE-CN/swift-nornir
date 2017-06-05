//
//  PlayerView.swift
//  Ubiquity
//
//  Created by sagesse on 05/06/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit
import AVFoundation

internal protocol PlayerViewDelegate: class {
    
    /// if the data is prepared to do the call this method
    func player(didPrepare player: PlayerView, item: AVPlayerItem)
    
    /// if you start playing the call this method
    func player(didStartPlay player: PlayerView, item: AVPlayerItem)
    /// if take the initiative to stop the play call this method
    func player(didStop player: PlayerView, item: AVPlayerItem)
    
    /// if the interruption due to lack of enough data to invoke this method
    func player(didStalled player: PlayerView, item: AVPlayerItem)
    /// if play is interrupted call the method, example: pause, in background mode, in the call
    func player(didSuspend player: PlayerView, item: AVPlayerItem)
    /// if interrupt restored to call this method
    /// automatically restore: in background mode to foreground mode, in call is end
    func player(didResume player: PlayerView, item: AVPlayerItem)
    
    /// if play completed call this method
    func player(didFinish player: PlayerView, item: AVPlayerItem)
    /// if the occur error call the method
    func player(didOccur player: PlayerView, item: AVPlayerItem, error: Error?)
    
}

internal class PlayerView: UIView {
    // the player status
    internal enum Status {
        
        case none
        
        case preparing
        case prepared
        
        case playing
        case pausing
        case stalling
        
        case stop
        case failure
        
        var isPrepared: Bool {
            switch self {
            case .none,
                 .preparing,
                 .failure:
                return false
                
            default:
                return true
            }
        }
        var isPlaying: Bool {
            switch self {
            case .playing,
                 .stalling:
                return true
                
            default:
                return false
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        _clean()
    }
    
    // after the start play minimum loaded time
    static var minimumBufferTime: TimeInterval = 1
    // after the play stalling recovery loaded time
    static var stallingBufferTime: TimeInterval = 3
    
    // event callback
    weak var delegate: PlayerViewDelegate?
    
    // the player status
    var status: Status {
        return _status
    }
    
    
    // prepare player
    func prepare(with item: AVPlayerItem?) {
        logger.debug?.write()
        
        // if has been started, stop & clean resource
        if _player != nil {
            _player?.pause()
            _player = nil
        }
        
        // only when loadedTimeRanges more than minimumBufferTime, prepare is completed
        _item = item
        _token = Int(CACurrentMediaTime())
        _status = .preparing
        
        // setup player
        _player = AVPlayer(playerItem: item)
        
    }
    
    // start play or resume play
    func play() {
        logger.debug?.write()
        
        // if item is nil, the player is not ready
        guard let _ = _item else {
            return
        }
        // if the data is ready, start
        // if then player is no playing, start
        guard _status.isPrepared && !_status.isPlaying else {
            return
        }
        
        // if is stop, replay
        if _status == .stop {
            _player?.seek(to: .init(seconds: 0, preferredTimescale: 1))
        }
        
        // start play,
        _status = .playing
        
        // active audio session, but it very low
        DispatchQueue.global().async {
            self._setActive(true)
            self._player?.play()
            DispatchQueue.main.async {
                self._cb_didStartPlay()
            }
        }
    }
    // stop play and release resouce
    func stop() {
        logger.debug?.write()
        
        // if item is nil, the player is not ready
        guard let _ = _item else {
            return
        }
        
        _status = .none
        _player?.pause()
        
        let token = _token
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
            guard self._token == token else {
                return
            }
            self._setActive(false)
            self._player?.replaceCurrentItem(with: nil)
        }
        
        _cb_didStop()
    }
    
    // pause player
    func suspend() {
        logger.debug?.write()
        
        // if item is nil, the player is not ready
        guard let _ = _item else {
            return
        }
        
        _status = .pausing
        _player?.pause()
        _cb_didSuspend()
    }
    // resume player
    func resume() {
        logger.debug?.write()
        
        // if item is nil, the player is not ready
        guard let _ = _item else {
            return
        }
        
        _status = .playing
        _player?.play()
        _cb_didResume()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // if keyPath is empty, it is unknown error
        guard let keyPath = keyPath else {
            return
        }
        // in processing
        switch keyPath {
        case #keyPath(_playerLayer.player.currentItem.status):
            _updateStatus()
            
        case #keyPath(_playerLayer.player.currentItem.loadedTimeRanges):
            _updateLoadedRanges()
            
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    fileprivate var _item: AVPlayerItem?
    fileprivate var _token: Int?
    fileprivate var _status: Status = .none
    
    fileprivate var _suspended: Bool = false
    fileprivate var _active: Bool = false
    
    @objc fileprivate var _playerLayer: AVPlayerLayer?
    @objc fileprivate var _player: AVPlayer? {
        set { return (_playerLayer?.player = newValue) ?? Void()  }
        get { return (_playerLayer?.player) }
    }
}

internal extension PlayerView {
    
    fileprivate func _updateStatus() {
        // must be created after the player to call the function
        guard let player = _player else {
            return
        }
        logger.trace?.write(player.status.rawValue)
        
        // check player status
        switch player.status {
        case .unknown:
            // wait to ready play
            break 
            
        case .readyToPlay:
            // wait to load
            break
            
        case .failed:
            // resource loading failure
            _status = .failure
            _cb_didOccurError(player.error)
        }
    }
    fileprivate func _updateLoadedRanges() {
        // must be created after the player to call the function
        guard let player = _player, let item = player.currentItem, let ranges = item.loadedTimeRanges as? [CMTimeRange] else {
            return
        }
        logger.debug?.write(item.loadedTimeRanges)
        
        switch _status {
        case .preparing:
            // status is preparing, check can prepare complete
            let duration = min(.init(PlayerView.minimumBufferTime), item.duration.seconds - item.currentTime().seconds)
            let range = CMTimeRange(start: item.currentTime(), duration: .init(seconds: duration, preferredTimescale: item.duration.timescale))
            // if contains the range, is prepared
            guard ranges.contains(where: { $0.containsTimeRange(range) }) else {
                return
            }
            // prepare completed
            _status = .prepared
            _cb_didPreare()
            
        case .stalling:
            // statis is stalling, check can restore playing
            let current = item.currentTime()
            let duration = min(.init(PlayerView.stallingBufferTime), item.duration.seconds - current.seconds)
            let range = CMTimeRange(start: current, duration: .init(seconds: duration, preferredTimescale: item.duration.timescale))
            // if contains the range, can restore
            guard ranges.contains(where: { $0.containsTimeRange(range) }) else {
                return
            }
            // prepare completed
            _status = .playing
            // if the player is suspended, only change the status
            if !_suspended {
                logger.debug?.write("restore play")
                player.play()
                _cb_didResume()
            }
            
        default:
            // update load progress
            break
        }
    }
    
    fileprivate func _setActive(_ active: Bool) {
        guard _active != active else {
            return
        }
        _active = active
        // change
        if active {
            _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            _ = try? AVAudioSession.sharedInstance().setActive(true, with: .notifyOthersOnDeactivation)
        } else {
            _ = try? AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
        }
    }
    
    /// setup env
    fileprivate func _setup() {
        
        let center = NotificationCenter.default
        
        // setup player layer relationship
        _playerLayer = layer as? AVPlayerLayer
        _playerLayer?.backgroundColor = UIColor.clear.cgColor
        
        // add observe item status
        addObserver(self, forKeyPath: #keyPath(_playerLayer.player.currentItem.status), options: [.new, .old], context: nil)
        addObserver(self, forKeyPath: #keyPath(_playerLayer.player.currentItem.loadedTimeRanges), options: [.new], context: nil)
        
        // add observe player play status
        center.addObserver(self, selector: #selector(_ntf_interruptioned(_:)), name: .AVAudioSessionInterruption, object: nil)
        center.addObserver(self, selector: #selector(_ntf_finished(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        center.addObserver(self, selector: #selector(_ntf_stalled(_:)), name: .AVPlayerItemPlaybackStalled, object: nil)
        
        center.addObserver(self, selector: #selector(_ntf_suspend(_:)), name: .UIApplicationWillResignActive, object: nil)
        center.addObserver(self, selector: #selector(_ntf_resume(_:)), name: .UIApplicationDidBecomeActive, object: nil)
    }
    /// clean setup env
    fileprivate func _clean() {
        
        let center = NotificationCenter.default
        
        // remove observe item status
        removeObserver(self, forKeyPath: #keyPath(_playerLayer.player.currentItem.status))
        removeObserver(self, forKeyPath: #keyPath(_playerLayer.player.currentItem.loadedTimeRanges))
        
        // remove all observers
        center.removeObserver(self, name: .AVAudioSessionInterruption, object: nil)
        
        center.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
        center.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        
        center.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        center.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: nil)
        
    }
    
    fileprivate dynamic func _ntf_interruptioned(_ sender: Notification) {
        // if item is nil, the player is not ready
        guard let _ = _item else {
            return
        }
        logger.debug?.write()
        
        // when calling to suspend
        _active = false
        _status = .pausing
        _player?.pause()
        _cb_didSuspend()
    }
    fileprivate dynamic func _ntf_finished(_ sender: Notification) {
        // if item is nil, the player is not ready
        // if item no equ to sender, the notification is other
        guard let item = _item, item === sender.object as? AVPlayerItem else {
            return
        }
        logger.debug?.write()
        
        // is finshed
        _status = .stop
        _player?.pause()
        _cb_didFinish()
    }
    fileprivate dynamic func _ntf_stalled(_ sender: Notification) {
        // if item is nil, the player is not ready
        guard let _ = _item else {
            return
        }
        logger.debug?.write()
        
        // player is stalling
        _status = .stalling
        _cb_didStalled()
    }
    
    fileprivate dynamic func _ntf_suspend(_ sender: Notification) {
        // if item is nil, the player is not ready
        guard let _ = _item else {
            return
        }
        // suspend player
        _suspended = true
        
        // if _status is playing, player is start, pause it
        // if _status is stalling, player is pause
        guard _status.isPlaying, _status != .stalling else {
            return
        }
        logger.debug?.write("pause")
        // pause player
        _player?.pause()
        _cb_didSuspend()
    }
    fileprivate dynamic func _ntf_resume(_ sender: Notification) {
        // if item is nil, the player is not ready
        guard let _ = _item else {
            return
        }
        // resume player
        _suspended = false
        
        // if _status is playing, player is start, resote
        // if _status is stalling, can't restore
        guard _status.isPlaying, _status != .stalling else {
            return
        }
        logger.debug?.write("restore")
        // resume player
        _player?.play()
        _cb_didResume()
    }
    
    fileprivate func _cb_didPreare() {
        // if item is nil, the player is not ready
        guard let item = _item else {
            return
        }
        delegate?.player(didPrepare: self, item: item)
    }
    fileprivate func _cb_didStartPlay() {
        // if item is nil, the player is not ready
        guard let item = _item else {
            return
        }
        delegate?.player(didStartPlay: self, item: item)
    }
    
    fileprivate func _cb_didSuspend() {
        // if item is nil, the player is not ready
        guard let item = _item else {
            return
        }
        delegate?.player(didSuspend: self, item: item)
    }
    fileprivate func _cb_didStalled() {
        // if item is nil, the player is not ready
        guard let item = _item else {
            return
        }
        delegate?.player(didStalled: self, item: item)
    }
    fileprivate func _cb_didResume() {
        // if item is nil, the player is not ready
        guard let item = _item else {
            return
        }
        delegate?.player(didResume: self, item: item)
    }
    
    fileprivate func _cb_didStop() {
        // if item is nil, the player is not ready
        guard let item = _item else {
            return
        }
        delegate?.player(didStop: self, item: item)
    }
    fileprivate func _cb_didFinish() {
        // if item is nil, the player is not ready
        guard let item = _item else {
            return
        }
        _setActive(false)
        delegate?.player(didFinish: self, item: item)
    }
    
    fileprivate func _cb_didOccurError(_ error: Error?) {
        logger.error?.write(String(describing: error))
        // if item is nil, the player is not ready
        guard let item = _item else {
            return
        }
        logger.error?.write(String(describing: error))
        delegate?.player(didOccur: self, item: item, error: error)
    }
}
