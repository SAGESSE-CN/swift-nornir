//
//  IBBadgeBar.swift
//  Browser
//
//  Created by sagesse on 20/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

enum IBBadgeBarItemStyle {
    
    case burst
    case favorites
    case panorama
    case screenshots
    case selfies
    case slomo
    case timelapse
    case video
    
    case recentlyDeleted
    case lastImport
    
    case loading
    
    fileprivate var imageName: String {
        switch self {
        case .burst:            return "browse_badge_burst"
        case .favorites:        return "browse_badge_favorites"
        case .panorama:         return "browse_badge_panorama"
        case .screenshots:      return "browse_badge_screenshots"
        case .selfies:          return "browse_badge_selfies"
        case .slomo:            return "browse_badge_slomo"
        case .timelapse:        return "browse_badge_timelapse"
        case .video:            return "browse_badge_video"
            
        case .recentlyDeleted:  return "browse_badge_recentlyDeleted"
        case .lastImport:       return "browse_badge_lastImport"
            
        case .loading:          return "browse_badge_loading"
        }
    }
}

class IBBadgeBarItem {
    
    init(title: String) {
        self.title = title
    }
    init(image: UIImage?) {
        self.image = image
    }
    convenience init(style: IBBadgeBarItemStyle) {
        // 缓存
        var icon = UIImage(named: style.imageName)
        if style != .loading {
            icon = icon?.withRenderingMode(.alwaysTemplate)
        }
        self.init(image: icon)
    }
    
    var title: String?
    var image: UIImage?
}

class IBBadgeBar: UIView {
    
    var backgroundImage: UIImage? {
        willSet {
            layer.contents = newValue?.cgImage
        }
    }
    
    var leftBarItems: [IBBadgeBarItem]? {
        didSet {
            _needUpdateVisableViews = true
            setNeedsLayout()
        }
    }
    var rightBarItems: [IBBadgeBarItem]? {
        didSet {
            _needUpdateVisableViews = true
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _updateVisableViewsIfNeeded()
        _updateVisableViewLayoutIfNeeded()
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        _leftViews.forEach { 
            guard let label = $0 as? UILabel else {
                return
            }
            label.textColor = tintColor
        }
        _rightViews.forEach { 
            guard let label = $0 as? UILabel else {
                return
            }
            label.textColor = tintColor
        }
    }
    
    private func _updateVisableViewsIfNeeded() {
        guard _needUpdateVisableViews else {
            return
        }
        _needUpdateVisableViews = false
        
        _leftViews.forEach { 
            $0.removeFromSuperview()
        }
        _rightViews.forEach { 
            $0.removeFromSuperview()
        }
        
        _leftViews = leftBarItems?.map { item -> UIView in
            let view = _createView(with: item)
            addSubview(view)
            return view
        } ?? []
        _rightViews = rightBarItems?.map { item -> UIView in
            let view = _createView(with: item)
            addSubview(view)
            return view
        } ?? []
        _cacheBounds = nil
    }
    private func _updateVisableViewLayoutIfNeeded() {
        guard _cacheBounds?.size != self.bounds.size else {
            return
        }
        _cacheBounds = self.bounds
        
        let sp = CGFloat(2)
        let edg = UIEdgeInsetsMake(2, 4, 2, 4)
        let bounds = UIEdgeInsetsInsetRect(self.bounds, edg)
        
        _ = _leftViews.reduce(bounds.minX) { x, view in
            var nframe = CGRect(x: x, y: bounds.minY, width: 0, height: 0)
            
            let size = view.sizeThatFits(bounds.size)
            
            nframe.size.width = size.width
            nframe.size.height = min(size.height, bounds.height)
            nframe.origin.x = x
            nframe.origin.y = bounds.minY + (bounds.height - nframe.height) / 2
            
            view.frame = nframe
            return x + nframe.width + sp
        }
        _ = _rightViews.reduce(bounds.maxX) { x, view in
            var nframe = CGRect(x: x, y: bounds.minY, width: 0, height: 0)
            
            let size = view.sizeThatFits(bounds.size)
            
            nframe.size.width = size.width
            nframe.size.height = min(size.height, bounds.height)
            nframe.origin.x = x - nframe.width
            nframe.origin.y = bounds.minY + (bounds.height - nframe.height) / 2
            
            view.frame = nframe
            return x - nframe.width - sp
        }
    }
    
    private func _createView(with item: IBBadgeBarItem) -> UIView {
        if let image = item.image {
            let view = UIImageView(image: image)
            view.contentMode = .center
            return view
        }
        if let title = item.title {
            let label = UILabel()
            
            label.text = title
            label.textColor = tintColor
            label.font = UIFont.systemFont(ofSize: 12)
            //label.adjustsFontSizeToFitWidth = true
            
            return label
        }
        return UIView()
    }
    
    private var _cacheBounds: CGRect?
    private var _needUpdateVisableViews: Bool = true
    
    private lazy var _leftViews: [UIView] = []
    private lazy var _rightViews: [UIView] = []
}

