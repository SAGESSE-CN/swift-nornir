//
//  IBContainterView.swift
//  Browser
//
//  Created by sagesse on 10/24/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


@objc public protocol IBContainterViewDelegate {
    
    @objc optional func containterViewDidScroll(_ containterView: IBContainterView) // any offset changes
    @objc optional func containterViewDidZoom(_ containterView: IBContainterView) // any zoom scale changes
    @objc optional func containterViewDidRotation(_ containterView: IBContainterView) // any rotation changes
    
    @objc optional func viewForZooming(in containterView: IBContainterView) -> UIView? // return a view that will be scaled. if delegate returns nil, nothing happens
    
    // called on start of dragging (may require some time and or distance to move)
    @objc optional func containterViewWillBeginDragging(_ containterView: IBContainterView)

    // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    @objc optional func containterViewWillEndDragging(_ containterView: IBContainterView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)

    // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    @objc optional func containterViewDidEndDragging(_ containterView: IBContainterView, willDecelerate decelerate: Bool)

    @objc optional func containterViewWillBeginDecelerating(_ containterView: IBContainterView) // called on finger up as we are moving
    @objc optional func containterViewDidEndDecelerating(_ containterView: IBContainterView) // called when scroll view grinds to a halt

    @objc optional func containterViewDidEndScrollingAnimation(_ containterView: IBContainterView) // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating

    @objc optional func containterViewShouldScrollToTop(_ containterView: IBContainterView) -> Bool // return a yes if you want to scroll to the top. if not defined, assumes YES
    @objc optional func containterViewDidScrollToTop(_ containterView: IBContainterView) // called when scrolling animation finished. may be called immediately if already at top
    
    @objc optional func containterViewWillBeginZooming(_ containterView: IBContainterView, with view: UIView?) // called before the scroll view begins zooming its content
    @objc optional func containterViewDidEndZooming(_ containterView: IBContainterView, with view: UIView?, atScale scale: CGFloat) // scale between minimum and maximum. called after any 'bounce' animations

    @objc optional func containterViewShouldBeginRotationing(_ containterView: IBContainterView, with view: UIView?) -> Bool // called before the scroll view begins zooming its content
    @objc optional func containterViewWillEndRotationing(_ containterView: IBContainterView, with view: UIView?, atOrientation orientation: UIImageOrientation)
    @objc optional func containterViewDidEndRotationing(_ containterView: IBContainterView, with view: UIView?, atOrientation orientation: UIImageOrientation) // scale between minimum and maximum. called after any 'bounce' animations
}


@objc public class IBContainterView: UIView {
    
    public weak var delegate: IBContainterViewDelegate?
    
    // default CGPointZero
    public var contentOffset: CGPoint {
        set { return _scrollView.contentOffset = newValue }
        get { return _scrollView.contentOffset }
    }
    // default CGSizeZero
    public var contentSize: CGSize = .zero
    // default UIEdgeInsetsZero. add additional scroll area around content
    public var contentInset: UIEdgeInsets {
        set { return _scrollView.contentInset = newValue }
        get { return _scrollView.contentInset }
    }
    
    // default YES. if YES, bounces past edge of content and back again
    public var bounces: Bool {
        set { return _scrollView.bounces = newValue }
        get { return _scrollView.bounces }
    }
    // default NO. if YES and bounces is YES, even if content is smaller than bounds, allow drag vertically
    public var alwaysBounceVertical: Bool {
        set { return _scrollView.alwaysBounceVertical = newValue }
        get { return _scrollView.alwaysBounceVertical }
    }
    // default NO. if YES and bounces is YES, even if content is smaller than bounds, allow drag horizontally
    public var alwaysBounceHorizontal: Bool {
        set { return _scrollView.alwaysBounceHorizontal = newValue }
        get { return _scrollView.alwaysBounceHorizontal }
    }
    
    // default YES. turn off any dragging temporarily
    public var isScrollEnabled: Bool {
        set { return _scrollView.isScrollEnabled = newValue }
        get { return _scrollView.isScrollEnabled }
    }
    
    // default YES. show indicator while we are tracking. fades out after tracking
    public var showsHorizontalScrollIndicator: Bool {
        set { return _scrollView.showsHorizontalScrollIndicator = newValue }
        get { return _scrollView.showsHorizontalScrollIndicator }
    }
    // default YES. show indicator while we are tracking. fades out after tracking
    public  var showsVerticalScrollIndicator: Bool {
        set { return _scrollView.showsVerticalScrollIndicator = newValue }
        get { return _scrollView.showsVerticalScrollIndicator }
    }
    // default is UIEdgeInsetsZero. adjust indicators inside of insets
    public var scrollIndicatorInsets: UIEdgeInsets {
        set { return _scrollView.scrollIndicatorInsets = newValue }
        get { return _scrollView.scrollIndicatorInsets }
    }
    // default is UIScrollViewIndicatorStyleDefault
    public var indicatorStyle: UIScrollViewIndicatorStyle {
        set { return _scrollView.indicatorStyle = newValue }
        get { return _scrollView.indicatorStyle }
    }
    
    public var decelerationRate: CGFloat {
        set { return _scrollView.decelerationRate = newValue }
        get { return _scrollView.decelerationRate }
    }
    
    // default is YES. if NO, we immediately call -touchesShouldBegin:withEvent:inContentView:. this has no effect on presses
    public var delaysContentTouches: Bool {
        set { return _scrollView.delaysContentTouches = newValue }
        get { return _scrollView.delaysContentTouches }
    }
    // default is YES. if NO, then once we start tracking, we don't try to drag if the touch moves. this has no effect on presses
    public var canCancelContentTouches: Bool {
        set { return _scrollView.canCancelContentTouches = newValue }
        get { return _scrollView.canCancelContentTouches }
    }
    
    // default is 1.0
    public var minimumZoomScale: CGFloat {
        return _scrollView.minimumZoomScale
    }
    // default is 1.0. must be > minimum zoom scale to enable zooming
    public var maximumZoomScale: CGFloat {
        return _scrollView.maximumZoomScale
    }
    
    // default is 1.0
    public var zoomScale: CGFloat  {
        set { return _scrollView.zoomScale = newValue }
        get { return _scrollView.zoomScale }
    }
    // default is YES. if set, user can go past min/max zoom while gesturing and the zoom will animate to the min/max value at gesture end
    public var bouncesZoom: Bool {
        set { return _scrollView.bouncesZoom = newValue }
        get { return _scrollView.bouncesZoom }
    }
    // default is YES.
    public var scrollsToTop: Bool {
        set { return _scrollView.scrollsToTop = newValue }
        get { return _scrollView.scrollsToTop }
    }
    
    // default is UIImageOrientationUp
    public var orientation: UIImageOrientation {
        set { return _updateOrientation(with: _angle(for: orientation), animated: false) }
        get { return _orientation }
    }
    
    // animate at constant velocity to new offset
    public func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        _scrollView.setContentOffset(contentOffset, animated: animated)
    }
    // scroll so rect is just visible (nearest edges). nothing if rect completely visible
    public func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        _scrollView.scrollRectToVisible(rect, animated: animated)
    }
    
    public func setZoomScale(_ scale: CGFloat, animated: Bool) {
        _scrollView.setZoomScale(scale, animated: animated)
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
        let x = max(min(width * ratioX - _scrollView.frame.width / 2, width - _scrollView.frame.width), 0)
        let y = max(min(height * ratioY - _scrollView.frame.height / 2, height - _scrollView.frame.height), 0)
        
        guard animated else {
            _scrollView.zoomScale = scale
            _scrollView.contentOffset = CGPoint(x: x, y: y)
            return
        }
        
        UIView.animate(withDuration: 0.35, animations: { [_scrollView] in
            UIView.setAnimationBeginsFromCurrentState(true)
            
            _scrollView.zoomScale = scale
            _scrollView.contentOffset = CGPoint(x: x, y: y)
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
        _scrollView.minimumZoomScale = 1
        _scrollView.maximumZoomScale = nmscale
        _scrollView.zoomScale = max(min(oscale, _scrollView.maximumZoomScale), _scrollView.minimumZoomScale)
        _scrollView.contentOffset = .zero
        
        // reset center
        view.center = CGPoint(x: max(view.frame.width, bounds.width) / 2, y: max(view.frame.height, bounds.height) / 2)
        
        // cache
        _bounds = bounds
        _scrollView.frame = bounds
        _orientation = orientation
    }
    
    public func setOrientation(_ orientation: UIImageOrientation, animated: Bool) {
        _updateOrientation(with: _angle(for: orientation), animated: animated)
    }
    
    public var isLockContentOffset: Bool {
        set { return _scrollView.isLockContentOffset = newValue }
        get { return _scrollView.isLockContentOffset }
    }
    
    // displays the scroll indicators for a short time. This should be done whenever you bring the scroll view to front.
    public func flashScrollIndicators() {
        _scrollView.flashScrollIndicators()
    }

    // returns YES if user has touched. may not yet have started dragging
    public var isTracking: Bool {
        return _scrollView.isTracking
    }
    // returns YES if user has started scrolling. this may require some time and or distance to move to initiate dragging
    public var isDragging: Bool {
        return _scrollView.isDragging
    }
    // returns YES if user isn't dragging (touch up) but scroll view is still moving
    public var isDecelerating: Bool {
        return _scrollView.isDecelerating
    }
    
    // returns YES if user in zoom gesture
    public var isZooming: Bool {
        return _scrollView.isZooming
    }
     // returns YES if we are in the middle of zooming back to the min/max value
    public var isZoomBouncing: Bool {
        return _scrollView.isZoomBouncing
    }
    
    // returns YES if user in rotation gesture
    public var isRotationing: Bool {
        return _isRotationing
    }
    
    // Use these accessors to configure the scroll view's built-in gesture recognizers.
    // Do not change the gestures' delegates or override the getters for these properties.
    
    // Change `panGestureRecognizer.allowedTouchTypes` to limit scrolling to a particular set of touch types.
    public var panGestureRecognizer: UIPanGestureRecognizer {
        return _scrollView.panGestureRecognizer
    }
    // `pinchGestureRecognizer` will return nil when zooming is disabled.
    public var pinchGestureRecognizer: UIPinchGestureRecognizer? {
        return _scrollView.pinchGestureRecognizer
    }
    // `pinchGestureRecognizer` will return nil when zooming is disabled.
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
            delegate?.containterViewDidRotation?(self)
        }
    }
    fileprivate var _contentView: UIView? {
        return delegate?.viewForZooming?(in: self)
    }
    
    fileprivate lazy var _scrollView: IBContainterScrollView = IBContainterScrollView()
    fileprivate lazy var _backgroundView: UIImageView = UIImageView()
    
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

fileprivate extension IBContainterView {
    
    fileprivate func _commonInit() {
        
        clipsToBounds = true
        
        // 主要是为了阻止automaticallyAdjustsScrollViewInsets
        _backgroundView.frame = bounds
        _backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _backgroundView.isHidden = true
        _backgroundView.isUserInteractionEnabled = false
        
        _scrollView.frame = bounds
        _scrollView.delegate = self
        _scrollView.clipsToBounds = false
        _scrollView.delaysContentTouches = false
        _scrollView.canCancelContentTouches = false
        _scrollView.showsVerticalScrollIndicator = false
        _scrollView.showsHorizontalScrollIndicator = false
        //_scrollView.alwaysBounceVertical = true
        //_scrollView.alwaysBounceHorizontal = true
        
        _rotationGestureRecognizer.delegate = self
        
        super.addSubview(_backgroundView)
        super.addSubview(_scrollView)
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
        
        let animations: () -> Void = { [_scrollView] in
            // orientation is change?
            if oldOrientation != newOrientation {
                // changed
                _scrollView.transform = transform
                _scrollView.frame = self.bounds
                
                _scrollView.minimumZoomScale = 1
                _scrollView.maximumZoomScale = nmscale
                _scrollView.zoomScale = 1
                _scrollView.contentOffset = .zero
                
                view?.frame = nbounds.applying(transform)
                view?.center = CGPoint(x: _scrollView.bounds.midX, y: _scrollView.bounds.midY)
                
            } else {
                // not change
                _scrollView.transform = .identity
            }
        }
        let completion: (Bool) -> Void = { [_scrollView] isFinished in
            
            if oldOrientation != newOrientation {
                
                _scrollView.transform = .identity
                _scrollView.frame = self.bounds
                
                view?.frame = nbounds
                view?.center = CGPoint(x: _scrollView.bounds.midX, y: _scrollView.bounds.midY)
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
    dynamic func rotationHandler(_ sender: UIRotationGestureRecognizer) {
        // is opened rotation?
        guard _isRotationing else {
            return 
        }
        _scrollView.transform = CGAffineTransform(rotationAngle: sender.rotation)
        // state is end?
        guard sender.state == .ended || sender.state == .cancelled || sender.state == .failed else {
            //delegate?.containterViewDidRotation?(self)
            return
        }
        // call update orientation
        _isRotationing = false
        _updateOrientation(with: round(sender.rotation / CGFloat(M_PI_2)) * CGFloat(M_PI_2), animated: true) { f in
            // callback notifi user
            self.delegate?.containterViewDidEndRotationing?(self, with: self._contentView, atOrientation: self._orientation)
        }
    }
}

extension IBContainterView: UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    public override func addSubview(_ view: UIView) {
        // always allows add to self
        _scrollView.addSubview(view)
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
        let offset = _scrollView.contentOffset
        // update frame(can't use autoresingmask, becase get current offset before change)
        _scrollView.frame = bounds
        // get contentView widht and height
        let width = max(_contentSize(for: _orientation).width, 1)
        let height = max(_contentSize(for: _orientation).height, 1)
        // calc minimum scale ratio & maximum scale roatio
        let nscale = min(min(bounds.width / width, bounds.height / height), 1)
        let nmscale = max(1 / nscale, 2)
        // calc current scale
        var oscale = max(view.frame.width / (width * nscale), view.frame.height / (height * nscale))
        
        // check boundary
        if _scrollView.zoomScale >= _scrollView.maximumZoomScale {
            oscale = nmscale // max
        }
        if _scrollView.zoomScale <= _scrollView.minimumZoomScale {
            oscale = 1 // min
        }
        
        // reset default size
        view.bounds = CGRect(x: 0, y: 0, width: _round(width * nscale), height: _round(height * nscale))
        
        // reset zoom position
        _scrollView.minimumZoomScale = 1
        _scrollView.maximumZoomScale = nmscale
        _scrollView.zoomScale = max(min(oscale, _scrollView.maximumZoomScale), _scrollView.minimumZoomScale)
        _scrollView.contentOffset = {
            
            let x = max(min(offset.x + ((_bounds?.width ?? 0) - bounds.width) / 2, _scrollView.contentSize.width - bounds.width), 0)
            let y = max(min(offset.y + ((_bounds?.height ?? 0) - bounds.height) / 2, _scrollView.contentSize.height - bounds.height), 0)
            
            return CGPoint(x: x, y: y)
        }()
        
        // reset center
        view.center = CGPoint(x: max(view.frame.width, bounds.width) / 2, y: max(view.frame.height, bounds.height) / 2)
        
        // cache
        _bounds = bounds
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if _rotationGestureRecognizer === gestureRecognizer {
            // if no found contentView, can't roation 
            guard let view = _contentView else {
                return false
            }
            // can rotation?
            guard delegate?.containterViewShouldBeginRotationing?(self, with: view) ?? true else {
                return false
            }
            _isRotationing = true
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view === _scrollView {
            return true
        }
        return false
    }
    
    // MARK: - UIScrollViewDelegate
    
    // any offset changes
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.containterViewDidScroll?(self)
    }

    // any zoom scale changes
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let view = _contentView {
            view.center = CGPoint(x: max(view.frame.width, bounds.width) / 2, y: max(view.frame.height, bounds.height) / 2)
        }
        delegate?.containterViewDidZoom?(self)
    }

    // called on start of dragging (may require some time and or distance to move)
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.containterViewWillBeginDragging?(self)
    }

    // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.containterViewWillEndDragging?(self, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.containterViewDidEndDragging?(self, willDecelerate: decelerate)
    }
    
    // called on finger up as we are moving
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)  {
        delegate?.containterViewWillBeginDecelerating?(self)
    }
    // called when scroll view grinds to a halt
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)  {
        delegate?.containterViewDidEndDecelerating?(self)
    }
    
    // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.containterViewDidEndScrollingAnimation?(self)
    }

    // return a view that will be scaled. if delegate returns nil, nothing happens
    public func viewForZooming(in scrollView: UIScrollView) -> UIView?  {
        return _contentView
    }
    // called before the scroll view begins zooming its content
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegate?.containterViewWillBeginZooming?(self, with: view)
    }
    // scale between minimum and maximum. called after any 'bounce' animations
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        delegate?.containterViewDidEndZooming?(self, with: view, atScale: scale)
    }

    // return a yes if you want to scroll to the top. if not defined, assumes YES
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return delegate?.containterViewShouldScrollToTop?(self) ?? true
    }
    // called when scrolling animation finished. may be called immediately if already at top
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        delegate?.containterViewDidScrollToTop?(self)
    }
}

internal class IBContainterScrollView: UIScrollView {
    
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
