//
//  BrowserDetailCell.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserDetailCell: UICollectionViewCell, ItemContainer {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
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
    
    ///
    /// update container content with item
    ///
    /// - parameter item: resource abstract of item
    ///
    func apply(with item: Item) {
        logger.trace?.write(item.size)
        
        // update canvas
        containerView?.contentSize = item.size
        containerView?.zoom(to: bounds , with: orientation, animated: false)
        
        // update init state
        _progress?.setValue(-1, animated: false)
        _console?.setState(.stop, animated: false)
        
        // update content
        (detailView as? ItemContainer)?.apply(with: item)
    }
    ///
    /// update container content inset
    ///
    /// - parameter contentInset: new content inset
    ///
    func apply(with contentInset: UIEdgeInsets) {
        logger.trace?.write(contentInset)
        
        _contentInset = contentInset
        
        // need update layout
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
        
        // update utility view
        _progress?.center = _progressCenter
        _console?.center = _consoleCenter
    }
    
    private func _setup() {
        
        // make detail & container view
        _detailView = (type(of: self).detailViewClass as? UIView.Type)?.init()
        _containerView = contentView as? CanvasView
        
        // setup container view if needed
        if let containerView = _containerView {
            containerView.delegate = self
            // add tap recognizer
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            
            doubleTapRecognizer.numberOfTapsRequired = 2
            tapRecognizer.numberOfTapsRequired = 1
            tapRecognizer.require(toFail: doubleTapRecognizer)
            
            containerView.addGestureRecognizer(doubleTapRecognizer)
            containerView.addGestureRecognizer(tapRecognizer)
        }
        // setup detail view if needed
        if let detailView = _detailView {
            _detailView = detailView
            _containerView?.addSubview(detailView)
            // set default background color
            _detailView?.backgroundColor = Browser.ub_backgroundColor
        }
        // setup console
        _console = ConsoleProxy(frame: .init(x: 0, y: 0, width: 70, height: 70), owner: self)
        _console?.addTarget(self, action: #selector(handleCommand(_:)), for: .touchUpInside)
        // setup progress
        _progress = ProgressProxy(frame: .init(x: 0, y: 0, width: 24, height: 24), owner: self)
        _progress?.addTarget(self, action: #selector(handleRetry(_:)), for: .touchUpInside)
    }
    
    dynamic func handleRetry(_ sender: Any) {
        logger.trace?.write()
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
    dynamic func handleCommand(_ sender: Any) {
        logger.trace?.write()
        
        self._console?.setState(.waiting, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self._console?.setState(.playing, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
                self._console?.setState(.stop, animated: true)
            })
        })
    }
    dynamic func handleTap(_ sender: UITapGestureRecognizer) {
        logger.trace?.write()
    }
    dynamic func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        logger.trace?.write()
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
    
    var draggingContentOffset: CGPoint?
    
    // config
    fileprivate var _contentInset: UIEdgeInsets = .zero
    fileprivate var _indicatorInset: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
    
    // content
    fileprivate var _detailView: UIView?
    fileprivate var _containerView: CanvasView?
    
    // progress
    fileprivate var _progress: ProgressProxy?
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
    
    // console
    fileprivate var _console: ConsoleProxy?
    fileprivate var _consoleCenter: CGPoint {
        return .init(x: bounds.midX,
                     y: bounds.midY)
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
    func ub_snapshotView(with context: TransitioningContext) -> UIView? {
        let view = detailView?.snapshotView(afterScreenUpdates: context.ub_operation.appear)
        view?.transform = .init(rotationAngle: -orientation.ub_angle)
        return view
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
        
        // update console status
        _console?.setIsHidden(true, animated: true)
    }
    func canvasViewWillBeginZooming(_ canvasView: CanvasView, with view: UIView?) {
        logger.trace?.write()
        
        // update console status
        _console?.setIsHidden(true, animated: true)
    }
    func canvasViewShouldBeginRotationing(_ canvasView: CanvasView, with view: UIView?) -> Bool {
        logger.trace?.write()
        
//        guard delegate?.browseDetailView?(self, canvasView, shouldBeginRotationing: view) ?? true else {
//            return false
//        }
        
        // update progress status
        _progress?.center = _progressCenter
        _progress?.setIsHidden(true, animated: false)
        
        // update console status
        _console?.setIsHidden(true, animated: true)
        
        return true
    }
    
    func canvasViewDidEndDecelerating(_ canvasView: CanvasView) {
        logger.trace?.write()
        // clear, is end decelerate
        draggingContentOffset = nil
        
        // if progress is hidden, delay update
        guard !(_progress?.isHidden ?? false) else {
            return
        }
        _console?.setIsHidden(false, animated: true)
    }
    func canvasViewDidEndDragging(_ canvasView: CanvasView, willDecelerate decelerate: Bool) {
        logger.trace?.write()
        // if you are slow, delay processing
        guard !decelerate else {
            return
        }
        // clear, is end dragg but no decelerat
        draggingContentOffset = nil
        
        // if progress is hidden, delay update
        guard !(_progress?.isHidden ?? false) else {
            return
        }
        _console?.setIsHidden(false, animated: true)
    }
    func canvasViewDidEndZooming(_ canvasView: CanvasView, with view: UIView?, atScale scale: CGFloat) {
        logger.trace?.write()
        
        // if progress is hidden, delay update
        guard !(_progress?.isHidden ?? false) else {
            return
        }
        _console?.setIsHidden(false, animated: true)
    }
    func canvasViewDidEndRotationing(_ canvasView: CanvasView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
        logger.trace?.write()
        // update content orientation
        self.orientation = orientation
        if let imageView = detailView as? UIImageView {
            imageView.image = imageView.image?.ub_withOrientation(orientation)
        }
        // update progress
        _progress?.center = _progressCenter
        _progress?.setIsHidden(false, animated: true)
        
        // update console status
        _console?.setIsHidden(false, animated: true)
        
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

