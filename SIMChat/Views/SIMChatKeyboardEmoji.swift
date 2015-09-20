//
//  SIMChatKeyboardEmoji.swift
//  SIMChat
//
//  Created by sagesse on 9/20/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SIMChatKeyboardEmoji: SIMView {
    
//    convenience init(delegate: SIMChatInputEmojiViewDelegate?) {
//        self.init()
//        self.delegate = delegate
//    }
    
    /// 构建
    override func build() {
        super.build()
        
        let line = SIMChatLine()
        let vs = ["c" : contentView,
                  "l" : line,
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
        contentView.registerClass(SIMChatKeyboardEmojiContentCell.self, forCellWithReuseIdentifier: "Cell")
        
        line.contentMode = .Top
        line.tintColor = UIColor(hex: 0xBDBDBD)
        line.translatesAutoresizingMaskIntoConstraints = false
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = (contentView.numberOfItemsInSection(0) + 21 - 1) / 21
        pageControl.hidesForSinglePage = true
        
        // add views
        addSubview(contentView)
        addSubview(line)
        addSubview(pageControl)
        
        // add constraints
        addConstraints(NSLayoutConstraintMake("H:|-(0)-[c]-(0)-|", views: vs))
        addConstraints(NSLayoutConstraintMake("H:|-(0)-[p]-(0)-|", views: vs))
        addConstraints(NSLayoutConstraintMake("H:|-(0)-[l]-(0)-|", views: vs))
        addConstraints(NSLayoutConstraintMake("V:|-(0)-[c][l(1)]-(40)-|", views: vs))
        addConstraints(NSLayoutConstraintMake("V:[p(24)]-(49)-|", views: vs))
    }

//    convenience init(delegate: SIMChatInputEmojiViewDelegate?) {
//        self.init()
//        self.delegate = delegate
//    }
//    
//    func buildUI() {
//        
//        addSubview(content)
//        addSubview(page)
//        addSubview(send)
//        addSubview(line)
//        
//        let cm = NSLayoutConstraint.constraintsWithVisualFormat
//        let addConstraints = self.addConstraints
//        let vs = ["vc": content,
//                  "vp": page,
//                  "vb": send,
//                  "vl": line]
//        
//        addConstraints(cm("H:|[vc]|", options: .allZeros, metrics: nil, views: vs))
//        addConstraints(cm("H:|[vl]|", options: .allZeros, metrics: nil, views: vs))
//        addConstraints(cm("H:[vb(64)]|", options: .allZeros, metrics: nil, views: vs))
//        addConstraints(cm("V:|[vc][vl(1)]-40-|", options: .allZeros, metrics: nil, views: vs))
//        addConstraints(cm("H:|[vp]|", options: .allZeros, metrics: nil, views: vs))
//        addConstraints(cm("V:[vp(24)]-49-|", options: .allZeros, metrics: nil, views: vs))
//        addConstraints(cm("V:[vb(41)]-0-|", options: .allZeros, metrics: nil, views: vs))
//        
//        page.currentPage = 0
//        page.numberOfPages = (content.numberOfItemsInSection(0) + 21 - 1) / 21
//        page.hidesForSinglePage = true
//        
//        // add events
//        page.addTarget(self, action: "onPageSwitch:", forControlEvents: .ValueChanged)
//        send.addTarget(self, action: "onSendClicked:", forControlEvents: .TouchUpInside)
//        content.addGestureRecognizer(event)
//    }
//
    /// ...
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(0, 216)
    }
//
//    weak var delegate: SIMChatInputEmojiViewDelegate?
//   
//    private(set) lazy var event: UIGestureRecognizer = {
//        let e = UITapGestureRecognizer(target: self, action: "onItemSelected:")
//        return e
//    }()
//    
//    private(set) lazy var send: UIButton = {
//        let v = UIButton.buttonWithType(UIButtonType.System) as! UIButton
//        
//        v.tintColor = UIColor.blueColor()
//        v.setTitle("发送", forState: .Normal)
//        v.setTranslatesAutoresizingMaskIntoConstraints(false)
//        
//        return v
//    }()
//    private(set) lazy var line: SFLineView = {
//        let v = SFLineView()
//        
//        v.contentMode = .Top
//        v.tintColor = UIColor(red: 189/255.0, green: 189/255.0, blue: 189/255.0, alpha: 1)
//        v.setTranslatesAutoresizingMaskIntoConstraints(false)
//        
//        return v
//    }()

    private(set) lazy var pageControl = UIPageControl()
    private(set) lazy var contentView = UICollectionView(frame: CGRectZero, collectionViewLayout: SIMChatKeyboardEmojiContentLayout())
    
    /// 生成表情列表
    private(set) lazy var emojis: [String] = {
        let emoji = { (x:UInt32) -> String in
            // 生成数字
            var idx = ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24)
            // 生成字符串.
            return withUnsafePointer(&idx) {
                return NSString(bytes: $0, length: sizeof(idx.dynamicType), encoding: NSUTF8StringEncoding) as! String
            }
        }
        
        var rs = [String]()
        
        for i:UInt32 in 0x1F600 ..< 0x1F64F {
            if i < 0x1F641 || i > 0x1F644 {
                rs.append(emoji(i))
            }
        }
        for i:UInt32 in 0x1F680 ..< 0x1F6A4 {
            rs.append(emoji(i))
        }
        for i:UInt32 in 0x1F6A5 ..< 0x1F6C5 {
            rs.append(emoji(i))
        }
        
        return rs
    }()
}
//
//
/// MARK: - /// UICollectionViewDelegate or UICollectionViewDataSource
extension SIMChatKeyboardEmoji : UICollectionViewDelegate, UICollectionViewDataSource {
//
//    /// 发送
//    func onSendClicked(sender: UIButton) {
//        if delegate?.chatInputEmojiViewShouldSendText?(self) ?? true {
//            delegate?.chatInputEmojiViewDidSendText?(self)
//        }
//    }
//    
//    /// 选中.
//    func onItemSelected(sender: UIGestureRecognizer) {
//        let pt = sender.locationInView(content)
//        if let idx = content.indexPathForItemAtPoint(pt) {
//            if let cell = content.cellForItemAtIndexPath(idx) {
//                if let value = cell.valueForKey("title") as? String {
//                    if value == "\u{7F}" {
//                        if delegate?.chatInputEmojiViewShouldDeleteText?(self) ?? true {
//                            delegate?.chatInputEmojiViewDidDeleteText?(self)
//                        }
//                    } else {
//                        if delegate?.chatInputEmojiView?(self, shouldSelectEmoji: value) ?? true {
//                            delegate?.chatInputEmojiView?(self, didSelectEmoji: value)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    /// 切换页面
    func onPageSwitch(sender: UIPageControl) {
        contentView.setContentOffset(CGPointMake(contentView.bounds.width * CGFloat(sender.currentPage), 0), animated: true)
    }
    /// 滑动
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControl.currentPage = Int((scrollView.contentOffset.x + scrollView.frame.width / 2.0) / scrollView.frame.width)
    }
    /// 页数
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count + (emojis.count + 20 - 1) / 20
    }
    /// 创建单元格
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! SIMChatKeyboardEmojiContentCell
        let page = indexPath.row / 21
        let idx = indexPath.row - page
        var title = "\u{7F}"
        
        if idx < self.emojis.count && (indexPath.row == 0 || (indexPath.row + 1) % 21 != 0) {
            title = self.emojis[idx]
        }
        // 更新
        cell.title = title
        
        return cell
    }
    
}

/// MAKR: - /// Type
extension SIMChatKeyboardEmoji {
    
    /// 单元格
    private class SIMChatKeyboardEmojiContentCell : UICollectionViewCell {
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
            titleLabel.font = UIFont.systemFontOfSize(28)
            titleLabel.textAlignment = .Center
            titleLabel.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        }
        /// 标题
        dynamic var title: String? {
            willSet {
                // 检查是不是删除。
                if (newValue ?? "") == "\u{7F}" {
                    if title != "\u{7F}" {
                        titleLabel.removeFromSuperview()
                    }
                    if imageView.superview != self {
                        imageView.frame = self.bounds
                        addSubview(imageView)
                    }
                } else {
                    if title == "\u{7F}" {
                        imageView.removeFromSuperview()
                    }
                    if titleLabel.superview != self {
                        titleLabel.frame = self.bounds
                        addSubview(titleLabel)
                    }
                    titleLabel.text = newValue
                }
            }
        }
        
        private(set) lazy var titleLabel = UILabel()
        private(set) lazy var imageView: UIImageView = {
            let view = UIImageView()
            view.image = SIMChatImageManager.deleteImageNor
            view.contentMode = .Left
            view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            return view
        }()
    }
    /// 内容的布局
    private class SIMChatKeyboardEmojiContentLayout : UICollectionViewLayout {
        
        var row = 3
        var column = 7
        
        /// t.
        override func collectionViewContentSize() -> CGSize {
            
            let count = self.collectionView?.numberOfItemsInSection(0) ?? 0
            let page = (count + (row * column - 1)) / (row * column)
            let frame = self.collectionView?.frame ?? CGRectZero
            
            return CGSizeMake(frame.width * CGFloat(page), 0)
        }
        ///
        override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            
            var ats = [UICollectionViewLayoutAttributes]()
            
            // 生成
            let frame = self.collectionView?.bounds ?? CGRectZero
            let count = self.collectionView?.numberOfItemsInSection(0) ?? 0
            
            let w: CGFloat = 36//(frame.width / CGFloat(self.column))
            let h: CGFloat = 36//(frame.height / CGFloat(self.row))
            let yg: CGFloat = 10
            let xg: CGFloat = (frame.width - w * CGFloat(self.column)) / CGFloat(self.column + 1)
            
            for i in 0 ..< count {
                // 计算。
                var r = CGFloat((i / self.column) % self.row)
                var c = CGFloat((i % self.column))
                let idx = NSIndexPath(forItem: i, inSection: 0)
                let page = CGFloat(i / (row * column))
                // 最后一个必须面右下
                if i == count - 1 {
                    r = CGFloat(self.row - 1)
                    c = CGFloat(self.column - 1)
                }
                let a = self.layoutAttributesForItemAtIndexPath(idx) ?? UICollectionViewLayoutAttributes(forCellWithIndexPath: idx)
                // .
                a.frame = CGRectMake(xg + c * (w + xg) + page * frame.width, yg + r * (h + yg), w, h)
                // o
                ats.append(a)
            }
            
            return ats
        }
    }
}

//
//@objc protocol SIMChatInputEmojiViewDelegate : NSObjectProtocol {
//    
//    optional func chatInputEmojiView(chatInputEmojiView: SIMChatInputEmojiView, shouldSelectEmoji emoji: String) -> Bool
//    optional func chatInputEmojiView(chatInputEmojiView: SIMChatInputEmojiView, didSelectEmoji emoji: String)
//    
//    optional func chatInputEmojiViewShouldDeleteText(chatInputEmojiView: SIMChatInputEmojiView) -> Bool
//    optional func chatInputEmojiViewDidDeleteText(chatInputEmojiView: SIMChatInputEmojiView)
//    
//    optional func chatInputEmojiViewShouldSendText(chatInputEmojiView: SIMChatInputEmojiView) -> Bool
//    optional func chatInputEmojiViewDidSendText(chatInputEmojiView: SIMChatInputEmojiView)
//}
