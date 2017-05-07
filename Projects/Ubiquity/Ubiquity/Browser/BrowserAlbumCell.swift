//
//  BrowserAlbumCell.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/4/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserAlbumCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self._setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._setup()
    }
    
    private func _setup() {
        
        // setup thumb
        _thumbView.frame = .init(x: 0, y: 0, width: 70, height: 70)
        _thumbView.backgroundColor = .white
        _thumbView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(_thumbView)
        
        // setup badge
        _badgeView.frame = UIEdgeInsetsInsetRect(_thumbView.bounds, UIEdgeInsetsMake(_thumbView.bounds.height - 24, 0.5, 0.5, 0.5))
        _badgeView.tintColor = .white
        _badgeView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        _thumbView.addSubview(_badgeView)
        
        // setup title
        _titleLabel.text = "All Photos"
        _titleLabel.font = .preferredFont(forTextStyle: .body)
        _titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(_titleLabel)
        
        // setup subtitle label
        _subtitleLabel.text = "956"
        _subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(_subtitleLabel)
        
        // setup constraints
        contentView.addConstraints([
            
            .make(_thumbView, .leading, .equal, contentView, .leading, 16),
            .make(_thumbView, .centerY, .equal, contentView, .centerY),
            
            .make(_thumbView, .width, .equal, nil, .notAnAttribute, 70),
            .make(_thumbView, .height, .equal, nil, .notAnAttribute, 70),
            
            .make(_titleLabel, .bottom, .equal, contentView, .centerY, -2),
            .make(_titleLabel, .leading, .equal, _thumbView, .trailing, 8),
            .make(_titleLabel, .trailing, .equal, contentView, .trailing),
            
            .make(_subtitleLabel, .top, .equal, contentView, .centerY, 2),
            .make(_subtitleLabel, .leading, .equal, _thumbView, .trailing, 8),
            .make(_subtitleLabel, .trailing, .equal, contentView, .trailing),
        ])
        
//        _thumbView.images = [
//            nil,//UIImage(named: "cl_1"),
//            nil,//UIImage(named: "cl_2"),
//            nil,//UIImage(named: "cl_3"),
//        ]
//        
//        _badgeView.backgroundImage = BadgeView.ub_backgroundImage
//        _badgeView.leftItems = [
//            .favorites
//        ]
        _thumbView.images = [nil, nil, nil]
    }
    
    private lazy var _titleLabel: UILabel = .init()
    private lazy var _subtitleLabel: UILabel = .init()
    
    private lazy var _thumbView: ThumbView = .init()
    private lazy var _badgeView: BadgeView = .init()
}

