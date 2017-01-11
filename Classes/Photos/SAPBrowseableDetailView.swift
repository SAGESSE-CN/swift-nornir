//
//  SAPBrowseableDetailView.swift
//  SAPhotos
//
//  Created by SAGESSE on 11/1/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import SAMedia
import AVFoundation

class TIImage: NSObject, Progressiveable {
    
    dynamic var content: Any?  {
        didSet {
            didChangeProgressiveContent()
        }
    }
    dynamic var progress: Double = 0 {
        didSet {
            didChangeProgressiveProgress()
        }
    }
}
class TIVideo: NSObject, Progressiveable {
    
    dynamic var content: Any?  {
        didSet {
            didChangeProgressiveContent()
        }
    }
    dynamic var progress: Double = 0 {
        didSet {
            didChangeProgressiveProgress()
        }
    }
}

class TestVideo: NSObject, SAPBrowseable {
    
    var browseType: SAPBrowseableType {
        return .video
    }
    
    var browseSize: CGSize { 
        //return CGSize(width: 1600, height: 1200)
        return CGSize(width: 1920, height: 1080)
    }
    var browseOrientation: UIImageOrientation  {
        return .up
    }
    
    var browseImage: Progressiveable? { 
        let item = TIImage() 
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            item.content = UIImage(named: "m41.jpg")
            item.progress = 15679.0 / 268343.0
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                item.content = UIImage(named: "m42.jpg")
                item.progress = 64829.0 / 268343.0
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(15)) {
                    item.content = UIImage(named: "m43.jpg")
                    item.progress = 150869.0 / 268343.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(25)) {
                        item.content = UIImage(named: "m44.jpg")
                        item.progress = 1.0
                    }
                }
            }
        }
        return item
    }
    // 这个参数只用于视频和音频
    var browseContent: Progressiveable? {
        let item = TIVideo()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            //let url = URL(string: "http://SAGESSE.me:1080/a.mp4")!
            let url = URL(string: "http://192.168.90.254/a.mp4")!
            
            item.content = AVPlayerItem(url: url)
            item.progress = 1
        }
        
        return item
    }  
}

internal class SAPBrowseableDetailView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    var contentView: UIView {
        return _contentView
    }
    var containterView: SAPContainterView {
        return _containterView
    }
    
    open dynamic var contents: SAPBrowseable? {
        set { return setContents(newValue, animated: false) }
        get { return _contents }
    }
    open dynamic func setContents(_ contents: SAPBrowseable?, animated: Bool) {
        let oldValue = _contents
        let newValue = contents
        // value is changed?
        guard newValue !== oldValue else {
            return
        }
        if !animated {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
        }
        // update values
        _contents = contents
        
        _contentView.orientation = newValue?.browseOrientation ?? .up
        
        _containterView.contentSize = newValue?.browseSize ?? .zero
        _containterView.zoom(to: bounds, with: _contentView.orientation, animated: false)
        
        _updateControlViewLayout()
        _updateProgressViewLayout()
        
        setProgressiveValue(newValue?.browseImage, forKey: #keyPath(SAPBrowseableDetailView._image))
        setProgressiveValue(nil, forKey: #keyPath(SAPBrowseableDetailView._content)) // 清空播放
        
        if !animated {
            CATransaction.commit()
        }
    }
    
    open dynamic var progress: Double {
        set { return setProgress(newValue, animated: false) }
        get { return _progress }
    }
    open dynamic func setProgress(_ progress: Double, animated: Bool) {
        let newValue = progress
        let oldValue = _progress
        // value is changed?
        guard oldValue != newValue else {
            return
        }
        // update value
        _progress = newValue
        _progressView.setProgress(newValue, animated: oldValue < newValue && animated)
        
        if newValue < 0.999999 {
            // is less 1, show progress view
            guard _canChangeProgressView else {
                return
            }
            _updateProgressViewIsHidden(false, animated: animated)
        } else {
            // is gte 1, hide progress
            guard animated else {
                _updateProgressViewIsHidden(true, animated: animated)
                return
            }
            // wait animation completion
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                guard newValue == self._progress else {
                    return
                }
                self._updateProgressViewIsHidden(true, animated: animated)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if _cacheBounds?.size != bounds.size {
            _cacheBounds = bounds
            _updateControlViewLayout()
        }
        if _cacheContentBounds?.size != _contentView.bounds.size {
            _updateProgressViewLayout()
        }
    }
    
    override func progressiveValue(_ progressiveValue: Progressiveable?, didChangeProgress value: Any?, context: String) {
        guard context == #keyPath(SAPBrowseableDetailView._image) else {
            return
        }
        setProgress(value as? Double ?? 0, animated: !CATransaction.disableActions() && UIView.areAnimationsEnabled)
    }
    
    // MARK: - Events
    
    dynamic func tapHandler(_ sender: AnyObject) {
        _logger.trace()
        
    }
    dynamic func doubleTapHandler(_ sender: UITapGestureRecognizer) {
        
        if _containterView.zoomScale != _containterView.minimumZoomScale {
            _containterView.setZoomScale(_containterView.minimumZoomScale, at: sender.location(in: _contentView), animated: true)
        } else {
            _containterView.setZoomScale(_containterView.maximumZoomScale, at: sender.location(in: _contentView), animated: true)
        }
    }
    
    private func _init() {
        
        //_tapGestureRecognizer.require(toFail: _doubleTapGestureRecognizer)
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        _contentView.isUserInteractionEnabled = false
        
        _containterView.frame = bounds
        _containterView.delegate = self
        _containterView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _containterView.addSubview(contentView)
        
        //_containterView.addGestureRecognizer(_tapGestureRecognizer)
        _containterView.addGestureRecognizer(_doubleTapGestureRecognizer)
        
        addSubview(_containterView)
        
        
//        let view = UIImageView()
//        let image = UIImage(named: "t3.jpg")
//        
//        view.image = image
//        view.backgroundColor = .random
//        view.isUserInteractionEnabled = false
//        
//        _containterView.addSubview(view)
//        _containterView.contentSize = image?.size ?? CGSize(width: 1600, height: 1200)
//        _contentView = view
        
        _contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
    }
    
    @IBAction func reload() {
        DispatchQueue.main.async {
            self.setContents(TestVideo(), animated: false)
        }
    }
    
    fileprivate dynamic var _image: Any? {
        set {
            
            _logger.trace(newValue)
            
            return _contentView.image = newValue
        }
        get { return _contentView.image }
    }
    fileprivate dynamic var _content: AVPlayerItem? {
        set {
            _logger.trace(newValue)
            
            if let item = newValue {
                _player = SAMVideoPlayer(item: item)
                _player?.play()
                
                
            } else {
                _player = nil
                _contentView.player = nil
            }
            
            _playerItem =  newValue
            _contentView.player = _player
        }
        get {
            return _playerItem
        }
    }
    
    var doubleTapGestureRecognizer: UITapGestureRecognizer {
        return _doubleTapGestureRecognizer
    }
    
    fileprivate var _player: SAMVideoPlayer?
    fileprivate var _playerItem: AVPlayerItem?
    
    fileprivate var _cacheBounds: CGRect?
    fileprivate var _cacheContentBounds: CGRect?
    
    fileprivate var _canChangeProgressView: Bool = true
    
    fileprivate var _automaticallyAdjustsControlViewIsHidden: Bool = true
    fileprivate var _automaticallyAdjustsProgressViewIsHidden: Bool = true
    
    fileprivate var _contents: SAPBrowseable?
    fileprivate var _contentInset: UIEdgeInsets = .zero
    
    fileprivate var _progress: Double = 1
    fileprivate var _progressViewIsHidden: Bool = true
    
    fileprivate var _controlView: SAPBrowseableControlView?
    fileprivate var _controlViewTask: String?
    fileprivate var _controlViewIsHidden: Bool = false
    
    fileprivate lazy var _contentView: SAPBrowseableContentView = SAPBrowseableContentView()
    fileprivate lazy var _progressView: SAPBrowseableProgressView = SAPBrowseableProgressView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
    fileprivate lazy var _containterView: SAPContainterView = SAPContainterView()
    
    //fileprivate lazy var _tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
    fileprivate lazy var _doubleTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(_:)))
}

fileprivate extension SAPBrowseableDetailView {
    
    private func _transition(with view: UIView?, animated: Bool, animations: @escaping () -> Void, completion: ((Bool) -> Void)?){
        guard let view = view, animated else {
            animations()
            completion?(false)
            return
        }
        UIView.transition(with: view, duration: 0.25, options: .curveEaseInOut, animations: animations, completion: completion)
    }
    
    fileprivate func _updateControlViewIsHidden(_ flag: Bool, animated: Bool, delay: TimeInterval) {
        let task = UUID().uuidString
        _controlViewTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(delay * 1000))) {
            guard task == self._controlViewTask else {
                return // task is change
            }
            self._updateControlViewIsHidden(flag, animated: animated)
        }
    }
    fileprivate func _updateControlViewIsHidden(_ flag: Bool, animated: Bool) {
        guard _controlViewIsHidden != flag else {
            return // no change
        }
        _controlViewIsHidden = flag
        
        let view = _controlView
        
        if let view = view, !flag {
            addSubview(view)
        }
        
        _transition(with: view, animated: animated, animations: {
            // if is hidden alpha is 0 else alpha is 1
            view?.alpha = flag ? 0 : 1
            
        }, completion: { _ in
            // if hidden need remove view
            guard self._controlViewIsHidden else {
                return
            }
            view?.removeFromSuperview()
        })
    }
    fileprivate func _updateProgressViewIsHidden(_ flag: Bool, animated: Bool) {
        guard _progressViewIsHidden != flag else {
            return // no change
        }
        _progressViewIsHidden = flag
        
        let view = _progressView
        
        if !flag {
            addSubview(view)
        }
        
        _transition(with: view, animated: animated, animations: {
            // if is hidden alpha is 0 else alpha is 1
            view.alpha = flag ? 0 : 1
            
        }, completion: { _ in
            // if hidden need remove view
            guard self._progressViewIsHidden else {
                return
            }
            view.removeFromSuperview()
        })
    }
    
    fileprivate func _updateControlViewLayout() {
        _logger.trace()
        
        guard let type = _contents?.browseType, type == .video || type == .audio else {
            // clear view
            _controlView?.removeFromSuperview()
            _controlView = nil
            return
        }
        let view = _controlView ?? SAPBrowseableControlView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        
        view.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        view.delegate = self
        
        // 更新状态
        
        if view.superview != self {
            addSubview(view)
        }
        
        _controlView = view
    }
    fileprivate func _updateProgressViewLayout() {
        
        let edg = UIEdgeInsetsMake(8, 8, 8, 8)
        let nframe = UIEdgeInsetsInsetRect(_contentView.frame, edg)
        let nbounds = UIEdgeInsetsInsetRect(self.bounds, _contentInset)
        
        let width_2 = _progressView.frame.width / 2
        let height_2 = _progressView.frame.height / 2
        
        var pt = convert(CGPoint(x: nframe.maxX - width_2, y: nframe.maxY - height_2), from: _contentView.superview)
        
        pt.x = max(min(pt.x, nbounds.maxX - width_2 - edg.right), nbounds.minX + edg.left + width_2)
        pt.y = max(min(pt.y, nbounds.maxY - height_2 - edg.bottom), nbounds.minY + edg.top + height_2)
        
        _progressView.center = pt
        _cacheContentBounds = _contentView.bounds
    }
}

extension SAPBrowseableDetailView: SAPBrowseableControlViewDelegate {
    
    func controlView(_ controlView: SAPBrowseableControlView, didChange state: SAPBrowseableControlState) {
        _logger.trace(state)
        
        setProgressiveValue(contents?.browseContent, forKey: #keyPath(SAPBrowseableDetailView._content))
    }
}

extension SAPBrowseableDetailView: SAPContainterViewDelegate {
    
    func viewForZooming(in containterView: SAPContainterView) -> UIView? {
        return _contentView
    }
    
    func containterViewDidScroll(_ containterView: SAPContainterView) {
        if _canChangeProgressView {
            _updateProgressViewLayout()
        }
    }
    func containterViewDidZoom(_ containterView: SAPContainterView) {
        if _canChangeProgressView {
            _updateProgressViewLayout()
        }
    }
    
    func containterViewWillBeginDragging(_ containterView: SAPContainterView) {
        if _automaticallyAdjustsControlViewIsHidden {
            _updateControlViewIsHidden(true, animated: true)
        }
    }
    func containterViewWillBeginZooming(_ containterView: SAPContainterView, with view: UIView?) {
        if _automaticallyAdjustsControlViewIsHidden {
            _updateControlViewIsHidden(true, animated: true)
        }
    }
    func containterViewShouldBeginRotationing(_ containterView: SAPContainterView, with view: UIView?) -> Bool {
        _canChangeProgressView = false
        
        if _automaticallyAdjustsControlViewIsHidden {
            _updateControlViewIsHidden(true, animated: true)
        }
        if _automaticallyAdjustsProgressViewIsHidden {
            _updateProgressViewIsHidden(true, animated: false)
        }
        
        return true
    }
    
    func containterViewDidEndDragging(_ containterView: SAPContainterView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        if _automaticallyAdjustsControlViewIsHidden {
            _updateControlViewIsHidden(false, animated: true)
        }
    }
    func containterViewDidEndDecelerating(_ containterView: SAPContainterView) {
        if _automaticallyAdjustsControlViewIsHidden {
            _updateControlViewIsHidden(false, animated: true)
        }
    }
    func containterViewDidEndZooming(_ containterView: SAPContainterView, with view: UIView?, atScale scale: CGFloat) {
        if _automaticallyAdjustsControlViewIsHidden {
            _updateControlViewIsHidden(false, animated: true)
        }
    }
    func containterViewDidEndRotationing(_ containterView: SAPContainterView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
        _canChangeProgressView = true
        _contentView.orientation = orientation
        
        if _automaticallyAdjustsControlViewIsHidden {
            _updateControlViewIsHidden(false, animated: true)
        }
        if _automaticallyAdjustsProgressViewIsHidden && progress <= 0.999999 {
            _updateProgressViewLayout()
            _updateProgressViewIsHidden(false, animated: true)
        }
    }
    
}
