//
//  ErrorInfoView.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/24/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class ErrorInfoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    var title: String? {
        set { return _titleLabel.text = newValue }
        get { return _titleLabel.text }
    }
    
    var subtitle: String? {
        set { return _subtitleLabel.text = newValue }
        get { return _subtitleLabel.text }
    }
    
    
    private func _setup() {
        
        let view = UIView()
        
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        _titleLabel.font = UIFont.systemFont(ofSize: 28)
        _titleLabel.textColor = .lightGray
        _titleLabel.textAlignment = .center
        _titleLabel.numberOfLines = 0
        _titleLabel.translatesAutoresizingMaskIntoConstraints = false
        _titleLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        _titleLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        
        _subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        _subtitleLabel.textColor = .lightGray
        _subtitleLabel.textAlignment = .center
        _subtitleLabel.numberOfLines = 0
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // setup content view
        view.addSubview(_titleLabel)
        view.addSubview(_subtitleLabel)
        view.addConstraints([
            .ub_make(_titleLabel, .top, .equal, view, .top),
            .ub_make(_titleLabel, .left, .equal, view, .left),
            .ub_make(_titleLabel, .right, .equal, view, .right),
            
            .ub_make(_subtitleLabel, .top, .equal, _titleLabel, .bottom, 16),
            
            .ub_make(_subtitleLabel, .left, .equal, view, .left),
            .ub_make(_subtitleLabel, .right, .equal, view, .right),
            .ub_make(_subtitleLabel, .bottom, .equal, view, .bottom),
        ])
        
        // setup subview
        addSubview(view)
        addConstraints([
            .ub_make(view, .left, .equal, self, .left, 20),
            .ub_make(view, .right, .equal, self, .right, -20),
            .ub_make(view, .centerY, .equal, self, .centerY),
        ])
    }
    
    private lazy var _titleLabel = UILabel()
    private lazy var _subtitleLabel = UILabel()
}
