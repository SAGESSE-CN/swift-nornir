//
//  BrowserDetailCell.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserDetailCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    var detailView: UIView? {
        return _detailView
    }
    var containerView: CanvasView? {
        return _containerView
    }
    
    var orientation: UIImageOrientation = .up
    //var orientation: UIImageOrientation = .left
    //var orientation: UIImageOrientation = .right
    //var orientation: UIImageOrientation = .down
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func apply(for item: Item) {
        logger.trace?.write(item.size)
        
        containerView?.contentSize = item.size
        containerView?.zoom(to: bounds , with: orientation, animated: false)
        
        if let imageView = detailView as? UIImageView {
            imageView.image = item.image?.withOrientation(orientation)
        }
        _contentSize = item.size
        
        _progress?.setValue(-1, animated: false)
    }
    func apply(for contentInset: UIEdgeInsets) {
        logger.trace?.write(contentInset)
        
        _contentInset = contentInset
        
        setNeedsLayout()
    }
    
//    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        if _cachedBounds != bounds {
//            _cachedBounds = bounds
//            // update the utility view layout
//            updateConsoleViewLayout()
//            //_updateIconLayoutIfNeeded()
//            //_updateConsoleLayoutIfNeeded()
//        }
        
        // update progress layout
        _progress?.center = _progressCenter
    }
    
    func setup() {
        
        // make detail & container view
        _detailView = (type(of: self).detailViewClass as? UIView.Type)?.init()
        _containerView = contentView as? CanvasView
        
        // setup container view if needed
        if let containerView = _containerView {
            containerView.delegate = self
            // add double tap recognizer
            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            doubleTapRecognizer.numberOfTapsRequired = 2
            containerView.addGestureRecognizer(doubleTapRecognizer)
        }
        // setup detail view if needed
        if let detailView = _detailView {
            _detailView = detailView
            _containerView?.addSubview(detailView)
            // set default background color
            _detailView?.backgroundColor = Browser.ub_backgroundColor
        }
        // setup progress view 
        _progress = Progress(frame: .init(x: 0, y: 0, width: 24, height: 24), owner: self)
        _progress?.addTarget(self, action: #selector(handleRetry(_:)))
        
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
    }
    
    dynamic func handleRetry(_ sender: Any) {
        self._progress?.setValue(0, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self._progress?.setValue(0.35, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self._progress?.setValue(0.65, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                    self._progress?.setValue(1.00, animated: true)
                })
            })
        })
    }
    dynamic func handleDoubleTap(_ sender: UITapGestureRecognizer) {
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
//
//    // MARK: Ivar
//
//    private var _cachedBounds: CGRect?
//
//    private var _type: IBAssetType = .unknow
//    private var _subtype: IBAssetSubtype = .unknow
//    
//    private var _consoleOfLock: Bool = false
//
//    fileprivate lazy var _typeView = UIButton(type: .system)
//    fileprivate lazy var _consoleView = IBVideoConsoleView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
    
    internal var draggingContentOffset: CGPoint?
    
    // content
    fileprivate var _contentSize: CGSize = .zero
    fileprivate var _contentInset: UIEdgeInsets = .zero
    fileprivate var _indicatorInset: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
    fileprivate var _containerView: CanvasView?
    fileprivate var _detailView: UIView?
    
    // progress
    fileprivate var _progress: Progress?
    fileprivate var _progressCenter: CGPoint {
        // If no progress or detailview center is zero
        guard let detailView = detailView, let progress = _progress else {
            return .zero
        }
        let rect1 = convert(detailView.bounds, from: detailView)
        let rect2 = UIEdgeInsetsInsetRect(bounds, _contentInset)
        
        let x = min(max(rect1.maxX, min(max(rect1.minX, rect2.minX) + rect1.width, rect2.maxX)), rect2.maxX)
        let y = min(rect1.maxY, rect2.maxY)
        
        return .init(x: x - _indicatorInset.right - progress.bounds.midX,
                     y: y - _indicatorInset.bottom - progress.bounds.midY)
    }
}


/// layout support
extension BrowserDetailCell {
    
    func updateConsole() {
    }
    func updateConsoleView(_ isLock: Bool, animated: Bool) {
//        logger.trace?.write(isLock, animated)
    }
    func updateConsoleViewLayout() {
//        logger.trace?.write()
    }
}

/// custom transition support
extension BrowserDetailCell: TransitioningView {
    
    var ub_frame: CGRect {
        guard let containerView = containerView, let detailView = detailView else {
            return .zero
        }
        let center = containerView.convert(detailView.center, from: detailView.superview)
        let bounds = detailView.frame.applying(.init(rotationAngle: orientation.ub_angle))
        
        let c1 = containerView.convert(center, to: window)
        let b1 = containerView.convert(bounds, to: window)
        
        return .init(x: c1.x - b1.width / 2, y: c1.y - b1.height / 2, width: b1.width, height: b1.height)
    }
    var ub_bounds: CGRect {
        guard let detailView = detailView else {
            return .zero
        }
        let bounds = detailView.frame.applying(.init(rotationAngle: orientation.ub_angle))
        return .init(origin: .zero, size: bounds.size)
    }
    var ub_transform: CGAffineTransform {
        guard let containerView = containerView else {
            return .identity
        }
        return containerView.contentTransform.rotated(by: orientation.ub_angle)
    }
    func ub_snapshotView(afterScreenUpdates: Bool) -> UIView? {
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
        imageView.backgroundColor = detailView.backgroundColor
        imageView.transform = .init(rotationAngle: -orientation.ub_angle)
        return imageView
    }
}

/// dynamic class support
extension BrowserDetailCell {
    // dynamically generated class
    dynamic class func `dynamic`(with viewClass: AnyClass) -> AnyClass {
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
    dynamic class var contentViewClass: AnyClass {
        return CanvasView.self
    }
    // provide detail view of class
    dynamic class var detailViewClass: AnyClass {
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
        //logger.trace?.write(canvasView.contentOffset, canvasView.isDecelerating, canvasView.isDragging, canvasView.isTracking)
        
        // update progress
        _progress?.center = _progressCenter
    }
    func canvasViewDidZoom(_ canvasView: CanvasView) {
        
        // update progress
        _progress?.center = _progressCenter
    }
    
    func canvasViewWillEndDragging(_ canvasView: CanvasView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        logger.trace?.write()
        // record the content offset of the end
        draggingContentOffset = targetContentOffset.move()
    }
    
    func canvasViewWillBeginDragging(_ canvasView: CanvasView) {
        logger.trace?.write()
        // at the start of the clear, prevent invalid content offset
        draggingContentOffset = nil
        
//        // update the utility view status
//        updateConsoleView(true, animated: true)
    }
    func canvasViewWillBeginZooming(_ canvasView: CanvasView, with view: UIView?) {
        logger.trace?.write()
        
//        // update the utility view status
//        updateConsoleView(true, animated: true)
    }
    func canvasViewShouldBeginRotationing(_ canvasView: CanvasView, with view: UIView?) -> Bool {
        logger.trace?.write()
        
//        guard delegate?.browseDetailView?(self, canvasView, shouldBeginRotationing: view) ?? true else {
//            return false
//        }
        
        // update progress
        _progress?.center = _progressCenter
        _progress?.setIsHidden(true, animated: false)
        
        return true
    }
    
    func canvasViewDidEndDecelerating(_ canvasView: CanvasView) {
        logger.trace?.write()
        // clear, is end decelerate
        draggingContentOffset = nil
        
//        // update the utility view status
//        updateConsoleView(false, animated: true)
    }
    func canvasViewDidEndDragging(_ canvasView: CanvasView, willDecelerate decelerate: Bool) {
        logger.trace?.write()
        guard !decelerate else {
            return
        }
        // clear, is end dragg but no decelerat
        draggingContentOffset = nil
        // update the utility view status
        updateConsoleView(false, animated: true)
    }
    func canvasViewDidEndZooming(_ canvasView: CanvasView, with view: UIView?, atScale scale: CGFloat) {
        logger.trace?.write()
        // update the utility view status
        updateConsoleView(false, animated: true)
    }
    func canvasViewDidEndRotationing(_ canvasView: CanvasView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
        logger.trace?.write()
        // update content orientation
        self.orientation = orientation
        if let imageView = detailView as? UIImageView {
            imageView.image = imageView.image?.withOrientation(orientation)
        }
        // update progress
        _progress?.center = _progressCenter
        _progress?.setIsHidden(false, animated: true)
        
//        updateConsoleView(false, animated: true)
//        delegate?.browseDetailView?(self, canvasView, didEndRotationing: view, atOrientation: orientation)
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
