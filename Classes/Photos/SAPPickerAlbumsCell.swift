//
//  SAPPickerAlbumsCell.swift
//  SAC
//
//  Created by SAGESSE on 9/21/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos

internal class SAPPickerAlbumsCell: UITableViewCell {

    var album: SAPAlbum? {
        didSet {
            guard let newValue = album else {
                return
            }
            let count = newValue.count
            
            _titleLabel.text = newValue.title
            _descriptionLabel.text = "\(count)"
            
            _stackView.layoutIfNeeded()
            _stackView.album = newValue
        }
    }
    
    private func _init() {
        
        _stackView.translatesAutoresizingMaskIntoConstraints = false
        
        _titleLabel.text = "Title"
        _titleLabel.font = UIFont.systemFont(ofSize: 18)
        _titleLabel.translatesAutoresizingMaskIntoConstraints = false
       
        _descriptionLabel.text = "Description"
        _descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        _descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(_stackView)
        contentView.addSubview(_titleLabel)
        contentView.addSubview(_descriptionLabel)
        
        addConstraint(_SAPLayoutConstraintMake(_stackView, .left, .equal, contentView, .left, 8))
        addConstraint(_SAPLayoutConstraintMake(_stackView, .centerY, .equal, contentView, .centerY))
        
        addConstraint(_SAPLayoutConstraintMake(_stackView, .width, .equal, _stackView, .height))
        addConstraint(_SAPLayoutConstraintMake(_stackView, .height, .equal, nil, .notAnAttribute, 70))
        
        addConstraint(_SAPLayoutConstraintMake(_titleLabel, .left, .equal, _stackView, .right, 8))
        addConstraint(_SAPLayoutConstraintMake(_titleLabel, .right, .equal, contentView, .right))
        addConstraint(_SAPLayoutConstraintMake(_titleLabel, .bottom, .equal, contentView, .centerY))
        
        addConstraint(_SAPLayoutConstraintMake(_descriptionLabel, .top, .equal, contentView, .centerY))
        addConstraint(_SAPLayoutConstraintMake(_descriptionLabel, .left, .equal, _stackView, .right, 8))
        addConstraint(_SAPLayoutConstraintMake(_descriptionLabel, .right, .equal, contentView, .right))
    }
    
    private lazy var _stackView: SAPPickerAlbumsStackView = SAPPickerAlbumsStackView()
    private lazy var _titleLabel: UILabel = UILabel()
    private lazy var _descriptionLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
