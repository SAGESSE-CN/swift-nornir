//
//  SIMChatPhotoBrowseView.swift
//  SIMChat
//
//  Created by sagesse on 11/22/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 元素
@objc public protocol SIMChatPhotoBrowseElement : NSObjectProtocol {
    ///
    /// 获取原图
    /// - parameter block 结果
    ///
    func original(block: UIImage? -> Void)
    ///
    /// 获取缩略图
    /// - parameter targetSize 目标, 如果为0自动获取(缓存)
    /// - parameter block 结果
    ///
    func thumbnail(targetSize: CGSize, block: UIImage? -> Void)
    ///
    /// 获取屏幕大小的图片
    /// - parameter block 结果
    ///
    func fullscreen(block: UIImage? -> Void)
   
    func originalIsLoaded() -> Bool
    func thumbnailIsLoaded() -> Bool
    func fullscreenIsLoaded() -> Bool
}

/// 图片浏览的数据源
public protocol SIMChatPhotoBrowseDataSource : class {
    ///
    /// 显示数量
    ///
    var count: Int { get }
    ///
    /// 获取对象
    /// - parameter targetSize 目标
    /// - parameter block 结果
    ///
    func fetch(index: Int, block: SIMChatPhotoBrowseElement? -> Void)
}

/// 图片浏览的代理
@objc public protocol SIMChatPhotoBrowseDelegate : NSObjectProtocol {
    /// 单击
    optional func browseViewDidClick(browseView: SIMChatPhotoBrowseView)
    /// 双击
    optional func browseViewDidDoubleClick(browseView: SIMChatPhotoBrowseView)
    
    /// 将要显示
    optional func browseView(browseView: SIMChatPhotoBrowseView, willDisplayElement element: SIMChatPhotoBrowseElement)
    /// 完成显示
    optional func browseView(browseView: SIMChatPhotoBrowseView, didDisplayElement element: SIMChatPhotoBrowseElement)
}

///
/// 图片浏览
///
public class SIMChatPhotoBrowseView: UIView {
    /// 序列化
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.build()
    }
    /// 初始化
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.build()
    }
    /// 构建
    func build() {
        let itemSpacing = SIMChatPhotoBrowseView.itemSpacing
        
        collectionView.frame = CGRectMake(-itemSpacing, 0, bounds.width + itemSpacing * 2, bounds.height)
        collectionView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        addSubview(collectionView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        SIMLog.trace()
        // 有任何风吹草动, 重置他
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func setCurrentIndex(index: Int, animated: Bool) {
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: .None, animated: false)
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsetsZero
        
        collection.delegate = self
        collection.dataSource = self
        collection.pagingEnabled = true
        collection.backgroundColor = UIColor.clearColor()
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.registerClass(ItemCellOfImage.self, forCellWithReuseIdentifier: "Image")
        
        return collection
    }()
    
    var currentShowIndex: Int = 0
    
    weak var dataSource: SIMChatPhotoBrowseDataSource?
    weak var delegate: SIMChatPhotoBrowseDelegate?
    
    static let itemSpacing: CGFloat = 16
}

extension SIMChatPhotoBrowseView : SIMChatPhotoBrowseDelegate {
    
    public func browseViewDidClick(browseView: SIMChatPhotoBrowseView) {
        delegate?.browseViewDidClick?(self)
    }
    
    public func browseViewDidDoubleClick(browseView: SIMChatPhotoBrowseView) {
        delegate?.browseViewDidDoubleClick?(self)
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension SIMChatPhotoBrowseView : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// Item数量
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    /// Item的视图
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Image", forIndexPath: indexPath) as! ItemCellOfImage
        
        // 打上标记
        cell.tag = indexPath.row
        cell.element = nil
        cell.imageView.delegate = self
        
        dataSource?.fetch(indexPath.row) { ele in
            // 检查标记
            guard cell.tag == indexPath.row else {
                return
            }
            cell.element = ele
        }
        
        // 加载前后
        
        return cell
    }
    
    /// 每个Item的大小
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // 减掉被自动缩进的值
        let width = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        let height = collectionView.bounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
        //SIMLog.trace("\(width) => \(height)")
        return CGSizeMake(width, height)
    }
    
    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        // 最新的位置
        let index = Int(round(collectionView.contentOffset.x / collectionView.bounds.width) + 0.1)
        
        // 通知.
        dataSource?.fetch(index) { [weak self] ele in
            guard let view = self, let ele = ele where index == view.currentShowIndex else {
                return
            }
            self?.delegate?.browseView?(view, didDisplayElement: ele)
        }
    }
    
    /// 滚动
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        // 最新的位置
        let index = Int(round(scrollView.contentOffset.x / scrollView.bounds.width) + 0.1)

        // 改变了?
        guard index != currentShowIndex else {
            return
        }
        currentShowIndex = index
        // 通知.
        dataSource?.fetch(index) { [weak self] ele in
            guard let view = self, let ele = ele where index == view.currentShowIndex else {
                return
            }
            self?.delegate?.browseView?(view, willDisplayElement: ele)
        }
    }
}

// MARK: - Type 
extension SIMChatPhotoBrowseView {
    private class ItemCellOfImage : UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)
            build()
        }
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            build()
        }
        private func build() {
            let itemSpacing = SIMChatPhotoBrowseView.itemSpacing
            
            imageView.frame = CGRectMake(itemSpacing, 0, bounds.width - itemSpacing * 2, bounds.height)
            imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            contentView.addSubview(imageView)
        }
        
        /// 需要显示的元素
        var element: SIMChatPhotoBrowseElement? {
            set { return imageView.element = newValue }
            get { return imageView.element }
        }
        
        private let imageView = SIMChatPhotoBrowseViewImage(frame: CGRectZero)
    }
}