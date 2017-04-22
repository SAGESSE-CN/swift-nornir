//
//  ConsoleView.swift
//  Ubiquity
//
//  Created by SAGESSE on 4/19/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class ConsoleProxy: NSObject, CAAnimationDelegate {
    
    init(frame: CGRect, owner: UIView) {
        _owner = owner
        _bounds = .init(origin: .zero, size: frame.size)
        _center = .init(x: frame.midX, y: frame.midY)
        _forwarder = EventCenter()
        super.init()
    }
    
    var bounds: CGRect {
        set {
            _bounds = newValue
            _consoleView?.bounds = newValue
        }
        get { return _bounds }
    }
    var center: CGPoint {
        set {
            _center = newValue
            _consoleView?.center = newValue
        }
        get { return _center }
    }
    
    func setState(_ state: ConsoleView.State, animated: Bool) {
        logger.trace?.write(state, animated)
        
        _updateState(state, animated: animated)
        _state = state
    }
    
    func setIsHidden(_ isHidden: Bool, animated: Bool) {
        logger.trace?.write(isHidden, animated)
        
        _updateState(_state, animated: animated, isForceHidden: isHidden)
    }
    
    func addTarget(_ target: AnyObject, action: Selector, for controlEvents: UIControlEvents) {
        logger.trace?.write()
        
        _forwarder.addTarget(target, action: action, for: controlEvents)
    }
    func removeTarget(_ target: AnyObject?, action: Selector?, for controlEvents: UIControlEvents) {
        logger.trace?.write()
        
        _forwarder.removeTarget(target, action: action, for: controlEvents)
    }
    
    private func _updateState(_ state: ConsoleView.State, animated: Bool, isForceHidden: Bool? = nil) {
        
        let isNone = (state == .none)
        let isHidden = (isForceHidden ?? isNone) || isNone
        
        // if consoleView not found, automatically create
        let consoleView = _consoleView ?? {
            let consoleView = ConsoleView(frame: .zero)
            
            consoleView.bounds = bounds
            consoleView.center = center
            consoleView.alpha = 0
            
            _owner.addSubview(consoleView)
            _forwarder.apply(consoleView)
            _consoleView = consoleView
            
            return consoleView
        }()
        
        // need animation?
        guard animated else {
            // no
            consoleView.alpha = 1
            consoleView.isHidden = isHidden
            consoleView.setState(state, animated: animated)
            // if it is none, remove consoleview
            guard isNone else {
                return
            }
            _consoleView?.removeFromSuperview()
            _consoleView = nil
            return
        }
        
        let from: Float = consoleView.layer.presentation()?.opacity ?? consoleView.layer.opacity
        let to: Float = isHidden ? 0 : 1
        // don't use block the animation because
        // he could not continue to animation from the previous value画
        let ani = CABasicAnimation(keyPath: "opacity")
        ani.fromValue = from
        ani.toValue = to
        ani.duration = TimeInterval(fabs(from - to)) * 0.25
        ani.delegate = self
        consoleView.layer.opacity = to
        consoleView.layer.add(ani, forKey: "opacity")
        // upload state
        UIView.animate(withDuration: 0.25, animations: {
            consoleView.setState(state, animated: animated)
        })
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard _state == .none, flag else {
            return
        }
        // state is none, remove
        _consoleView?.removeFromSuperview()
        _consoleView = nil
    }
    
    private var _bounds: CGRect
    private var _center: CGPoint
    
    private var _state: ConsoleView.State = .none
    private var _isHidden: Bool = true
    
    private var _owner: UIView
    private var _forwarder: EventCenter
    private var _consoleView: ConsoleView?
}

internal class ConsoleView: UIControl {
    
    internal enum State: Int {
        case none
        case waiting
        case playing
        case stop
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    override var isSelected: Bool {
        didSet {
            _videoButton.isSelected = isSelected
        }
    }
    override var isEnabled: Bool {
        didSet {
            _videoButton.isEnabled = isSelected
        }
    }
    
    func setState(_ state: State, animated: Bool) {
        _state = state
        
        switch state {
        case .none:
            _videoButton.alpha = 1
            _indicatorView.alpha = 0
            _indicatorView.stopAnimating()
            
        case .playing:
            _videoButton.alpha = 0
            _indicatorView.alpha = 0
            _indicatorView.stopAnimating()
            
        case .stop:
            _videoButton.alpha = 1
            _indicatorView.alpha = 0
            _indicatorView.stopAnimating()
        
        case .waiting:
            _videoButton.alpha = 0
            _indicatorView.alpha = 1
            _indicatorView.startAnimating()
        }
        
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // only need to stop state operation event
        guard _state == .stop else {
            return false
        }
        return super.point(inside: point, with: event)
    }
    
    private func _setup() {
        
        let image = UIImage.ub_init(named: "ubiquity_button_play")
        
        // setup video button
        _videoButton.frame = bounds
        _videoButton.setImage(image, for: .normal)
        _videoButton.isUserInteractionEnabled = false
        _videoButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // setup indicator
        _indicatorView.frame = bounds
        _indicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(_videoButton)
        addSubview(_indicatorView)
    }
    
    private var _state: State = .none
    
    private lazy var _videoButton: ConsoleVideoButton = .init(frame: .zero)
    private lazy var _indicatorView: UIActivityIndicatorView = .init(activityIndicatorStyle: .whiteLarge)
}

internal class ConsoleVideoButton: UIControl {
    
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
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 禁止其他的所有手势(独占模式)
        return false
    }
    
    private func _updateState() {
        let image = _allImages[state.rawValue] ?? nil
        
        _imageView.image = image
        _imageView.sizeToFit()
        _foregroundView.image = image
    }
    private func _setup() {
        
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
        
        _backgroundView.frame = bounds
        _backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _backgroundView.isUserInteractionEnabled = false
        
        addSubview(_contentView)
        addSubview(_imageView)
    }
    
    private lazy var _imageView: UIImageView = .init(frame: .zero)
    private lazy var _contentView: UIView = .init(frame: .zero)
    
    private lazy var _backgroundView: UIVisualEffectView = .init(effect: UIBlurEffect(style: .light))
    private lazy var _foregroundView: ConsoleVideoBackgroundView =  .init(frame: .zero)
    
    private lazy var _allImages: [UInt: UIImage?] = [:]
}
internal class ConsoleVideoBackgroundView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
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
    
    private func _setup() {
        super.backgroundColor = .clear
    }
    
    private var _backgroundColor: UIColor?
}
