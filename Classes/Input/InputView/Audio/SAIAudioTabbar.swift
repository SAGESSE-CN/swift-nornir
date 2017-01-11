//
//  SAIAudioTabbar.swift
//  SAC
//
//  Created by SAGESSE on 9/19/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

internal protocol SAIAudioTabbarDelegate: NSObjectProtocol {
    
    func numberOfItemsInTabbar(_ tabbar: SAIAudioTabbar) -> Int
    func tabbar(_ tabbar: SAIAudioTabbar, titleAt index: Int) -> String
    
    func tabbar(_ tabbar: SAIAudioTabbar, shouldSelectItemAt index: Int) -> Bool
    func tabbar(_ tabbar: SAIAudioTabbar, didSelectItemAt index: Int)
    
}

internal class SAIAudioTabbar: UIView {

    override var intrinsicContentSize: CGSize {
        return CGSize(width: -1, height: 26)
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event) {
            if view === _contentView {
                return view
            }
        }
        return nil
    }
    
    func reloadData() {
        _reloadContentView()
    }
    var numberOfItems: Int  {
        return delegate?.numberOfItemsInTabbar(self) ?? 0
    }
    
    var font: UIFont?
    var textColor: UIColor?
    var textHighlightedColor: UIColor?
    
    weak var delegate: SAIAudioTabbarDelegate?
    
    var indicatorColor: UIColor? {
        set { return _indicatorView.backgroundColor = newValue }
        get { return _indicatorView.backgroundColor }
    }

    var index: CGFloat = 0 {
        willSet {
            _reloadContentOffset(newValue)
        }
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer) {
        let pt = sender.location(in: _contentView)
        let idx = _itemViews.index {
            $0.frame.contains(pt)
        }
        if let idx = idx, let delegate = delegate {
            guard delegate.tabbar(self, shouldSelectItemAt: idx) else {
                return
            }
            delegate.tabbar(self, didSelectItemAt: idx)
        }
    }
    
    private func _reloadContentOffset(_ newValue: CGFloat) {
        //_logger.trace(newValue)
        
        if !_isInit {
            _isInit = true
            _reloadContentView()
        }
        
        let idx = min(max(Int(newValue), 0), _itemViews.count)
        
        guard idx < _itemViews.count else {
            return
        }
        if _activatedItemView !== _itemViews[idx] {
            _activatedItemView?.textColor = textColor
            _activatedItemView = _itemViews[idx]
            _activatedItemView?.textColor = textHighlightedColor
        }
        
        var nframe = _contentView.frame
        nframe.origin.x = frame.width / 2 - _contentView.frame.width * (newValue / CGFloat(_itemViews.count))
        _contentView.frame = nframe
    }
    private func _reloadContentView() {
        
        // clear
        _itemViews.forEach {
            $0.removeFromSuperview()
        }
        _itemViews.removeAll()
        
        let s: CGFloat = 8
        var x: CGFloat = 0
        let y: CGFloat = 0
        let height: CGFloat = 21
        
        x -= s / 2
        (0 ..< numberOfItems).forEach {
            let label = _makeLabel(_title(at: $0))
            
            
            var nframe = label.bounds
            nframe.origin.x = x + s
            nframe.origin.y = y
            nframe.size.height = height
            label.frame = nframe
            
            _itemViews.append(label)
            _contentView.addSubview(label)
            
            x += s + nframe.width
        }
        x += s / 2
        
        _contentView.frame = CGRect(x: 0, y: 5, width: max(x, 0), height: height)
    }
    
    private func _title(at index: Int) -> String {
        return delegate?.tabbar(self, titleAt: index) ?? "Unknow"
    }
    
    private func _makeLabel(_ title: String) -> UILabel {
        let label = UILabel()
        
        label.font = font
        label.text = title
        label.textColor = textColor
        label.sizeToFit()
        
        return label
    }
    
    private func _init() {
        _logger.trace()
        
        font = UIFont.boldSystemFont(ofSize: 13)
        textColor = .gray
        textHighlightedColor = .purple
        indicatorColor = .purple
        
        _indicatorView.translatesAutoresizingMaskIntoConstraints = false
        _indicatorView.layer.cornerRadius = 2.5
        _indicatorView.layer.masksToBounds = true
        _indicatorView.isUserInteractionEnabled = false
        
        addSubview(_indicatorView)
        addSubview(_contentView)
        addConstraints([
            _SAILayoutConstraintMake(_indicatorView, .top, .equal, self, .top),
            _SAILayoutConstraintMake(_indicatorView, .width, .equal, nil, .width, 5),
            _SAILayoutConstraintMake(_indicatorView, .height, .equal, nil, .width, 5),
            _SAILayoutConstraintMake(_indicatorView, .centerX, .equal, self, .centerX),
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }
    
    private var _isInit = false
    
    private weak var _activatedItemView: UILabel?
    
    private lazy var _itemViews: [UILabel] = []
    private lazy var _contentView: UIView = UIView()
    private lazy var _indicatorView: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}
