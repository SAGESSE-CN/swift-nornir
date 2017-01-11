//
//  IBVideoConsoleButton.swift
//  Browser
//
//  Created by sagesse on 15/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class IBVideoConsoleButton: UIControl {
    
    func setImage(_ image: UIImage?, for state: UIControlState) {
        _allImages[state.rawValue] = image
        _updateState()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _imageView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        _contentView.layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
    
    override var isSelected: Bool {
        didSet {
            _updateState()
        }
    }
    override var isEnabled: Bool {
        didSet {
            _updateState()
        }
    }
    override var isHighlighted: Bool {
        didSet {
            _updateState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 禁止其他的所有手势(独占模式)
        return false
    }
    
    func _updateState() {
        let image = _allImages[state.rawValue] ?? nil
        
        _imageView.image = image
        _imageView.sizeToFit()
        _foregroundView.image = image
    }
    func _commonInit() {
        
        _imageView.alpha = 0.3
        _imageView.isUserInteractionEnabled = false
        
        _contentView.frame = bounds
        _contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        _contentView.isUserInteractionEnabled = false
        _contentView.layer.masksToBounds = true
        
        _contentView.addSubview(_backgroundView)
        _contentView.addSubview(_foregroundView)
        
        _foregroundView.frame = bounds
        _foregroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _foregroundView.isUserInteractionEnabled = false
        _foregroundView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        _effect = _backgroundView.effect
        _backgroundView.frame = bounds
        _backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _backgroundView.isUserInteractionEnabled = false
        
        addSubview(_contentView)
        addSubview(_imageView)
    }
    
    private var _effect: UIVisualEffect?
    private lazy var _allImages: [UInt: UIImage?] = [:]
    
    private lazy var _imageView = UIImageView(frame: .zero)
    private lazy var _contentView = UIView(frame: .zero)
    
    private lazy var _foregroundView = IBVideoConsoleBackgroundView(frame: .zero)
    private lazy var _backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
}
