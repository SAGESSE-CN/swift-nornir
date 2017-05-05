//
//  ThumbView.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/5/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class ThumbView: UIView {

    // 缩图图, 0-3张
    var images: [UIImage?]? {
        didSet {
            _update(at: images)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self._setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _layers.enumerated().forEach {
            $1.frame = UIEdgeInsetsInsetRect(bounds, _inset(at: $0))
        }
    }
    
    func _inset(at index: Int) -> UIEdgeInsets {
        let sw = _inset * CGFloat(index)
        return .init(top: -sw, left: sw, bottom: sw * 3, right: sw)
    }
    func _update(at images: [UIImage?]?) {
        
        // 如果images为空, 显示空相册
        guard let images = images else {
            // 这是一个空的相册
            _layers.forEach {
                $0.isHidden = false
            }
            // 生成图标视图
            let view = UIImageView()
            
            view.image = UIImage.ub_init(named: "ubiquity_icon_empty_album")?.withRenderingMode(.alwaysTemplate)
            view.frame = bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.contentMode = .center
            view.tintColor = .gray
            
            addSubview(view)
            _iconView = view
            return
        }
        // 显示的时候清除
        _iconView?.removeFromSuperview()
        _iconView = nil
        
        // 更新缩略图
        _layers.enumerated().forEach {
            // 检查是否包含该图片
            guard $0 < images.count else {
                // 超出隐藏
                $1.isHidden = true
                $1.contents = nil
                return
            }
            // 更新图片
            $1.isHidden = false
            $1.contents = images[$0]?.cgImage
        }
        
    }
    
    private func _setup() {
        
        // setup layer
        _layers.reversed().forEach {
            $0.backgroundColor = Browser.ub_backgroundColor?.cgColor
            layer.addSublayer($0)
        }
    }
    
    private var _inset: CGFloat = 2
    private var _iconView: UIImageView?
    
    private lazy var _layers: [CALayer] = (0 ..< 3).map { _ in
        let layer = CALayer()
        
        layer.masksToBounds = true
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.white.cgColor
        layer.contentsGravity = kCAGravityResizeAspectFill
        
        return layer
    }
}
//    var album: SAPAlbum? {
//        didSet {
//            guard let newValue = album else {
//                return
//            }
//            guard let newResult = newValue.fetchResult else {
//                // is empty
//                _updateIcon(.normal)
//                _updatePhotos([])
//                return 
//            }
//            let range = NSMakeRange(max(newValue.count - 3, 0), min(3, newValue.count))
//            
//            _updateIcon(SAPBadge(collectionSubtype: newValue.subtype))
//            _updatePhotos(newValue.photos(with: newResult, in: range).reversed())
//        }
//    }
//    
//    override func progressiveValue(_ progressiveValue: Progressiveable?, didChangeContent value: Any?, context: String) {
//        guard let index = Int(context) else {
//            return
//        }
//        _imageLayers[index].contents = (value as? UIImage)?.cgImage
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        let h = bounds.height
//        let w = bounds.width
//        let sw: CGFloat = 4
//        
//        _imageLayers.enumerated().forEach {
//            let fidx = CGFloat($0)
//            var nframe = CGRect(x: 0, y: 0, width: w - sw * fidx, height: h - sw * fidx)
//            nframe.origin.x = (w - nframe.width) / 2
//            nframe.origin.y = (0 - (sw / 2) * fidx)
//            $1.frame = nframe
//        }
//    }
//    
//    private func _updateIcon(_ badge: SAPBadge) {
//        guard badge != .normal else {
//            // removew
//            _badgeView?.removeFromSuperview()
//            _badgeView = nil
//            
//            return
//        }
//        guard _badgeView?.superview == nil else {
//            // is exists
//            _badgeView?.badge = badge
//            return
//        }
//        
//        let view = SAPBadgeView()
//        _badgeView = view
//        
//        
//        //photo_icon_thumbnail_loading
//        
//        let st: CGFloat = 0.5
//        
//        view.badge = badge
//        view.tintColor = .white
//        view.frame = CGRect(x: st, y: bounds.height - 24 - st, width: bounds.width - st * 2, height: 24)
//        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        
//        addSubview(view)
//    }
//    private func _updatePhotos(_ photos: [SAPAsset]) {
//        //_logger.trace(photos.count)
//        
//        // 更新内容
//        var size = bounds.size
//        
//        size.width *= UIScreen.main.scale
//        size.height *= UIScreen.main.scale
//        
//        _imageLayers.enumerated().forEach { 
//            guard !photos.isEmpty else {
//                // 这是一个空的相册
//                $0.element.isHidden = false
//                $0.element.backgroundColor = UIColor(white: 0.9, alpha: 1).cgColor
//                
//                setProgressiveValue(nil, forKey: "\($0.offset)")
//                return
//            }
//            guard $0.offset < photos.count else {
//                // 这个相册并没有3张图片
//                $0.element.isHidden = true
//                $0.element.contentsGravity = kCAGravityResizeAspectFill
//                
//                setProgressiveValue(nil, forKey: "\($0.offset)")
//                return
//            }
//            let photo = photos[$0.offset]
//            
//            $0.element.isHidden = false
//            $0.element.backgroundColor = UIColor.white.cgColor
//            
//            setProgressiveValue(photo.imageItem(with: size), forKey: "\($0.offset)")
//        }
//        
//        if photos.isEmpty {
//            
//            guard _iconView == nil else {
//                return
//            }
//            
//            let view = UIImageView()
//            _iconView = view
//            
//            view.image = UIImage.sap_init(named: "photo_icon_empty_album")?.withRenderingMode(.alwaysTemplate)
//            view.frame = bounds
//            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            view.contentMode = .center
//            view.tintColor = UIColor.gray
//            
//            addSubview(view)
//            
//        } else {
//            
//            _iconView?.image = nil
//            _iconView?.removeFromSuperview()
//            _iconView = nil
//        }
//    }
//    
//    private func _init() {
//        //_logger.trace()
//        
//        _imageLayers = (0 ..< 3).map { index in
//            let il = CALayer()
//            
//            il.masksToBounds = true
//            il.borderWidth = 0.5
//            il.borderColor = UIColor.white.cgColor
//            il.contentsGravity = kCAGravityResizeAspectFill
//            
//            layer.insertSublayer(il, at: 0)
//            
//            return il
//        }
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        _init()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        _init()
//    }
//    
//    private var _iconView: UIImageView?
//    private var _badgeView: SAPBadgeView?
//    
//    private lazy var _imageLayers: [CALayer] = []
