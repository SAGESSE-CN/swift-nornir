//
//  CanvasView.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

@objc internal protocol CanvasViewDelegate {
    
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


@objc internal class CanvasView: UIView {
    
    public weak var delegate: CanvasViewDelegate?
    
    /// default CGPointZero
    @NSManaged var contentOffset: CGPoint
    /// default UIEdgeInsetsZero. add additional scroll area around content
    @NSManaged var contentInset: UIEdgeInsets
    
    /// default YES. if YES, bounces past edge of content and back again
    @NSManaged var bounces: Bool
    /// default NO. if YES and bounces is YES, even if content is smaller than bounds, allow drag vertically
    @NSManaged var alwaysBounceVertical: Bool
    /// default NO. if YES and bounces is YES, even if content is smaller than bounds, allow drag horizontally
    @NSManaged var alwaysBounceHorizontal: Bool
    
    /// default YES. turn off any dragging temporarily
    @NSManaged var isScrollEnabled: Bool
    
    /// default YES. show indicator while we are tracking. fades out after tracking
    @NSManaged var showsHorizontalScrollIndicator: Bool
    /// default YES. show indicator while we are tracking. fades out after tracking
    @NSManaged var showsVerticalScrollIndicator: Bool
    /// default is UIEdgeInsetsZero. adjust indicators inside of insets
    @NSManaged var scrollIndicatorInsets: UIEdgeInsets
    /// default is UIScrollViewIndicatorStyleDefault
    @NSManaged var indicatorStyle: UIScrollViewIndicatorStyle
    
    @NSManaged var decelerationRate: CGFloat
    
    /// default is YES. if NO, we immediately call -touchesShouldBegin:withEvent:inContentView:. this has no effect on presses
    @NSManaged var delaysContentTouches: Bool
    /// default is YES. if NO, then once we start tracking, we don't try to drag if the touch moves. this has no effect on presses
    @NSManaged var canCancelContentTouches: Bool
    
    /// default is 1.0
    @NSManaged var minimumZoomScale: CGFloat
    @NSManaged var maximumZoomScale: CGFloat
    /// default is 1.0
    @NSManaged var zoomScale: CGFloat
    /// default is YES. if set, user can go past min/max zoom while gesturing and the zoom will animate to the min/max value at gesture end
    @NSManaged var bouncesZoom: Bool
    /// default is YES.
    @NSManaged var scrollsToTop: Bool
    
    /// animate at constant velocity to new offset
    @NSManaged func setContentOffset(_ contentOffset: CGPoint, animated: Bool)
    /// scroll so rect is just visible (nearest edges). nothing if rect completely visible
    @NSManaged func scrollRectToVisible(_ rect: CGRect, animated: Bool)
    
    /// default CGSizeZero
    var contentSize: CGSize = .zero
    /// default is UIImageOrientationUp
    var orientation: UIImageOrientation {
        set { return _updateOrientation(with: _angle(for: orientation), animated: false) }
        get { return _orientation }
    }
    
    func setZoomScale(_ scale: CGFloat, animated: Bool) {
        _containerView.setZoomScale(scale, animated: animated)
    }
    func setZoomScale(_ scale: CGFloat, at point: CGPoint, animated: Bool) {
        guard let view = _contentView else {
            return setZoomScale(scale, animated: animated)
        }
        
        let width = view.bounds.width * scale
        let height = view.bounds.height * scale
        
        let ratioX = max(min(point.x, view.bounds.width), 0) / max(view.bounds.width, 1)
        let ratioY = max(min(point.y, view.bounds.height), 0) / max(view.bounds.height, 1)
        
        // calculate the location of this point in zoomed
        let x = max(min(width * ratioX - _containerView.frame.width / 2, width - _containerView.frame.width), 0)
        let y = max(min(height * ratioY - _containerView.frame.height / 2, height - _containerView.frame.height), 0)
        
        guard animated else {
            _containerView.zoomScale = scale
            _containerView.contentOffset = CGPoint(x: x, y: y)
            return
        }
        
        UIView.animate(withDuration: 0.35, animations: { [_containerView] in
            UIView.setAnimationBeginsFromCurrentState(true)
            
            _containerView.zoomScale = scale
            _containerView.contentOffset = CGPoint(x: x, y: y)
        })
    }
    func zoom(to rect: CGRect, with orientation: UIImageOrientation, animated: Bool) {
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
        _containerView.minimumZoomScale = 1
        _containerView.maximumZoomScale = nmscale
        _containerView.zoomScale = max(min(oscale, _containerView.maximumZoomScale), _containerView.minimumZoomScale)
        _containerView.contentOffset = .zero
        
        // reset center
        view.center = CGPoint(x: max(view.frame.width, bounds.width) / 2, y: max(view.frame.height, bounds.height) / 2)
        
        // cache
        _bounds = bounds
        _containerView.frame = bounds
        _orientation = orientation
    }
    
    func setOrientation(_ orientation: UIImageOrientation, animated: Bool) {
        _updateOrientation(with: _angle(for: orientation), animated: animated)
    }
    
    @NSManaged var isLockContentOffset: Bool
    
    /// displays the scroll indicators for a short time. This should be done whenever you bring the scroll view to front.
    @NSManaged func flashScrollIndicators()
    
    /// returns YES if user has touched. may not yet have started dragging
    @NSManaged var isTracking: Bool
    /// returns YES if user has started scrolling. this may require some time and or distance to move to initiate dragging
    @NSManaged var isDragging: Bool 
    /// returns YES if user isn't dragging (touch up) but scroll view is still moving
    @NSManaged var isDecelerating: Bool
    
    /// returns YES if user in zoom gesture
    @NSManaged var isZooming: Bool 
    /// returns YES if we are in the middle of zooming back to the min/max value
    @NSManaged var isZoomBouncing: Bool 
    
    /// returns YES if user in rotation gesture
    var isRotationing: Bool {
        return _isRotationing
    }
    
    /// Use these accessors to configure the scroll view's built-in gesture recognizers.
    /// Do not change the gestures' delegates or override the getters for these properties.
    
    /// Change `panGestureRecognizer.allowedTouchTypes` to limit scrolling to a particular set of touch types.
    @NSManaged var panGestureRecognizer: UIPanGestureRecognizer 
    /// `pinchGestureRecognizer` will return nil when zooming is disabled.
    @NSManaged var pinchGestureRecognizer: UIPinchGestureRecognizer?
    
    /// `pinchGestureRecognizer` will return nil when zooming is disabled.
    var rotationGestureRecognizer: UIRotationGestureRecognizer? {
        // if there is no `zoomingView` there is no rotation gesture
        guard let _ = _contentView else {
            return nil
        }
        return _rotationGestureRecognizer
    }
    
    var contentTransform: CGAffineTransform {
        return _containerView.transform
    }
    
//    override func setNeedsLayout() {
//        super.setNeedsLayout()
//        _containerView.setNeedsLayout()
//    }
//    override func layoutIfNeeded() {
//        super.layoutIfNeeded()
//        _containerView.layoutIfNeeded()
//    }
    
    fileprivate var _bounds: CGRect?
    fileprivate var _targetOffset: CGPoint?
    fileprivate var _isRotationing: Bool = false
    
    fileprivate var _orientation: UIImageOrientation = .up {
        didSet {
            delegate?.canvasViewDidRotation?(self)
        }
    }
    fileprivate var _contentView: UIView? {
        return delegate?.viewForZooming?(in: self)
    }
    
    fileprivate lazy var _containerView: CanvasContainerView = CanvasContainerView()
    
    fileprivate lazy var _rotationGestureRecognizer: UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotationHandler(_:)))
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
}

extension CanvasView {
    
    fileprivate func _commonInit() {
        
        clipsToBounds = true
        
        _containerView.frame = bounds
        _containerView.delegate = self
        _containerView.clipsToBounds = false
        _containerView.delaysContentTouches = false
        _containerView.canCancelContentTouches = false
        _containerView.showsVerticalScrollIndicator = false
        _containerView.showsHorizontalScrollIndicator = false
        //_containerView.alwaysBounceVertical = true
        //_containerView.alwaysBounceHorizontal = true
        
        _rotationGestureRecognizer.delegate = self
        
        super.addSubview(_containerView)
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
        case .up, .upMirrored:
            return 0 * CGFloat.pi / 2
            
        case .right, .rightMirrored:
            return 1 * CGFloat.pi / 2
            
        case .down, .downMirrored:
            return 2 * CGFloat.pi / 2
            
        case .left, .leftMirrored:
            return 3 * CGFloat.pi / 2
        }
    }
    
    /// convert angle to orientation
    fileprivate func _orientation(for angle: CGFloat) -> UIImageOrientation {
        switch Int(angle / (.pi / 2)) % 4 {
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
        
        let animations: () -> Void = { [_containerView] in
            // orientation is change?
            if oldOrientation != newOrientation {
                // changed
                _containerView.transform = transform
                _containerView.frame = self.bounds
                
                _containerView.minimumZoomScale = 1
                _containerView.maximumZoomScale = nmscale
                _containerView.zoomScale = 1
                _containerView.contentOffset = .zero
                
                view?.frame = nbounds.applying(transform)
                view?.center = CGPoint(x: _containerView.bounds.midX, y: _containerView.bounds.midY)
                
            } else {
                // not change
                _containerView.transform = .identity
            }
        }
        let completion: (Bool) -> Void = { [_containerView] isFinished in
            
            if oldOrientation != newOrientation {
                
                _containerView.transform = .identity
                _containerView.frame = self.bounds
                
                view?.frame = nbounds
                view?.center = CGPoint(x: _containerView.bounds.midX, y: _containerView.bounds.midY)
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
    fileprivate dynamic func rotationHandler(_ sender: UIRotationGestureRecognizer) {
        // is opened rotation?
        guard _isRotationing else {
            return
        }
        _containerView.transform = CGAffineTransform(rotationAngle: sender.rotation)
        // state is end?
        guard sender.state == .ended || sender.state == .cancelled || sender.state == .failed else {
            //delegate?.canvasViewDidRotation?(self)
            return
        }
        // call update orientation
        _isRotationing = false
        _updateOrientation(with: round(sender.rotation / (.pi / 2)) * (.pi / 2), animated: true) { f in
            // callback notifi user
            self.delegate?.canvasViewDidEndRotationing?(self, with: self._contentView, atOrientation: self._orientation)
        }
    }
    
    override func addSubview(_ view: UIView) {
        // always allows add to self
        _containerView.addSubview(view)
    }
    
    // update subview layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // size is change?
        guard _bounds?.size != bounds.size else {
            return
        }
        guard let view = _contentView else {
            return
        }
        // get current offset
        let offset = _containerView.contentOffset
        // update frame(can't use autoresingmask, becase get current offset before change)
        _containerView.frame = bounds
        // get contentView widht and height
        let width = max(_contentSize(for: _orientation).width, 1)
        let height = max(_contentSize(for: _orientation).height, 1)
        // calc minimum scale ratio & maximum scale roatio
        let nscale = min(min(bounds.width / width, bounds.height / height), 1)
        let nmscale = max(1 / nscale, 2)
        // calc current scale
        var oscale = max(view.frame.width / (width * nscale), view.frame.height / (height * nscale))
        
        // check boundary
        if _containerView.zoomScale >= _containerView.maximumZoomScale {
            oscale = nmscale // max
        }
        if _containerView.zoomScale <= _containerView.minimumZoomScale {
            oscale = 1 // min
        }
        
        // reset default size
        view.bounds = CGRect(x: 0, y: 0, width: _round(width * nscale), height: _round(height * nscale))
        
        // reset zoom position
        _containerView.minimumZoomScale = 1
        _containerView.maximumZoomScale = nmscale
        _containerView.zoomScale = max(min(oscale, _containerView.maximumZoomScale), _containerView.minimumZoomScale)
        _containerView.contentOffset = {
            
            let x = max(min(offset.x + ((_bounds?.width ?? 0) - bounds.width) / 2, _containerView.contentSize.width - bounds.width), 0)
            let y = max(min(offset.y + ((_bounds?.height ?? 0) - bounds.height) / 2, _containerView.contentSize.height - bounds.height), 0)
            
            return CGPoint(x: x, y: y)
        }()
        
        // reset center
        view.center = CGPoint(x: max(view.frame.width, bounds.width) / 2, y: max(view.frame.height, bounds.height) / 2)
        
        // need to notice delegate when update the bounds
        scrollViewDidScroll(_containerView)
        
        // cache
        _bounds = bounds
    }
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return _containerView
    }
}

///
/// Provide the gesture recognition support
///
extension CanvasView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view === _containerView {
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.canvasViewDidScroll?(self)
    }
    
    /// any zoom scale changes
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let view = _contentView {
            view.center = CGPoint(x: max(view.frame.width, bounds.width) / 2, y: max(view.frame.height, bounds.height) / 2)
        }
        delegate?.canvasViewDidZoom?(self)
    }
    
    /// called on start of dragging (may require some time and or distance to move)
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.canvasViewWillBeginDragging?(self)
    }
    
    /// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.canvasViewWillEndDragging?(self, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    /// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.canvasViewDidEndDragging?(self, willDecelerate: decelerate)
    }
    
    /// called on finger up as we are moving
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)  {
        delegate?.canvasViewWillBeginDecelerating?(self)
    }
    /// called when scroll view grinds to a halt
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)  {
        delegate?.canvasViewDidEndDecelerating?(self)
    }
    
    /// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.canvasViewDidEndScrollingAnimation?(self)
    }
    
    /// return a view that will be scaled. if delegate returns nil, nothing happens
    func viewForZooming(in scrollView: UIScrollView) -> UIView?  {
        return _contentView
    }
    /// called before the scroll view begins zooming its content
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegate?.canvasViewWillBeginZooming?(self, with: view)
    }
    /// scale between minimum and maximum. called after any 'bounce' animations
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        delegate?.canvasViewDidEndZooming?(self, with: view, atScale: scale)
    }
    
    /// return a yes if you want to scroll to the top. if not defined, assumes YES
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return delegate?.canvasViewShouldScrollToTop?(self) ?? true
    }
    /// called when scrolling animation finished. may be called immediately if already at top
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        delegate?.canvasViewDidScrollToTop?(self)
    }
}

internal class CanvasContainerView: UIScrollView {
    
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
