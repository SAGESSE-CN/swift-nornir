//
//  SIMChatImagePickerController+Assets.swift
//  SIMChat
//
//  Created by sagesse on 11/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 图片控制器
class SIMChatImageAssetsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    init(album: SIMChatImageAlbum) {
        let layout = AssetLayout()
        layout.itemSize = CGSizeMake(78, 78)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.headerReferenceSize = CGSizeMake(0, 10)
        layout.footerReferenceSize = CGSizeZero
        self.album = album
        super.init(collectionViewLayout: layout)
    }
    required init?(coder aDecoder: NSCoder) {
        self.album = nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(album != nil, "Album can't empty!")
        
        self.title = album?.title
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "onCancel:")
        
        let s1 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: "")
//        let s2 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: "")
        let i1 = UIBarButtonItem(title: "预览", style: .Bordered, target: nil, action: "")
        let i2 = UIBarButtonItem(title: "编辑", style: .Bordered, target: nil, action: "")
        let i3 = UIBarButtonItem(title: "原图", style: .Bordered, target: nil, action: "")
        let i4 = UIBarButtonItem(title: "发送(99)", style: .Done, target: nil, action: "")
        
        i1.width = 32
        i2.width = 48
        i4.width = 48
        
        
        //self.setToolbarHidden(false)
        self.toolbarItems = [i1, i2, i3, s1, i4]
        
        // Register cell classes
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.collectionView?.registerClass(AssetCell.self, forCellWithReuseIdentifier: "Asset")
        
    }
    
    /// 视图将要显示
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // 临时关闭侧滑手势
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    /// 视图将要消失
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // 恢复侧滑手势
        self.navigationController?.interactivePopGestureRecognizer?.enabled = true
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album?.count ?? 0
    }
    
    /// 创建单元格
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Asset", forIndexPath: indexPath) as! AssetCell
        album?.asset(indexPath.row) { asset in
            cell.asset = asset
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    /// 计算每个单元格的大小
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        let column = UIDevice.currentDevice().orientation.isLandscape ? landscapeColumn : portraitColumn
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            let tw = (width - (layout.minimumInteritemSpacing * CGFloat(column - 1))) / CGFloat(column)
            return CGSizeMake(tw, tw)
        }
        return CGSizeMake(width / CGFloat(column), width / CGFloat(column))
    }
    
    // MARK: Rotate
    
    /// 转屏事件, iOS 6.x, iOS 7.x
    @available(iOS, introduced=2.0, deprecated=8.0)
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        self.collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    /// 转屏事件, iOS 8.x
    @available(iOS, introduced=8.0)
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    // ..
    private var album: SIMChatImageAlbum?
    
    private let portraitColumn = 4
    private let landscapeColumn = 7
}

// MARK: - Type
extension SIMChatImageAssetsViewController {
    /// 图片布局
    private class AssetLayout : UICollectionViewFlowLayout {
        override func collectionViewContentSize() -> CGSize {
            let s = super.collectionViewContentSize()
            guard let collectionView = collectionView else {
                return s
            }
            let h = collectionView.bounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
            // 加上1让他动起来
            return CGSizeMake(s.width, max(h + 0.25, s.height))
        }
    }
    /// 图片单元格
    private class AssetCell : UICollectionViewCell {
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.build()
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.build()
        }
        private func build() {
            
            backgroundView = UIView()
            backgroundView?.backgroundColor = UIColor(white: 0, alpha: 0.4)
            backgroundView?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            photoView.frame = bounds
            photoView.clipsToBounds = true
            photoView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            markView.frame = CGRectMake(bounds.width - 23 - 4.5, 4.5, 23, 23)
            markView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleBottomMargin]
            markView.image = UIImage(named: "image_deselect")
            markView.highlightedImage = UIImage(named: "image_select")
            markView.userInteractionEnabled = true
            
            contentView.addSubview(photoView)
            contentView.addSubview(markView)
        }
        
        override var highlighted: Bool {
            willSet {
                // 必须有要所改变
                guard newValue != highlighted else {
                    return
                }
                // 有?
                if newValue {
                    self.backgroundView?.frame = self.contentView.bounds
                    if self.backgroundView?.superview != self.contentView && self.backgroundView != nil {
                        self.contentView.addSubview(self.backgroundView!)
                    }
                } else {
                    if self.backgroundView?.superview != nil {
                        self.backgroundView?.removeFromSuperview()
                    }
                }
            }
        }
        
        var asset: SIMChatImageAsset? {
            didSet {
                photoView.asset = asset
            }
        }
        
        private lazy var photoView = SIMChatImagePhotoView(frame: CGRectZero)
        private lazy var markView = UIImageView(frame: CGRectZero)
    }
}

// MARK: - Event
extension SIMChatImageAssetsViewController {
    /// 取消
    private dynamic func onCancel(sender: AnyObject) {
        SIMLog.trace()
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}