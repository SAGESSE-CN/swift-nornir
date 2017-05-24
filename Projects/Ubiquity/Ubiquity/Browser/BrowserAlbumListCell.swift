//
//  BrowserAlbumListCell.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/4/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserAlbumListCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    func willDisplay(with collection: Collection, library: Library) {
        //logger.trace?.write(collection.ub_localIdentifier)
        
        let count = collection.ub_assetCount
        let assets = collection.ub_assets(at: max(count - 3, 0) ..< count)
        
        // setup content
        _titleLabel.text = collection.ub_localizedTitle
        _subtitleLabel.text = "\(count)"
        
        // setup badge icon & background
        if let icon = BadgeView.Item.ub_init(subtype: collection.ub_collectionSubtype) {
            // show icon
            _badgeView.leftItems = [icon]
            _badgeView.backgroundImage = BadgeView.ub_backgroundImage
            
        } else {
            // hide icon
            _badgeView.leftItems = nil
            _badgeView.backgroundImage = nil
        }
        
        // setup thumb image
        _thumbView.images = assets.map { asset in
            
            return nil
        }
    }
    func endDisplay(with collection: Collection, library: Library) {
        //logger.trace?.write(collection.ub_localIdentifier)
        
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
        _titleLabel.font = .preferredFont(forTextStyle: .body)
        _titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(_titleLabel)
        
        // setup subtitle label
        _subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(_subtitleLabel)
        
        // setup constraints
        contentView.addConstraints([
            
            .ub_make(_thumbView, .leading, .equal, contentView, .leading, 16),
            .ub_make(_thumbView, .centerY, .equal, contentView, .centerY),
            
            .ub_make(_thumbView, .width, .equal, nil, .notAnAttribute, 70),
            .ub_make(_thumbView, .height, .equal, nil, .notAnAttribute, 70),
            
            .ub_make(_titleLabel, .bottom, .equal, contentView, .centerY, -2),
            .ub_make(_titleLabel, .leading, .equal, _thumbView, .trailing, 8),
            .ub_make(_titleLabel, .trailing, .equal, contentView, .trailing),
            
            .ub_make(_subtitleLabel, .top, .equal, contentView, .centerY, 2),
            .ub_make(_subtitleLabel, .leading, .equal, _thumbView, .trailing, 8),
            .ub_make(_subtitleLabel, .trailing, .equal, contentView, .trailing),
        ])
        
    }
    
    private lazy var _titleLabel: UILabel = .init()
    private lazy var _subtitleLabel: UILabel = .init()
    
    private lazy var _thumbView: ThumbView = .init()
    private lazy var _badgeView: BadgeView = .init()
}

