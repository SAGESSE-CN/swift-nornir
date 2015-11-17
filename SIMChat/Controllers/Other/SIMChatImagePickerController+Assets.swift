//
//  SIMChatImagePickerController+Assets.swift
//  SIMChat
//
//  Created by sagesse on 11/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

import Photos
import AssetsLibrary


extension SIMChatImagePickerController {
    /// 图片控制器
    class AssetsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
        
        init(album: SIMChatImagePickerController.Album) {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSizeMake(78, 78)
            layout.minimumLineSpacing = 2
            layout.minimumInteritemSpacing = 2
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
            
            // Register cell classes
            self.collectionView?.backgroundColor = UIColor.whiteColor()
            self.collectionView?.registerClass(AssetCell.self, forCellWithReuseIdentifier: "Asset")
        }
        
        /// 视图将要显示
        override func viewWillAppear(animated: Bool) {
            super.viewWillAppear(animated)
            // 临时关闭侧滑手势
            self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        }
        
        /// 视图将要消失
        override func viewWillDisappear(animated: Bool) {
            super.viewWillDisappear(animated)
            // 恢复侧滑手势
            self.navigationController?.interactivePopGestureRecognizer?.enabled = true
        }
        
        // MARK: UICollectionViewDataSource
        
        override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return album?.count ?? 0
        }
        
        /// 创建单元格
        override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Asset", forIndexPath: indexPath) as! AssetCell
            cell.asset = album?.assets[indexPath.row]
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
        private var album: SIMChatImagePickerController.Album?
        
        private let portraitColumn = 4
        private let landscapeColumn = 7
    }
}

// MARK: - Type
extension SIMChatImagePickerController.AssetsViewController {
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
            
            photo.frame = bounds
            photo.clipsToBounds = true
            photo.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            contentView.addSubview(photo)
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
        
        var asset: SIMChatImagePickerController.Asset? {
            didSet {
                photo.asset = asset
            }
        }
        
        private lazy var photo = SIMChatImagePickerController.PhotoView(frame: CGRectZero)
    }
}

// MARK: - Event
extension SIMChatImagePickerController.AssetsViewController {
    /// 取消
    private dynamic func onCancel(sender: AnyObject) {
        SIMLog.trace()
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}