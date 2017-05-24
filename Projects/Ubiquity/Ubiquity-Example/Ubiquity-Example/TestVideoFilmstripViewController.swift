//
//  TestVideoFilmstripViewController.swift
//  Ubiquity-Example
//
//  Created by SAGESSE on 5/8/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit
import AVFoundation

import Photos

@testable import Ubiquity


class Generator {
    
//    init(asset: AVAsset) {
//        self.asset = asset
//        self.generator = AVAssetImageGenerator(asset: asset)
//    }
    init(asset: AVAsset, duration: TimeInterval) {
        self.asset = asset
        self.duration = duration
        self.generator = AVAssetImageGenerator(asset: asset)
        self.configure()
    }
    
    private func configure() {
        
        self.generator.requestedTimeToleranceBefore = kCMTimeZero
        self.generator.requestedTimeToleranceAfter = kCMTimeZero
        
//        self.generator.maximumSize = .init(width: item.width * 2, height: item.height * 2)
        
//        let setting = ScrubberSettings.settings
        
//        let duration = max(self.duration, Generator.minVideoDuration)
//        let content = CGSize(width: CGFloat(log2(duration)) * Generator.baseVideoWidth, height: 38)
//
//        let count = Int(ceil(content.width /  (content.height * setting.filmstripAspectRatio)) + 0.5)
//        let item = CGSize(width: content.width / CGFloat(count), height: content.height)
//        
//        let step = duration / Double(count)
        
    }
    
    
//    // generated the target image size
//    let targetSize: CGSize
    
    private var asset: AVAsset
    private var duration: TimeInterval
    private var generator: AVAssetImageGenerator
    
}



class Scrubber {
    
    init(player: AVPlayer) {
        self.player = player
        self.seeking = player.currentTime()
    }
    
    func seek(to offset: CMTime) {
        // if the player is not ready, don't allow the seek
        guard self.player.status == .readyToPlay else {
            return
        }
        // if less than a certain threshold, can skip the request
        guard self.seeking != offset else {
            return
        }
        self.seeking = offset
        // if is updating, waiting for next a chance
        if !self.updating {
            self.update()
        }
    }
    
    private func update() {
        
        // if the player is not ready, don't allow the seek
        guard self.player.status == .readyToPlay else {
            self.updating = false
            return
        }
        // seek on pausing after
        if self.player.rate != 0 {
            self.player.pause()
        }
        // generate local variables, for the closure captured
        let seek = self.seeking
        // start the update
        self.updating = true
        self.player.seek(to: seek, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero) { finished in
            // if equal that can stop the loaded
            guard self.seeking == seek else {
                self.update()
                return
            }
            self.updating = false
        }
    }
    
    private(set) var player: AVPlayer
    private(set) var seeking: CMTime
    private(set) var updating: Bool = false
}
class ScrubberView: UIView {
    
    init(frame: CGRect, duration: TimeInterval) {
        super.init(frame: frame)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    deinit {
        // must manually clear
        player = nil
    }
    
    var player: AVPlayer? {
        set {
            // if there is any change
            guard newValue != _scrubber?.player else {
                return
            }
            // remove observer if needed
            if let observer = _timeObserver {
                _scrubber?.player.removeTimeObserver(observer)
            }
            // clean contex
            _scrubber = nil
            _timeObserver = nil
            // if this is the new player
            guard let player = newValue else {
                return
            }
            // create context & add the observer
            _scrubber = Scrubber(player: player)
            _timeObserver = player.addPeriodicTimeObserver(forInterval: .init(seconds: 0.33, preferredTimescale: 100), queue: nil) { [weak self] time in
                self?._updateTime(at: .init(time.seconds))
            }
        }
        get {
            return _scrubber?.player
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // update layout on frame changes
        updateVisibleLayout()
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        // update layout on superview changes
        updateVisibleLayout()
    }
    
    func updateTime(seek: Bool) {
        
        // if read failure, player is not ready, ignore
        guard let player = self.player, player.status == .readyToPlay else {
            return
        }
        guard let duration = player.currentItem?.duration else {
            return
        }
        // calculate the percentage of the current
        let percent = min(max(_indicatorView.center.x / max(bounds.width + 1, 1), 0), 1)
        let time = duration.seconds * .init(percent)
        
        // update time
        _indicatorView.text = .init(format: "%zd:%02zd", Int(time) / 60, Int(time) % 60)
        _scrubber?.seek(to: .init(seconds: time, preferredTimescale: duration.timescale))
    }
    func updateVisibleLayout() {
        
        guard let superview = superview else {
            return
        }
        
        let rect = convert(superview.bounds, from: superview)
        
        _updateVisibleRect(in: rect)
        _updateVisibleLayout()
        
//        let x = max(min(rect.minX, bounds.width - rect.width), 0)
//        let y = max(min(rect.minY, bounds.height - rect.height), 0)
//        
        //_scrollView.frame = .init(x: x, y: y, width: rect.width, height: rect.height)
        _indicatorView.center = .init(x: min(max(rect.midX, 0), bounds.maxX), y: bounds.midY)
    }
    
    private func _updateVisibleRect(in rect: CGRect) {
        
        // if the content size changed, need to renew layout
        if _layout?.contentSize != bounds.size {
            _layout = ScrubberViewLayout(contentSize: bounds.size)
        }
        
        logger.trace?.write(rect)
        
        
    }
    private func _updateVisibleLayout() {
        
    }
    
    private func _updateTime(at time: TimeInterval) {
    }
    
    
    private func _setup() {
        
        _indicatorView.frame = .init(x: 0, y: 0, width: frame.height / 2, height: frame.height)
        _indicatorView.backgroundColor = .init(white: 1, alpha: 0.5)
        _indicatorView.isUserInteractionEnabled = false
        addSubview(_indicatorView)
    }
    
    private var _visibleRect: CGRect = .zero
    private var _visibleCells: [UIView]?
    private var _visibleLayoutAttributes: [ScrubberViewLayoutAttributes]?
    
    private var _layout: ScrubberViewLayout?
    private var _scrubber: Scrubber?
    private var _timeObserver: Any?
    
    fileprivate lazy var _indicatorView = ScrubberIndicatorView(frame: .zero)
    
}
class ScrubberViewLayout: NSObject {
    
    init(contentSize: CGSize) {
        
        let count = Int(contentSize.height * ScrubberSettings.settings.filmstripAspectRatio + 0.5)
        let width = contentSize.width / .init(count)
        
        self.itemSize = .init(width: width, height: contentSize.height)
        self.contentSize = contentSize
        self.layoutAttributes = (0 ..< count).map { v in
            let attributes = ScrubberViewLayoutAttributes()
            return attributes
        }
        
        super.init()
    }
    
    func layoutAttributesForElements(in rect: CGRect) -> Array<ScrubberViewLayoutAttributes> {
        return []
    }
    
    let itemSize: CGSize
    let contentSize: CGSize
    let layoutAttributes: Array<ScrubberViewLayoutAttributes>
    
    
}
class ScrubberViewLayoutAttributes: NSObject {
}
class ScrubberIndicatorView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    var text: String? {
        set { return _label.text = newValue }
        get { return _label.text }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _line.bounds = .init(x: 0, y: 0, width: 1, height: bounds.height)
        _line.position = .init(x: bounds.midX, y: bounds.midY)
        _label.center = .init(x: bounds.midX, y: bounds.minY - _label.bounds.midY - 5)
    }
    
    private func _setup() {
        
        _line.backgroundColor = UIColor(red: 0.25, green: 0.51, blue: 0.75, alpha: 1).cgColor
        layer.addSublayer(_line)
        
        _label.text = "0:00"
        _label.textColor = .black
        _label.textAlignment = .center
        _label.layer.cornerRadius = 2
        _label.layer.masksToBounds = true
        _label.backgroundColor = .init(white: 1, alpha: 0.8)
        _label.frame = .init(x: 0, y: 0, width: 46, height: 18)
        _label.font = .systemFont(ofSize: 11)
        addSubview(_label)
    }
    
    
    private lazy var _line: CALayer = CALayer()
    private lazy var _label: UILabel = UILabel()
}
class ScrubberSettings {
    
    // the video width of a second
    var baseVideoWidth: CGFloat = 150
    // the video minimum support duration, shorter than the length to the length calculation
    var minVideoDuration: TimeInterval = 1.5
    // the video thumbnail ratio
    var filmstripAspectRatio: CGFloat = 16 / 9
    
    // size that fits with duration
    func sizeThatFits(_ size: CGSize, duration: TimeInterval) -> CGSize {
        // the vaild time
        let time = max(duration, minVideoDuration)
        // calculate the content size
        return .init(width: floor(.init(log2(time)) * .init(baseVideoWidth) * 2) / 2, height: size.height)
    }
    
    static let settings: ScrubberSettings = .init()
}

class TestVideoFilmstripViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var asset: AVAsset!
    var player: AVPlayer!
    var generator: AVAssetImageGenerator!
    
    var scrubberView: ScrubberView?
    
    var generator2: Generator?
    
    func loadx(_ asset: AVAsset) {
        
        let playerView = VideoPlayerView(frame: self.contentView.bounds)
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(playerView)
        
        //self.asset = AVURLAsset(url: URL(string: "http://192.168.0.107/c.m4v")!)
        
        
        self.asset = asset//AVURLAsset(url: URL(string: "http://192.168.2.3/c.m4v")!)
        self.player = AVPlayer(playerItem: AVPlayerItem(asset: self.asset)) 
        (playerView.layer as? AVPlayerLayer)?.player = self.player
        
        let size = ScrubberSettings.settings.sizeThatFits(.init(width: 0, height: 38), duration: self.asset.duration.seconds)
        
        let setting = ScrubberSettings.settings
        let duration = max(self.asset.duration.seconds, setting.minVideoDuration)
        let count = Int(ceil(size.width /  (size.height * setting.filmstripAspectRatio)) + 0.5)
        let item = CGSize(width: size.width / CGFloat(count), height: size.height)
        let step = duration / Double(count)
        
        let values = (0 ..< count).map { v -> CMTime in
            let t = Double(v) * step
            return CMTime(seconds: t, preferredTimescale: self.asset.duration.timescale)
        }
        
        let view1 = UIView(frame: .init(x: 0, y: 0, width: 160, height: 38))
        let view2 = ScrubberView(frame: .init(x: view1.frame.maxX + 40, y: 0, width: size.width, height: size.height), duration: self.asset.duration.seconds)
        let view3 = UIView(frame: .init(x: view2.frame.maxX + 40, y: 0, width: 160, height: 38))
        self.wv = view2
        
        self.scrubberView = view2
        self.scrubberView?.player = self.player
        
        self.generator2 = Generator(asset: self.asset, duration: asset.duration.seconds)
        
        
        (0 ..< count).forEach {
            
            let sv = UIImageView(frame: .init(x: item.width * CGFloat($0), y: 0, width: item.width, height: item.height))
            sv.backgroundColor = .random
            sv.contentMode = .scaleAspectFill
            sv.clipsToBounds = true
            view2.addSubview(sv)
        }
        view2.bringSubview(toFront: view2._indicatorView)
        
        view1.backgroundColor = .random
        view2.backgroundColor = .random
        view3.backgroundColor = .random
        
        scrollView.contentSize = .init(width: view3.frame.maxX, height: 0)
        scrollView.clipsToBounds = false
        scrollView.addSubview(view1)
        scrollView.addSubview(view2)
        scrollView.addSubview(view3)

        self.generator = AVAssetImageGenerator(asset: self.asset)
        self.generator.requestedTimeToleranceAfter = kCMTimeZero
        self.generator.requestedTimeToleranceBefore = kCMTimeZero
        self.generator.maximumSize = .init(width: item.width * 2, height: item.height * 2)
        
        self.generator.generateCGImagesAsynchronously(forTimes: values as [NSValue]) { rt, image, vt, rs, er in
            guard let index = values.index(where: { $0.seconds == rt.seconds }) else {
                return
            }
            let sv = view2.subviews[index] as? UIImageView
            if let image = image {
                DispatchQueue.main.async {
                    sv?.image = UIImage(cgImage: image, scale: 2, orientation: .up)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.requestAuthorization { _ in
            let cx = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: nil)
            guard let c = cx.firstObject else {
                return
            }
            guard let i = PHAsset.fetchAssets(in: c, options: nil).lastObject else {
                return
            }
            PHImageManager.default().requestAVAsset(forVideo: i, options: nil) { (asset, _, _) in
                DispatchQueue.main.async {
                    self.loadx(asset!)
                }
            }
        }
        
//        self.asset.loadValuesAsynchronously(forKeys: [#keyPath(AVURLAsset.duration)]) { [weak self] in
//            guard let `self` = self else {
//                return
//            }
//            let duration = CMTimeGetSeconds(self.asset.duration)
//            print(duration)
//        }
        
        //ScrubberSettings.settings.filmstripAspectRatio
        
//        self.scrollView.panGestureRecognizer.addTarget(self, action: #selector(xa(_:)))

        // Do any additional setup after loading the view.
    }
    
    var wv: UIView?
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
        guard let wv = wv else {
            return
        }
        let w1 = wv.frame.minX - 0 //0 - wv.minX
        let w2 = scrollView.contentSize.width - wv.frame.maxX //wv.maxX - end
        
        let x = scrollView.contentOffset.x + scrollView.contentInset.left
        scrollView.contentInset = .init(top: 0, left: view.frame.width / 2 - w1,
                                        bottom: 0, right: view.frame.width / 2 - w2)
        scrollView.contentOffset.x = x - scrollView.contentInset.left
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        self.scrubberView?.updateVisibleLayout()
        self.scrubberView?.updateTime(seek: true)
        
//        guard let player = self.player, let item = player.currentItem, player.status == .readyToPlay else {
//            return
//        }
//        let x = scrollView.contentOffset.x + scrollView.contentInset.left
//        let percent = min(max(x, 0), scrollView.contentSize.width) / scrollView.contentSize.width
//        
//        let duration = item.duration
//        let seek = CMTime(seconds: .init(percent) * duration.seconds, preferredTimescale: duration.timescale)
//        
//        timeLabel?.text = String(format: "%.2lf/%.2lf", seek.seconds, duration.seconds)
//        scrubber?.seek(to: seek)
    }
}
