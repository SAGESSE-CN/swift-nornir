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
        _contentView.addSubview(_playerView)
    }
    
    fileprivate var _item: Item?
    
    fileprivate lazy var _thumbView: UIImageView = .init()
    fileprivate lazy var _playerView: PlayerView = .init()
    fileprivate lazy var _contentView: UIView = .init()
    
    fileprivate weak var _delegate: OperableDelegate?
}

/// provide item play support
internal extension VideoView {
    ///
    /// a video player view
    ///
    internal class PlayerView: UIView, Operable {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self._setup()
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        deinit {
            self._clean()
        }
        
        /// operate event callback delegate
        weak var delegate: OperableDelegate?
        
        /// to prepare data you need
        func prepare(with item: Item) {
            logger.trace?.write()
            
            //let url = URL(string: "http://192.168.0.109/a.mp4")!
            let url = URL(string: "http://192.168.0.109/b.mp4")!
            //let url = URL(string: "http://sagesse.me:1080/a.mp4")!
            
            let o = AVPlayerItem(asset: AVURLAsset(url: url))//.init(fileURLWithPath: path)))
            

            //_palyerLayer?.player = player
            
            _item = item
            _player = AVPlayer(playerItem: o)
            _isReady = false
            _isPlaying = false
            
            //AVPlayerItem(asset: <#T##AVAsset#>)
            //        NSURL *sourceMovieURL = [NSURL fileURLWithPath:videoStr];
            //        AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
            
            //delegate?.operable(didPrepare: self, item: item)
        }
        
        /// play action, what must be after prepare otherwise this will not happen
        func play() {
            // there must be the item
            guard let item = _item else {
                return
            }
            logger.trace?.write()
            
            _player?.play()
            _isPlaying = true
            _isStalling = false
            
            delegate?.operable(didStartPlay: self, item: item)
        }
        /// stop action
        func stop() {
            // there must be the item
            guard let item = _item else {
                return
            }
            logger.trace?.write()
            
            _player = nil
            _isPlaying = false
            _isStalling = false
            
            delegate?.operable(didStop: self, item: item)
        }
        
        /// suspend action
        func suspend() {
            // there must be the item
            guard let item = _item else {
                return
            }
            logger.trace?.write()
            
            _isPlaying = false
            
            delegate?.operable(didSuspend: self, item: item)
        }
        /// resume suspend
        func resume() {
            // there must be the item
            guard let item = _item else {
                return
            }
            logger.trace?.write()
            
            _isPlaying = true
            
            delegate?.operable(didResume: self, item: item)
        }
        
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
                self.ntf_updateStatus()
                
            case #keyPath(_playerLayer.player.currentItem.loadedTimeRanges):
                self.ntf_updateLoadedRanges()
                
            default:
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        }
        
        func ntf_updateStatus() {
            // there must be a player and item
            guard let item = _item, let player = _player else {
                return
            }
            logger.trace?.write(player.status.rawValue)
            
            // check player status
            switch player.status {
            case .unknown:
                // the status is unknown, need wait some time
                break 
                
            case .readyToPlay:
                // if _isReady is true, this suggests that has been prepared
                guard !_isReady else {
                    return
                }
                _isReady = true
                
                // notice
                delegate?.operable(didPrepare: self, item: item)
                
            case .failed:
                // the status is load fail
                ntf_error(player.error)
            }
        }
        func ntf_updateLoadedRanges() {
            // there must be a player and item
            guard let item = _item, let player = _player, let playerItem = player.currentItem else {
                return
            }
            logger.debug?.write(playerItem.loadedTimeRanges)
            // only when the caching, need process the event
            guard _isStalling, let loadedRanges = playerItem.loadedTimeRanges as? [CMTimeRange] else {
                return
            }
            // vaild play range
            let begin = player.currentTime()
            let end = begin + .init(seconds: 10, preferredTimescale: begin.timescale)
            let r = CMTimeRange(start: begin, end: min(end, playerItem.duration))
            // check whether the contains vaild play range
            guard loadedRanges.contains(where: { $0.containsTimeRange(r) }) else {
                return
            }
            // update status
            _isStalling = false
            // if _isAutoPausing is true, this suggests that now is in the background mode
            // if _isPlaying is true, this suggests that have already play is starting
            guard !_isAutoPausing, _isPlaying else {
                return
            }
            logger.debug?.write("continue play")
            // restore play status
            player.play()
            delegate?.operable(didResume: self, item: item)
        }
        
        func ntf_interruptioned(_ sender: Notification) {
            // must provide the data for the operation
            guard let item = _item, let player = _player, player.currentItem === sender.object as? AVPlayerItem else {
                return
            }
            logger.debug?.write()
            
            delegate?.operable(didSuspend: self, item: item)
        }
        func ntf_finished(_ sender: Notification) {
            // must provide the data for the operation
            guard let item = _item, let player = _player, player.currentItem === sender.object as? AVPlayerItem else {
                return
            }
            logger.debug?.write()
            
            _isPlaying = false
            
            delegate?.operable(didFinish: self, item: item)
        }
        func ntf_stalled(_ sender: Notification) {
            // must provide the data for the operation
            guard let item = _item, let player = _player, player.currentItem === sender.object as? AVPlayerItem else {
                return
            }
            logger.debug?.write()
            
            _isStalling = true
            
            delegate?.operable(didStalled: self, item: item)
        }
        
        func ntf_suspend(_ sender: Notification) {
            // must provide the data for the operation
            guard let item = _item, let player = _player else {
                return
            }
            logger.trace?.write("pause is \(!_isStalling && _isPlaying)")
            
            // enable auto pauseing
            _isAutoPausing = true
            
            // if _isStalling is true, this suggests is in the caching
            // if _isPlaying is true, this suggests that have already play is starting
            guard !_isStalling, _isPlaying else {
                return
            }
            // pause video
            player.pause()
            delegate?.operable(didSuspend: self, item: item)
        }
        func ntf_resume(_ sender: Notification) {
            // must provide the data for the operation
            guard let item = _item, let player = _player else {
                return
            }
            logger.trace?.write("play is \(!_isStalling && _isPlaying)")
            
            // disable auto pauseing
            _isAutoPausing = false
            
            // if _isStalling is true, this suggests is in the caching
            // if _isPlaying is true, this suggests that have already play is starting
            guard !_isStalling, _isPlaying else {
                return
            }
            // continue play video
            player.play()
            delegate?.operable(didResume: self, item: item)
        }
        
        func ntf_error(_ error: Error?) {
            // must provide the data for the operation
            guard let item = _item else {
                return
            }
            logger.error?.write(String(describing: error))
            
            delegate?.operable(didOccur: self, item: item, error: error)
        }
        
        /// setup env
        private func _setup() {
            
            let center = NotificationCenter.default
            
            // setup player layer relationship
            _playerLayer = layer as? AVPlayerLayer
            
            // add observe item status
            addObserver(self, forKeyPath: #keyPath(_playerLayer.player.currentItem.status), options: .new, context: nil)
            addObserver(self, forKeyPath: #keyPath(_playerLayer.player.currentItem.loadedTimeRanges), options: .new, context: nil)
            
            // add observe player play status
            center.addObserver(self, selector: #selector(ntf_interruptioned(_:)), name: .AVAudioSessionInterruption, object: nil)
            center.addObserver(self, selector: #selector(ntf_finished(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
            center.addObserver(self, selector: #selector(ntf_stalled(_:)), name: .AVPlayerItemPlaybackStalled, object: nil)
            
            center.addObserver(self, selector: #selector(ntf_suspend(_:)), name: .UIApplicationWillResignActive, object: nil)
            center.addObserver(self, selector: #selector(ntf_resume(_:)), name: .UIApplicationDidBecomeActive, object: nil)
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
        
//    func _addObservers() {
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(sessionDidInterruption(_:)), name: .AVAudioSessionInterruption, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(playerDecodeErrorDidOccur(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(playerDidStalled(_:)), name: .AVPlayerItemPlaybackStalled, object: nil)
//        
//        _changeTask = _player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: .main) { [weak self](time) in
//            guard let `self` = self else {
//                return
//            }
//            self._delegate?.player?(didChange: self, currentTime: TimeInterval(CMTimeGetSeconds(time)))
//        }
//    }
//    func _removeObservers() {
//        
//        // 必须调用, 用于清除observer
//        item = nil
//        
//        if let task = _changeTask {
//            _player.removeTimeObserver(task)
//            _changeTask = nil
//        }
//        
//        NotificationCenter.default.removeObserver(self)
//    }
        
        private var _item: Item?
        
        private var _isReady: Bool = false
        private var _isPlaying: Bool = false
        
        private var _isStalling: Bool = false // caching
        private var _isAutoPausing: Bool = false // pausing
        
        
        @objc private var _playerLayer: AVPlayerLayer?
        @objc private var _player: AVPlayer? {
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
    }
    
    /// if you start playing the call this method
    func operable(didStartPlay operable: Operable, item: Item) {
        delegate?.operable(didStartPlay: self, item: item)
    }
    /// if take the initiative to stop the play call this method
    func operable(didStop operable: Operable, item: Item) {
        delegate?.operable(didStop: self, item: item)
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
        
        // setup player view
        let replicantView = ReplicantView(contentView: _playerView)
        replicantView.frame = contentView.bounds
        replicantView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(replicantView)
        
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

//open class SAMVideoPlayer: NSObject, SAMPlayerProtocol {
//    
//    public override init() {
//        super.init()
//        _addObservers()
//    }
//    
//    public convenience init(item: AVPlayerItem) {
//        self.init()
//        self.item = item
//    }
//    
//    public convenience init(contentsOf url: URL) {
//        self.init(item: AVPlayerItem(url: url))
//    }
//    
//    deinit {
//        _removeObservers()
//    }
//    
//    // MARK: - Properties
//    
//    open var item: AVPlayerItem? {
//        set {
//            
//            item?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
//            item?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
//            
//            newValue?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: .new, context: nil)
//            newValue?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: .new, context: nil)
//            
//            // 强制停止播放
//            stop()
//            
//            return _item = newValue
//        }
//        get {
//            return _item
//        }
//    }
//    open var player: AVPlayer {
//        return _player
//    }
//    
//    // the player status
//    open var status: SAMVideoPlayerStatus {
//        return _status
//    }
//    
//    // the duration of the media.
//    open var duration: TimeInterval {
//        guard let item = _player.currentItem else {
//            return 0
//        }
//        return TimeInterval(CMTimeGetSeconds(item.duration))
//    }
//    
//    // If the media is playing, currentTime is the offset into the media of the current playback position.
//    // If the media is not playing, currentTime is the offset into the media where playing would start.
//    open var currentTime: TimeInterval {
//        guard let item = _player.currentItem else {
//            return 0
//        }
//        return TimeInterval(CMTimeGetSeconds(item.currentTime()))
//    }
//    
//    // This property provides a collection of time ranges for which the download task has media data already downloaded and playable.
//    open var loadedTime: TimeInterval {
//        guard let range = _player.currentItem?.loadedTimeRanges.first?.timeRangeValue else {
//            return 0
//        }
//        return TimeInterval(CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration))
//    }
//   
//    // This property provides a collection of time ranges for which the download task has media data already downloaded and playable.
//    // The ranges provided might be discontinuous.
//    open var loadedTimeRanges: Array<NSValue>? {
//        return _player.currentItem?.loadedTimeRanges
//    }
//    
//    // an delegate
//    open weak var delegate: SAMVideoPlayerDelegate? {
//        set { return _delegate = newValue}
//        get { return _delegate }
//    }
//    
//    
//    // MARK: - Transport Control
//    
//    
//    // prepare media the resources needed and active audio session
//    // methods that return BOOL return YES on success and NO on failure.
//    @discardableResult open func prepare() -> Bool {
//        return _performForPrepare(with: nil)
//    }
//    
//    // play a media, if it is not ready to complete, will be ready to complete the automatic playback.
//    @discardableResult open func play() -> Bool {
//        return _performForPlay(with: { [weak _player] in
//            _player?.play()
//            return true
//        })
//    }
//    @discardableResult open func play(at time: TimeInterval) -> Bool {
//        let scale = _player.currentTime().timescale
//        let tm = CMTimeMakeWithSeconds(Float64(trunc(time * 10) / 10), scale)
//        // 如果正在播放
//        guard !_status.isPlayed else {
//            _player.pause()
//            _player.seek(to: tm)
//            _player.play()
//            return true
//        }
//        return _performForPlay(with: { [weak _player] in
//            _player?.pause()
//            _player?.seek(to: tm, completionHandler: { b in
//                _player?.play()
//            })
//            return true
//        })
//    }
//    
//    @discardableResult open func seek(to time: TimeInterval) -> Bool {
//        guard !_status.isStoped else {
//            return false
//        }
//        let scale = _player.currentTime().timescale
//        let tm = CMTimeMakeWithSeconds(Float64(trunc(time * 10) / 10), scale)
//        _player.seek(to: tm)
//        return true
//    }
//    
//    // pause play
//    open func pause() {
//        
//        guard _status.isPlayed || _status == .loading else {
//            return
//        }
//        
//        _player.pause()
//        _status = .pauseing
//        _deactive()
//        
//        _delegate?.player?(didPause: self)
//    }
//    
//    open func stop() {
//        
//        guard !_status.isStoped else {
//            return
//        }
//        
//        _item?.seek(to: CMTimeMake(0, 1))
//        _player.replaceCurrentItem(with: nil)
//        
//        _status = .stop
//        _deactive()
//        
//        _delegate?.player?(didStop: self)
//    }
//    
//    // MARK: - Method
//    
//    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        
//        if keyPath == #keyPath(AVPlayerItem.status) {
//            
//            if _status.isPlayed {
//                if _player.status == .readyToPlay {
//                    // 进入了后台, 然后再次切回来了
//                    _player.play()
//                } else {
//                    _status = .pauseing
//                    _delegate?.player?(didPause: self)
//                }
//                return
//            }
//            if _status == .preparing {
//                _ = _prepareTask?()
//                _prepareTask = nil
//                return
//            }
//            
//            return
//        }
//        if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
//            guard let ranges = _player.currentItem?.loadedTimeRanges else {
//                return
//            }
//            playerDidChangeLoadedRanges(ranges)
//            return
//        }
//        
//        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//    }
//    
//    // 播放器发生错误
//    open func playerDecodeErrorDidOccur(_ sender: Notification) {
//        // 检查是不是自己的通知
//        guard let item = sender.object as? AVPlayerItem, item === player.currentItem else {
//            return
//        }
//        _item?.seek(to: CMTimeMake(0, 1))
//        _player.replaceCurrentItem(with: nil)
//        _status = .error
//        _deactive()
//        
//        let error = sender.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? NSError
//        
//        _delegate?.player?(didOccur: self, error: error)
//    }
//    // 播入完成
//    open func playerDidFinishPlaying(_ sender: Notification) {
//        // 检查是不是自己的通知
//        guard let item = sender.object as? AVPlayerItem, item === player.currentItem else {
//            return
//        }
//        _item?.seek(to: CMTimeMake(0, 1))
//        _player.replaceCurrentItem(with: nil)
//        _status = .stop
//        _deactive()
//        
//        _delegate?.player?(didFinishPlaying: self, successfully: true)
//    }
//    // 加载新的内容
//    open func playerDidChangeLoadedRanges(_ ranges: Array<NSValue>) {
//        // 检查是不是自己的通知
//        guard let range = ranges.first?.timeRangeValue else {
//            return
//        }
//        
//        let start = CMTimeGetSeconds(range.start)
//        let duration = CMTimeGetSeconds(range.duration)
//        
//        let time = TimeInterval(start + duration)
//        
//        // 加载进度改变了, 通知用户
//        _delegate?.player?(didChange: self, loadedTime: time)
//        _delegate?.player?(didChange: self, loadedTimeRanges: ranges)
//        
//        // 如果可以恢复的话
//        guard duration > 3 || time >= self.duration  else {
//            return
//        }
//        // 如果是加载中, 恢复播放状态
//        guard _status == .loading else {
//            return
//        }
//        guard _delegate?.player?(shouldRestorePlaying: self) ?? true else {
//            return
//        }
//        
//        _player.play()
//        _status = .playing
//        _delegate?.player?(didRestorePlaying: self)
//    }
//    // 播放中断(网络原因)
//    open func playerDidStalled(_ sender: Notification) {
//        // 检查是不是自己的通知
//        guard let item = sender.object as? AVPlayerItem, item === player.currentItem else {
//            return
//        }
//        
//        _status = .loading
//        _delegate?.player?(didStalled: self)
//    }
//    // 播放中断(系统原因)
//    open func sessionDidInterruption(_ sender: Notification) {
//        
//        _status = .interruptioning
//        _deactive()
//        
//        _delegate?.player?(didInterruption: self)
//    }
//    
//    // MARK: - ivar
//    
//    fileprivate var _item: AVPlayerItem?
//    fileprivate var _status: SAMVideoPlayerStatus = .stop
//    
//    fileprivate var _isActived: Bool = false
//    
//    fileprivate weak var _delegate: SAMVideoPlayerDelegate?
//    
//    fileprivate var _changeTask: Any?
//    fileprivate var _prepareTask: (() -> Bool)?
//    
//    fileprivate lazy var _player: AVPlayer = AVPlayer()
//}
//
//private extension SAMVideoPlayer {
//    
//    func _addObservers() {
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(sessionDidInterruption(_:)), name: .AVAudioSessionInterruption, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(playerDecodeErrorDidOccur(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(playerDidStalled(_:)), name: .AVPlayerItemPlaybackStalled, object: nil)
//        
//        _changeTask = _player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: .main) { [weak self](time) in
//            guard let `self` = self else {
//                return
//            }
//            self._delegate?.player?(didChange: self, currentTime: TimeInterval(CMTimeGetSeconds(time)))
//        }
//    }
//    func _removeObservers() {
//        
//        // 必须调用, 用于清除observer
//        item = nil
//        
//        if let task = _changeTask {
//            _player.removeTimeObserver(task)
//            _changeTask = nil
//        }
//        
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    
//    @discardableResult func _active() -> Bool {
//        guard !_isActived else {
//            return true
//        }
//        _isActived = true
//        do {
//            
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//            try AVAudioSession.sharedInstance().sm_setActive(true, context: self)
//            return true
//        } catch {
//            return false
//        }
//        
//    }
//    @discardableResult func _deactive() -> Bool {
//        guard _isActived else {
//            return true
//        }
//        _isActived = false
//        do {
//            try AVAudioSession.sharedInstance().sm_setActive(false, with: .notifyOthersOnDeactivation, context: self)
//            return true
//        } catch {
//            return false
//        }
//    }
//    
//    
//    func _performForPrepare(with handler: ((Void) -> Bool)?) -> Bool {
//        // 己经准备过了?
//        guard !_status.isPrepared else {
//            return handler?() ?? true
//        }
//        let taskItem = _item
//        let task: () -> Bool = { [weak self] in
//            // 防止在闭包其间self被释放掉
//            guard let `self` = self else {
//                return false
//            }
//            guard let item = self._item, item === taskItem else {
//                // 如果任务己经取消掉了, 忽略
//                return false
//            }
//            guard self._player.status == .readyToPlay else {
//                // 出现了错误
//                self._status = .error
//                self._delegate?.player?(didOccur: self, error: item.error)
//                
//                return false
//            }
//            
//            // 准备好了
//            self._status = .prepared
//            self._prepareTask = nil
//            self._delegate?.player?(didPreparing: self)
//            
//            // 处理外部事件
//            return handler?() ?? true
//        }
//        guard _status != .preparing else {
//            _prepareTask = task
//            return false
//        }
//        guard let item = _item else {
//            // 没有Item不能播放
//            return false
//        }
//        guard _delegate?.player?(shouldPreparing: self) ?? true else {
//            // 用户没有准备好, 取消操作
//            _prepareTask = nil
//            return false
//        }
//        
//        // 替换掉item
//        _player.replaceCurrentItem(with: item)
//        
//        guard item.status == .readyToPlay else {
//            // 未准备好, 等待事件
//            _status = .preparing
//            _prepareTask = task
//            return false
//        }
//        
//        return task()
//    }
//    func _performForPlay(with handler: ((Void) -> Bool)?) -> Bool {
//        guard _status != .playing else {
//            // 如果是正在播放中, 忽略
//            return true
//        }
//        return _performForPrepare { [weak self] in
//            // 防止在闭包其间self被释放掉
//            guard let `self` = self else {
//                return false
//            }
//            guard self._status.isPrepared else {
//                // 并没有准备完成
//                return false
//            }
//            guard self.delegate?.player?(shouldPlaying: self) ?? true else {
//                // 用户取消了播放, 忽略该操作
//                return false
//            }
//            guard self._active() else {
//                // 激活失败
//                self._performForError(with: -1, message: "Can't active session")
//                return false
//            }
//            guard handler?() ?? true else {
//                // 播放失败, 恢复现场
//                self._performForError(with: -1, message: "can't play")
//                return false
//            }
//            
//            self._status = .playing
//            self._delegate?.player?(didPlaying: self)
//            
//            return true
//        }
//    }
//    func _performForError(with code: Int, message: String) {
//        
//        _status = .error
//        
//        _deactive()
//        _delegate?.player?(didOccur: self, error: nil)
//    }
//}

