//
//  VideoView.swift
//  Ubiquity
//
//  Created by SAGESSE on 4/22/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit
import AVFoundation

///
/// display video resources
///
internal class VideoView: UIView, Displayable, Operable, OperableDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self._setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._setup()
    }
    
    private func _setup() {
        
        // setup content view
        _contentView.frame = bounds
        _contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(_contentView)
        
        // setup thumb view
        _thumbView.frame = bounds
        _thumbView.clipsToBounds = true
        _thumbView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _contentView.addSubview(_thumbView)
        
        // setup player view
        _playerView.frame = bounds
        _playerView.delegate = self
        _playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    fileprivate lazy var _thumbView: UIImageView = .init()
    fileprivate lazy var _playerView: PlayerView = .init()
    fileprivate lazy var _contentView: UIView = .init()
    
    fileprivate weak var _delegate: OperableDelegate?
}
///
/// display video resources
///
internal class VideoSettings {
    
    // it is a singleton, not allowed outside
    private init() {
    }
    
    // after the start play minimum loaded time
    var minimumBufferTime: TimeInterval = 1
    // after the play stalling recovery loaded time
    var stallingBufferTime: TimeInterval = 3
    
    //
    static var settings: VideoSettings = .init()
}

/// provide item play support
internal extension VideoView {
    ///
    /// player status
    ///
    internal enum Status {
        
        case preparing
        case prepared
        
        case playing
        case pausing
        case stalling
        
        case stop
        case failure
        
        var isPrepared: Bool {
            switch self {
            case .preparing,
                 .stop,
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
        
//        var isStarted: Bool {
//            return false
//        }
//        var isPaused: Bool {
//            return false
//        }
    }
    ///
    /// a video player view
    ///
    internal class PlayerView: UIView, Operable {
        
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
        
        /// operate event callback delegate
        weak var delegate: OperableDelegate?
        
        /// change the layer for AVPlayerLayer
        override class var layerClass: AnyClass {
            return AVPlayerLayer.self
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
        
        
        /// setup env
        private func _setup() {
            
            let center = NotificationCenter.default
            
            // setup player layer relationship
            _playerLayer = layer as? AVPlayerLayer
            _playerLayer?.backgroundColor = UIColor.black.cgColor
            
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
        private func _clean() {
            
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
        
        
        fileprivate var _item: Item?
        fileprivate var _status: Status = .stop
        
        fileprivate var _suspended: Bool = false
        
        @objc fileprivate var _playerLayer: AVPlayerLayer?
        @objc fileprivate var _player: AVPlayer? {
            set { return (_playerLayer?.player = newValue) ?? Void()  }
            get { return (_playerLayer?.player) }
        }
    }
    
    weak var delegate: OperableDelegate? {
        set { return _delegate = newValue }
        get { return _delegate }
    }
    
    func play() {
        _playerView.play()
    }
    func stop() {
        _playerView.stop()
    }
    
    func suspend() {
        _playerView.suspend()
    }
    func resume() {
        _playerView.resume()
    }
    
    func prepare(with item: Item) {
        _playerView.prepare(with: item)
    }
}
/// provide player event forward support
internal extension VideoView {
    
    /// if the data is prepared to do the call this method
    func operable(didPrepare operable: Operable, item: Item) {
        delegate?.operable(didPrepare: self, item: item)
        // prepare in a hidden the view
        addSubview(_playerView)
    }
    
    /// if you start playing the call this method
    func operable(didStartPlay operable: Operable, item: Item) {
        delegate?.operable(didStartPlay: self, item: item)
    }
    /// if take the initiative to stop the play call this method
    func operable(didStop operable: Operable, item: Item) {
        delegate?.operable(didStop: self, item: item)
        // stop to clear
        _playerView.removeFromSuperview()
    }
    
    /// if the interruption due to lack of enough data to invoke this method
    func operable(didStalled operable: Operable, item: Item) {
        delegate?.operable(didStalled: self, item: item)
    }
    /// if play is interrupted call the method, example: pause, in background mode, in the call
    func operable(didSuspend operable: Operable, item: Item) {
        delegate?.operable(didSuspend: self, item: item)
    }
    /// if interrupt restored to call this method
    func operable(didResume operable: Operable, item: Item) {
        delegate?.operable(didResume: self, item: item)
    }
    
    /// if play completed call this method
    func operable(didFinish operable: Operable, item: Item) {
        delegate?.operable(didFinish: self, item: item)
    }
    /// if the occur error call the method
    func operable(didOccur operable: Operable, item: Item, error: Error?) {
        delegate?.operable(didOccur: self, item: item, error: error)
        // stop to clear
        _playerView.removeFromSuperview()
    }
}

/// provide snapshot support
internal extension VideoView {
    ///
    /// a video snapshot view
    ///
    internal class ReplicantView: UIView {
        
        init(contentView: UIView) {
            super.init(frame: contentView.frame)
            _contentView = contentView
        }
        
        override init(frame: CGRect) {
            // can't alloc the type of object
            fatalError("init(frame:) has not been implemented")
        }
        required init?(coder aDecoder: NSCoder) {
            // can't alloc the type of object
            fatalError("init(coder:) has not been implemented")
        }
        
        override func willMove(toWindow newWindow: UIWindow?) {
            super.willMove(toWindow: newWindow)
            
            logger.debug?.write("show is \(newWindow != nil)")
            // need to display a snapshot?
            guard let contentView = _contentView else {
                return
            }
            
            if newWindow == nil {
                // setup for hidde
                if contentView.superview !== self {
                    return // ownership has been transferred
                }
                contentView.frame = _contentViewFrame
                _contentViewSuperview?.addSubview(contentView)
                _contentViewSuperview = nil
                
            } else {
                // setup for show
                if contentView.superview === self {
                    return // in display
                }
                _contentViewSuperview = contentView.superview
                _contentViewFrame = contentView.frame
                contentView.frame = bounds
                addSubview(contentView)
            }
        }
        
        private var _contentViewFrame: CGRect = .zero
        
        private weak var _contentView: UIView?
        private weak var _contentViewSuperview: UIView?
    }
    
    ///
    /// generate quick snapshot, if there is time synchronous display
    ///
    override func snapshotView(afterScreenUpdates afterUpdates: Bool) -> UIView? {
        let snapshotView = UIView(frame: frame)
        let contentView = UIView(frame: .zero)
        
        // setup snapshot view
        snapshotView.backgroundColor = backgroundColor
        snapshotView.addSubview(contentView)
        
        // setup content view
        let size = snapshotView.bounds.applying(_contentView.transform).size
        contentView.bounds = .init(origin: .zero, size: size)
        contentView.center = .init(x: snapshotView.bounds.midX, y: snapshotView.bounds.midY)
        contentView.transform = _contentView.transform
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // setup thumb view
        let imageView = UIImageView(frame: contentView.bounds)
        imageView.image = _thumbView.image
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(imageView)
        
        // if playerview is show, setup player view
        if _playerView.superview == self {
            let replicantView = ReplicantView(contentView: _playerView)
            replicantView.frame = contentView.bounds
            replicantView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.addSubview(replicantView)
        }
        
        return snapshotView
    }
    
}

/// provide item display support
internal extension VideoView {
    ///
    /// display container content with item
    ///
    /// - parameter item: need display the item
    /// - parameter orientation: need display the orientation
    ///
    func display(with item: Item, orientation: UIImageOrientation) {
        logger.debug?.write()
        
        // update image
        _thumbView.image = item.image//?.ub_withOrientation(orientation)
        _contentView.transform = .init(rotationAngle: orientation.ub_angle)
    }
    
    ///
    /// setup content layout
    ///
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = bounds.applying(_contentView.transform).size
        
        // update content view layout
        _contentView.bounds = .init(x: 0, y: 0, width: size.width, height: size.height)
        _contentView.center = .init(x: bounds.midX, y: bounds.midY)
        
        // update thumb & player view layout
        _thumbView.frame = convert(bounds, to: _contentView)
        _playerView.frame = convert(bounds, to: _contentView)
    }
}

/// playerView control event support
extension VideoView.PlayerView {
    
    /// to prepare data you need
    func prepare(with item: Item) {
        logger.trace?.write()
        
        // if has been started, stop & clean resource
        if _player != nil {
            _player?.pause()
            _player = nil
        }
        
        // save data & status
        // only when loadedTimeRanges more than minimumBufferTime, prepare is completed
        _item = item
        _status = .preparing
        
        // prepare data
        
        //let url = URL(string: "http://192.168.2.3/a.mp4")!
        //let url = URL(string: "http://192.168.2.3/b.mp4")!
        //let url = URL(string: "http://192.168.2.3/c.m4v")!
        
        //let url = URL(string: "http://192.168.0.107/a.mp4")!
        //let url = URL(string: "http://192.168.0.102/b.mp4")!
        //let url = URL(string: "http://192.168.0.102/c.m4v")!
        
        //let url = URL(string: "http://v4.music.126.net/20170512163709/202e0eceec83d17455634b807176f839/web/cloudmusic/Nzg5MzEyMTY=/b6f37d9ea0b4483212dece4f6ff4620d/a359f74e73667f6ff32fab9340277671.mp4")!
        let url = URL(string: "http://v4.music.126.net/20170515021110/337ebc2471c25ccb1192a770facac8f7/web/cloudmusic/JiYxMSEgIyAiJiAwMiQwMA==/mv/5373013/b8517d36ac9170989eb899b6a6da36e5.mp4")!
        //let url = URL(string: "http://v4.music.126.net/20170512164107/b5617f04715a1cf7ce18ca107197c3cd/web/cloudmusic/ODE1MDgxMDg=/027190c853c462390e40008fa242362d/60a8d1ad5c0e03ff2d398d8df56782a1.mp4")!
        
        
        let a = AVURLAsset(url: url)
        let o = AVPlayerItem(asset: a)
        
        _player = AVPlayer(playerItem: o)
    }
    
    /// play action, what must be after prepare otherwise this will not happen
    func play() {
        // if the dta is ready, start
        // if then player is no playing, start
        guard _status.isPrepared && !_status.isPlaying else {
            return
        }
        logger.trace?.write()
        
        // start play,
        _status = .playing
        _player?.play()
        _cb_didStartPlay()
    }
    /// stop action
    func stop() {
        // there must be the item
        guard let _ = _item else {
            return
        }
        logger.trace?.write()
        
        _status = .stop
        _player?.pause()
        _player = nil
        _cb_didStop()
    }
    
    /// suspend action
    func suspend() {
        // there must be the item
        guard let _ = _item else {
            return
        }
        logger.trace?.write()
        
        _status = .pausing
        _player?.pause()
        _cb_didSuspend()
    }
    /// resume suspend
    func resume() {
        // there must be the item
        guard let _ = _item else {
            return
        }
        logger.trace?.write()
        
        _status = .playing
        _player?.play()
        _cb_didResume()
    }
}
/// playerView update
extension VideoView.PlayerView {
    
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
            // it is preparing, check whether has been prepare
            let duration = min(.init(VideoSettings.settings.minimumBufferTime), item.duration.seconds - item.currentTime().seconds)
            let range = CMTimeRange(start: item.currentTime(), duration: .init(seconds: duration, preferredTimescale: item.duration.timescale))
            // if contains the range, is prepared
            guard ranges.contains(where: { $0.containsTimeRange(range) }) else {
                return
            }
            // prepare completed
            _status = .prepared
            _cb_didPreare()
            
        case .stalling:
            // it is stalling, check whether has been can restore
            let duration = min(.init(VideoSettings.settings.stallingBufferTime), item.duration.seconds - item.currentTime().seconds)
            let range = CMTimeRange(start: item.currentTime(), duration: .init(seconds: duration, preferredTimescale: item.duration.timescale))
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
    
}
/// playerView event process support
extension VideoView.PlayerView {
    
    fileprivate dynamic func _ntf_interruptioned(_ sender: Notification) {
        // must provide the data for the operation
        guard let _ = _item, let player = _player, player.currentItem === sender.object as? AVPlayerItem else {
            return
        }
        logger.debug?.write()
        
        // when calling to suspend
        _status = .pausing
        _player?.pause()
        _cb_didSuspend()
    }
    fileprivate dynamic func _ntf_finished(_ sender: Notification) {
        // must provide the data for the operation
        guard let _ = _item, let player = _player, player.currentItem === sender.object as? AVPlayerItem else {
            return
        }
        logger.debug?.write()
        
        // is finshed
        _status = .stop
        _player?.pause()
        _cb_didFinish()
    }
    fileprivate dynamic func _ntf_stalled(_ sender: Notification) {
        // must provide the data for the operation
        guard let _ = _item, let player = _player, player.currentItem === sender.object as? AVPlayerItem else {
            return
        }
        logger.debug?.write()
        
        // player is stalling
        _status = .stalling
        _cb_didStalled()
    }
    
    fileprivate dynamic func _ntf_suspend(_ sender: Notification) {
        // must provide the data for the operation
        guard let _ = _item, let _ = _player else {
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
        // must provide the data for the operation
        guard let _ = _item, let _ = _player else {
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
    
}

/// playerView callback support
extension VideoView.PlayerView {
    
    fileprivate func _cb_didPreare() {
        // must provide the item for the operation
        guard let item = _item else {
            return
        }
        delegate?.operable(didPrepare: self, item: item)
    }
    fileprivate func _cb_didStartPlay() {
        // must provide the item for the operation
        guard let item = _item else {
            return
        }
        delegate?.operable(didStartPlay: self, item: item)
    }
    
    fileprivate func _cb_didSuspend() {
        // must provide the item for the operation
        guard let item = _item else {
            return
        }
        delegate?.operable(didSuspend: self, item: item)
    }
    fileprivate func _cb_didStalled() {
        // must provide the item for the operation
        guard let item = _item else {
            return
        }
        delegate?.operable(didStalled: self, item: item)
    }
    fileprivate func _cb_didResume() {
        // must provide the item for the operation
        guard let item = _item else {
            return
        }
        delegate?.operable(didResume: self, item: item)
    }
    
    fileprivate func _cb_didStop() {
        // must provide the item for the operation
        guard let item = _item else {
            return
        }
        delegate?.operable(didStop: self, item: item)
    }
    fileprivate func _cb_didFinish() {
        // must provide the item for the operation
        guard let item = _item else {
            return
        }
        delegate?.operable(didFinish: self, item: item)
    }
    
    fileprivate func _cb_didOccurError(_ error: Error?) {
        logger.error?.write(String(describing: error))
        // must provide the data for the operation
        guard let item = _item else {
            return
        }
        logger.error?.write(String(describing: error))
        
        delegate?.operable(didOccur: self, item: item, error: error)
    }
}
