//
//  SAPPickerAlbumsStackView.swift
//  SAC
//
//  Created by SAGESSE on 9/21/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos

internal class SAPPickerAlbumsStackView: UIView {
    
    var album: SAPAlbum? {
        didSet {
            guard let newValue = album else {
                return
            }
            guard let newResult = newValue.fetchResult else {
                // is empty
                _updateIcon(.normal)
                _updatePhotos([])
                return 
            }
            let range = NSMakeRange(max(newValue.count - 3, 0), min(3, newValue.count))
            
            _updateIcon(SAPBadge(collectionSubtype: newValue.subtype))
            _updatePhotos(newValue.photos(with: newResult, in: range).reversed())
        }
    }
    
    override func progressiveValue(_ progressiveValue: Progressiveable?, didChangeContent value: Any?, context: String) {
        guard let index = Int(context) else {
            return
        }
        _imageLayers[index].contents = (value as? UIImage)?.cgImage
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let h = bounds.height
        let w = bounds.width
        let sw: CGFloat = 4
        
        _imageLayers.enumerated().forEach {
            let fidx = CGFloat($0)
            var nframe = CGRect(x: 0, y: 0, width: w - sw * fidx, height: h - sw * fidx)
            nframe.origin.x = (w - nframe.width) / 2
            nframe.origin.y = (0 - (sw / 2) * fidx)
            $1.frame = nframe
        }
    }
    
    private func _updateIcon(_ badge: SAPBadge) {
        guard badge != .normal else {
            // removew
            _badgeView?.removeFromSuperview()
            _badgeView = nil
            
            return
        }
        guard _badgeView?.superview == nil else {
            // is exists
            _badgeView?.badge = badge
            return
        }
        
        let view = SAPBadgeView()
        _badgeView = view
        
        
        //photo_icon_thumbnail_loading
        
        let st: CGFloat = 0.5
        
        view.badge = badge
        view.tintColor = .white
        view.frame = CGRect(x: st, y: bounds.height - 24 - st, width: bounds.width - st * 2, height: 24)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(view)
    }
    private func _updatePhotos(_ photos: [SAPAsset]) {
        //_logger.trace(photos.count)
        
        // 更新内容
        var size = bounds.size
        
        size.width *= UIScreen.main.scale
        size.height *= UIScreen.main.scale
        
        _imageLayers.enumerated().forEach { 
            guard !photos.isEmpty else {
                // 这是一个空的相册
                $0.element.isHidden = false
                $0.element.backgroundColor = UIColor(white: 0.9, alpha: 1).cgColor
                
                setProgressiveValue(nil, forKey: "\($0.offset)")
                return
            }
            guard $0.offset < photos.count else {
                // 这个相册并没有3张图片
                $0.element.isHidden = true
                $0.element.contentsGravity = kCAGravityResizeAspectFill
                
                setProgressiveValue(nil, forKey: "\($0.offset)")
                return
            }
            let photo = photos[$0.offset]
            
            $0.element.isHidden = false
            $0.element.backgroundColor = UIColor.white.cgColor
            
            setProgressiveValue(photo.imageItem(with: size), forKey: "\($0.offset)")
        }
        
        if photos.isEmpty {
            
            guard _iconView == nil else {
                return
            }
            
            let view = UIImageView()
            _iconView = view
            
            view.image = UIImage.sap_init(named: "photo_icon_empty_album")?.withRenderingMode(.alwaysTemplate)
            view.frame = bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.contentMode = .center
            view.tintColor = UIColor.gray
            
            addSubview(view)
            
        } else {
            
            _iconView?.image = nil
            _iconView?.removeFromSuperview()
            _iconView = nil
        }
    }
    
    private func _init() {
        //_logger.trace()
        
        _imageLayers = (0 ..< 3).map { index in
            let il = CALayer()
            
            il.masksToBounds = true
            il.borderWidth = 0.5
            il.borderColor = UIColor.white.cgColor
            il.contentsGravity = kCAGravityResizeAspectFill
            
            layer.insertSublayer(il, at: 0)
            
            return il
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    private var _iconView: UIImageView?
    private var _badgeView: SAPBadgeView?
    
    private lazy var _imageLayers: [CALayer] = []
}
