//
//  CanvasView.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

@objc public protocol CanvasViewDelegate {
    
    @objc optional func canvasViewDidScroll(_ canvasView: CanvasView) /// any offset changes
    @objc optional func canvasViewDidZoom(_ canvasView: CanvasView) /// any zoom scale changes
    @objc optional func canvasViewDidRotation(_ canvasView: CanvasView) /// any rotation changes
    
    @objc optional func viewForZooming(in canvasView: CanvasView) -> UIView? /// return a view that will be scaled. if delegate returns nil, nothing happens
    
    /// called on start of dragging (may require some time and or distance to move)
    @objc optional func canvasViewWillBeginDragging(_ canvasView: CanvasView)
    
    /// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    @objc optional func canvasViewWillEndDragging(_ canvasView: CanvasView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    
    /// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    @objc optional func canvasViewDidEndDragging(_ canvasView: CanvasView, willDecelerate decelerate: Bool)
    
    @objc optional func canvasViewWillBeginDecelerating(_ canvasView: CanvasView) /// called on finger up as we are moving
    @objc optional func canvasViewDidEndDecelerating(_ canvasView: CanvasView) /// called when scroll view grinds to a halt
    
    @objc optional func canvasViewDidEndScrollingAnimation(_ canvasView: CanvasView) /// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    
    @objc optional func canvasViewShouldScrollToTop(_ canvasView: CanvasView) -> Bool /// return a yes if you want to scroll to the top. if not defined, assumes YES
    @objc optional func canvasViewDidScrollToTop(_ canvasView: CanvasView) /// called when scrolling animation finished. may be called immediately if already at top
    
    @objc optional func canvasViewWillBeginZooming(_ canvasView: CanvasView, with view: UIView?) /// called before the scroll view begins zooming its content
    @objc optional func canvasViewDidEndZooming(_ canvasView: CanvasView, with view: UIView?, atScale scale: CGFloat) /// scale between minimum and maximum. called after any 'bounce' animations
    
    @objc optional func canvasViewShouldBeginRotationing(_ canvasView: CanvasView, with view: UIView?) -> Bool /// called before the scroll view begins zooming its content
    @objc optional func canvasViewWillEndRotationing(_ canvasView: CanvasView, with view: UIView?, atOrientation orientation: UIImageOrientation)
    @objc optional func canvasViewDidEndRotationing(_ canvasView: CanvasView, with view: UIView?, atOrientation orientation: UIImageOrientation) /// scale between minimum and maximum. called after any 'bounce' animations
}


@objc public class CanvasView: UIView {
    
    public weak var delegate: CanvasViewDelegate?
    
    /// default CGPointZero
    public var contentOffset: CGPoint {
        set { return _containterView.contentOffset = newValue }
        get { return _containterView.contentOffset }
    }
    /// default CGSizeZero
    public var contentSize: CGSize = .zero
    /// default UIEdgeInsetsZero. add additional scroll area around content
    public var contentInset: UIEdgeInsets {
        set { return _containterView.contentInset = newValue }
        get { return _containterView.contentInset }
    }
    
    /// default YES. if YES, bounces past edge of content and back again
    public var bounces: Bool {
        set { return _containterView.bounces = newValue }
        get { return _containterView.bounces }
    }
    /// default NO. if YES and bounces is YES, even if content is smaller than bounds, allow drag vertically
    public var alwaysBounceVertical: Bool {
        set { return _containterView.alwaysBounceVertical = newValue }
        get { return _containterView.alwaysBounceVertical }
    }
    /// default NO. if YES and bounces is YES, even if content is smaller than bounds, allow drag horizontally
    public var alwaysBounceHorizontal: Bool {
        set { return _containterView.alwaysBounceHorizontal = newValue }
        get { return _containterView.alwaysBounceHorizontal }
    }
    
    /// default YES. turn off any dragging temporarily
    public var isScrollEnabled: Bool {
        set { return _containterView.isScrollEnabled = newValue }
        get { return _containterView.isScrollEnabled }
    }
    
    /// default YES. show indicator while we are tracking. fades out after tracking
    public var showsHorizontalScrollIndicator: Bool {
        set { return _containterView.showsHorizontalScrollIndicator = newValue }
        get { return _containterView.showsHorizontalScrollIndicator }
    }
    /// default YES. show indicator while we are tracking. fades out after tracking
    public  var showsVerticalScrollIndicator: Bool {
        set { return _containterView.showsVerticalScrollIndicator = newValue }
        get { return _containterView.showsVerticalScrollIndicator }
    }
    /// default is UIEdgeInsetsZero. adjust indicators inside of insets
    public var scrollIndicatorInsets: UIEdgeInsets {
        set { return _containterView.scrollIndicatorInsets = newValue }
        get { return _containterView.scrollIndicatorInsets }
    }
    /// default is UIScrollViewIndicatorStyleDefault
    public var indicatorStyle: UIScrollViewIndicatorStyle {
        set { return _containterView.indicatorStyle = newValue }
        get { return _containterView.indicatorStyle }
    }
    
    public var decelerationRate: CGFloat {
        set { return _containterView.decelerationRate = newValue }
        get { return _containterView.decelerationRate }
    }
    
    /// default is YES. if NO, we immediately call -touchesShouldBegin:withEvent:inContentView:. this has no effect on presses
    public var delaysContentTouches: Bool {
        set { return _containterView.delaysContentTouches = newValue }
        get { return _containterView.delaysContentTouches }
    }
    /// default is YES. if NO, then once we start tracking, we don't try to drag if the touch moves. this has no effect on presses
    public var canCancelContentTouches: Bool {
        set { return _containterView.canCancelContentTouches = newValue }
        get { return _containterView.canCancelContentTouches }
    }
    
    /// default is 1.0
    public var minimumZoomScale: CGFloat {
        return _containterView.minimumZoomScale
    }
    /// default is 1.0. must be > minimum zoom scale to enable zooming
    public var maximumZoomScale: CGFloat {
        return _containterView.maximumZoomScale
    }
    
    /// default is 1.0
    public var zoomScale: CGFloat  {
        set { return _containterView.zoomScale = newValue }
        get { return _containterView.zoomScale }
    }
    /// default is YES. if set, user can go past min/max zoom while gesturing and the zoom will animate to the min/max value at gesture end
    public var bouncesZoom: Bool {
        set { return _containterView.bouncesZoom = newValue }
        get { return _containterView.bouncesZoom }
    }
    /// default is YES.
    public var scrollsToTop: Bool {
        set { return _containterView.scrollsToTop = newValue }
        get { return _containterView.scrollsToTop }
    }
    
    /// default is UIImageOrientationUp
    public var orientation: UIImageOrientation {
        set { return _updateOrientation(with: _angle(for: orientation), animated: false) }
        get { return _orientation }
    }
    
    /// animate at constant velocity to new offset
    public func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        _containterView.setContentOffset(contentOffset, animated: animated)
    }
    /// scroll so rect is just visible (nearest edges). nothing if rect completely visible
    public func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        _containterView.scrollRectToVisible(rect, animated: animated)
    }
    
    public func setZoomScale(_ scale: CGFloat, animated: Bool) {
        _containterView.setZoomScale(scale, animated: animated)
    }
    public func setZoomScale(_ scale: CGFloat, at point: CGPoint, animated: Bool) {
        guard let view = _contentView else {
            return setZoomScale(scale, animated: animated)
        }
        
        let width = view.bounds.width * scale
        let height = view.bounds.height * scale
        
        let ratioX = max(min(point.x, view.bounds.width), 0) / max(view.bounds.width, 1)
        let ratioY = max(min(point.y, view.bounds.height), 0) / max(view.bounds.height, 1)
        
        // calculate the location of this point in zoomed
        let x = max(min(width * ratioX - _containterView.frame.width / 2, width - _containterView.frame.width), 0)
        let y = max(min(height * ratioY - _containterView.frame.height / 2, height - _containterView.frame.height), 0)
        
        guard animated else {
            _containterView.zoomScale = scale
            _containterView.contentOffset = CGPoint(x: x, y: y)
            return
        }
        
        UIView.animate(withDuration: 0.35, animations: { [_containterView] in
            UIView.setAnimationBeginsFromCurrentState(true)
            
            _containterView.zoomScale = scale
            _containterView.contentOffset = CGPoint(x: x, y: y)
        })
    }
    public func zoom(to rect: CGRect, with orientation: UIImageOrientation, animated: Bool) {
        guard let view = _contentView else {
            return
        }
        // get contentView widht and height
        let width = max(_contentSize(for: orientation).width, 1)
        let height = max(_contentSize(for: orientation).height, 1)
        // calc minimum scale ratio & maximum scale roatio
        let nscale = min(min(bounds.width / width, bounds.height / height), 1)
        let nmscale = max(1 / nscale, 2)
        // calc current scale
        let oscale = min(min(rect.width, width) / (width * nscale), min(rect.height, height) / (height * nscale))
        
        // reset default size
        view.bounds = CGRect(x: 0, y: 0, width: _round(width * nscale), height: _round(height * nscale))
        
        // reset zoom position
        _containterView.minimumZoomScale = 1
        _containterView.maximumZoomScale = nmscale
        _containterView.zoomScale = max(min(oscale, _containterView.maximumZoomScale), _containterView.minimumZoomScale)
        _containterView.contentOffset = .zero
        
        // reset center
        view.center = CGPoint(x: max(view.frame.width, bounds.width) / 2, y: max(view.frame.height, bounds.height) / 2)
        
        // cache
        _bounds = bounds
        _containterView.frame = bounds
        _orientation = orientation
    }
    
    public func setOrientation(_ orientation: UIImageOrientation, animated: Bool) {
        _updateOrientation(with: _angle(for: orientation), animated: animated)
    }
    
    public var isLockContentOffset: Bool {
        set { return _containterView.isLockContentOffset = newValue }
        get { return _containterView.isLockContentOffset }
    }
    
    /// displays the scroll indicators for a short time. This should be done whenever you bring the scroll view to front.
    public func flashScrollIndicators() {
        _containterView.flashScrollIndicators()
    }
    
    /// returns YES if user has touched. may not yet have started dragging
    public var isTracking: Bool {
        return _containterView.isTracking
    }
    /// returns YES if user has started scrolling. this may require some time and or distance to move to initiate dragging
    public var isDragging: Bool {
        return _containterView.isDragging
    }
    /// returns YES if user isn't dragging (touch up) but scroll view is still moving
    public var isDecelerating: Bool {
        return _containterView.isDecelerating
    }
    
    /// returns YES if user in zoom gesture
    public var isZooming: Bool {
        return _containterView.isZooming
    }
    /// returns YES if we are in the middle of zooming back to the min/max value
    public var isZoomBouncing: Bool {
        return _containterView.isZoomBouncing
    }
    
    /// returns YES if user in rotation gesture
    public var isRotationing: Bool {
        return _isRotationing
    }
    
    /// Use these accessors to configure the scroll view's built-in gesture recognizers.
    /// Do not change the gestures' delegates or override the getters for these properties.
    
    /// Change `panGestureRecognizer.allowedTouchTypes` to limit scrolling to a particular set of touch types.
    public var panGestureRecognizer: UIPanGestureRecognizer {
        return _containterView.panGestureRecognizer
    }
    /// `pinchGestureRecognizer` will return nil when zooming is disabled.
    public var pinchGestureRecognizer: UIPinchGestureRecognizer? {
        return _containterView.pinchGestureRecognizer
    }
    /// `pinchGestureRecognizer` will return nil when zooming is disabled.
    public var rotationGestureRecognizer: UIRotationGestureRecognizer? {
        // if there is no `zoomingView` there is no rotation gesture
        guard let _ = _contentView else {
            return nil
        }
        return _rotationGestureRecognizer
    }
    
    fileprivate var _bounds: CGRect?
    fileprivate var _isRotationing: Bool = false
    
    fileprivate var _orientation: UIImageOrientation = .up {
        didSet {
            delegate?.canvasViewDidRotation?(self)
        }
    }
    fileprivate var _contentView: UIView? {
        return delegate?.viewForZooming?(in: self)
    }
    
    fileprivate lazy var _containterView: CanvasContainterView = CanvasContainterView()
    
    fileprivate lazy var _rotationGestureRecognizer: UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotationHandler(_:)))
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
}

fileprivate extension CanvasView {
    
    fileprivate func _commonInit() {
        
        clipsToBounds = true
        
        _containterView.frame = bounds
        _containterView.delegate = self
        _containterView.clipsToBounds = false
        _containterView.delaysContentTouches = false
        _containterView.canCancelContentTouches = false
        _containterView.showsVerticalScrollIndicator = false
        _containterView.showsHorizontalScrollIndicator = false
        //_containterView.alwaysBounceVertical = true
        //_containterView.alwaysBounceHorizontal = true
        
        _rotationGestureRecognizer.delegate = self
        
        super.addSubview(_containterView)
        super.addGestureRecognizer(_rotationGestureRecognizer)
    }
    
    fileprivate func _round(_ val: CGFloat) -> CGFloat {
        return trunc(val * 2) / 2
    }
    
    /// get content with orientation
    fileprivate func _contentSize(for orientation: UIImageOrientation) -> CGSize {
        if _isLandscape(for: orientation) {
            return CGSize(width: contentSize.height, height: contentSize.width)
        }
        return contentSize
    }
    
    /// convert orientation to angle
    fileprivate func _angle(for orientation: UIImageOrientation) -> CGFloat {
        switch orientation {
        case .up,
             .upMirrored:
            return 0 * CGFloat(M_PI_2)
        case .right,
             .rightMirrored:
            return 1 * CGFloat(M_PI_2)
        case .down,
             .downMirrored:
            return 2 * CGFloat(M_PI_2)
        case .left,
             .leftMirrored:
            return 3 * CGFloat(M_PI_2)
        }
    }
    
    /// convert angle to orientation
    fileprivate func _orientation(for angle: CGFloat) -> UIImageOrientation {
        switch Int(angle / CGFloat(M_PI_2)) % 4 {
        case 0:     return .up
        case 1, -3: return .right
        case 2, -2: return .down
        case 3, -1: return .left
        default:    return .up
        }
    }
    fileprivate func _isLandscape(for orientation: UIImageOrientation) -> Bool {
        switch orientation {
        case .left, .leftMirrored: return true
        case .right, .rightMirrored: return true
        case .up, .upMirrored: return false
        case .down, .downMirrored: return false
        }
    }
    
    /// with angle update orientation
    fileprivate func _updateOrientation(with angle: CGFloat, animated: Bool, completion handler: ((Bool) -> Void)? = nil) {
        //_logger.trace(angle)
        
        let oldOrientation = _orientation
        let newOrientation = _orientation(for: _angle(for: _orientation) + angle)
        
        // get contentView width and height
        let view = _contentView
        let width = max(_contentSize(for: newOrientation).width, 1)
        let height = max(_contentSize(for: newOrientation).height, 1)
        // calc minimum scale ratio
        let nscale = min(min(bounds.width / width, bounds.height / height), 1)
        let nmscale = max(1 / nscale, 2)
        
        let nbounds = CGRect(x: 0, y: 0, width: _round(width * nscale), height: _round(height * nscale))
        let transform = CGAffineTransform(rotationAngle: angle)
        
        let animations: () -> Void = { [_containterView] in
            // orientation is change?
            if oldOrientation != newOrientation {
                // changed
                _containterView.transform = transform
                _containterView.frame = self.bounds
                
                _containterView.minimumZoomScale = 1
                _containterView.maximumZoomScale = nmscale
                _containterView.zoomScale = 1
                _containterView.contentOffset = .zero
                
                view?.frame = nbounds.applying(transform)
                view?.center = CGPoint(x: _containterView.bounds.midX, y: _containterView.bounds.midY)
                
            } else {
                // not change
                _containterView.transform = .identity
            }
        }
        let completion: (Bool) -> Void = { [_containterView] isFinished in
            
            if oldOrientation != newOrientation {
                
                _containterView.transform = .identity
                _containterView.frame = self.bounds
                
                view?.frame = nbounds
                view?.center = CGPoint(x: _containterView.bounds.midX, y: _containterView.bounds.midY)
            }
            
            handler?(isFinished)
        }
        // update
        _orientation = newOrientation
        // can use animation?
        if !animated {
            animations()
            completion(true)
            return
        }
        
        UIView.animate(withDuration: 0.35, animations: animations, completion: completion)
    }
    
    /// rotation handler
    internal dynamic func rotationHandler(_ sender: UIRotationGestureRecognizer) {
        // is opened rotation?
        guard _isRotationing else {
            return
        }
        _containterView.transform = CGAffineTransform(rotationAngle: sender.rotation)
        // state is end?
        guard sender.state == .ended || sender.state == .cancelled || sender.state == .failed else {
            //delegate?.canvasViewDidRotation?(self)
            return
        }
        // call update orientation
        _isRotationing = false
        _updateOrientation(with: round(sender.rotation / CGFloat(M_PI_2)) * CGFloat(M_PI_2), animated: true) { f in
            // callback notifi user
            self.delegate?.canvasViewDidEndRotationing?(self, with: self._contentView, atOrientation: self._orientation)
        }
    }
    
    public override func addSubview(_ view: UIView) {
        // always allows add to self
        _containterView.addSubview(view)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // size is change?
        guard _bounds?.size != bounds.size else {
            return
        }
        guard let view = _contentView else {
            return
        }
        // get current offset
        let offset = _containterView.contentOffset
        // update frame(can't use autoresingmask, becase get current offset before change)
        _containterView.frame = bounds
        // get contentView widht and height
        let width = max(_contentSize(for: _orientation).width, 1)
        let height = max(_contentSize(for: _orientation).height, 1)
        // calc minimum scale ratio & maximum scale roatio
        let nscale = min(min(bounds.width / width, bounds.height / height), 1)
        let nmscale = max(1 / nscale, 2)
        // calc current scale
        var oscale = max(view.frame.width / (width * nscale), view.frame.height / (height * nscale))
        
        // check boundary
        if _containterView.zoomScale >= _containterView.maximumZoomScale {
            oscale = nmscale // max
        }
        if _containterView.zoomScale <= _containterView.minimumZoomScale {
            oscale = 1 // min
        }
        
        // reset default size
        view.bounds = CGRect(x: 0, y: 0, width: _round(width * nscale), height: _round(height * nscale))
        
        // reset zoom position
        _containterView.minimumZoomScale = 1
        _containterView.maximumZoomScale = nmscale
        _containterView.zoomScale = max(min(oscale, _containterView.maximumZoomScale), _containterView.minimumZoomScale)
        _containterView.contentOffset = {
            
            let x = max(min(offset.x + ((_bounds?.width ?? 0) - bounds.width) / 2, _containterView.contentSize.width - bounds.width), 0)
            let y = max(min(offset.y + ((_bounds?.height ?? 0) - bounds.height) / 2, _containterView.contentSize.height - bounds.height), 0)
            
            return CGPoint(x: x, y: y)
        }()
        
        // reset center
        view.center = CGPoint(x: max(view.frame.width, bounds.width) / 2, y: max(view.frame.height, bounds.height) / 2)
        
        // cache
        _bounds = bounds
    }
}

///
/// Provide the gesture recognition support
///
extension CanvasView: UIGestureRecognizerDelegate {
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if _rotationGestureRecognizer === gestureRecognizer {
            // if no found contentView, can't roation
            guard let view = _contentView else {
                return false
            }
            // can rotation?
            guard delegate?.canvasViewShouldBeginRotationing?(self, with: view) ?? true else {
                return false
            }
            _isRotationing = true
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view === _containterView {
            return true
        }
        return false
    }
    
}

///
/// Provide the scroll view display support
///
extension CanvasView: UIScrollViewDelegate {
    
    /// any offset changes
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.canvasViewDidScroll?(self)
    }
    
    /// any zoom scale changes
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let view = _contentView {
            view.center = CGPoint(x: max(view.frame.width, bounds.width) / 2, y: max(view.frame.height, bounds.height) / 2)
        }
        delegate?.canvasViewDidZoom?(self)
    }
    
    /// called on start of dragging (may require some time and or distance to move)
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.canvasViewWillBeginDragging?(self)
    }
    
    /// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.canvasViewWillEndDragging?(self, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    /// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.canvasViewDidEndDragging?(self, willDecelerate: decelerate)
    }
    
    /// called on finger up as we are moving
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)  {
        delegate?.canvasViewWillBeginDecelerating?(self)
    }
    /// called when scroll view grinds to a halt
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)  {
        delegate?.canvasViewDidEndDecelerating?(self)
    }
    
    /// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.canvasViewDidEndScrollingAnimation?(self)
    }
    
    /// return a view that will be scaled. if delegate returns nil, nothing happens
    public func viewForZooming(in scrollView: UIScrollView) -> UIView?  {
        return _contentView
    }
    /// called before the scroll view begins zooming its content
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegate?.canvasViewWillBeginZooming?(self, with: view)
    }
    /// scale between minimum and maximum. called after any 'bounce' animations
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        delegate?.canvasViewDidEndZooming?(self, with: view, atScale: scale)
    }
    
    /// return a yes if you want to scroll to the top. if not defined, assumes YES
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return delegate?.canvasViewShouldScrollToTop?(self) ?? true
    }
    /// called when scrolling animation finished. may be called immediately if already at top
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        delegate?.canvasViewDidScrollToTop?(self)
    }
}

internal class CanvasContainterView: UIScrollView {
    
    override var contentOffset: CGPoint {
        set {
            if !isLockContentOffset {
                super.contentOffset = newValue
            }
            _lockedContentOffset = newValue
        }
        get {
            return super.contentOffset
        }
    }
    
    var isLockContentOffset: Bool = false {
        willSet {
            guard isLockContentOffset != newValue else {
                return
            }
            let offset = contentOffset
//            if !newValue {
//                let x = max(min(_lockedContentOffset.x, contentSize.width), 0)
//                let y = max(min(_lockedContentOffset.y, contentSize.height), 0)
//                super.contentOffset = CGPoint(x: x, y: y)
//            }
            _lockedContentOffset = offset
        }
    }
    
    var _lockedContentOffset: CGPoint = .zero
}
