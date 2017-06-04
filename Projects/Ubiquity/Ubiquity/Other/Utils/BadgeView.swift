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
        
        static var recently     = Item(named: "ubiquity_badge_recently")
        static var lastImport   = Item(named: "ubiquity_badge_lastImport")
        
        static func text(_ value: String) -> Item {
            return Item(text: value)
        }
        static func image(_ value: UIImage?) -> Item {
            return Item(image: value)
        }
        
        private init(text: String) {
            self.text = text
            self.itemTpye = 0
            super.init()
        }
        private init(image: UIImage?) {
            self.image = image
            self.itemTpye = 1
            super.init()
        }
        private convenience init(named: String, render: UIImageRenderingMode = .alwaysTemplate) {
            let icon = UIImage.ub_init(named: named)?.withRenderingMode(render)
            self.init(image: icon)
        }
        
        var text: String?
        var image: UIImage?
        
        var itemTpye: Int
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    private func _setup() {
        //_updateBackgroundImage()
        _needUpdateVisableViews = true
    }
    
    var leftItem: Item? {
        set { return leftItems = newValue.map({ [$0] }) }
        get { return leftItems?.first }
    }
    var leftItems: Array<Item>? {
        set {
            let oldValue = _leftItems
            _leftItems = newValue ?? []
            // no need update, check it any change
            guard !_needUpdateVisableViews && !oldValue.elementsEqual(_leftItems) else {
                return
            }
            _needUpdateVisableViews = true
            setNeedsLayout()
        }
        get {
            return _leftItems
        }
    }
    
    var rightItem: Item? {
        set { return rightItems = newValue.map({ [$0] }) }
        get { return rightItems?.first }
    }
    var rightItems: Array<Item>? {
        set {
            let oldValue = _rightItems
            _rightItems = newValue ?? []
            // no need update, check it any change
            guard !_needUpdateVisableViews && !oldValue.elementsEqual(_rightItems) else {
                return
            }
            _needUpdateVisableViews = true
            setNeedsLayout()
        }
        get {
            return _rightItems
        }
    }
    
    var backgroundImage: UIImage? {
        didSet {
            guard oldValue !== backgroundImage else {
                return
            }
            _updateBackgroundImage()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _updateVisableViewsIfNeeded()
        _updateVisableViewLayoutIfNeeded()
    }
    
    private func _updateBackgroundImage() {
        layer.contents = backgroundImage?.cgImage
    }
    private func _updateVisableViewsIfNeeded() {
        // need update visable view?
        guard _needUpdateVisableViews else {
            return
        }
        _needUpdateVisableViews = false
        
        // new list
        var leftItemViews: [UIView] = []
        var rightItemViews: [UIView] = []
        
        // left: create & remove & update
        (0 ..< max(_leftItems.count, _leftItemViews.count)).forEach { index in
            // check contains the item
            if index < _leftItems.count {
                let item = _leftItems[index]
                // item view is already?
                if index < _leftItemViews.count {
                    // exist, check reuse
                    let view = _leftItemViews[index]
                    if view.tag == item.itemTpye {
                        (view as AnyObject).apply?(item)
                        leftItemViews.append(view)
                        return // reuse
                    }
                }
                // new
                let view = _createView(with: item)
                (view as AnyObject).apply?(item)
                leftItemViews.append(view)
            }
            // item view is already?
            if index < _leftItemViews.count {
                // remove
                let view = _leftItemViews[index]
                view.isHidden = true
                if view is ItemTextView {
                    _reusequeueItemViews1.append(view)
                } else if view is ItemImageView {
                    _reusequeueItemViews2.append(view)
                }
            }
        }
        
        // right: create & remove & update
        (0 ..< max(_rightItems.count, _rightItemViews.count)).forEach { index in
            // check contains the item
            if index < _rightItems.count {
                let item = _rightItems[index]
                // item view is already?
                if index < _rightItemViews.count {
                    // exist, check reuse
                    let view = _rightItemViews[index]
                    if view.tag == item.itemTpye {
                        (view as AnyObject).apply?(item)
                        rightItemViews.append(view)
                        return // reuse
                    }
                }
                // new
                let view = _createView(with: item)
                (view as AnyObject).apply?(item)
                rightItemViews.append(view)
            }
            // item view is already?
            if index < _rightItemViews.count {
                // remove
                let view = _rightItemViews[index]
                view.isHidden = true
                if view is ItemTextView {
                    _reusequeueItemViews1.append(view)
                } else if view is ItemImageView {
                    _reusequeueItemViews2.append(view)
                }
            }
        }
        
        _leftItemViews = leftItemViews
        _rightItemViews = rightItemViews
        
        _cacheBounds = nil
    }
    private func _updateVisableViewLayoutIfNeeded() {
        // need update visable view layout?
        guard _cacheBounds?.size != self.bounds.size else {
            return
        }
        _cacheBounds = self.bounds
        
        let sp = CGFloat(2)
        let edg = UIEdgeInsetsMake(2, 4, 2, 4)
        let bounds = UIEdgeInsetsInsetRect(self.bounds, edg)
        
        _ = _leftItemViews.reduce(bounds.minX) { x, view in
            var nframe = CGRect(x: x, y: bounds.minY, width: 0, height: 0)
            
            let size = view.sizeThatFits(bounds.size)
            
            nframe.size.width = size.width
            nframe.size.height = min(size.height, bounds.height)
            nframe.origin.x = x
            nframe.origin.y = bounds.minY + (bounds.height - nframe.height) / 2
            
            view.frame = nframe
            return x + nframe.width + sp
        }
        _ = _rightItemViews.reduce(bounds.maxX) { x, view in
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
        if item.itemTpye == 0 {
            let label = _reusequeueItemViews1.last as? ItemTextView ?? ItemTextView()
            if !_reusequeueItemViews1.isEmpty {
                _reusequeueItemViews1.removeLast()
            } else {
                addSubview(label)
            }
            label.isHidden = false
            label.textColor = tintColor
            label.font = UIFont.systemFont(ofSize: 12)
            //label.adjustsFontSizeToFitWidth = true
            
            return label
        }
        if item.itemTpye == 1 {
            let view = _reusequeueItemViews2.last as? ItemImageView ?? ItemImageView()
            if !_reusequeueItemViews2.isEmpty {
                _reusequeueItemViews2.removeLast()
            } else {
                addSubview(view)
            }
            view.isHidden = false
            view.contentMode = .center
            return view
        }
        fatalError()
    }
    
    private var _cacheBounds: CGRect?
    private var _needUpdateVisableViews: Bool = true
    
    private lazy var _leftItems: [Item] = []
    private lazy var _rightItems: [Item] = []
    
    private lazy var _leftItemViews: [UIView] = []
    private lazy var _rightItemViews: [UIView] = []
    
    private lazy var _reusequeueItemViews1: [UIView] = []
    private lazy var _reusequeueItemViews2: [UIView] = []
}



extension BadgeView {
    internal class ItemTextView: UILabel {
        
        func apply(_ item: Item) {
            text = item.text
        }
        
        override func tintColorDidChange() {
            super.tintColorDidChange()
            self.textColor = tintColor
        }
    }
    internal class ItemImageView: UIImageView {
        
        func apply(_ item: Item) {
            image = item.image
        }
    }
}

extension BadgeView {
    static var ub_backgroundImage: UIImage? {
        if let image = __backgroundImage {
            return image
        }
        logger.debug?.write("load `ubiquity_background_gradient`")
        let image = UIImage.ub_init(named: "ubiquity_background_gradient")
        __backgroundImage = image
        return image
    }
}

private weak var __backgroundImage: UIImage?

