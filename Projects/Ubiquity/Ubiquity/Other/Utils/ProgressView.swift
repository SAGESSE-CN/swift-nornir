//
//  Progress.swift
//  Ubiquity
//
//  Created by SAGESSE on 4/18/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class ProgressProxy: NSObject {
    init(frame: CGRect, owner: UIView) {
        _owner = owner
        _center = .init(x: frame.midX, y: frame.midY)
        _bounds = .init(origin: .zero, size: frame.size)
        _forwarder = EventCenter()
        super.init()
    }
    
    var bounds: CGRect {
        set {
            _bounds = newValue
            _progressView?.bounds = newValue
            _progressView?.radius = (bounds.width / 2) - 3
        }
        get { return _bounds }
    }
    var center: CGPoint {
        set {
            _center = newValue
            _progressView?.center = newValue
        }
        get { return _center }
    }
    
    var value: Double {
        return _value
    }
    var isHidden: Bool {
        return _isForceHidden
    }
    
    func setValue(_ value: Double, animated: Bool) {
        // value have any change?
        guard _value != value else {
            return // no change
        }
        logger.trace?.write(value, animated)
        
        // update value
        _value = value
        // check whether progressView has been hidden?
        guard !_isForceHidden else {
            // if you need animation, delayed update
            guard !animated else {
                return
            }
            // if you don't need animation, enforce the update
            _progressView?.setProgress(value, animated: false)
            return
        }
        // update ui
        _updateProgress(value, animated: animated)
    }
    func setIsHidden(_ isHidden: Bool, animated: Bool) {
        // progress is full
        guard _valueOfPresentation <= 0.999999 else {
            return
        }
        logger.trace?.write(isHidden, animated)
        // set force hidden flag
        _isForceHidden = isHidden
        _updateProgress(_value, animated: animated, isForceHidden: isHidden)
    }
    
    func addTarget(_ target: AnyObject, action: Selector, for controlEvents: UIControlEvents) {
        logger.trace?.write()
        
        _forwarder.addTarget(target, action: action, for: controlEvents)
    }
    func removeTarget(_ target: AnyObject?, action: Selector?, for controlEvents: UIControlEvents) {
        logger.trace?.write()
        
        _forwarder.removeTarget(target, action: action, for: controlEvents)
    }
    
    private func _updateProgress(_ progress: Double, animated: Bool, isForceHidden: Bool? = nil) {
        
        // if progress greater than or equal to 1.0(±0.000001), status is full
        let isFull = progress > 0.999999
        // if not specified, the automatic calculation is hidden
        let isHidden = (isForceHidden ?? isFull) || isFull
        
        // if progressView not found, automatically create
        let progressView = _progressView ?? {
            let progressView = ProgressView(frame: .zero)
            
            progressView.bounds = bounds
            progressView.center = center
            progressView.strokeColor = UIColor.lightGray
            progressView.fillColor = UIColor.white
            progressView.progress = progress
            progressView.radius = (bounds.width / 2) - 3
            progressView.alpha = isHidden ? 0 : 1
            
            _owner?.addSubview(progressView)
            _forwarder.apply(progressView)
            _progressView = progressView
            
            return progressView
        }()
        // update to presentation value
        _valueOfPresentation = progress
        // need update animate?
        guard animated else {
            // if don't need animation
            _progressView?.alpha = isHidden ? 0 : 1
            _progressView?.setProgress(progress, animated: false)
            // if it is full, clear the progressView
            guard isFull else {
                return
            }
            _progressView?.removeFromSuperview()
            _progressView = nil
            return
        }
        // commit animation
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            // if hidden is false, nedd show animation
            // if progress is change, need show animation
            guard progressView.progress != progress || !isHidden else {
                return
            }
            // update status for show
            progressView.alpha = 1
            
        }, completion: { finished in
            // if this failure, that have a new alpha
            guard finished else {
                return
            }
            // progress is must be update
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveLinear, animations: {
                // update progress
                progressView.progress = progress
                
            }, completion: { finished in
                // if this failure, that have a new progress
                guard finished, isHidden else {
                    return
                }
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    // update status for hide
                    progressView.alpha = 0
                    
                }, completion: { finished in
                    // if this failure, that have a new alpha
                    guard finished, isFull else {
                        return
                    }
                    // clear if need
                    self._progressView?.removeFromSuperview()
                    self._progressView = nil
                })
            })
        })
    }
    
    private var _bounds: CGRect
    private var _center: CGPoint
    
    private var _value: Double = 1.0
    private var _valueOfPresentation: Double = 1.0
    private var _isForceHidden: Bool = false
    
    private var _forwarder: EventCenter
    private var _progressView: ProgressView?
    
    private weak var _owner: UIView?
}

internal class ProgressView: UIControl {
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    var fillColor: UIColor? {
        set {
            _layer.fillColor = newValue?.cgColor
        }
        get {
            guard let color = _layer.fillColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }
    var strokeColor: UIColor? {
        set {
            _layer.strokeColor = newValue?.cgColor
        }
        get {
            guard let color = _layer.strokeColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }
    
    var radius: CGFloat {
        set { return _layer.radius = newValue }
        get { return _layer.radius }
    }
    var progress: Double {
        set { return _layer.progress = newValue }
        get { return _layer.progress }
    }
    
    func setRaidus(_ radius: CGFloat, animated: Bool) {
        _layer.radius = radius
        guard !animated else {
            return
        }
        let ani = CABasicAnimation(keyPath: "radius")
        ani.toValue = radius
        _layer.add(ani, forKey: "radius")
    }
    func setProgress(_ progress: Double, animated: Bool) {
        _layer.progress = progress
        guard !animated else {
            return
        }
        let ani = CABasicAnimation(keyPath: "progress")
        ani.toValue = progress
        _layer.add(ani, forKey: "progress")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard progress < -0.000001 else {
            return false
        }
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(-8, -8, -8, -8)).contains(point)
    }
    
    override class var layerClass: AnyClass {
        return ProgressLayer.self
    }
    
    private func _setup() {
        
        backgroundColor = .clear
        
        _layer.radius = 3
        _layer.lineWidth = 1 / UIScreen.main.scale
        
        _layer.fillColor = fillColor?.cgColor
        _layer.strokeColor = strokeColor?.cgColor
    }
    
    private var _layer: ProgressLayer {
        return layer as! ProgressLayer
    }
}

internal class ProgressLayer: CAShapeLayer {
    
    override init() {
        super.init()
        _setup()
    }
    override init(layer: Any) {
        super.init(layer: layer)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    @NSManaged var radius: CGFloat
    @NSManaged var progress: Double
    
    override func display() {
        super.display()
        updatePathIfNeeded(with: _currentProgress, radius: _currentRadius)
    }
    override func layoutSublayers() {
        super.layoutSublayers()
        updatePathIfNeeded(with: _currentProgress, radius: _currentRadius)
    }
    
    override func action(forKey key: String) -> CAAction? {
        switch key {
        case #keyPath(radius):
            guard let ani = super.action(forKey: #keyPath(backgroundColor)) as? CABasicAnimation else {
                return nil
            }
            ani.keyPath = key
            ani.fromValue = _currentRadius
            ani.toValue = nil
            return ani
            
        case #keyPath(progress):
            guard let ani = super.action(forKey: #keyPath(backgroundColor)) as? CABasicAnimation else {
                return nil
            }
            ani.keyPath = key
            ani.fromValue = _currentProgress
            ani.toValue = nil
            return ani
            
        default:
            return super.action(forKey: key)
        }
    }
    override class func needsDisplay(forKey key: String) -> Bool {
        switch key {
        case #keyPath(radius):
            return true
            
        case #keyPath(progress):
            return true
            
        default:
            return super.needsDisplay(forKey: key)
        }
    }
    
    func updatePathIfNeeded(with progress: Double, radius: CGFloat) {
        // nned update?
        guard _cacheProgress != progress || _cacheBounds != bounds || _cacheRadius != radius else {
            return // no change
        }
        _cacheRadius = radius
        _cacheProgress = progress
        _cacheBounds = bounds
        
        let it = (bounds.width / 2) - radius
        let edg = UIEdgeInsetsMake(it, it, it, it)
        
        let rect1 = bounds
        let rect2 = UIEdgeInsetsInsetRect(rect1, edg)
        
        let op = UIBezierPath(roundedRect: rect1, cornerRadius: rect1.width / 2)
        
        guard progress > 0.000001 else {
            // progress is == 0, is empty
            op.append(.init(roundedRect: rect2, cornerRadius: rect2.width / 2))
            // progress is < 0, is error, show error icon
            if progress < -0.000001 {
                let mp = UIBezierPath(cgPath: iconForError())
                let x = (rect1.width - mp.bounds.width) / 2
                let y = (rect1.height - mp.bounds.height) / 2
                mp.apply(CGAffineTransform(translationX: x, y: y))
                op.append(mp)
            }
            path = op.cgPath
            return
        }
        guard progress < 0.999999 else {
            // progress is >= 1, is full
            path = op.cgPath
            return
        }
        let s = 0 - CGFloat.pi / 2
        let e = s + CGFloat.pi * 2 * CGFloat(progress)
        
        op.move(to: .init(x: rect2.midX, y: rect2.midY))
        op.addLine(to: .init(x: rect2.midX, y: rect2.minY))
        op.addArc(withCenter: .init(x: rect2.midX, y: rect2.midY), radius: rect2.width / 2, startAngle: s, endAngle: e, clockwise: false)
        op.close()
        
        path = op.cgPath
    }
    
    private func iconForError() -> CGPath {
        if let path = _cacheIconPath, _cacheIconRadius == radius {
            return path
        }
        let str = NSAttributedString(string: "!", attributes: nil) as CFAttributedString
        let font = CTFontCreateWithName("Symbol" as CFString, radius * 2, nil)
        
        let line = CTLineCreateWithAttributedString(str)
        let run = (CTLineGetGlyphRuns(line) as NSArray)[0] as! CTRun
            
        var glyph: CGGlyph = 0
        CTRunGetGlyphs(run, CFRangeMake(0, 1), &glyph)
        
        let path = CTFontCreatePathForGlyph(font, glyph, nil)
        let bounds = path?.boundingBox ?? .zero
        var transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: -bounds.minX, y: -bounds.maxY)
        
        _cacheIconPath = path?.mutableCopy(using: &transform)
        _cacheIconRadius = radius
       
        // 一定会成功的
        return _cacheIconPath!
    }
    
    private func _setup() {
        
        lineCap = kCALineCapRound
        lineJoin = kCALineJoinRound
        lineWidth = 1
        
        fillRule = kCAFillRuleEvenOdd
        fillColor = UIColor.white.cgColor
        
        strokeStart = 0
        strokeEnd = 1
        strokeColor = UIColor.lightGray.cgColor
    }
    
    private var _cacheRadius: CGFloat = 0
    private var _cacheProgress: Double = -1
    private var _cacheBounds: CGRect = .zero
    
    private var _cacheIconRadius: CGFloat = 0
    private var _cacheIconPath: CGPath?
    
    private var _currentRadius: CGFloat {
        return presentation()?.radius ?? radius
    }
    private var _currentProgress: Double {
        return presentation()?.progress ?? progress
    }
}

