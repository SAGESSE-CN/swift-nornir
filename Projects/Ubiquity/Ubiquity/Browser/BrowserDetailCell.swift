//
//  BrowserDetailCell.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserDetailCell: UICollectionViewCell {
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    internal var detailView: UIView? {
        return _detailView
    }
    internal var containerView: CanvasView? {
        return _containerView
    }
    
    internal var orientation: UIImageOrientation = .up
//    internal var orientation: UIImageOrientation = .left
    
//    var asset: Browseable?
//    
//    var orientation: UIImageOrientation = .up
//    
//    weak var delegate: BrowseDetailViewDelegate?
//
    
//    var contentInset: UIEdgeInsets = .zero {
//        didSet {
//            guard contentInset != oldValue else {
//                return
//            }
//            _updateIconLayoutIfNeeded()
//            _updateProgressLayoutIfNeeded()
//        }
//    }
    
    internal override func prepareForReuse() {
        super.prepareForReuse()
        
//        // 重置
//        _progressOfHidden = true
//        _progressOfLock = nil
//        _progressView.progress = 0
//        _progressView.removeFromSuperview()
//        _progressView.alpha = 0
//        _progress = 0
        
    }
    
    internal func apply(for item: Item) {
        
        containerView?.contentSize = item.size
        containerView?.zoom(to: bounds , with: orientation, animated: false)
        
        detailView?.backgroundColor = item.backgroundColor
        
        if let imageView = detailView as? UIImageView {
            imageView.image = item.image?.withOrientation(orientation)
        }
        
        _contentSize = item.size
    }
    
//    internal override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
//        super.apply(layoutAttributes)
//
//        detailView.backgroundColor = newValue.backgroundColor
//        detailView.image = newValue.browseImage?.withOrientation(orientation)
        
//        if let imageView = detailView as? UIImageView {
//            imageView.image = UIImage(named: "t1_g")
//        }
//        containerView?.contentSize = .init(width: 1600, height: 1200)
//        containerView?.zoom(to: bounds , with: .up, animated: false)
//        containerView.contentSize = newValue.browseContentSize
//        containerView.zoom(to: bounds, with: orientation, animated: false)
//        //containerView.setZoomScale(containerView.maximumZoomScale, animated: false)
//    }
    
    internal override func layoutSubviews() {
        super.layoutSubviews()
//        guard _cachedBounds != bounds else {
//            return
//        }
//        _cachedBounds = bounds
        //_updateIconLayoutIfNeeded()
        //_updateConsoleLayoutIfNeeded()
        //_updateProgressLayoutIfNeeded()
    }
    
    internal func setup() {
        
        // make detail & container view
        _detailView = (type(of: self).detailViewClass as? UIView.Type)?.init()
        _containerView = contentView as? CanvasView
        
        // setup container view if needed
        if let containerView = _containerView {
            containerView.delegate = self
            // add double tap recognizer
            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(_:)))
            doubleTapRecognizer.numberOfTapsRequired = 2
            containerView.addGestureRecognizer(doubleTapRecognizer)
        }
        // setup detail view if needed
        if let detailView = _detailView {
            _detailView = detailView
            _detailView?.backgroundColor = UIColor(white: 0.94, alpha: 1)
            _containerView?.addSubview(detailView)
        }
        
//        _typeView.frame = CGRect(x: 0, y: 0, width: 60, height: 26)
//        _typeView.titleLabel?.font = UIFont.systemFont(ofSize: 14)
//        _typeView.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, -4)
//        _typeView.isUserInteractionEnabled = false
//        _typeView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
//        _typeView.tintColor = UIColor.black.withAlphaComponent(0.6)
//        _typeView.layer.cornerRadius = 3
//        _typeView.layer.masksToBounds = true
//        
//        _typeView.setTitle("HDR", for: .normal)
//        _typeView.setImage(UIImage(named: "browse_badge_hdr"), for: .normal)
//
//        _consoleView.delegate = self
//        
//        _progressView.radius = (_progressView.bounds.width / 2) - 3
//        _progressView.fillColor = UIColor.white
//        _progressView.strokeColor = UIColor.lightGray
//        _progressView.addTarget(self, action: #selector(progressView(willRetry: )), for: .touchUpInside)
    }
    
    internal dynamic func doubleTapHandler(_ sender: UITapGestureRecognizer) {
        guard let containerView = containerView else {
            return
        }
        let location = sender.location(in: self.detailView)
        // zoome operator wait to next run loop
        DispatchQueue.main.async {
            if containerView.zoomScale != containerView.minimumZoomScale {
                containerView.setZoomScale(containerView.minimumZoomScale, at: location, animated: true)
            } else {
                containerView.setZoomScale(containerView.maximumZoomScale, at: location, animated: true)
            }
        }
    }
//
//    func apply(_ asset: Browseable?) {
//        guard let newValue = asset else {
//            // 清除
//            _asset = nil
//            
//            return
//        }
//        guard _asset !== newValue else {
//            return
//        }
//        _asset = asset
//        //playable
//        // // Load the asset's "playable" key
//        // [asset loadValuesAsynchronouslyForKeys:@[@"playable"] completionHandler:^{
//        //     NSError *error = nil;
//        //     AVKeyValueStatus status =
//        //         [asset statusOfValueForKey:@"playable" error:&error];
//        //     switch (status) {
//        //     case AVKeyValueStatusLoaded:
//        //         // Sucessfully loaded, continue processing
//        //         break;
//        //     case AVKeyValueStatusFailed:
//        //         // Examine NSError pointer to determine failure
//        //         break;
//        //     case AVKeyValueStatusCancelled:
//        //         // Loading cancelled
//        //         break;
//        //     default:
//        //         // Handle all other cases
//        //         break;
//        //     }
//        // }];
//        
//        //AVAsynchronousKeyValueLoading
//        
//        detailView.backgroundColor = newValue.backgroundColor
//        detailView.image = newValue.browseImage?.withOrientation(orientation)
//        containerView.contentSize = newValue.browseContentSize
//        containerView.zoom(to: bounds, with: orientation, animated: false)
//        //containerView.setZoomScale(containerView.maximumZoomScale, animated: false)
//        
//        _updateType(newValue.browseType, animated: false)
//        _updateSubtype(newValue.browseSubtype, animated: false)
//        
//        //_updateProgress(0.25, force: false, animated: false)
//        _updateProgress(-1, force: false, animated: false)
//        //DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
//        //    self._updateProgress(0.35, animated: true)
//        //    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
//        //        self._updateProgress(0.65, animated: true)
//        //        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
//        //            self._updateProgress(1.00, animated: true)
//        //        })
//        //    })
//        //})
//    }
//    
//    
//    fileprivate var _asset: Browseable?
//    
//    // MARK: Value
//    
//    fileprivate func _updateType(_ type: IBAssetType, animated: Bool) {
//        guard _type != type else {
//            _consoleView.stop()
//            _consoleView.updateFocus(true, animated: animated)
//            return
//        }
//        _type = type
//        if _type == .video {
//            if _consoleView.superview != self {
//                addSubview(_consoleView)
//            }
//            _consoleView.stop()
//            _consoleView.updateFocus(true, animated: animated)
//        } else {
//            if _consoleView.superview != nil {
//                _consoleView.removeFromSuperview()
//            }
//            _consoleView.stop()
//            _consoleView.updateFocus(false, animated: animated)
//        }
//    }
//    fileprivate func _updateSubtype(_ subtype: IBAssetSubtype, animated: Bool) {
//        guard _subtype != subtype else {
//            return // no change
//        }
//        _subtype = subtype
//        if _subtype != .unknow {
//            if _typeView.superview != self {
//                _typeView.alpha = 0
//                addSubview(_typeView)
//            }
//            // 更新icon和布局
//            _updateIconLayoutIfNeeded()
//            guard _typeView.alpha < 1 else {
//                return
//            }
//            UIView.ib_animate(withDuration: 0.25, animated: animated, animations: {
//                self._typeView.alpha = 1
//            })
//        } else {
//            // 更新icon和布局
//            _updateIconLayoutIfNeeded()
//            guard _typeView.superview != nil else {
//                return
//            }
//            UIView.ib_animate(withDuration: 0.25, animated: animated, animations: {
//
//                self._typeView.alpha = 0
//
//            }, completion: { isFinished in
//                guard isFinished else {
//                    return
//                }
//                self._typeView.alpha = 1
//                self._typeView.removeFromSuperview()
//            })
//        }
//    }
//    fileprivate func _updateProgress(_ progress: Double, force: Bool? = nil, animated: Bool) {
//        guard _progressOfLock == nil else {
//            // is lock
//            _progressOfLock = progress
//            return
//        }
//        let full = progress > 0.999999 // progress >= 1.0(±0.000001)
//        let view = _progressView
//        
//        let oldProgress = _progress
//        let oldHidden = _progressOfHidden
//        let newProgress = progress
//        let newHidden = (force ?? full) || full
//        
//        guard newProgress != oldProgress || newHidden != oldHidden else {
//            return // no change
//        }
//        _progress = newProgress
//        _progressOfHidden = newHidden
//        
//        if (newProgress != view.progress || !newHidden) && view.superview == nil {
//            addSubview(view)
//        }
//        _updateProgressLayoutIfNeeded()
//        
//        guard animated else {
//            view.setProgress(newProgress, animated: false)
//            if newHidden {
//                view.alpha = 0
//                view.removeFromSuperview()
//            } else {
//                view.alpha = 1
//            }
//            return
//        }
//        
//        // show if need
//        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
//            guard newProgress != oldProgress || !newHidden else {
//                return
//            }
//            view.alpha = 1
//        }, completion: { isFinish in
//            var delay: TimeInterval = 0.35
//            // set if need
//            if newProgress == oldProgress {
//                delay = 0
//            }
//            view.setProgress(newProgress, animated: true)
//            // hidden if need
//            UIView.animate(withDuration: 0.25, delay: delay, options: .curveLinear, animations: {
//                guard view.progress > 0.999999 || newHidden else {
//                    return
//                }
//                view.alpha = 0
//            }, completion: { isFinish in
//                guard isFinish else {
//                    return
//                }
//                guard view.progress > 0.999999 || self._progressOfHidden else {
//                    return
//                }
//                view.removeFromSuperview()
//            })
//        })
//    }
//    
//    // MARK: Layout & Auto Lock
//    
//    fileprivate func _updateConsoleLock(_ lock: Bool, animated: Bool) {
//        guard _consoleOfLock != lock && !_progressOfHidden else {
//            return
//        }
//        _consoleOfLock = lock
//        _consoleView.updateFocus(!lock, animated: animated)
//    }
//    fileprivate func _updateProgressLock(_ lock: Bool, animated: Bool) {
//        if lock {
//            // 锁定
//            let progress = _progress
//            _updateProgress(progress, force: true, animated: animated)
//            _progressOfLock = progress
//        } else {
//            // 解锁, 并尝试恢复
//            let progress = _progressOfLock ?? _progress
//            _progressOfLock = nil
//            _updateProgress(progress, force: false, animated: animated)
//        }
//    }
//    
//    fileprivate func _updateIconLayoutIfNeeded() {
//        guard _typeView.superview != nil else {
//            return
//        }
//        let edg = _containerInset
//        let bounds = UIEdgeInsetsInsetRect(self.bounds, contentInset)
//       
//        var nframe = _typeView.frame
//        nframe.origin.x = bounds.minX + edg.left
//        nframe.origin.y = bounds.minY + edg.top
//        nframe.size.height = 27
//        _typeView.frame = nframe
//    }
//    fileprivate func _updateConsoleLayoutIfNeeded() {
//        guard _consoleView.superview != nil else {
//            return
//        }
//        _consoleView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
//    }
//    fileprivate func _updateProgressLayoutIfNeeded() {
//        guard !_progressOfHidden else {
//            return
//        }
//        //logger.debug(containerView.contentSize)
//        
//        let edg = _containerInset
//        let size = _progressView.frame.size
//        let frame = convert(detailView.frame, from: detailView.superview)
//        let bounds = UIEdgeInsetsInsetRect(self.bounds, contentInset)
//        
//        let y2 = min(frame.maxY, bounds.maxY)
//        let x2 = min(max(frame.maxX, min(max(frame.minX, bounds.minX) + frame.width, bounds.maxX)), bounds.maxX)
//        
//        _progressView.center = CGPoint(x: x2 - size.width / 2 - edg.right, y: y2 - size.height / 2 - edg.bottom)
//    }
//    
//    // MARK: Init
//    
//    private func _commonInit() {
//        
//    }
//    
//    // MARK: Ivar
//    
//    private var _cachedBounds: CGRect?
//    
//    private var _containerInset: UIEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
//    
//    private var _type: IBAssetType = .unknow
//    private var _subtype: IBAssetSubtype = .unknow
//    
//    private var _consoleOfLock: Bool = false
//    
//    private var _progress: Double = 0
//    private var _progressOfLock: Double?
//    private var _progressOfHidden: Bool = true
//    
//    fileprivate lazy var _typeView = UIButton(type: .system)
//    fileprivate lazy var _consoleView = IBVideoConsoleView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
//    fileprivate lazy var _progressView = IBOverlayProgressView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
    
    public var draggingContentOffset: CGPoint?
    
    fileprivate var _contentSize: CGSize = .zero
    
    private var _detailView: UIView?
    private var _containerView: CanvasView?
    
}

/// custom transition support
extension BrowserDetailCell: TransitioningView {
    
    internal var ub_frame: CGRect {
        guard let containerView = containerView, let detailView = detailView else {
            return .zero
        }
        let center = containerView.convert(detailView.center, from: detailView.superview)
        let bounds = detailView.frame.applying(.init(rotationAngle: orientation.ub_angle))
        
        let c1 = containerView.convert(center, to: window)
        let b1 = containerView.convert(bounds, to: window)
        
        return .init(x: c1.x - b1.width / 2, y: c1.y - b1.height / 2, width: b1.width, height: b1.height)
    }
    internal var ub_bounds: CGRect {
        guard let detailView = detailView else {
            return .zero
        }
        let bounds = detailView.frame.applying(.init(rotationAngle: orientation.ub_angle))
        return .init(origin: .zero, size: bounds.size)
    }
    internal var ub_transform: CGAffineTransform {
        guard let containerView = containerView else {
            return .identity
        }
        return containerView.contentTransform.rotated(by: orientation.ub_angle)
    }
    internal func ub_snapshotView(afterScreenUpdates: Bool) -> UIView? {
//        let view = detailView?.snapshotView(afterScreenUpdates: afterScreenUpdates)
//        view?.transform = .init(rotationAngle: -orientation.ub_angle)
//        return view
        guard let detailView = detailView else {
            return nil
        }
        let imageView = UIImageView(frame: detailView.frame)
        if let x = detailView as? UIImageView {
            imageView.image = x.image
        }
        imageView.transform = .init(rotationAngle: -orientation.ub_angle)
        return imageView
    }
}

/// dynamic class support
internal extension BrowserDetailCell {
    // dynamically generated class
    internal dynamic class func `dynamic`(with viewClass: AnyClass) -> AnyClass {
        let name = "\(NSStringFromClass(self))<\(NSStringFromClass(viewClass))>"
        // if the class has been registered, ignore
        if let newClass = objc_getClass(name) as? AnyClass {
            return newClass
        }
        // if you have not registered this, dynamically generate it
        let newClass: AnyClass = objc_allocateClassPair(self, name, 0)
        let method: Method = class_getClassMethod(self, #selector(getter: detailViewClass))
        objc_registerClassPair(newClass)
        // because it is a class method, it can not used class, need to use meta class
        guard let metaClass = objc_getMetaClass(name) as? AnyClass else {
            return newClass
        }
        let getter: @convention(block) () -> AnyClass = {
            return viewClass
        }
        // add class method
        class_addMethod(metaClass, #selector(getter: detailViewClass), imp_implementationWithBlock(unsafeBitCast(getter, to: AnyObject.self)), method_getTypeEncoding(method))
        return newClass
    }
    // provide content view of class
    internal dynamic class var contentViewClass: AnyClass {
        return CanvasView.self
    }
    // provide detail view of class
    internal dynamic class var detailViewClass: AnyClass {
        return UIView.self
    }
    // provide content view of class, iOS 8+
    fileprivate dynamic class var _contentViewClass: AnyClass {
        return contentViewClass
    }
}

/// canvas view support
extension BrowserDetailCell: CanvasViewDelegate {
    
    func viewForZooming(in canvasView: CanvasView) -> UIView? {
        return detailView
    }
    
    func canvasViewDidScroll(_ canvasView: CanvasView) {
        logger.trace?.write(canvasView.contentOffset, canvasView.isDecelerating, canvasView.isDragging, canvasView.isTracking)
        
//        _updateProgressLayoutIfNeeded()
    }
    func canvasViewDidZoom(_ canvasView: CanvasView) {
//        _updateProgressLayoutIfNeeded()
    }
    
    func canvasViewWillEndDragging(_ canvasView: CanvasView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        logger.trace?.write(targetContentOffset.move())
        draggingContentOffset = targetContentOffset.move()
    }
    
    func canvasViewWillBeginDragging(_ canvasView: CanvasView) {
        // at the start of the clear, prevent invalid content offset
        draggingContentOffset = nil
//        _updateConsoleLock(true, animated: true)
    }
    func canvasViewWillBeginZooming(_ canvasView: CanvasView, with view: UIView?) {
//        _updateConsoleLock(true, animated: true)
    }
    func canvasViewShouldBeginRotationing(_ canvasView: CanvasView, with view: UIView?) -> Bool {
//        guard delegate?.browseDetailView?(self, canvasView, shouldBeginRotationing: view) ?? true else {
//            return false
//        }
//        
//        _updateConsoleLock(true, animated: true)
//        _updateProgressLock(true, animated: false)
//        
        return true
    }
    
    func canvasViewDidEndDecelerating(_ canvasView: CanvasView) {
        // clear, is end decelerate
        draggingContentOffset = nil
//        _updateConsoleLock(false, animated: true)
    }
    func canvasViewDidEndDragging(_ canvasView: CanvasView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        // clear, is end dragg but no decelerat
        draggingContentOffset = nil
//        _updateConsoleLock(false, animated: true)
    }
    func canvasViewDidEndZooming(_ canvasView: CanvasView, with view: UIView?, atScale scale: CGFloat) {
//        _updateConsoleLock(false, animated: true)
    }
    func canvasViewDidEndRotationing(_ canvasView: CanvasView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
        // update content orientation
        self.orientation = orientation
        if let imageView = detailView as? UIImageView {
            imageView.image = imageView.image?.withOrientation(orientation)
        }
//
//        delegate?.browseDetailView?(self, canvasView, didEndRotationing: view, atOrientation: orientation)
//        
//        _updateProgressLock(false, animated: true)
//        _updateConsoleLock(false, animated: true)
    }
}

//extension BrowserDetailCell: IBVideoConsoleViewDelegate {
//    
//    func progressView(willRetry sender: Any) {
//        _logger.debug()
//        
//        _updateProgress(0, animated: false)
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
//            self._updateProgress(0.25, animated: true)
//        })
//    }
//    
//    func videoConsoleView(didPlay videoConsoleView: IBVideoConsoleView) {
//        videoConsoleView.wait()
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
//            videoConsoleView.play()
//        })
//    }
//    func videoConsoleView(didStop videoConsoleView: IBVideoConsoleView) {
//        videoConsoleView.stop()
//    }
//}
//
//extension BrowserDetailCell: ScrollViewDelegate {
//   
//}

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
