//
//  SAIEmoticonTabItemView.swift
//  SAC
//
//  Created by SAGESSE on 9/15/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

internal class SAIEmoticonTabItemView: UICollectionViewCell {
    
    var group: SAIEmoticonGroup? {
        willSet {
            guard group !== newValue else {
                return
            }
            _imageView.image = newValue?.thumbnail
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        _imageView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        _line.frame = CGRect(x: bounds.maxX - 0.25, y: 8, width: 0.5, height: bounds.height - 16)
    }
    
    private func _init() {
        //_logger.trace()
        
        _line.backgroundColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        
        _imageView.contentMode = .scaleAspectFit
        _imageView.bounds = CGRect(x: 0, y: 0, width: 25, height: 25)
        
        contentView.addSubview(_imageView)
        contentView.layer.addSublayer(_line)
        
        selectedBackgroundView = UIView()
    }
    
    private lazy var _imageView: UIImageView = UIImageView()
    private lazy var _line: CALayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}


/////
///// 页面控制视图
/////
//internal class SACInputPanelPageControl: UIView {
//    
//    var hidesForSinglePage: Bool = false
//    
//    var pageIndicatorTintColor: UIColor? = UIColor.gray
//    var currentPageIndicatorTintColor: UIColor? = UIColor.darkGray
//    
//    var currentPage: IndexPath = IndexPath(item: 0, section: 0) {
//        didSet {
//            guard (oldValue as NSIndexPath).row != currentPage.row || (oldValue as NSIndexPath).section != currentPage.section else {
//                return
//            }
//            if (oldValue as NSIndexPath).section != currentPage.section {
//                reloadPages()
//            } else {
//                if (oldValue as NSIndexPath).row < _pages.count {
//                    _pages[(oldValue as NSIndexPath).row].backgroundColor = pageIndicatorTintColor
//                }
//                if currentPage.row < _pages.count {
//                    _pages[currentPage.row].backgroundColor = currentPageIndicatorTintColor
//                }
//            }
//        }
//    }
//    
//    var _groups: Array<UIImageView> = []
//    var _pages: Array<UIView> = []
//    
//    var _pageGap: CGFloat = 4
//    var _pageWH: CGFloat = 7
//    
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        var width = CGFloat(_pages.count) * (_pageWH + _pageGap) - _pageGap
//        var height = CGFloat(_pageWH)
//        _groups.enumerated().forEach {
//            width += ($0.element.image?.size.width ?? 0) + _pageGap
//            height = max($0.element.image?.size.height ?? 0, height)
//        }
//        return CGSize(width: width - _pageGap, height: height)
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//    }
//    
//    func reloadData() {
//        reloadSections()
//    }
//    
//    func reloadPages() {
//        let count = delegate?.pageControl(self, numberOfPagesInSection: currentPage.section) ?? 0
//        var tmp = _pages
//        _pages.removeAll()
//        (0 ..< count).forEach {
//            let view = tmp.popLast() ?? UIView()
//            view.layer.cornerRadius = _pageWH / 2
//            view.layer.masksToBounds = true
//            if currentPage.row == $0 {
//                view.backgroundColor = currentPageIndicatorTintColor
//            } else {
//                view.backgroundColor = pageIndicatorTintColor
//            }
//            _pages.append(view)
//            addSubview(view)
//        }
//        tmp.forEach {
//            $0.removeFromSuperview()
//        }
//        
//        updateLayout()
//    }
//    func reloadSections() {
//        // 更新组
//        if let count = delegate?.numberOfSectionsInPageControl(self) , count > 1 {
//            var tmp = _groups
//            _groups.removeAll()
//            (0 ..< count).forEach {
//                let view = tmp.popLast() ?? UIImageView()
//                view.image = delegate?.pageControl(self, imageOfSection: $0)
//                _groups.append(view)
//                addSubview(view)
//            }
//            tmp.forEach {
//                $0.removeFromSuperview()
//            }
//        } else {
//            _groups.forEach {
//                $0.removeFromSuperview()
//            }
//            _groups.removeAll()
//        }
//        
//        reloadPages()
//    }
//    
//    func updateLayout() {
//        let width = sizeThatFits(CGSize.zero).width
//        var x = (bounds.width - width) / 2
//        
//        if _groups.isEmpty {
//            _pages.forEach {
//                let size = CGSize(width: _pageWH, height: _pageWH)
//                $0.frame = CGRect(x: x, y: (bounds.height - size.height) / 2, width: size.width, height: size.height)
//                x += size.width + _pageGap
//            }
//        } else {
//            _groups.enumerated().forEach {
//                let size = $0.element.image?.size ?? CGSize.zero
//                $0.element.frame = CGRect(x: x, y: (bounds.height - size.height) / 2, width: size.width, height: size.height)
//                if $0.offset == currentPage.section {
//                    _pages.forEach {
//                        let size = CGSize(width: _pageWH, height: _pageWH)
//                        $0.frame = CGRect(x: x, y: (bounds.height - size.height) / 2, width: size.width, height: size.height)
//                        x += size.width + _pageGap
//                    }
//                    $0.element.isHidden = true
//                } else {
//                    x += size.width + _pageGap
//                    $0.element.isHidden = false
//                }
//            }
//        }
//    }
//    
//    weak var delegate: SACInputPanelPageControlDelegate?
//  
//    override var intrinsicContentSize: CGSize {
//        return CGSize(width: bounds.width, height: 25)
//    }
//}
//
