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
        
        title = album?.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "onCancel:")
        
        let s1 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: "")
//        let s2 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: "")
        let i1 = UIBarButtonItem(title: "预览", style: .Bordered, target: nil, action: "")
        let i2 = UIBarButtonItem(title: "编辑", style: .Bordered, target: nil, action: "")
        let i3 = UIBarButtonItem(title: "原图", style: .Bordered, target: nil, action: "")
        let i4 = UIBarButtonItem(title: "发送(99)", style: .Done, target: nil, action: "")
        
        i1.width = 32
        i2.width = 48
        i4.width = 48
        
        //setToolbarHidden(false)
        toolbarItems = [i1, i2, i3, s1, i4]
        
        // Register cell classes
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.registerClass(AssetCell.self, forCellWithReuseIdentifier: "Asset")
//        collectionView?.canCancelContentTouches = true
        
        if let collectionView = collectionView {
            // 添加手势
            let pan = UIPanGestureRecognizer(target: self, action: "onSelectItems:")
            pan.delegate = self
            collectionView.panGestureRecognizer.requireGestureRecognizerToFail(pan)
//            pan.requireGestureRecognizerToFail()
            collectionView.addGestureRecognizer(pan)
        }
    }
    
    /// 视图将要显示
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // 临时关闭侧滑手势
        navigationController?.interactivePopGestureRecognizer?.enabled = false
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    /// 视图将要消失
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // 恢复侧滑手势
        navigationController?.interactivePopGestureRecognizer?.enabled = true
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album?.count ?? 0
    }
    
    /// 创建单元格
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Asset", forIndexPath: indexPath) as! AssetCell
        // 标记和默认值
        cell.tag = indexPath.row
        cell.mark = false
        // 更新内容
        album?.asset(indexPath.row) { [weak self]asset in
            // 检查标记
            guard cell.tag == indexPath.row else {
                return
            }
            // 更新数据
            cell.asset = asset
            // 更新状态
            if let asset = asset {
                cell.mark = self?.selectedItems.contains(asset) ?? false
            } else {
                cell.mark = false
            }
        }
        // 设置回调事件
        cell.selectHandler = { [weak self] cell in
            // 检查数据, 如果没有数据说明还在加载, 不能点击
            guard let asset = cell.asset else {
                return
            }
            // 检查是否己经存在
            if let index = self?.selectedItems.indexOf(asset) {
                // 取消
                self?.selectedItems.removeAtIndex(index)
                cell.setMark(false, animated: true)
            } else {
                // 选中
                self?.selectedItems.insert(asset)
                cell.setMark(true, animated: true)
            }
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
    
    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        SIMLog.trace(indexPath)
    }
    
    // MARK: Rotate
    
    /// 转屏事件, iOS 6.x, iOS 7.x
    @available(iOS, introduced=2.0, deprecated=8.0)
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    /// 转屏事件, iOS 8.x
    @available(iOS, introduced=8.0)
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    private var selectedItems: Set<SIMChatImageAsset> = []
    
    // 批量选中
    private var selectedBegin: Int?
    private var selectedEnd: Int?
    private var selectedType: Bool?
    
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
    private class AssetCell : UICollectionViewCell, UIGestureRecognizerDelegate {
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            build()
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
            build()
        }
        private func build() {
            
            photoView.frame = bounds
            photoView.clipsToBounds = true
            photoView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            markView.frame = CGRectMake(bounds.width - 23 - 4.5, 4.5, 23, 23)
            markView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleBottomMargin]
            markView.userInteractionEnabled = true
            // 默认图片
            markView.image = SIMChatImageLibrary.sharedLibrary().deselectImage
            
            contentView.addSubview(photoView)
            contentView.addSubview(markView)
            
            // 添加点击手势
            let tap = UITapGestureRecognizer(target: self, action: "onSelectItem:")
            tap.delegate = self
            contentView.addGestureRecognizer(tap)
        }
        
        /// 重新调整可点击范围
        @objc func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
            let size = markView.bounds.size
            let origin = touch.locationInView(markView)
            // 如果在这个范围内
            if fabs(hypot(origin.x - size.width / 2, origin.y - size.height / 2)) < size.width {
                return true
            }
            return false
        }
        
        /// 选择事件
        private dynamic func onSelectItem(sender: AnyObject) {
            selectHandler?(self)
        }
        
        /// 设置
        func setMark(mark: Bool, animated: Bool) {
            self.mark = mark
            if animated && mark {
                // 选中时, 加点特效
                let a = CAKeyframeAnimation(keyPath: "transform.scale")
                
                a.values = [0.8, 1.2, 1]
                a.duration = 0.25
                a.calculationMode = kCAAnimationCubic
                
                markView.layer.addAnimation(a, forKey: "v")
            }
        }
        
        /// 图片
        var asset: SIMChatImageAsset? {
            didSet {
                photoView.asset = asset
            }
        }
        
        /// 标记
        var mark: Bool = false {
            didSet {
                // 必须有所改变
                guard mark != oldValue else {
                    return
                }
                let lib = SIMChatImageLibrary.sharedLibrary()
                markView.image = mark ? lib.selectImage : lib.deselectImage
            }
        }
        
        /// 选择事件回调
        /// 因为这个是一个不公开的类, 所以简单点直接用闭包
        var selectHandler: (AssetCell -> Void)?
        
        private lazy var photoView = SIMChatImagePhotoView(frame: CGRectZero)
        private lazy var markView = UIImageView(frame: CGRectZero)
    }
}

// MARK: - Event
extension SIMChatImageAssetsViewController : UIGestureRecognizerDelegate {
    
    /// 手势将要开始的时候检查一下是否需要使用
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let pt = pan.velocityInView(collectionView)
            // 检测手势的方向
            // 如果超出阀值视为放弃该手势
            if fabs(pt.y) > 240 || fabs(pt.y / pt.x) > 1.5 {
                return false
            }
        }
        return true
    }
    
    /// 取消
    private dynamic func onCancel(sender: AnyObject) {
        SIMLog.trace()
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    /// 批量选中
    private dynamic func onSelectItems(sender: UIPanGestureRecognizer) {
        let pt = sender.locationInView(collectionView)
        // 结束的时候检查状态
        defer {
            // 结束的时候重置他
            if sender.state == .Failed || sender.state == .Cancelled || sender.state == .Ended  {
                selectedBegin = nil
                selectedEnd = nil
                selectedType = nil
            }
        }
        // 先转为indexPath, 必须成功
        guard let indexPath = collectionView?.indexPathForItemAtPoint(pt) else {
            return
        }
        
        // 把上一次的结束做为取消
        let deselectedEnd = selectedEnd
        
        // 开始的时候必须重置选中区域
        if selectedBegin == nil {
            selectedBegin = indexPath.row
            selectedEnd = indexPath.row
        } else {
            selectedEnd = indexPath.row
        }
        
        // 如果为空就跳过事件处理
        guard let sb = selectedBegin, let se = selectedEnd else {
            return
        }
        
        let begin = min(sb, se)
        let end = max(sb, se)
        
        // 选中区域
        for i in begin ... end {
            guard let cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: i, inSection: 0)) as? AssetCell else {
                continue
            }
            // 取出
            if selectedType == nil {
                selectedType = !cell.mark
            }
            // 临时标记
            cell.mark = selectedType ?? true
            // 如果是结束, 那就提交
            // 对于手势取消/中断都认为是成功
            if sender.state == .Ended || sender.state == .Failed || sender.state == .Cancelled {
                if let asset = cell.asset, let mark = selectedType {
                    // 检查状态
                    if mark {
                        selectedItems.insert(asset)
                    } else {
                        selectedItems.remove(asset)
                    }
                }
            }
        }
        
        // 计算需要取消的
        if let ce = deselectedEnd {
            for i in min(sb, ce) ... max(sb, ce) {
                // 如果这个区域在sb-se之内, 跳过
                if begin <= i && i <= end {
                    continue
                }
                guard let cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: i, inSection: 0)) as? AssetCell else {
                    continue
                }
                // 重新恢复标记
                if let asset = cell.asset {
                    cell.mark = self.selectedItems.contains(asset)
                } else {
                    cell.mark = false
                }
            }
        }
    }
}