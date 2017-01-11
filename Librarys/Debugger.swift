//
//  Debugger.swift
//  Example
//
//  Created by SAGESSE on 03/11/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

internal class Debugger: UIView {
    
    func addRect(_ rect: CGRect, key: String = UUID().uuidString) {
        rects[key] = rect
        setNeedsDisplay()
    }
    func addPoint(_ point: CGPoint, key: String = UUID().uuidString) {
        points[key] = point
        setNeedsDisplay()
    }
    
    func color(with key: String) -> UIColor {
        if let color = colors[key] {
            return color
        }
        let maxValue: UInt32 = 24
        let color = UIColor(red: CGFloat(arc4random() % maxValue) / CGFloat(maxValue),
                            green: CGFloat(arc4random() % maxValue) / CGFloat(maxValue) ,
                            blue: CGFloat(arc4random() % maxValue) / CGFloat(maxValue) ,
                            alpha: 1)
        colors[key] = color
        return color
    }
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.setLineWidth(1 / UIScreen.main.scale)
        
        points.forEach {
            
            context?.setStrokeColor(color(with: $0).cgColor)
            context?.beginPath()
            // x
            context?.move(to: CGPoint(x: bounds.minX, y: $1.y))
            context?.addLine(to: CGPoint(x: bounds.maxX, y: $1.y))
            // y
            context?.move(to: CGPoint(x: $1.x, y: bounds.minY))
            context?.addLine(to: CGPoint(x: $1.x, y: bounds.maxY))
            
            context?.strokePath()
        }
        rects.forEach {
            context?.setStrokeColor(color(with: $0).cgColor)
            context?.beginPath()
            // x1
            context?.move(to: CGPoint(x: bounds.minX, y: $1.minY))
            context?.addLine(to: CGPoint(x: bounds.maxX, y: $1.minY))
            // x2
            context?.move(to: CGPoint(x: bounds.minX, y: $1.maxY))
            context?.addLine(to: CGPoint(x: bounds.maxX, y: $1.maxY))
            // y1
            context?.move(to: CGPoint(x: $1.minX, y: bounds.minY))
            context?.addLine(to: CGPoint(x: $1.minX, y: bounds.maxY))
            // y2
            context?.move(to: CGPoint(x: $1.maxX, y: bounds.minY))
            context?.addLine(to: CGPoint(x: $1.maxX, y: bounds.maxY))
            
            context?.strokePath()
        }
    }
    
    lazy var rects: [String: CGRect] = [:]
    lazy var points: [String: CGPoint] = [:]
    
    lazy var colors: [String: UIColor] = [:]
}

extension UIView {
    
    private var _debugger: Debugger? {
        set { return objc_setAssociatedObject(self, &__DEBUGGER, newValue, .OBJC_ASSOCIATION_RETAIN) }
        get { return objc_getAssociatedObject(self, &__DEBUGGER) as? Debugger }
    }
    
    var debugger: Debugger {
        if let debugger = _debugger {
            return debugger
        }
        let debugger = Debugger()
        
        debugger.frame = bounds
        debugger.backgroundColor = .clear
        debugger.isUserInteractionEnabled = false
        debugger.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        addSubview(debugger)
        
        _debugger = debugger
        return debugger
    }
}

private var __DEBUGGER = "__DEBUGGER"
