//
//  SIMChatInputPanel+Tool.swift
//  SIMChat
//
//  Created by sagesse on 1/22/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

// TODO: 内部设计有点混乱/不太合理, 有时间需要重构一下
// TODO: 暂未支持横屏

extension SIMChatInputPanel {
    public class Tool: UIView {
        public override init(frame: CGRect) {
            super.init(frame: frame)
            build()
        }
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            build()
        }
        
        public weak var delegate: SIMChatInputPanelDelegateTool?
        
        private lazy var _pageControl: UIPageControl = {
            let view = UIPageControl()
            view.numberOfPages = 8
            view.hidesForSinglePage = true
            view.pageIndicatorTintColor = UIColor.grayColor()
            view.currentPageIndicatorTintColor = UIColor.darkGrayColor()
            view.addTarget(self, action: "onPageChanged:", forControlEvents: .ValueChanged)
            return view
        }()
        private lazy var _contentView: UICollectionView = {
            let layout = ContentLayout()
            let view = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
            view.delegate = self
            view.dataSource = self
            view.pagingEnabled = true
            view.delaysContentTouches = false
            view.showsVerticalScrollIndicator = false
            view.showsHorizontalScrollIndicator = false
            view.registerClass(ContentCell.self, forCellWithReuseIdentifier: "Item")
            return view
        }()
        
        private lazy var _builtInTools: Array<SIMChatInputAccessory> = {
            return [
                SIMChatInputToolAccessory("page:photo", "相片", UIImage(named: "simchat_icons_pic")),
                SIMChatInputToolAccessory("page:camera", "照相机", UIImage(named: "simchat_icons_camera"))
            ]
        }()
    }
}

extension SIMChatInputPanel.Tool {
    /// 对应的单元格
    private class ContentCell : UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.build()
        }
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.build()
        }
        /// 构建
        func build() {
            
            let vs = ["t" : titleLabel,
                      "c" : contentView2]
            
            // config
            titleLabel.font = UIFont.systemFontOfSize(12)
            titleLabel.textAlignment = .Center
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.opaque = true
            
            contentView2.translatesAutoresizingMaskIntoConstraints = false
            
            // add views
            addSubview(contentView2)
            addSubview(titleLabel)
            
            // add constrait
            addConstraints(NSLayoutConstraintMake("H:|-(0)-[c]-(0)-|", views: vs))
            addConstraints(NSLayoutConstraintMake("H:|-(0)-[t]-(0)-|", views: vs))
            addConstraints(NSLayoutConstraintMake("V:|-(0)-[c]-(0)-[t(20)]-(0)-|", views: vs))
            
            // add events
            contentView2.addTarget(self, action: "onItemPress:", forControlEvents: .TouchUpInside)
        }
        
        weak var delegate: SIMChatInputAccessoryDelegate?
        
        /// 关联的item
        dynamic var accessory: SIMChatInputAccessory? {
            willSet {
                titleLabel.text = newValue?.accessoryName
                contentView2.setBackgroundImage(newValue?.accessoryImage, forState: .Normal)
            }
        }
        /// 选择了该择
        dynamic func onItemPress(sender: AnyObject) {
            guard let accessory = accessory else {
                return
            }
            SIMLog.trace()
            if  delegate?.accessoryShouldSelect?(accessory) ?? true {
                delegate?.accessoryDidSelect?(accessory)
            }
        }
        
        private(set) lazy var titleLabel = UILabel()
        private(set) lazy var contentView2 = UIButton()
    }
    /// 对应的布局
    private class ContentLayout : UICollectionViewLayout {
        //
        var row = 2
        var column = 4
        /// t.
        private override func collectionViewContentSize() -> CGSize {
            
            let count = self.collectionView?.numberOfItemsInSection(0) ?? 0
            let page = (count + (row * column - 1)) / (row * column)
            let frame = self.collectionView?.frame ?? CGRectZero
            
            return CGSizeMake(frame.width * CGFloat(page), 0)
        }
        /// s.
        override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            var ats = [UICollectionViewLayoutAttributes]()
            // 生成
            let frame = self.collectionView?.bounds ?? CGRectZero
            let count = self.collectionView?.numberOfItemsInSection(0) ?? 0
            // config
            let w: CGFloat = 50
            let h: CGFloat = 70
            let yg: CGFloat = 28
            let xg: CGFloat = (frame.width - w * CGFloat(self.column)) / CGFloat(self.column + 1)
            // fill
            for i in 0 ..< count {
                // 计算。
                let r = CGFloat((i / self.column) % self.row)
                let c = CGFloat((i % self.column))
                let idx = NSIndexPath(forItem: i, inSection: 0)
                let page = CGFloat(i / (row * column))
                
                let a = self.layoutAttributesForItemAtIndexPath(idx) ?? UICollectionViewLayoutAttributes(forCellWithIndexPath: idx)
                a.frame = CGRectMake(xg + c * (w + xg) + page * frame.width, yg + r * (h + yg), w, h)
                // o
                ats.append(a)
            }
            return ats
        }
    }
}

extension SIMChatInputPanel.Tool {
    private func build() {
        backgroundColor = UIColor.whiteColor()//UIColor(argb: 0xFFEBECEE)
        _contentView.backgroundColor = backgroundColor
        
        addSubview(_contentView)
        addSubview(_pageControl)
        
        SIMChatLayout.make(_contentView)
            .top.equ(self).top
            .left.equ(self).left
            .right.equ(self).right
            .bottom.equ(_pageControl).top
            .submit()
        
        SIMChatLayout.make(_pageControl)
            .left.equ(self).left
            .right.equ(self).right
            .bottom.equ(self).bottom(15)
            .height.equ(20)
            .submit()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension SIMChatInputPanel.Tool: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        _pageControl.currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = _builtInTools.count + (delegate?.numberOfInputPanelToolItems?(self) ?? 0)
        let page = (count + (8 - 1)) / 8
        if _pageControl.numberOfPages != page {
            _pageControl.numberOfPages = page
        }
        return count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("Item", forIndexPath: indexPath)
    }
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? ContentCell {
            if indexPath.row < _builtInTools.count {
                cell.accessory = _builtInTools[indexPath.row]
                cell.delegate = self
            } else {
                cell.accessory = delegate?.inputPanel?(self, itemAtIndex: indexPath.row - _builtInTools.count)
                cell.delegate = self
            }
        }
    }
}

// MARK: - SIMChatInputAccessoryDelegate

extension SIMChatInputPanel.Tool: SIMChatInputAccessoryDelegate {
    public func accessoryShouldSelect(accessory: SIMChatInputAccessory) -> Bool {
        return delegate?.inputPanel?(self, shouldSelectTool: accessory) ?? true
    }
    public func accessoryDidSelect(accessory: SIMChatInputAccessory) {
        delegate?.inputPanel?(self, didSelectTool: accessory)
    }
}

@objc public protocol SIMChatInputPanelDelegateTool : NSObjectProtocol {
    optional func inputPanel(inputPanel: UIView, shouldSelectTool item: SIMChatInputAccessory) -> Bool
    optional func inputPanel(inputPanel: UIView, didSelectTool item: SIMChatInputAccessory)
    
    optional func numberOfInputPanelToolItems(inputPanel: UIView) -> Int
    optional func inputPanel(inputPanel: UIView, itemAtIndex index: Int) -> SIMChatInputAccessory?
}

extension SIMChatInputPanel.Tool {
    /// 切换页面
    func onPageChanged(sender: UIPageControl) {
        _contentView.setContentOffset(CGPointMake(_contentView.bounds.width * CGFloat(sender.currentPage), 0), animated: true)
    }
}

public class SIMChatInputToolAccessory: SIMChatInputAccessory {
    
    public init(_ identifier: String, _ name: String, _ image: UIImage?, _ selectImage: UIImage? = nil) {
        accessoryIdentifier = identifier
        accessoryName = name
        
        accessoryImage = image
        accessorySelectImage = selectImage
    }
    
    @objc public var accessoryIdentifier: String
    @objc public var accessoryName: String?
    
    @objc public var accessoryImage: UIImage?
    @objc public var accessorySelectImage: UIImage?
}

