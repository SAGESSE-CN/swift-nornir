//
//  BrowseViewCell.swift
//  Browser
//
//  Created by sagesse on 11/14/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class BrowseViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    var asset: Browseable? {
        willSet {
            guard asset !== newValue else {
                return
            }
            _previewView.backgroundColor = newValue?.backgroundColor
            _previewView.image = newValue?.browseImage
            
            _badgeBar.backgroundImage = UIImage(named: "browse_background_gradient")
            _badgeBar.leftBarItems = [.init(style: .video)]
            //_badgeBar.rightBarItems = [.init(style: .loading)]
            _badgeBar.rightBarItems = [.init(title: "9:99")]
        }
    }
    
    var previewView: UIImageView {
        return _previewView
    }
    
    private func _commonInit() {
        
        _previewView.contentMode = .scaleAspectFill
        _previewView.frame = contentView.bounds
        _previewView.clipsToBounds = true
        _previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        _badgeBar.frame = CGRect(x: 0, y: contentView.bounds.height - 20, width: contentView.bounds.width, height: 20)
        _badgeBar.tintColor = .white
        _badgeBar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        _badgeBar.isUserInteractionEnabled = false
        
        contentView.addSubview(_previewView)
        contentView.addSubview(_badgeBar)
    }
    
    private lazy var _previewView = UIImageView(frame: .zero)
    private lazy var _badgeBar = IBBadgeBar(frame: .zero)
}

