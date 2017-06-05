//
//  VideoContentView.swift
//  Ubiquity
//
//  Created by SAGESSE on 4/22/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit
import AVFoundation

internal class VideoContentView: UIView, Displayable, Operable {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    weak var operaterDelegate: OperableDelegate?
    
    weak var displayerDelegate: DisplayableDelegate? {
        set { return _thumbView.displayerDelegate = newValue }
        get { return _thumbView.displayerDelegate }
    }
    
    func prepare() {
        // there must be the item
        guard let asset = _asset, let library = _library else {
            return
        }
        
        // prepare data
        let options = DataSourceOptions()
        
        // request player item
        _prepareing = true
        _prepared = false
        _request = library.ub_requestPlayerItem(forVideo: asset, options: options) { [weak self, weak asset] item, response in
            // if the asset is nil, the asset has been released
            guard let asset = asset else {
                return
            }
            self?._prepareing = false
            self?._prepared = true
            self?._updateItem(item, response: response, asset: asset)
        }
    }
    func play() {
        
        // if is prepared, start playing
        if _prepared {
            _playerView.play()
            return
        }
        // if is prepareing, start prepare
        if !_prepareing {
            prepare()
            return
        }
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
    
    // display asset
    func willDisplay(with asset: Asset, in library: Library, orientation: UIImageOrientation) {
        logger.debug?.write()
        
        // save context
        _asset = asset
        _library = library
        
        // update large content
        _thumbView.willDisplay(with: asset, in: library, orientation: orientation)
    }
    // end display asset
    func endDisplay(with asset: Asset, in library: Library) {
        logger.trace?.write()
        
        // when are requesting an player item, please cancel it
        _request.map { request in
            // reveal cancel
            library.ub_cancelRequest(request)
        }
        
        // stop player if needed
        _playerView.stop()
        
        // clear context
        _asset = nil
        _request = nil
        _library = nil
        // reset status
        _prepared = false
        _prepareing = false
        
        // clear content
        _thumbView.endDisplay(with: asset, in: library)
    }
    
    // update palyer item
    private func _updateItem(_ item: AVPlayerItem?, response: Response, asset: Asset) {
        // the current asset has been changed?
        guard _asset === asset else {
            // reset status
            _prepareing = false
            _prepared = false
            // change, all reqeust is expire
            logger.debug?.write("\(asset.ub_localIdentifier) item is expire")
            return
        }
        logger.trace?.write("\(asset.ub_localIdentifier)")
        
        // if item is nil, the player preare error 
        guard let item = item else {
            // notice to delegate
            operaterDelegate?.operable(didOccur: self, asset: asset, error: response.ub_error)
            return
        }
        _playerView.prepare(with: item)
    }
    
    private func _setup() {
        
        // setup thumb view
        _thumbView.frame = bounds
        _thumbView.clipsToBounds = true
        _thumbView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(_thumbView)
        
        
        // setup player view
        _playerView.frame = bounds
        _playerView.delegate = self
        _playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    fileprivate var _asset: Asset?
    fileprivate var _library: Library?
    
    fileprivate var _request: Request?
    fileprivate var _prepareing: Bool = false
    fileprivate var _prepared: Bool = false
    
    fileprivate lazy var _thumbView: PhotoContentView = .init()
    fileprivate lazy var _playerView: PlayerView = .init()
    
    fileprivate weak var _delegate: (DisplayableDelegate & OperableDelegate)?
}

/// provide player event forward support
extension VideoContentView: PlayerViewDelegate {
    
    /// if the data is prepared to do the call this method
    func player(didPrepare player: PlayerView, item: AVPlayerItem) {
        // if asset is nil, the view no display
        guard let asset = _asset else {
            return
        }
        operaterDelegate?.operable(didPrepare: self, asset: asset)
        // prepare in a hidden the view
        _playerView.frame = bounds
        addSubview(_playerView)
        _thumbView.removeFromSuperview()
    }
    
    /// if you start playing the call this method
    func player(didStartPlay player: PlayerView, item: AVPlayerItem) {
        // if asset is nil, the view no display
        guard let asset = _asset else {
            return
        }
        operaterDelegate?.operable(didStartPlay: self, asset: asset)
    }
    /// if take the initiative to stop the play call this method
    func player(didStop player: PlayerView, item: AVPlayerItem) {
        // if asset is nil, the view no display
        guard let asset = _asset else {
            return
        }
        operaterDelegate?.operable(didStop: self, asset: asset)
        // stop to clear
        _thumbView.frame = bounds
        addSubview(_thumbView)
        _playerView.removeFromSuperview()
    }
    
    /// if the interruption due to lack of enough data to invoke this method
    func player(didStalled player: PlayerView, item: AVPlayerItem) {
        // if asset is nil, the view no display
        guard let asset = _asset else {
            return
        }
        operaterDelegate?.operable(didStalled: self, asset: asset)
    }
    /// if play is interrupted call the method, example: pause, in background mode, in the call
    func player(didSuspend player: PlayerView, item: AVPlayerItem) {
        // if asset is nil, the view no display
        guard let asset = _asset else {
            return
        }
        operaterDelegate?.operable(didSuspend: self, asset: asset)
    }
    /// if interrupt restored to call this method
    /// automatically restore: in background mode to foreground mode, in call is end
    func player(didResume player: PlayerView, item: AVPlayerItem) {
        // if asset is nil, the view no display
        guard let asset = _asset else {
            return
        }
        operaterDelegate?.operable(didResume: self, asset: asset)
    }
    
    /// if play completed call this method
    func player(didFinish player: PlayerView, item: AVPlayerItem) {
        // if asset is nil, the view no display
        guard let asset = _asset else {
            return
        }
        operaterDelegate?.operable(didFinish: self, asset: asset)
    }
    /// if the occur error call the method
    func player(didOccur player: PlayerView, item: AVPlayerItem, error: Error?) {
        // if asset is nil, the view no display
        guard let asset = _asset else {
            return
        }
        operaterDelegate?.operable(didOccur: self, asset: asset, error: error)
        // stop to clear
        addSubview(_thumbView)
        _playerView.removeFromSuperview()
    }
}

//internal class VideoPlayerView: UIView, Operable {
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        _setup()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    deinit {
//        _clean()
//    }
//    
//    /// operate event callback delegate
//    weak var operaterDelegate: OperableDelegate?
//    
//    
//    var status: VideoPlayerStatus {
//        return _status
//    }
//    
//    /// to prepare data you need
//    func prepare(with asset: Asset, in library: Library) {
//        logger.debug?.write()
//        
//        // if has been started, stop & clean resource
//        if _player != nil {
//            _player?.pause()
//            _player = nil
//        }
//        
//        // only when loadedTimeRanges more than minimumBufferTime, prepare is completed
//        _asset = asset
//        _token = Int(CACurrentMediaTime())
//        _status = .preparing
//    }
//    
//    /// play action, what must be after prepare otherwise this will not happen
//    func play() {
//        logger.debug?.write()
//        
//        // if the dta is ready, start
//        // if then player is no playing, start
//        guard _status.isPrepared && !_status.isPlaying else {
//            return
//        }
//        
//        // start play,
//        _status = .playing
//        _player?.play()
//        _cb_didStartPlay()
//    }
//    /// stop action
//    func stop() {
//        logger.debug?.write()
//        
//        // there must be the item
//        guard let _ = _asset else {
//            return
//        }
//        
//        _status = .none
//        _request = nil
//        _player?.pause()
//        
//        let token = _token
//        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
//            guard self._token == token else {
//                return
//            }
//            self._player?.replaceCurrentItem(with: nil)
//        }
//        
//        _cb_didStop()
//    }
//    
//    /// suspend action
//    func suspend() {
//        logger.debug?.write()
//        
//        // there must be the item
//        guard let _ = _asset else {
//            return
//        }
//        
//        _status = .pausing
//        _player?.pause()
//        _cb_didSuspend()
//    }
//    /// resume suspend
//    func resume() {
//        logger.debug?.write()
//        
//        // there must be the item
//        guard let _ = _asset else {
//            return
//        }
//        
//        _status = .playing
//        _player?.play()
//        _cb_didResume()
//    }
//    
//    override class var layerClass: AnyClass {
//        return AVPlayerLayer.self
//    }
//    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        // if keyPath is empty, it is unknown error
//        guard let keyPath = keyPath else {
//            return
//        }
//        // in processing
//        switch keyPath {
//        case #keyPath(_playerLayer.player.currentItem.status):
//            _updateStatus()
//            
//        case #keyPath(_playerLayer.player.currentItem.loadedTimeRanges):
//            _updateLoadedRanges()
//            
//        default:
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//        }
//    }
//    
//    private func _updateStatus() {
//        // must be created after the player to call the function
//        guard let player = _player else {
//            return
//        }
//        logger.trace?.write(player.status.rawValue)
//        
//        // check player status
//        switch player.status {
//        case .unknown:
//            // wait to ready play
//            break 
//            
//        case .readyToPlay:
//            // wait to load
//            break
//            
//        case .failed:
//            // resource loading failure
//            _status = .failure
//            _cb_didOccurError(player.error)
//        }
//    }
//    private func _updateLoadedRanges() {
//        // must be created after the player to call the function
//        guard let player = _player, let item = player.currentItem, let ranges = item.loadedTimeRanges as? [CMTimeRange] else {
//            return
//        }
//        logger.debug?.write(item.loadedTimeRanges)
//        
//        switch _status {
//        case .preparing:
//            // it is preparing, check whether has been prepare
//            let duration = min(.init(VideoPlayerSettings.settings.minimumBufferTime), item.duration.seconds - item.currentTime().seconds)
//            let range = CMTimeRange(start: item.currentTime(), duration: .init(seconds: duration, preferredTimescale: item.duration.timescale))
//            // if contains the range, is prepared
//            guard ranges.contains(where: { $0.containsTimeRange(range) }) else {
//                return
//            }
//            // prepare completed
//            _status = .prepared
//            _cb_didPreare()
//            
//        case .stalling:
//            // it is stalling, check whether has been can restore
//            let current = item.currentTime()
//            let duration = min(.init(VideoPlayerSettings.settings.stallingBufferTime), item.duration.seconds - current.seconds)
//            let range = CMTimeRange(start: current, duration: .init(seconds: duration, preferredTimescale: item.duration.timescale))
//            // if contains the range, can restore
//            guard ranges.contains(where: { $0.containsTimeRange(range) }) else {
//                return
//            }
//            // prepare completed
//            _status = .playing
//            // if the player is suspended, only change the status
//            if !_suspended {
//                logger.debug?.write("restore play")
//                player.play()
//                _cb_didResume()
//            }
//            
//        default:
//            // update load progress
//            break
//        }
//    }
//    
//    /// setup env
//    private func _setup() {
//        
//        let center = NotificationCenter.default
//        
//        // setup player layer relationship
//        _playerLayer = layer as? AVPlayerLayer
//        _playerLayer?.backgroundColor = UIColor.clear.cgColor
//        
//        // add observe item status
//        addObserver(self, forKeyPath: #keyPath(_playerLayer.player.currentItem.status), options: [.new, .old], context: nil)
//        addObserver(self, forKeyPath: #keyPath(_playerLayer.player.currentItem.loadedTimeRanges), options: [.new], context: nil)
//        
//        // add observe player play status
//        center.addObserver(self, selector: #selector(_ntf_interruptioned(_:)), name: .AVAudioSessionInterruption, object: nil)
//        center.addObserver(self, selector: #selector(_ntf_finished(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
//        center.addObserver(self, selector: #selector(_ntf_stalled(_:)), name: .AVPlayerItemPlaybackStalled, object: nil)
//        
//        center.addObserver(self, selector: #selector(_ntf_suspend(_:)), name: .UIApplicationWillResignActive, object: nil)
//        center.addObserver(self, selector: #selector(_ntf_resume(_:)), name: .UIApplicationDidBecomeActive, object: nil)
//    }
//    /// clean setup env
//    private func _clean() {
//        
//        let center = NotificationCenter.default
//        
//        // remove observe item status
//        removeObserver(self, forKeyPath: #keyPath(_playerLayer.player.currentItem.status))
//        removeObserver(self, forKeyPath: #keyPath(_playerLayer.player.currentItem.loadedTimeRanges))
//        
//        // remove all observers
//        center.removeObserver(self, name: .AVAudioSessionInterruption, object: nil)
//        
//        center.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
//        center.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
//        
//        center.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
//        center.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: nil)
//        
//    }
//    
//    private func _cb_didPreare() {
//        // must provide the item for the operation
//        guard let asset = _asset else {
//            return
//        }
//        operaterDelegate?.operable(didPrepare: self, asset: asset)
//    }
//    private func _cb_didStartPlay() {
//        // must provide the item for the operation
//        guard let asset = _asset else {
//            return
//        }
//        operaterDelegate?.operable(didStartPlay: self, asset: asset)
//    }
//    
//    private func _cb_didSuspend() {
//        // must provide the item for the operation
//        guard let asset = _asset else {
//            return
//        }
//        operaterDelegate?.operable(didSuspend: self, asset: asset)
//    }
//    private func _cb_didStalled() {
//        // must provide the item for the operation
//        guard let asset = _asset else {
//            return
//        }
//        operaterDelegate?.operable(didStalled: self, asset: asset)
//    }
//    private func _cb_didResume() {
//        // must provide the item for the operation
//        guard let asset = _asset else {
//            return
//        }
//        operaterDelegate?.operable(didResume: self, asset: asset)
//    }
//    
//    private func _cb_didStop() {
//        // must provide the item for the operation
//        guard let asset = _asset else {
//            return
//        }
//        operaterDelegate?.operable(didStop: self, asset: asset)
//    }
//    private func _cb_didFinish() {
//        // must provide the item for the operation
//        guard let asset = _asset else {
//            return
//        }
//        operaterDelegate?.operable(didFinish: self, asset: asset)
//    }
//    
//    private func _cb_didOccurError(_ error: Error?) {
//        logger.error?.write(String(describing: error))
//        // must provide the data for the operation
//        guard let asset = _asset else {
//            return
//        }
//        logger.error?.write(String(describing: error))
//        
//        operaterDelegate?.operable(didOccur: self, asset: asset, error: error)
//    }
//    
//    private dynamic func _ntf_interruptioned(_ sender: Notification) {
//        // must provide the data for the operation
//        guard let _ = _asset, let player = _player, player.currentItem === sender.object as? AVPlayerItem else {
//            return
//        }
//        logger.debug?.write()
//        
//        // when calling to suspend
//        _status = .pausing
//        _player?.pause()
//        _cb_didSuspend()
//    }
//    private dynamic func _ntf_finished(_ sender: Notification) {
//        // must provide the data for the operation
//        guard let _ = _asset, let player = _player, player.currentItem === sender.object as? AVPlayerItem else {
//            return
//        }
//        logger.debug?.write()
//        
//        // is finshed
//        _status = .stop
//        _player?.pause()
//        _cb_didFinish()
//    }
//    private dynamic func _ntf_stalled(_ sender: Notification) {
//        // must provide the data for the operation
//        guard let _ = _asset, let player = _player, player.currentItem === sender.object as? AVPlayerItem else {
//            return
//        }
//        logger.debug?.write()
//        
//        // player is stalling
//        _status = .stalling
//        _cb_didStalled()
//    }
//    
//    private dynamic func _ntf_suspend(_ sender: Notification) {
//        // must provide the data for the operation
//        guard let _ = _asset, let _ = _player else {
//            return
//        }
//        // suspend player
//        _suspended = true
//        
//        // if _status is playing, player is start, pause it
//        // if _status is stalling, player is pause
//        guard _status.isPlaying, _status != .stalling else {
//            return
//        }
//        logger.debug?.write("pause")
//        // pause player
//        _player?.pause()
//        _cb_didSuspend()
//    }
//    private dynamic func _ntf_resume(_ sender: Notification) {
//        // must provide the data for the operation
//        guard let _ = _asset, let _ = _player else {
//            return
//        }
//        // resume player
//        _suspended = false
//        
//        // if _status is playing, player is start, resote
//        // if _status is stalling, can't restore
//        guard _status.isPlaying, _status != .stalling else {
//            return
//        }
//        logger.debug?.write("restore")
//        // resume player
//        _player?.play()
//        _cb_didResume()
//    }
//    
//    
//    private var _token: Int?
//    private var _asset: Asset?
//    private var _status: VideoPlayerStatus = .none
//    
//    private var _request: Request?
//    
//    private var _suspended: Bool = false
//    
//    @objc private var _playerLayer: AVPlayerLayer?
//    @objc private var _player: AVPlayer? {
//        set { return (_playerLayer?.player = newValue) ?? Void()  }
//        get { return (_playerLayer?.player) }
//    }
//}
//
