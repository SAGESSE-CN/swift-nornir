//
//  SAIAudioPlayToolbar.swift
//  SAC
//
//  Created by SAGESSE on 9/17/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

internal class SAIAudioPlayToolbar: UIView {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: -1, height: 44)
    }
    
    internal var confirmButton: UIButton {
        return _confirmButton
    }
    internal var cancelButton: UIButton {
        return _cancelButton
    }
    
    private func _init() {
        _logger.trace()
        
        let nImage = UIImage.sai_init(named: "keyboard_audio_toolbar_btn_nor")
        let hImage = UIImage.sai_init(named: "keyboard_audio_toolbar_btn_press")
        
        _confirmButton.setTitle("发送", for: UIControlState())
        _confirmButton.setTitleColor(.gray, for: .normal)
        _confirmButton.setTitleColor(.gray, for: .disabled)
        _confirmButton.setBackgroundImage(nImage, for: .normal)
        _confirmButton.setBackgroundImage(nImage, for: .disabled)
        _confirmButton.setBackgroundImage(hImage, for: .highlighted)
        _confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        _cancelButton.setTitle("取消", for: UIControlState())
        _cancelButton.setTitleColor(.gray, for: UIControlState())
        _cancelButton.setBackgroundImage(nImage, for: .normal)
        _cancelButton.setBackgroundImage(hImage, for: .highlighted)
        _cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(_cancelButton)
        addSubview(_confirmButton)
        
        addConstraint(_SAILayoutConstraintMake(_cancelButton, .top, .equal, self, .top))
        addConstraint(_SAILayoutConstraintMake(_cancelButton, .left, .equal, self, .left))
        addConstraint(_SAILayoutConstraintMake(_cancelButton, .bottom, .equal, self, .bottom))
        
        addConstraint(_SAILayoutConstraintMake(_cancelButton, .right, .equal, _confirmButton, .left))
        addConstraint(_SAILayoutConstraintMake(_cancelButton, .width, .equal, _confirmButton, .width))
        
        addConstraint(_SAILayoutConstraintMake(_confirmButton, .top, .equal, self, .top))
        addConstraint(_SAILayoutConstraintMake(_confirmButton, .right, .equal, self, .right))
        addConstraint(_SAILayoutConstraintMake(_confirmButton, .bottom, .equal, self, .bottom))
    }
    
    private lazy var _cancelButton: UIButton = UIButton()
    private lazy var _confirmButton: UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
