//
//  SAPPickerAssetsFooter.swift
//  SAC
//
//  Created by SAGESSE on 10/21/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

internal class SAPPickerAssetsFooter: UICollectionReusableView {
    
    var title: String? {
        set { return _titleLabel.text = newValue }
        get { return _titleLabel.text }
    }
    
    private func _init() {
        
        _titleLabel.frame = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(10, 0, 0, 0))
        _titleLabel.textAlignment = .center
        _titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(_titleLabel)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    private lazy var _titleLabel: UILabel = UILabel()
}
