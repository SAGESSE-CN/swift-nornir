//
//  IBOverlayProgressLayer.swift
//  Browser
//
//  Created by sagesse on 12/17/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import CoreText

open class IBOverlayProgressLayer: CAShapeLayer {
    
    public override init() {
        super.init()
        commonInit()
    }
    public override init(layer: Any) {
        super.init(layer: layer)
        commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    @NSManaged open var radius: CGFloat
    @NSManaged open var progress: Double
    
    open override func display() {
        super.display()
        updatePathIfNeeded(with: _currentProgress, radius: _currentRadius)
    }
    open override func layoutSublayers() {
        super.layoutSublayers()
        updatePathIfNeeded(with: _currentProgress, radius: _currentRadius)
    }
    
    open override func action(forKey key: String) -> CAAction? {
        switch key {
        case "radius":
            let animation = CABasicAnimation(keyPath: key)
            animation.fromValue = _currentRadius
            return animation
            
        case "progress":
            let animation = CABasicAnimation(keyPath: key)
            animation.fromValue = _currentProgress
            return animation
            
        default:
            return super.action(forKey: key)
        }
    }
    open override class func needsDisplay(forKey key: String) -> Bool {
        switch key {
        case "radius":
            return true
            
        case "progress":
            return true
            
        default:
            return super.needsDisplay(forKey: key)
        }
    }
    
    open func updatePathIfNeeded(with progress: Double, radius: CGFloat) {
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
        let s = 0 - CGFloat(M_PI / 2)
        let e = s + CGFloat(M_PI * 2 * progress)
        
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
    
    private func commonInit() {
        
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
        return (presentation() as IBOverlayProgressLayer?)?.radius ?? radius
    }
    private var _currentProgress: Double {
        return (presentation() as IBOverlayProgressLayer?)?.progress ?? progress
    }
}

