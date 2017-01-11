//
//  IBVideoConsoleView.swift
//  Browser
//
//  Created by sagesse on 16/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


@objc protocol IBVideoConsoleViewDelegate {
    
    @objc optional func videoConsoleView(shouldPlay videoConsoleView: IBVideoConsoleView) -> Bool
    @objc optional func videoConsoleView(didPlay videoConsoleView: IBVideoConsoleView)
    
    @objc optional func videoConsoleView(shouldStop videoConsoleView: IBVideoConsoleView) -> Bool
    @objc optional func videoConsoleView(didStop videoConsoleView: IBVideoConsoleView)
}

class IBVideoConsoleView: UIView {
    enum State {
        case none
        case playing
        case waiting
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    weak var delegate: IBVideoConsoleViewDelegate?
    
    func play() {
        _updateState(.playing, animated: true)
    }
    func wait() {
        _updateState(.waiting, animated: true)
    }
    func stop() {
        _updateState(.none, animated: true)
    }
    
    func updateFocus(_ focus: Bool, animated: Bool) {
        guard _state == .none else {
            return
        }
        UIView.animate(withDuration: 0.25, animations: {
            self._operatorView.alpha = focus ? 1 : 0
        })
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard _operatorView.superview == self else {
            return false
        }
        return super.point(inside: point, with: event)
    }
    
    func operatorHandler(_ sender: Any) {
        if _state != .none {
            // stop
            guard delegate?.videoConsoleView?(shouldStop: self) ?? true else {
                return
            }
            delegate?.videoConsoleView?(didStop: self)
        } else {
            // play
            guard delegate?.videoConsoleView?(shouldPlay: self) ?? true else {
                return
            }
            delegate?.videoConsoleView?(didPlay: self)
        }
    }
    
    private func _updateState(_ state: State, animated: Bool) {
        _state = state
        
        switch state {
        case .none:
            if _operatorView.superview != self {
                _operatorView.alpha = 0
                _operatorView.frame = bounds
                addSubview(_operatorView)
            }
            if !animated {
                _indicatorView.isHidden = false
                _indicatorView.stopAnimating()
                _indicatorView.removeFromSuperview()
                return
            }
            UIView.animate(withDuration: 0.25, animations: {
                
                self._operatorView.alpha = 1
                
            }, completion: { isFinished in
                
                self._indicatorView.isHidden = false
                self._indicatorView.stopAnimating()
                self._indicatorView.removeFromSuperview()
            })
        
        case .waiting:
            if _indicatorView.superview != self {
                _indicatorView.isHidden = true
                _indicatorView.frame = bounds
                addSubview(_indicatorView)
            }
            if !animated {
                _operatorView.alpha = 1
                _operatorView.removeFromSuperview() 
                _indicatorView.isHidden = false
                _indicatorView.startAnimating()
                return
            }
            UIView.animate(withDuration: 0.25, animations: {
                
                self._operatorView.alpha = 0
                
            }, completion: { isFinished in
                
                self._operatorView.alpha = 1
                self._operatorView.removeFromSuperview() 
                self._indicatorView.isHidden = false
                self._indicatorView.startAnimating()
            })
        
        case .playing:
            if !animated {
                _indicatorView.alpha = 1
                _indicatorView.stopAnimating()
                _indicatorView.removeFromSuperview()
                _operatorView.alpha = 1
                _operatorView.removeFromSuperview()
                return
            }
            UIView.animate(withDuration: 0.25, animations: {
                
                self._indicatorView.alpha = 0
                self._operatorView.alpha = 0
                
            }, completion: { isFinished in
                
                self._indicatorView.alpha = 1
                self._indicatorView.stopAnimating()
                self._indicatorView.removeFromSuperview()
                self._operatorView.alpha = 1
                self._operatorView.removeFromSuperview()
            })
        }
    }
    
    private func _commonInit() {
        
        _operatorView.frame = bounds
        _operatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _operatorView.addTarget(self, action: #selector(operatorHandler(_:)), for: .touchUpInside)
        
        _operatorView.setImage(UIImage(named: "browse_button_play"), for: .normal)
        _operatorView.setImage(UIImage(named: "browse_button_play"), for: .highlighted)
        
        _indicatorView.frame = bounds
        _indicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private var _state: State = .none
    
    private lazy var _indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    private lazy var _operatorView = IBVideoConsoleButton(frame: .zero)
}
