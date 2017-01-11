//
//  IBVideoConsoleBackgroundView.swift
//  Browser
//
//  Created by sagesse on 12/17/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class IBVideoConsoleBackgroundView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commitInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commitInit()
    }
    
    var image: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var backgroundColor: UIColor? {
        set {
            _backgroundColor = newValue
            setNeedsDisplay()
        }
        get {
            return _backgroundColor
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        backgroundColor?.setFill()
        context.fill(rect)
        guard let img = image?.cgImage else {
            return
        }
        context.clip(to: rect, mask: img)
        context.clear(rect)
    }
    
    func _commitInit() {
        super.backgroundColor = .clear
    }
    
    var _backgroundColor: UIColor?
}
