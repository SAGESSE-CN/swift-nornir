//
//  SIMChatInputPanel+Emoji.swift
//  SIMChat
//
//  Created by sagesse on 1/22/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

extension SIMChatInputPanel {
    public class Emoji: UIView {
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
            view.backgroundColor = UIColor.redColor()
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
            return view
        }()
    }
}

extension SIMChatInputPanel.Emoji {
    private class TabBar: UIScrollView {
        override func intrinsicContentSize() -> CGSize {
            return CGSizeMake(bounds.width, 37)
        }
    }
    private class PageControl: UIView {
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
            
            registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        }
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
}

extension SIMChatInputPanel.Emoji {
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
    }
}

extension SIMChatInputPanel.Emoji {
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let row = Int((_contentView.contentOffset.x + 10) / bounds.width)
        
        _contentView.collectionViewLayout.invalidateLayout()
        _contentView.contentOffset = CGPointMake(CGFloat(row) * bounds.width, 0)
    }
}

// MARK: - UICollectionViewDelegate or UICollectionViewDataSource

extension SIMChatInputPanel.Emoji: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        pageControl.currentPage = Int((scrollView.contentOffset.x + scrollView.frame.width / 2.0) / scrollView.frame.width)
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return emojis.count + (emojis.count + 20 - 1) / 20
        return 8
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.grayColor() : UIColor.blueColor()
//        let page = indexPath.row / 21
//        let idx = indexPath.row - page
//        var title: String?
//        
//        if idx < self.emojis.count && (indexPath.row == 0 || (indexPath.row + 1) % 21 != 0) {
//            title = self.emojis[idx]
//        }
//        // 更新
//        cell.emoji = title
    }
}
