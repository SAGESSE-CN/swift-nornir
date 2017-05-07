//
//  BrowserDetailCell.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserDetailCell: UICollectionViewCell, Displayable {
    
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
    var draggingContentOffset: CGPoint? {
        return _draggingContentOffset
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // update utility view
        _progress?.center = _progressCenter
        _console?.center = _consoleCenter
    }
    
    ///
    /// display container content with item
    ///
    /// - parameter item: need display the item
    /// - parameter orientation: need display the orientation
    ///
    func display(with item: Item, orientation: UIImageOrientation) {
        logger.trace?.write(item.size)
        
        // update ata
        _item = item
        _orientation = orientation
        
        // update canvas view
        _containerView?.contentSize = item.size
        _containerView?.zoom(to: bounds , with: orientation, animated: false)
        
        // update util view
        _progress?.setValue(1.000, animated: false)
        _console?.setState(.stop, animated: false)
        
        // update content
        (_detailView as? Displayable)?.display(with: item, orientation: orientation)
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
            
            // If the detail to support the operation, set the operation delegate
            (_detailView as? Operable)?.delegate = self
        }
        // setup console
        _console = ConsoleProxy(frame: .init(x: 0, y: 0, width: 70, height: 70), owner: self)
        _console?.addTarget(self, action: #selector(handleCommand(_:)), for: .touchUpInside)
        // setup progress
        _progress = ProgressProxy(frame: .init(x: 0, y: 0, width: 24, height: 24), owner: self)
        _progress?.addTarget(self, action: #selector(handleRetry(_:)), for: .touchUpInside)
    }
    
    // data
    fileprivate var _item: Item?
    fileprivate var _orientation: UIImageOrientation = .up
    
    // config
    fileprivate var _contentInset: UIEdgeInsets = .zero
    fileprivate var _indicatorInset: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
    fileprivate var _draggingContentOffset: CGPoint?
    
    // state
    fileprivate var _isZooming: Bool = false
    fileprivate var _isDragging: Bool = false
    fileprivate var _isRotationing: Bool = false
    
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


/// event support
extension BrowserDetailCell {
    
    fileprivate dynamic func handleRetry(_ sender: Any) {
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
    fileprivate dynamic func handleCommand(_ sender: Any) {
        logger.trace?.write()
        
        // if is stopped, click goto prepare
        if _console?.state == .stop {
            // check the data
            guard let item = _item else {
                return
            }
            // update the status for waiting
            _console?.setState(.waiting, animated: true)
            // prepare player
            (_detailView as? Operable)?.prepare(with: item)
        }
    }
    
    fileprivate dynamic func handleTap(_ sender: UITapGestureRecognizer) {
        logger.trace?.write()
    }
    fileprivate dynamic func handleDoubleTap(_ sender: UITapGestureRecognizer) {
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
        _draggingContentOffset = targetContentOffset.move()
    }
    
    func canvasViewWillBeginDragging(_ canvasView: CanvasView) {
        logger.trace?.write()
        // update canvas view status
        _isDragging = true
        // update console status
        _console?.setIsHidden(true, animated: true)
        // at the start of the clear, prevent invalid content offset
        _draggingContentOffset = nil
    }
    func canvasViewWillBeginZooming(_ canvasView: CanvasView, with view: UIView?) {
        logger.trace?.write()
        // update canvas view status
        _isZooming = true
        // update console status
        _console?.setIsHidden(true, animated: true)
    }
    func canvasViewShouldBeginRotationing(_ canvasView: CanvasView, with view: UIView?) -> Bool {
        logger.trace?.write()
        // if the item is nil, are not allowed to rotate
        guard let _ = _item else {
            return false
        }
        // update canvas view status
        _isRotationing = true
        // update progress status
        _progress?.center = _progressCenter
        _progress?.setIsHidden(true, animated: false)
        // update console status
        _console?.setIsHidden(true, animated: true)
        
        // delegate?.browseDetailView?(self, canvasView, shouldBeginRotationing: view) ?? true
        return true
    }
    
    func canvasViewDidEndDecelerating(_ canvasView: CanvasView) {
        logger.trace?.write()
        // update canvas view status
        _isDragging = false
        // if is rotationing, delay update
        if !_isRotationing {
            _console?.setIsHidden(false, animated: true)
        }
        // clear, is end decelerate
        _draggingContentOffset = nil
    }
    func canvasViewDidEndDragging(_ canvasView: CanvasView, willDecelerate decelerate: Bool) {
        logger.trace?.write()
        // if you are slow, delay processing
        guard !decelerate else {
            return
        }
        // update canvas view status
        _isDragging = false
        // if is rotationing, delay update
        if !_isRotationing {
            _console?.setIsHidden(false, animated: true)
        }
        // clear, is end dragg but no decelerat
        _draggingContentOffset = nil
    }
    func canvasViewDidEndZooming(_ canvasView: CanvasView, with view: UIView?, atScale scale: CGFloat) {
        logger.trace?.write()
        // update canvas view status
        _isZooming = false
        // if is rotationing, delay update
        if !_isRotationing {
            _console?.setIsHidden(false, animated: true)
        }
    }
    func canvasViewDidEndRotationing(_ canvasView: CanvasView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
        logger.trace?.write()
        // if the item is nil, are not allowed to rotate
        guard let item = _item else {
            return
        }
        // update canvas view status
        _isRotationing = false
        // update content orientation
        _orientation = orientation
        (_detailView as? Displayable)?.display(with: item, orientation: orientation)
        // update progress
        _progress?.center = _progressCenter
        _progress?.setIsHidden(false, animated: true)
        
        // update console status
        _console?.setIsHidden(false, animated: true)
        
        // delegate?.browseDetailView?(self, canvasView, didEndRotationing: view, atOrientation: orientation)
    }
}

/// custom transition support
extension BrowserDetailCell: TransitioningView {
    
    var ub_frame: CGRect {
        guard let containerView = _containerView, let detailView = _detailView else {
            return .zero
        }
        let center = containerView.convert(detailView.center, from: detailView.superview)
        let bounds = detailView.frame.applying(.init(rotationAngle: _orientation.ub_angle))
        
        let c1 = containerView.convert(center, to: window)
        let b1 = containerView.convert(bounds, to: window)
        
        return .init(x: c1.x - b1.width / 2, y: c1.y - b1.height / 2, width: b1.width, height: b1.height)
    }
    var ub_bounds: CGRect {
        guard let detailView = detailView else {
            return .zero
        }
        let bounds = detailView.frame.applying(.init(rotationAngle: _orientation.ub_angle))
        return .init(origin: .zero, size: bounds.size)
    }
    var ub_transform: CGAffineTransform {
        guard let containerView = containerView else {
            return .identity
        }
        return containerView.contentTransform.rotated(by: _orientation.ub_angle)
    }
    func ub_snapshotView(with context: TransitioningContext) -> UIView? {
        let view = _detailView?.snapshotView(afterScreenUpdates: context.ub_operation.appear)
        view?.transform = .init(rotationAngle: -_orientation.ub_angle)
        return view
    }
    
    func ub_transitionDidStart(_ context: TransitioningContext) {
        logger.trace?.write(context.ub_operation)
        
        // restore util view status
        _console?.setIsHidden(true, animated: false)
        _progress?.setIsHidden(true, animated: false)
    }
    func ub_transitionDidEnd(_ didComplete: Bool) {
        logger.trace?.write(didComplete)
        
        // restore util view status
        _console?.setIsHidden(false, animated: true)
        _progress?.setIsHidden(false, animated: true)
    }
}

/// operation support
extension BrowserDetailCell: OperableDelegate {
    
    func operable(didPrepare operable: Operable, item: Item) {
        logger.trace?.write()
        
        operable.play()
    }
    func operable(didStartPlay operable: Operable, item: Item) {
        logger.trace?.write()
        
        _console?.setState(.playing, animated: true)
    }
    func operable(didStop operable: Operable, item: Item) {
        logger.trace?.write()
        
        _console?.setState(.stop, animated: true)
    }
    
    func operable(didStalled operable: Operable, item: Item) {
        logger.trace?.write()
        
        _console?.setState(.waiting, animated: true)
    }
    func operable(didSuspend operable: Operable, item: Item) {
        logger.trace?.write()
        // nothing
    }
    func operable(didResume operable: Operable, item: Item) {
        logger.trace?.write()
        
        _console?.setState(.playing, animated: true)
    }
    
    func operable(didFinish operable: Operable, item: Item) {
        logger.trace?.write()
        
        _console?.setState(.stop, animated: true)
    }
    func operable(didOccur operable: Operable, item: Item, error: Error?) {
        logger.trace?.write()
        
        _console?.setState(.stop, animated: true)
    }
}
