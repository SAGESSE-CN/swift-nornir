//
//  SIMChatKeyboardTool.swift
//  SIMChat
//
//  Created by sagesse on 9/20/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 自定义键盘-工具箱
class SIMChatKeyboardTool: SIMView {
    /// 初始化
    convenience init(delegate: SIMChatKeyboardToolDelegate, dataSource: SIMChatKeyboardToolDataSource? = nil) {
        self.init(frame: CGRectZero)
        self.delegate = delegate
        self.dataSource = dataSource
    }
    /// 构建
    override func build() {
        super.build()
        
        let vs = ["c" : contentView,
                  "p" : pageControl]
        
        // config
        pageControl.pageIndicatorTintColor = UIColor.grayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.darkGrayColor()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.dataSource = self
        contentView.delegate = self
        contentView.pagingEnabled = true
        contentView.backgroundColor = UIColor.clearColor()
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.delaysContentTouches = false
        contentView.registerClass(SIMChatKeyboardToolContentCell.self, forCellWithReuseIdentifier: "Cell")
        
        builtInTools.append(UIBarButtonItem(tag: -1, title: "图片", image: UIImage(named: "simchat_icons_pic")))
        builtInTools.append(UIBarButtonItem(tag: -2, title: "相机", image: UIImage(named: "simchat_icons_camera")))
        
        // add views
        addSubview(contentView)
        addSubview(pageControl)
        
        // add constraints
        addConstraints(NSLayoutConstraintMake("H:|-(0)-[c]-(0)-|", views: vs))
        addConstraints(NSLayoutConstraintMake("H:|-(0)-[p]-(0)-|", views: vs))
        addConstraints(NSLayoutConstraintMake("V:|-(0)-[c]-(0)-[p(24)]-(0)-|", views: vs))
        
        // add events
        pageControl.addTarget(self, action: "onPageChanged:", forControlEvents: .ValueChanged)
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = (contentView.numberOfItemsInSection(0) + 8 - 1) / 8
        pageControl.hidesForSinglePage = true
    }
    /// ...
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(0, 216)
    }
    /// 代理.
    weak var delegate: SIMChatKeyboardToolDelegate?
    weak var dataSource: SIMChatKeyboardToolDataSource? {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.contentView.reloadData()
                self.pageControl.numberOfPages = (self.contentView.numberOfItemsInSection(0) + 8 - 1) / 8
            }
        }
    }
    
    private(set) lazy var pageControl = UIPageControl()
    private(set) lazy var contentView = UICollectionView(frame: CGRectZero, collectionViewLayout: SIMChatKeyboardToolContentLayout())
    
    private(set) lazy var builtInTools = [UIBarButtonItem]()
}

/// MARK: - /// UICollectionViewDelegate or UICollectionViewDataSource
extension SIMChatKeyboardTool : UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// 滑动完成
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControl.currentPage = Int((scrollView.contentOffset.x + scrollView.frame.width / 2.0) / scrollView.frame.width)
    }
    /// 获取单元格数量
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return builtInTools.count + (dataSource?.chatKeyboardTool(self, numberOfItemsInSection: section) ?? 0)
    }
    /// 创建单元格
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! SIMChatKeyboardToolContentCell
        //  更新数据
        if indexPath.row < builtInTools.count {
            cell.item = builtInTools[indexPath.row]
        } else {
            // 新的index
            let idx = NSIndexPath(forRow: indexPath.row - builtInTools.count, inSection: indexPath.section)
            // 更新
            cell.item = dataSource?.chatKeyboardTool(self, itemAtIndexPath: idx)
        }
        // ok
        return cell
    }
}

/// MAKR: - /// Type
extension SIMChatKeyboardTool {
    /// 对应的单元格
    private class SIMChatKeyboardToolContentCell : UICollectionViewCell {
        /// 初始化
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.build()
        }
        /// 反序列化
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
            
            contentView2.translatesAutoresizingMaskIntoConstraints = false
            
            // add views
            addSubview(contentView2)
            addSubview(titleLabel)
            
            // add constrait
            addConstraints(NSLayoutConstraintMake("H:|-(0)-[c]-(0)-|", views: vs))
            addConstraints(NSLayoutConstraintMake("H:|-(0)-[t]-(0)-|", views: vs))
            addConstraints(NSLayoutConstraintMake("V:|-(0)-[c]-(0)-[t(20)]-(0)-|", views: vs))
            
            // add events
            contentView2.addTarget(self, action: "onItem:", forControlEvents: .TouchUpInside)
        }
        /// 关联的item
        dynamic var item: UIBarButtonItem? {
            willSet {
                titleLabel.text = newValue?.title
                contentView2.setBackgroundImage(newValue?.image, forState: .Normal)
            }
        }
        /// 选择了该择
        dynamic func onItem(sender: AnyObject) {
            if let item = self.item {
                /// 顺着响应链往上找
                var responder = sender.nextResponder()
                while responder != nil {
                    if let view = responder as? SIMChatKeyboardTool {
                        view.onItem(item)
                    }
                    responder = responder?.nextResponder()
                }
            }
        }
        
        private(set) lazy var titleLabel = UILabel()
        private(set) lazy var contentView2 = UIButton()
    }
    /// 对应的布局
    private class SIMChatKeyboardToolContentLayout : UICollectionViewLayout {
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
            let yg: CGFloat = 20
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

/// MARK: 增强
extension UIBarButtonItem {
    /// 初始化
    convenience init(tag: Int, title: String, image: UIImage?) {
        self.init()
        self.tag = tag
        self.title = title
        self.image = image
    }
}

/// MARK: - /// Events
extension SIMChatKeyboardTool {
    
    /// 选择了
    func onItem(item: UIBarButtonItem) {
        delegate?.chatKeyboardTool?(self, didSelectedItem: item)
    }
    /// 切换页面
    func onPageChanged(sender: UIPageControl) {
        contentView.setContentOffset(CGPointMake(contentView.bounds.width * CGFloat(sender.currentPage), 0), animated: true)
    }
}

/// 代理
@objc protocol SIMChatKeyboardToolDelegate : NSObjectProtocol {
    optional func chatKeyboardTool(chatKeyboardTool: SIMChatKeyboardTool, didSelectedItem item: UIBarButtonItem)
}

/// 数据源
@objc protocol SIMChatKeyboardToolDataSource : NSObjectProtocol {
    func chatKeyboardTool(chatKeyboardTool: SIMChatKeyboardTool, numberOfItemsInSection section: Int) -> Int
    func chatKeyboardTool(chatKeyboardTool: SIMChatKeyboardTool, itemAtIndexPath indexPath: NSIndexPath) -> UIBarButtonItem?
}