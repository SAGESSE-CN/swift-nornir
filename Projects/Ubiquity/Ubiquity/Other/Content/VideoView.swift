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
internal class VideoView: UIView, Displayable, Operable {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self._setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._setup()
    }
    
    /// operate event callback delegate
    weak var delegate: OperableDelegate? 
    
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
        let playerView = VideoPlayerReplicantView(contentView: _playerView)
        playerView.frame = contentView.bounds
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(playerView)
        
        return snapshotView
    }
    
    func play() {
        logger.trace?.write()
        
        guard let item = _item else {
            return
        }
        
        _playerView.play()
        
        self.delegate?.operable(didStartPlay: self, item: item)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
//            if (arc4random() % 2) == 0 {
//                self.delegate?.operable(didFinish: self, item: item)
//            } else {
//                self.delegate?.operable(didOccur: self, item: item, error: nil)
//            }
//        }
    }
    func suspend() {
        logger.trace?.write()
    }
    func resume() {
        logger.trace?.write()
    }
    func stop() {
        logger.trace?.write()
        
        guard let item = _item else {
            return
        }
        
        delegate?.operable(didStop: self, item: item)
    }
    
    func prepare(with item: Item) {
        logger.trace?.write()
        
        _item = item
        _playerView.prepare(with: item)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.delegate?.operable(didPrepare: self, item: item)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = bounds.applying(_contentView.transform).size
        
        // update content view layout
        _contentView.bounds = .init(x: 0, y: 0, width: size.width, height: size.height)
        _contentView.center = .init(x: bounds.midX, y: bounds.midY)
        
        // update thumb view & player view layout
        _thumbView.frame = convert(bounds, to: _contentView)
        _playerView.frame = convert(bounds, to: _contentView)
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
        _playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _contentView.addSubview(_playerView)
    }
    
    private var _item: Item?
    
    private lazy var _contentView: UIView = .init()
    
    private lazy var _thumbView: UIImageView = .init()
    private lazy var _playerView: VideoPlayerView = .init()
//
//    private var _playing: Bool = false
}

internal class VideoPlayerView: UIView {
    
    override class var layerClass: AnyClass {
       return VideoPlayerLayer.self
    }
    
    
    func play() {
        _palyerLayer?.player?.play()
    }
    
    func prepare(with item: Item) {
        guard let path = Bundle.main.path(forResource: "阴阳师-地表最萌告白", ofType: "m4v") else {
            return
        }
        logger.debug?.write(path)
        
        let item = AVPlayerItem(asset: AVURLAsset(url: .init(fileURLWithPath: path)))
        
//        self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
//        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
//        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//        playerLayer.frame = self.layer.bounds;
//        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        let player = AVPlayer(playerItem: item)
        
        _palyerLayer?.player = player
        
        
        
        //AVPlayerItem(asset: <#T##AVAsset#>)
//        NSURL *sourceMovieURL = [NSURL fileURLWithPath:videoStr];
//        AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
        
        
    }
    
    private var _palyerLayer: VideoPlayerLayer? {
        return layer as? VideoPlayerLayer
    }
}
internal class VideoPlayerReplicantView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(contentView: VideoPlayerView) {
        super.init(frame: contentView.frame)
        _contentView = contentView
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
    
    weak var _contentView: UIView?
    lazy var _contentViewFrame: CGRect = .zero
    weak var _contentViewSuperview: UIView?
}
internal class VideoPlayerLayer: AVPlayerLayer {
}
