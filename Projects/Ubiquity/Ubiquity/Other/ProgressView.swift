//
//  ProgressView.swift
//  Ubiquity
//
//  Created by SAGESSE on 4/18/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class ProgressView: UIView {
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
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
        set {
            setRaidus(newValue, animated: false)
        }
        get {
            return _layer.radius
        }
    }
    var progress: Double {
        set {
            setProgress(newValue, animated: false)
        }
        get {
            return _layer.progress
        }
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
        return super.point(inside: point, with: event)
    }
    
    override class var layerClass: AnyClass {
        return ProgressLayer.self
    }
    
    private func setup() {
        
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
        setup()
    }
    override init(layer: Any) {
        super.init(layer: layer)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
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
            let ani = CABasicAnimation(keyPath: key)
            ani.keyPath = key
            ani.fromValue = _currentRadius
            ani.toValue = nil
            return ani
            
        case #keyPath(progress):
            let ani = CABasicAnimation(keyPath: key)
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
    
    private func setup() {
        
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
