//
//  BrowseDetailViewCell.swift
//  Browser
//
//  Created by sagesse on 11/15/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

extension UIImage {
    
    public func withOrientation(_ orientation: UIImageOrientation) -> UIImage? {
        guard imageOrientation != orientation else {
            return self
        }
        if let image = cgImage {
            return UIImage(cgImage: image, scale: scale, orientation: orientation)
        }
        if let image = ciImage {
            return UIImage(ciImage: image, scale: scale, orientation: orientation)
        }
        return nil
    }
}

class BrowseDetailViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    var asset: Browseable? 
    
    var orientation: UIImageOrientation = .up
    
    weak var delegate: BrowseDetailViewDelegate?
    
    lazy var detailView: UIImageView = UIImageView()
    lazy var containterView: IBContainterView = IBContainterView()
    lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(_:)))
    
    override var contentView: UIView {
        return containterView
    }
    
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            guard contentInset != oldValue else {
                return
            }
            _updateIconLayoutIfNeeded()
            _updateProgressLayoutIfNeeded()
        }
    }
    
    dynamic func doubleTapHandler(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: detailView)
        
        DispatchQueue.main.async {
            let containterView = self.containterView
            if containterView.zoomScale != containterView.minimumZoomScale {
                containterView.setZoomScale(containterView.minimumZoomScale, at: location, animated: true)
            } else {
                containterView.setZoomScale(containterView.maximumZoomScale, at: location, animated: true)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 重置
        _progressOfHidden = true
        _progressOfLock = nil
        _progressView.progress = 0
        _progressView.removeFromSuperview()
        _progressView.alpha = 0
        _progress = 0
    }
    
    func apply(_ asset: Browseable?) {
        guard let newValue = asset else {
            // 清除
            _asset = nil
            
            return
        }
        guard _asset !== newValue else {
            return
        }
        _asset = asset
        //playable
        // // Load the asset's "playable" key
        // [asset loadValuesAsynchronouslyForKeys:@[@"playable"] completionHandler:^{
        //     NSError *error = nil;
        //     AVKeyValueStatus status =
        //         [asset statusOfValueForKey:@"playable" error:&error];
        //     switch (status) {
        //     case AVKeyValueStatusLoaded:
        //         // Sucessfully loaded, continue processing
        //         break;
        //     case AVKeyValueStatusFailed:
        //         // Examine NSError pointer to determine failure
        //         break;
        //     case AVKeyValueStatusCancelled:
        //         // Loading cancelled
        //         break;
        //     default:
        //         // Handle all other cases
        //         break;
        //     }
        // }];
        
        //AVAsynchronousKeyValueLoading
        
        detailView.backgroundColor = newValue.backgroundColor
        detailView.image = newValue.browseImage?.withOrientation(orientation)
        containterView.contentSize = newValue.browseContentSize
        containterView.zoom(to: bounds, with: orientation, animated: false)
        //containterView.setZoomScale(containterView.maximumZoomScale, animated: false)
        
        _updateType(newValue.browseType, animated: false)
        _updateSubtype(newValue.browseSubtype, animated: false)
        
        //_updateProgress(0.25, force: false, animated: false)
        _updateProgress(-1, force: false, animated: false)
        //DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        //    self._updateProgress(0.35, animated: true)
        //    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
        //        self._updateProgress(0.65, animated: true)
        //        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
        //            self._updateProgress(1.00, animated: true)
        //        })
        //    })
        //})
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard _cachedBounds != bounds else {
            return
        }
        _cachedBounds = bounds
        _updateIconLayoutIfNeeded()
        _updateConsoleLayoutIfNeeded()
        _updateProgressLayoutIfNeeded()
    }
    
    fileprivate var _asset: Browseable?
    
    // MARK: Value
    
    fileprivate func _updateType(_ type: IBAssetType, animated: Bool) {
        guard _type != type else {
            _consoleView.stop()
            _consoleView.updateFocus(true, animated: animated)
            return
        }
        _type = type
        if _type == .video {
            if _consoleView.superview != self {
                addSubview(_consoleView)
            }
            _consoleView.stop()
            _consoleView.updateFocus(true, animated: animated)
        } else {
            if _consoleView.superview != nil {
                _consoleView.removeFromSuperview()
            }
            _consoleView.stop()
            _consoleView.updateFocus(false, animated: animated)
        }
    }
    fileprivate func _updateSubtype(_ subtype: IBAssetSubtype, animated: Bool) {
        guard _subtype != subtype else {
            return // no change
        }
        _subtype = subtype
        if _subtype != .unknow {
            if _typeView.superview != self {
                _typeView.alpha = 0
                addSubview(_typeView)
            }
            // 更新icon和布局
            _updateIconLayoutIfNeeded()
            guard _typeView.alpha < 1 else {
                return
            }
            UIView.ib_animate(withDuration: 0.25, animated: animated, animations: {
                self._typeView.alpha = 1
            })
        } else {
            // 更新icon和布局
            _updateIconLayoutIfNeeded()
            guard _typeView.superview != nil else {
                return
            }
            UIView.ib_animate(withDuration: 0.25, animated: animated, animations: {

                self._typeView.alpha = 0

            }, completion: { isFinished in
                guard isFinished else {
                    return
                }
                self._typeView.alpha = 1
                self._typeView.removeFromSuperview()
            })
        }
    }
    fileprivate func _updateProgress(_ progress: Double, force: Bool? = nil, animated: Bool) {
        guard _progressOfLock == nil else {
            // is lock
            _progressOfLock = progress
            return
        }
        let full = progress > 0.999999 // progress >= 1.0(±0.000001)
        let view = _progressView
        
        let oldProgress = _progress
        let oldHidden = _progressOfHidden
        let newProgress = progress
        let newHidden = (force ?? full) || full
        
        guard newProgress != oldProgress || newHidden != oldHidden else {
            return // no change
        }
        _progress = newProgress
        _progressOfHidden = newHidden
        
        if (newProgress != view.progress || !newHidden) && view.superview == nil {
            addSubview(view)
        }
        _updateProgressLayoutIfNeeded()
        
        guard animated else {
            view.setProgress(newProgress, animated: false)
            if newHidden {
                view.alpha = 0
                view.removeFromSuperview()
            } else {
                view.alpha = 1
            }
            return
        }
        
        // show if need
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            guard newProgress != oldProgress || !newHidden else {
                return
            }
            view.alpha = 1
        }, completion: { isFinish in
            var delay: TimeInterval = 0.35
            // set if need
            if newProgress == oldProgress {
                delay = 0
            }
            view.setProgress(newProgress, animated: true)
            // hidden if need
            UIView.animate(withDuration: 0.25, delay: delay, options: .curveLinear, animations: {
                guard view.progress > 0.999999 || newHidden else {
                    return
                }
                view.alpha = 0
            }, completion: { isFinish in
                guard isFinish else {
                    return
                }
                guard view.progress > 0.999999 || self._progressOfHidden else {
                    return
                }
                view.removeFromSuperview()
            })
        })
    }
    
    // MARK: Layout & Auto Lock
    
    fileprivate func _updateConsoleLock(_ lock: Bool, animated: Bool) {
        guard _consoleOfLock != lock && !_progressOfHidden else {
            return
        }
        _consoleOfLock = lock
        _consoleView.updateFocus(!lock, animated: animated)
    }
    fileprivate func _updateProgressLock(_ lock: Bool, animated: Bool) {
        if lock {
            // 锁定
            let progress = _progress
            _updateProgress(progress, force: true, animated: animated)
            _progressOfLock = progress
        } else {
            // 解锁, 并尝试恢复
            let progress = _progressOfLock ?? _progress
            _progressOfLock = nil
            _updateProgress(progress, force: false, animated: animated)
        }
    }
    
    fileprivate func _updateIconLayoutIfNeeded() {
        guard _typeView.superview != nil else {
            return
        }
        let edg = _containterInset
        let bounds = UIEdgeInsetsInsetRect(self.bounds, contentInset)
       
        var nframe = _typeView.frame
        nframe.origin.x = bounds.minX + edg.left
        nframe.origin.y = bounds.minY + edg.top
        nframe.size.height = 27
        _typeView.frame = nframe
    }
    fileprivate func _updateConsoleLayoutIfNeeded() {
        guard _consoleView.superview != nil else {
            return
        }
        _consoleView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    fileprivate func _updateProgressLayoutIfNeeded() {
        guard !_progressOfHidden else {
            return
        }
        //logger.debug(containterView.contentSize)
        
        let edg = _containterInset
        let size = _progressView.frame.size
        let frame = convert(detailView.frame, from: detailView.superview)
        let bounds = UIEdgeInsetsInsetRect(self.bounds, contentInset)
        
        let y2 = min(frame.maxY, bounds.maxY)
        let x2 = min(max(frame.maxX, min(max(frame.minX, bounds.minX) + frame.width, bounds.maxX)), bounds.maxX)
        
        _progressView.center = CGPoint(x: x2 - size.width / 2 - edg.right, y: y2 - size.height / 2 - edg.bottom)
    }
    
    // MARK: Init
    
    private func _commonInit() {
        
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        detailView.backgroundColor = UIColor(white: 0.94, alpha: 1)
        
        containterView.frame = bounds
        containterView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containterView.delegate = self
        containterView.addSubview(detailView)
        containterView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        _typeView.frame = CGRect(x: 0, y: 0, width: 60, height: 26)
        _typeView.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        _typeView.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, -4)
        _typeView.isUserInteractionEnabled = false
        _typeView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        _typeView.tintColor = UIColor.black.withAlphaComponent(0.6)
        _typeView.layer.cornerRadius = 3
        _typeView.layer.masksToBounds = true
        
        _typeView.setTitle("HDR", for: .normal)
        _typeView.setImage(UIImage(named: "browse_badge_hdr"), for: .normal)
        
        _consoleView.delegate = self
        
        _progressView.radius = (_progressView.bounds.width / 2) - 3
        _progressView.fillColor = UIColor.white
        _progressView.strokeColor = UIColor.lightGray
        _progressView.addTarget(self, action: #selector(progressView(willRetry: )), for: .touchUpInside)
        
        super.addSubview(containterView)
    }
    
    // MARK: Ivar
    
    private var _cachedBounds: CGRect?
    
    private var _containterInset: UIEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
    
    private var _type: IBAssetType = .unknow
    private var _subtype: IBAssetSubtype = .unknow
    
    private var _consoleOfLock: Bool = false
    
    private var _progress: Double = 0
    private var _progressOfLock: Double?
    private var _progressOfHidden: Bool = true
    
    fileprivate lazy var _typeView = UIButton(type: .system)
    fileprivate lazy var _consoleView = IBVideoConsoleView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
    fileprivate lazy var _progressView = IBOverlayProgressView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
}

extension BrowseDetailViewCell: IBVideoConsoleViewDelegate {
    
    func progressView(willRetry sender: Any) {
        _logger.debug()
        
        _updateProgress(0, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self._updateProgress(0.25, animated: true)
        })
    }
    
    func videoConsoleView(didPlay videoConsoleView: IBVideoConsoleView) {
        videoConsoleView.wait()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
            videoConsoleView.play()
        })
    }
    func videoConsoleView(didStop videoConsoleView: IBVideoConsoleView) {
        videoConsoleView.stop()
    }
}

extension BrowseDetailViewCell: IBContainterViewDelegate {
   
    func viewForZooming(in containterView: IBContainterView) -> UIView? {
        return detailView
    }
    
    func containterViewDidScroll(_ containterView: IBContainterView) {
        _updateProgressLayoutIfNeeded()
    }
    
    func containterViewDidZoom(_ containterView: IBContainterView) {
        _updateProgressLayoutIfNeeded()
    }
    
    func containterViewWillBeginDragging(_ containterView: IBContainterView) {
        _updateConsoleLock(true, animated: true)
    }
    
    func containterViewWillBeginZooming(_ containterView: IBContainterView, with view: UIView?) {
        _updateConsoleLock(true, animated: true)
    }
    
    func containterViewShouldBeginRotationing(_ containterView: IBContainterView, with view: UIView?) -> Bool {
        guard delegate?.browseDetailView?(self, containterView, shouldBeginRotationing: view) ?? true else {
            return false
        }
        
        _updateConsoleLock(true, animated: true)
        _updateProgressLock(true, animated: false)
        
        return true
    }
    
    func containterViewDidEndDragging(_ containterView: IBContainterView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        _updateConsoleLock(false, animated: true)
    }
    
    func containterViewDidEndDecelerating(_ containterView: IBContainterView) {
        _updateConsoleLock(false, animated: true)
    }
    
    func containterViewDidEndZooming(_ containterView: IBContainterView, with view: UIView?, atScale scale: CGFloat) {
        _updateConsoleLock(false, animated: true)
    }
    
    func containterViewDidEndRotationing(_ containterView: IBContainterView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
        self.orientation = orientation
        self.detailView.image = detailView.image?.withOrientation(orientation)
        
        delegate?.browseDetailView?(self, containterView, didEndRotationing: view, atOrientation: orientation)
        
        _updateProgressLock(false, animated: true)
        _updateConsoleLock(false, animated: true)
    }
}
