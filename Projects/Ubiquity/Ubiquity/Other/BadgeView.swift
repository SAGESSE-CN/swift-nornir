//
//  BadgeView.swift
//  Ubiquity
//
//  Created by SAGESSE on 4/18/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BadgeView: UIView {
    /// displayable item
    internal class Item: NSObject {
        
        static var downloading  = Item(named: "ubiquity_badge_downloading", render: .alwaysOriginal)
        
        static var burst        = Item(named: "ubiquity_badge_burst")
        static var favorites    = Item(named: "ubiquity_badge_favorites")
        static var panorama     = Item(named: "ubiquity_badge_panorama")
        static var screenshots  = Item(named: "ubiquity_badge_screenshots")
        static var selfies      = Item(named: "ubiquity_badge_selfies")
        static var slomo        = Item(named: "ubiquity_badge_slomo")
        static var timelapse    = Item(named: "ubiquity_badge_timelapse")
        static var video        = Item(named: "ubiquity_badge_video")
        
        static var recentlyDeleted  = Item(named: "ubiquity_badge_recentlyDeleted")
        static var lastImport       = Item(named: "ubiquity_badge_lastImport")
        
        static func text(_ value: String) -> Item {
            return Item(text: value)
        }
        static func image(_ value: UIImage?) -> Item {
            return Item(image: value)
        }
        
        private init(text: String) {
            self.text = text
            super.init()
        }
        private init(image: UIImage?) {
            self.image = image
            super.init()
        }
        private convenience init(named: String, render: UIImageRenderingMode = .alwaysTemplate) {
            let icon = UIImage.ub_init(named: named)?.withRenderingMode(render)
            self.init(image: icon)
        }
        
        var text: String?
        var image: UIImage?
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        //_updateBackgroundImage()
        _needUpdateVisableViews = true
    }
    
    var leftItems: Array<Item>? {
        didSet {
            _needUpdateVisableViews = true
            setNeedsLayout()
        }
    }
    var rightItems: Array<Item>? {
        didSet {
            _needUpdateVisableViews = true
            setNeedsLayout()
        }
    }
    var backgroundImage: UIImage? {
        didSet {
            _updateBackgroundImage()
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
    
    private func _updateBackgroundImage() {
        guard let newValue = backgroundImage else {
            let image: UIImage? = _backgroundImage ?? {
                let image = UIImage.ub_init(named: "ubiquity_background_gradient")
                _backgroundImage = image
                return image
            }()
            layer.contents = image?.cgImage
            return
        }
        layer.contents = newValue.cgImage
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
        
        _leftViews = leftItems?.map { item -> UIView in
            let view = _createView(with: item)
            addSubview(view)
            return view
        } ?? []
        _rightViews = rightItems?.map { item -> UIView in
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
    
    private func _createView(with item: Item) -> UIView {
        if let image = item.image {
            let view = UIImageView(image: image)
            view.contentMode = .center
            return view
        }
        if let title = item.text {
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

private weak var _backgroundImage: UIImage?

