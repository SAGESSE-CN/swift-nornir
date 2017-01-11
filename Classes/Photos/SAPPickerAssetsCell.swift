//
//  SAPPickerAssetsCell.swift
//  SAC
//
//  Created by SAGESSE on 9/21/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit


internal class SAPPickerAssetsCell: UICollectionViewCell {
    
    var album: SAPAlbum?
    
    lazy var photoView: SAPAssetView = SAPAssetView()
    
    override var contentView: UIView {
        return photoView
    }
    
    private func _init() {
        
        backgroundColor = UIColor(white: 0, alpha: 0.1)
        
        //let s = 1 / UIScreen.main.scale
        //photoView.frame = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(s, s, s, s))
        
        photoView.frame = bounds
        photoView.allowsSelection = true
        photoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        super.contentView.removeFromSuperview()
        addSubview(contentView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
