//
//  SIMChatInputPanel+Face.swift
//  SIMChat
//
//  Created by sagesse on 1/22/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

extension SIMChatInputPanel {
    public class Face: UIView {
        public override init(frame: CGRect) {
            super.init(frame: frame)
            build()
        }
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            build()
        }
        
        private lazy var _tabBar: TabBar = {
            let view = TabBar()
            view.backgroundColor = UIColor.purpleColor()
            return view
        }()
        private lazy var _pageControl: PageControl = {
            let view = PageControl()
            view.numberOfPages = 8
            view.pageIndicatorTintColor = UIColor.grayColor()
            view.currentPageIndicatorTintColor = UIColor.darkGrayColor()
            return view
        }()
        private lazy var _contentView: ContentView = {
            let view = ContentView()
            view.showsHorizontalScrollIndicator = false
            view.showsVerticalScrollIndicator = false
            view.pagingEnabled = true
            view.dataSource = self
            view.delegate = self
            view.backgroundColor = UIColor.whiteColor()
            
            view.registerClass(Page.Classic.self, forCellWithReuseIdentifier: NSStringFromClass(Model.Classic.self))
            
            return view
        }()
        
        private lazy var _pages: [AnyObject] = Model.Classic.emojis().reverse() + Model.Classic.faces()
        
        private struct Page {}
        private struct Model {}
    }
}

extension SIMChatInputPanel.Face {
    private class TabBar: UIScrollView {
        override func intrinsicContentSize() -> CGSize {
            return CGSizeMake(bounds.width, 37)
        }
    }
    private class PageControl: UIPageControl {
        override func intrinsicContentSize() -> CGSize {
            return CGSizeMake(bounds.width, 25)
        }
    }
    private class ContentView: UICollectionView {
        init() {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .Horizontal
            layout.sectionInset = UIEdgeInsetsZero
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            super.init(frame: CGRectZero, collectionViewLayout: layout)
            
            registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Unknow")
        }
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override func registerClass(cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
            super.registerClass(cellClass, forCellWithReuseIdentifier: identifier)
            cellClasses[identifier] = cellClass
        }
        
        private var cellClasses: [String: AnyClass] = [:]
    }
}

// MARK: - Content Page -> Classic

extension SIMChatInputPanel.Face.Page {
    /// 经典类型
    private class Classic: UICollectionViewCell {
       
        /// 对应的模型
        var model: SIMChatInputPanel.Face.Model.Classic? {
            didSet {
                guard model !== oldValue else {
                    return
                }
                setNeedsDisplay()
                
            }
        }
        
        lazy var backspaceButton: UIButton = {
            let view = UIButton()
            view.setImage(SIMChatImageManager.images_face_delete_nor, forState: .Normal)
            view.setImage(SIMChatImageManager.images_face_delete_press, forState: .Highlighted)
            return view
        }()
        
        var maximumItemCount: Int = 7
        var maximumLineCount: Int = 3
        
        var contentInset: UIEdgeInsets = UIEdgeInsetsMake(12, 10, 42, 10)
        
        override func drawRect(rect: CGRect) {
            //let ctx = UIGraphicsGetCurrentContext()
            
            let width = bounds.width - contentInset.left - contentInset.right
            let height = bounds.height - contentInset.top - contentInset.bottom
            let size = CGSizeMake(width / CGFloat(maximumItemCount), height / CGFloat(maximumLineCount))
            
            let config = [
                NSFontAttributeName: UIFont.systemFontOfSize(32)
            ]
            
            for row in 0 ..< maximumLineCount {
                for col in 0 ..< maximumItemCount {
                    let index = row * maximumItemCount + col
                    guard index < model?.value.count else {
                        continue
                    }
                    guard let value: NSString = model?.value[index] else {
                        continue
                    }
                    
                    if value.length <= 2 {
                        var frame = CGRectZero
                        
                        frame.origin.x = contentInset.left + CGFloat(col) * size.width
                        frame.origin.y = contentInset.top + CGFloat(row) * size.height
                        
                        frame.size = value.sizeWithAttributes(config)
                        frame.origin.x += (size.width - frame.size.width) / 2
                        frame.origin.y += (size.height - frame.size.height) / 2
                        
                        value.drawInRect(frame, withAttributes: config)
                    } else if value.hasPrefix("qq:") {
                        guard let image = UIImage(named: "SIMChat.bundle/Face/\(value.substringFromIndex(3))") else {
                            continue
                        }
                        var frame = CGRectZero
                        
                        frame.origin.x = contentInset.left + CGFloat(col) * size.width
                        frame.origin.y = contentInset.top + CGFloat(row) * size.height
                        
                        frame.size = image.size
                        frame.origin.x += (size.width - frame.size.width) / 2
                        frame.origin.y += (size.height - frame.size.height) / 2
                        
                        image.drawInRect(frame)
                    }
                }
            }
            
            if true {
                var frame = CGRectZero
                
                frame.origin.x = contentInset.left + CGFloat(maximumItemCount - 1) * size.width
                frame.origin.y = contentInset.top + CGFloat(maximumLineCount - 1) * size.height
                frame.size.width = size.width
                frame.size.height = size.height
                
                backspaceButton.frame = frame
                
                if backspaceButton.superview != contentView {
                    contentView.addSubview(backspaceButton)
                }
            }
        }
    }
}

// MARK: - Content Model
extension SIMChatInputPanel.Face.Model {
    /// 经典类型
    private class Classic {
        init(_ value: [String]) {
            self.value = value
        }
        
        var value: [String] = []
        
        static func faces() -> [Classic] {
            let emojis = (1 ... 141).map {
                String(format: "qq:%03d", $0)
            }
            var pages = [Classic]()
            let maxEle = (3 * 7) - 1
            for i in 0 ..< (emojis.count + maxEle - 1) / maxEle {
                let beg = i * maxEle
                let end = min((i + 1) * maxEle, emojis.count)
                let page = Classic(Array(emojis[beg ..< end]))
                pages.append(page)
            }
            return pages
        }
        
        static func emojis() -> [Classic] {
            // 生成emoij函数
            let emoji = { (x:UInt32) -> String in
                var idx = ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24)
                return withUnsafePointer(&idx) {
                    return NSString(bytes: $0, length: sizeof(idx.dynamicType), encoding: NSUTF8StringEncoding) as! String
                }
            }
            var emojis = [String]()
            for i:UInt32 in 0x1F600 ..< 0x1F64F {
                if i < 0x1F641 || i > 0x1F644 {
                    emojis.append(emoji(i))
                }
            }
            for i:UInt32 in 0x1F680 ..< 0x1F6A4 {
                emojis.append(emoji(i))
            }
            for i:UInt32 in 0x1F6A5 ..< 0x1F6C5 {
                emojis.append(emoji(i))
            }
            
            var pages = [Classic]()
            let maxEle = (3 * 7) - 1
            for i in 0 ..< (emojis.count + maxEle - 1) / maxEle {
                let beg = i * maxEle
                let end = min((i + 1) * maxEle, emojis.count)
                let page = Classic(Array(emojis[beg ..< end]))
                pages.append(page)
            }
            return pages
        }
        
//    /// 生成表情列表
//    private(set) lazy var faces: [String] = {
//        return rs
//    }()
    }
}

// MARK: - Private Method

extension SIMChatInputPanel.Face {
    private func build() {
        
        // add view
        addSubview(_contentView)
        addSubview(_pageControl)
        addSubview(_tabBar)
        
        // add layout
        
        SIMChatLayout.make(_contentView)
            .top.equ(self).top
            .left.equ(self).left
            .right.equ(self).right
            .bottom.equ(_tabBar).top
            .submit()
        
        SIMChatLayout.make(_pageControl)
            .left.equ(self).left
            .right.equ(self).right
            .bottom.equ(_contentView).bottom(5)
            .submit()
        
        SIMChatLayout.make(_tabBar)
            .left.equ(self).left
            .right.equ(self).right
            .bottom.equ(self).bottom
            .submit()
        
        
        _pageControl.currentPage = 8
        _pageControl.numberOfPages = _pages.count
        _contentView.reloadData()
        dispatch_async(dispatch_get_main_queue()) {
            self._contentView.scrollToItemAtIndexPath(NSIndexPath(forItem: 8, inSection: 0), atScrollPosition: .None, animated: false)
        }
    }
}

extension SIMChatInputPanel.Face {
    public override func layoutSubviews() {
        super.layoutSubviews()
        
//        let row = Int((_contentView.contentOffset.x) / bounds.width)
//        
//        _contentView.collectionViewLayout.invalidateLayout()
//        _contentView.contentOffset = CGPointMake(CGFloat(row) * bounds.width, 0)
    }
}

// MARK: - UICollectionViewDelegate or UICollectionViewDataSource

extension SIMChatInputPanel.Face: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        _pageControl.currentPage = Int((scrollView.contentOffset.x + scrollView.frame.width / 2.0) / scrollView.frame.width)
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _pages.count
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let page = _pages[indexPath.item]
        var identifier = NSStringFromClass(page.dynamicType)
        if _contentView.cellClasses[identifier] == nil {
            identifier = "Unknow"
        }
        return collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = collectionView.backgroundColor
        
        if let cell = cell as? Page.Classic, page = _pages[indexPath.item] as? Model.Classic {
            cell.model = page
        }
        
        
        //cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.grayColor() : UIColor.blueColor()
        
//        let page = indexPath.row / 21
//        let idx = indexPath.row - page
//        var title: String?
//        
//        if idx < self.faces.count && (indexPath.row == 0 || (indexPath.row + 1) % 21 != 0) {
//            title = self.faces[idx]
//        }
//        // 更新
//        cell.face = title
    }
}
