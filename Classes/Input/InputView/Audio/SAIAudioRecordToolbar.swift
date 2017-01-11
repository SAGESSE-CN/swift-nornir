//
//  SAIAudioRecordToolbar.swift
//  SAC
//
//  Created by SAGESSE on 9/16/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

internal class SAIAudioRecordToolbar: UIView {
    
    var leftView: UIImageView { return _leftView }
    var rightView: UIImageView { return _rightView }
    
    var leftBackgroundView: UIImageView { return _leftBackgroundView }
    var rightBackgroundView: UIImageView { return _rightBackgroundView }
    
    private func _init() {
        _logger.trace()
        
        _line.image = UIImage.sai_init(named: "keyboard_audio_toolbar_op_line")
        _line.translatesAutoresizingMaskIntoConstraints = false
        
        _leftView.image = UIImage.sai_init(named: "keyboard_audio_toolbar_op_listen_nor")
        _leftView.highlightedImage = UIImage.sai_init(named: "keyboard_audio_toolbar_op_listen_press")
        _leftView.translatesAutoresizingMaskIntoConstraints = false
        
        _rightView.image = UIImage.sai_init(named: "keyboard_audio_toolbar_op_delete_nor")
        _rightView.highlightedImage = UIImage.sai_init(named: "keyboard_audio_toolbar_op_delete_press")
        _rightView.translatesAutoresizingMaskIntoConstraints = false
        
        _leftBackgroundView.image = UIImage.sai_init(named: "keyboard_audio_toolbar_op_nor")
        _leftBackgroundView.highlightedImage = UIImage.sai_init(named: "keyboard_audio_toolbar_op_press")
        _leftBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        _rightBackgroundView.image = UIImage.sai_init(named: "keyboard_audio_toolbar_op_nor")
        _rightBackgroundView.highlightedImage = UIImage.sai_init(named: "keyboard_audio_toolbar_op_press")
        _rightBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        // add subview
        addSubview(_line)
        addSubview(_leftBackgroundView)
        addSubview(_rightBackgroundView)
        addSubview(_leftView)
        addSubview(_rightView)
        
        // add constraint s
        addConstraint(_SAILayoutConstraintMake(_line, .top, .equal, self, .top, 14))
        addConstraint(_SAILayoutConstraintMake(_line, .left, .equal, self, .left, 3.5))
        addConstraint(_SAILayoutConstraintMake(_line, .right, .equal, self, .right, -3.5))
        addConstraint(_SAILayoutConstraintMake(_line, .bottom, .equal, self, .bottom))
        
        addConstraint(_SAILayoutConstraintMake(_leftBackgroundView, .top, .equal, self, .top))
        addConstraint(_SAILayoutConstraintMake(_leftBackgroundView, .left, .equal, self, .left))
        
        addConstraint(_SAILayoutConstraintMake(_rightBackgroundView, .top, .equal, self, .top))
        addConstraint(_SAILayoutConstraintMake(_rightBackgroundView, .right, .equal, self, .right))
        
        addConstraint(_SAILayoutConstraintMake(_leftView, .centerX, .equal, _leftBackgroundView, .centerX))
        addConstraint(_SAILayoutConstraintMake(_leftView, .centerY, .equal, _leftBackgroundView, .centerY))
        addConstraint(_SAILayoutConstraintMake(_rightView, .centerX, .equal, _rightBackgroundView, .centerX))
        addConstraint(_SAILayoutConstraintMake(_rightView, .centerY, .equal, _rightBackgroundView, .centerY))
    }
    
    private lazy var _line: UIImageView = UIImageView()
    
    private lazy var _leftView: UIImageView = UIImageView()
    private lazy var _rightView: UIImageView = UIImageView()
    
    private lazy var _leftBackgroundView: UIImageView = UIImageView()
    private lazy var _rightBackgroundView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
}
