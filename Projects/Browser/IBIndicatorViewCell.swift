//
//  IBIndicatorViewCell.swift
//  Browser
//
//  Created by sagesse on 11/22/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class IBIndicatorViewCell: IBTilingViewCell {
    
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
            
            _imageView.image = newValue?.browseImage
            _imageView.backgroundColor = newValue?.backgroundColor
            
            _contentSize = newValue?.browseContentSize
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let size = _contentSize else {
            return
        }
        var nframe = CGRect(origin: .zero, size: _fitContentSize ?? .zero)
        if _cacheContentSize != size || _fitContentSize == nil {
            let fit = _convert(size, from: bounds)
            nframe.size = fit
            _fitContentSize = fit
            _cacheContentSize = size
            _cacheBounds = nil
        }
        if _cacheBounds != bounds {
            
            nframe.size.width = min(nframe.width, bounds.width)
            nframe.size.height = min(nframe.height, bounds.height)
            nframe.origin.x = (bounds.width - nframe.width) / 2
            nframe.origin.y = (bounds.height - nframe.height) / 2
            
            _imageView.frame = nframe
            _cacheBounds = bounds
        }
    }
    
    private func _convert(_ size: CGSize, from rect: CGRect) -> CGSize {
        guard size.height > 0 && rect.height > 0 else {
            return .zero
        }
        let scale = rect.height / size.height
        return CGSize(width: size.width * scale, height: size.height * scale)
    }
    
    private func _commonInit() {
        
        _imageView.frame = bounds
        _imageView.contentMode = .scaleAspectFill
        _imageView.clipsToBounds = true
        
        addSubview(_imageView)
    }
    
    private var _fitContentSize: CGSize?
    private var _contentSize: CGSize? {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var _cacheBounds: CGRect?
    private var _cacheContentSize: CGSize?
    
    private lazy var _imageView: UIImageView = UIImageView()
}
