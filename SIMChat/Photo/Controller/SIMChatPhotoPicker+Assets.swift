//
//  SIMChatPhotoPicker+Assets.swift
//  SIMChat
//
//  Created by sagesse on 11/22/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 图片控制器
internal class SIMChatPhotoPickerAssets: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    init(_ album: SIMChatPhotoAlbum, _ picker: SIMChatPhotoPicker?) {
        let layout = AssetLayout()
        layout.itemSize = CGSizeMake(78, 78)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.headerReferenceSize = CGSizeMake(0, 10)
        layout.footerReferenceSize = CGSizeZero
        self.album = album
        self.picker = picker
        super.init(collectionViewLayout: layout)
    }
    required init?(coder aDecoder: NSCoder) {
        self.album = nil
        self.picker = nil
        super.init(coder: aDecoder)
    }
    deinit {
        // 完成。清除他
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(album != nil, "Album can't empty!")
        
        title = album?.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "onCancel:")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Done, target: nil, action: "")
        
        if picker?.allowsMultipleSelection ?? false {
            let s1 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: "")
            let i1 = UIBarButtonItem(title: "预览", style: .Plain, target: self, action: "onPreview:")
            let i3 = UIBarButtonItem(customView: originButton)
            let i4 = UIBarButtonItem(title: "发送(0)", style: .Done, target: self, action: "onSend:")
            
            i1.width = 32
            i4.width = 48
            
            toolbarItems = [i1, i3, s1, i4]
        }
        
        // Register cell classes
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.registerClass(AssetCell.self, forCellWithReuseIdentifier: "Asset")
//        collectionView?.canCancelContentTouches = true
        
        // 添加手势
        let pan = UIPanGestureRecognizer(target: self, action: "onSelectItems:")
        pan.delegate = self
        pan.enabled = picker?.allowsMultipleSelection ?? false
        collectionView?.panGestureRecognizer.requireGestureRecognizerToFail(pan)
        collectionView?.addGestureRecognizer(pan)
        
        // 更新选中数量
        selectedCountChanged(picker?.selectedItems.count ?? 0)
        
        // 监听
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onSelectedCountChangedNTF:", name: SIMChatPhotoPickerCountDidChangedNotification, object: nil)
    }
    
    /// 视图将要显示
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SIMLog.trace()
        // 开启工具栏
        navigationController?.setToolbarHidden(!(picker?.allowsMultipleSelection ?? false), animated: animated)
        
        // 回来的时候重置当前显示的
        if let indexs = collectionView?.indexPathsForVisibleItems() where album?.count ?? 0 != 0 && needUpdateSelectedItems {
            let cur = NSIndexPath(forItem: self.currentSelectedIndex, inSection: 0)
            // 重置可见的单元格
            if let cells = collectionView?.visibleCells() {
                for cell in cells {
                    if let cell = cell as? AssetCell {
                        cell.mark = self.picker?.checkItem(cell.asset) ?? false
                    }
                }
            }
            // 如果需要显示, 那就滚动
            if !indexs.contains(cur) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView?.scrollToItemAtIndexPath(cur, atScrollPosition: .CenteredVertically, animated: false)
                }
            }
        }
        
        // 重置显示
        onOrigin(nil)
    }
    
    /// 视图将要消失
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        SIMLog.trace()
        // 恢复侧滑手势
        navigationController?.interactivePopGestureRecognizer?.enabled = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        SIMLog.trace()
        // 临时关闭侧滑手势
        navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        SIMLog.trace()
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
        cell.markView.hidden = !(picker?.allowsMultipleSelection ?? false)
        // 更新内容
        album?.asset(indexPath.row) { [weak self]asset in
            // 检查标记
            guard cell.tag == indexPath.row else {
                return
            }
            // 更新数据
            cell.asset = asset
            // 更新状态
            cell.mark = self?.picker?.checkItem(asset) ?? false
            cell.markView.hidden = !(self?.picker?.allowsMultipleSelection ?? false) || !(self?.picker?.canSelectItem(asset) ?? true)
        }
        // 设置回调事件
        cell.selectHandler = { [weak self] cell in
            // 检查数据, 如果没有数据说明还在加载, 不能点击
            guard let asset = cell.asset, let ss = self else {
                return
            }
            // 检查是否己经存在
            if ss.picker?.checkItem(asset) ?? false {
                // 取消
                ss.picker?.deselectItem(asset)
                cell.setMark(false, animated: true)
            } else {
                // 选中
                let st = ss.picker?.selectItem(asset) ?? false
                cell.setMark(st, animated: true)
            }
        }
        return cell
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    /// 计算每个单元格的大小
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        let column = columnMax()
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            let tw = (width - (layout.minimumInteritemSpacing * CGFloat(column - 1))) / CGFloat(column)
            return CGSizeMake(tw, tw)
        }
        return CGSizeMake(width / CGFloat(column), width / CGFloat(column))
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        SIMLog.trace(indexPath.row)
        
        currentSelectedIndex = indexPath.row
        
        onShowBrowser(album, defIndex: currentSelectedIndex)
    }
    
    // MARK: Rotate
    
    /// 转屏事件, iOS 6.x, iOS 7.x
    @available(iOS, introduced=2.0, deprecated=8.0)
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        collectionView?.collectionViewLayout.invalidateLayout()
        SIMLog.trace()
    }
    
    /// 转屏事件, iOS 8.x
    @available(iOS, introduced=8.0)
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        collectionView?.collectionViewLayout.invalidateLayout()
        SIMLog.trace()
    }
    
    private lazy var originButton: UIButton = {
        let btn = UIButton(type: .System)
        
        btn.setImage(SIMChatPhotoLibrary.Images.markDeselect, forState:  .Normal)
        btn.titleLabel?.font = UIFont.systemFontOfSize(17)
        btn.setTitle("原图", forState: .Normal)
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
        btn.sizeToFit()
        btn.frame = CGRectMake(0, 0, btn.bounds.width + 8, btn.bounds.height)
        
        btn.addTarget(self, action: "onOrigin:", forControlEvents: .TouchUpInside)
        
        return btn
    }()
    
    // 批量选中
    private var selectedBegin: Int?
    private var selectedEnd: Int?
    private var selectedType: Bool?
    
    // ..
    private var album: SIMChatPhotoAlbum?
    
    private let portraitColumn = 4
    private let landscapeColumn = 7
    private var needUpdateSelectedItems = false
    
    // 当前选中的
    var currentSelectedIndex: Int = 0 {
        didSet {
            guard currentSelectedIndex != oldValue else {
                return
            }
            needUpdateSelectedItems = true
        }
    }
    
    /// 选择器
    weak var picker: SIMChatPhotoPicker?
}

//// MARK: - Transitions
//extension SIMChatPhotoPickerAssets : UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning {
//    
//    /// 转场时间
//    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
//        return 0.25
//    }
//    /// 动画效果
//    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
//        // ok
//        guard let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
//            return
//        }
//        
//        let containerView = transitionContext.containerView()
//        
//        toVC.view.frame = transitionContext.finalFrameForViewController(toVC)
//        toVC.view.alpha = 0
//        
//        containerView?.addSubview(toVC.view)
//        
//        
//        UIView.animateWithDuration(0.25, animations: {
//            toVC.view.alpha = 1
//        }, completion: { f in
//            transitionContext.completeTransition(true)
//        })
//        
////        // 初始化一开始的状态
////        toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
////        toViewController.view.alpha = 0;
////        toViewController.imageView.hidden = YES;
////        
////        [containerView addSubview:toViewController.view];
//    }
//    /// 动画结束
//    func animationEnded(transitionCompleted: Bool) {
//        SIMLog.trace()
//    }
//    
//    /// 切换
//    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
////        if fromVC is SIMChatImagePreviewsViewController || toVC is SIMChatImagePreviewsViewController {
////            return self
////        }
//        return nil
//    }
//}

// MARK: - Type
extension SIMChatPhotoPickerAssets {
    /// 图片布局
    private class AssetLayout : UICollectionViewFlowLayout {
        override func collectionViewContentSize() -> CGSize {
            originContentSize = super.collectionViewContentSize()
            guard let collectionView = collectionView else {
                return originContentSize
            }
            let h = collectionView.bounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
            // 加上1让他动起来
            return CGSizeMake(originContentSize.width, max(h + 0.25, originContentSize.height))
        }
        var originContentSize = CGSizeZero
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
            
            assetView.frame = bounds
            assetView.clipsToBounds = true
            assetView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            markView.frame = CGRectMake(bounds.width - 23 - 4.5, 4.5, 23, 23)
            markView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleBottomMargin]
            markView.userInteractionEnabled = true
            // 默认图片
            markView.image = SIMChatPhotoLibrary.Images.markDeselect
            
            contentView.addSubview(assetView)
            contentView.addSubview(markView)
            
            // 添加点击手势
            let tap = UITapGestureRecognizer(target: self, action: "onSelectItem:")
            tap.delegate = self
            contentView.addGestureRecognizer(tap)
        }
        
        /// 重新调整可点击范围
        @objc func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
            // 必须要显示
            if markView.hidden || markView.alpha < 0.1 {
                return false
            }
            let size = markView.bounds.size
            let origin = touch.locationInView(markView)
            // 如果在这个半径范围内
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
            if animated {
                // 选中时, 加点特效
                let a = CAKeyframeAnimation(keyPath: "transform.scale")
                
                a.values = [0.8, 1.2, 1]
                a.duration = 0.25
                a.calculationMode = kCAAnimationCubic
                
                markView.layer.addAnimation(a, forKey: "v")
            }
        }
        
        /// 图片
        var asset: SIMChatPhotoAsset? {
            didSet {
                assetView.asset = asset
                // 检查类型
                switch asset?.mediaType ?? .Unknown  {
                case .Unknown:  assetView.badgeStyle = .None
                case .Image:    assetView.badgeStyle = .None
                case .Video:    assetView.badgeStyle = .Video
                case .Audio:    assetView.badgeStyle = .Audio
                }
                let duration = asset?.mediaDuration ?? 0
                // 总是更新value
                assetView.badgeValue = String(format: "%d:%02d", Int(duration / 60), Int(duration % 60))
            }
        }
        
        /// 标记
        var mark: Bool = false {
            didSet {
                // 必须有所改变
                guard mark != oldValue else {
                    return
                }
                markView.image = mark ? SIMChatPhotoLibrary.Images.markSelect : SIMChatPhotoLibrary.Images.markDeselect
            }
        }
        
        /// 选择事件回调
        /// 因为这个是一个不公开的类, 所以简单点直接用闭包
        var selectHandler: (AssetCell -> Void)?
        
        private lazy var markView = UIImageView(frame: CGRectZero)
        private lazy var assetView = SIMChatPhotoAssetView(frame: CGRectZero)
    }
}

// MARK: - Event
extension SIMChatPhotoPickerAssets : UIGestureRecognizerDelegate {
    
    /// 手势将要开始的时候检查一下是否需要使用
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let pt = pan.velocityInView(collectionView)
            // 检测手势的方向
            // 如果超出阀值视为放弃该手势
            if fabs(pt.y) > 80 || fabs(pt.y / pt.x) > 2.5 {
                return false
            }
        }
        return true
    }
    
    /// 获取显示
    @inline(__always) private func columnMax() -> Int {
        return UIDevice.currentDevice().orientation.isLandscape ? landscapeColumn : portraitColumn
    }
    
    /// 显示预览
    @inline(__always) private func onShowBrowser(source: SIMChatPhotoBrowseDataSource?, defIndex: Int) {
        // 创建.
        let vc = SIMChatPhotoPickerPreviews(source, picker, def: defIndex)
        
        vc.previousViewController = self
        
        //navigationController?.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 数量改变
    @inline(__always) private func selectedCountChanged(count: Int) {
        if let it = toolbarItems?.last as UIBarButtonItem? {
            let nmin = max(picker?.minimumNumberOfSelection ?? 0, 1)
            let nmax = picker?.maximumNumberOfSelection ?? 0 < nmin ? Int.max : picker?.maximumNumberOfSelection ?? 0
            
            it.enabled = count >= nmin && count <= nmax
            it.title = "发送(\(count))"
        }
        if let it = toolbarItems?.first as UIBarButtonItem? {
            it.enabled = count > 0
            originButton.enabled = count > 0
        }
    }
    private dynamic func onSelectedCountChangedNTF(sender: NSNotification) {
        selectedCountChanged((sender.object as? Int) ?? 0)
    }
    ///
    /// 点击取消
    ///
    private dynamic func onCancel(sender: AnyObject) {
        SIMLog.trace()
        picker?.cancel()
    }
    ///
    /// 点击返回
    ///
    private dynamic func onBack(sender: AnyObject) {
        SIMLog.trace()
        navigationController?.popViewControllerAnimated(true)
    }
    ///
    /// 点击发送
    ///
    private dynamic func onSend(sender: AnyObject) {
        SIMLog.trace()
        picker?.confirm()
    }
    ///
    /// 更新原图选项
    ///
    private dynamic func onOrigin(sender: AnyObject?) {
        SIMLog.trace()
        
        // 按钮才改变
        if sender != nil {
           picker?.requireOrigin = !(picker?.requireOrigin ?? false)
        }
        
        if picker?.requireOrigin ?? false {
            originButton.setImage(SIMChatPhotoLibrary.Images.markSelectSmall, forState: .Normal)
        } else {
            originButton.setImage(SIMChatPhotoLibrary.Images.markDeselectSmall, forState: .Normal)
        }
    }
    ///
    /// 预览
    ///
    private dynamic func onPreview(sender: AnyObject) {
        SIMLog.trace()
        let source = (picker?.selectedItems.array as NSArray?)?.copy() as? NSArray
        onShowBrowser(source, defIndex: 0)
    }
    ///
    /// 批量选中
    ///
    private dynamic func onSelectItems(sender: UIPanGestureRecognizer) {
        let pt = sender.locationInView(collectionView)
        // 离开作用哉的时候检查状态
        defer {
            if sender.state == .Ended || sender.state == .Failed || sender.state == .Cancelled {
                // 如果为空就跳过事件处理
                if let sb = selectedBegin, let se = selectedEnd {
                    // 如果是结束, 那就提交选中区域
                    for i in min(sb, se) ... max(sb, se) {
                        guard let cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: i, inSection: 0)) as? AssetCell else {
                            continue
                        }
                        // 不能选择隐藏的元素
                        guard !cell.markView.hidden else {
                            continue
                        }
                        if let asset = cell.asset, let mark = selectedType {
                            // 检查状态
                            if mark {
                                cell.mark = picker?.selectItem(asset) ?? false
                            } else {
                                picker?.deselectItem(asset)
                                cell.mark = false
                            }
                        }
                    }
                }
                
                selectedBegin = nil
                selectedEnd = nil
                selectedType = nil
            }
        }
        
        // 转为indexPath
        var currentIndexPath = collectionView?.indexPathForItemAtPoint(pt)
        
        // 检查边界
        if let collectionView = collectionView, let layout = collectionViewLayout as? UICollectionViewFlowLayout where currentIndexPath == nil {
            if pt.y <= 0 {
                // 小于头
                if collectionView.numberOfItemsInSection(0) > 0 {
                    currentIndexPath = NSIndexPath(forItem: 0, inSection: 0)
                }
            } else {
                let size = self.collectionView(collectionView, layout: layout, sizeForItemAtIndexPath: NSIndexPath())
                
                // 计算这个点虚拟的index
                let row = Int((pt.y + layout.minimumLineSpacing) / (size.height + layout.minimumLineSpacing))
                let column = Int((pt.x + layout.minimumInteritemSpacing) / (size.width + layout.minimumInteritemSpacing))
                let columnMax = self.columnMax()
                let index = (row * columnMax) + column
                
                // 超出末尾
                if index >= collectionView.numberOfItemsInSection(0) {
                    // 大于尾
                    let idx = max(collectionView.numberOfItemsInSection(0) - 1, 0)
                    currentIndexPath = NSIndexPath(forItem: idx, inSection: 0)
                }
            }
        }
        
        // 先转为indexPath, 必须成功
        guard let indexPath = currentIndexPath  else {
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
        var count = picker?.selectedItems.count ?? 0
        
        // 选中区域
        for i in begin ... end {
            guard let cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: i, inSection: 0)) as? AssetCell else {
                continue
            }
            // 不能选择隐藏的元素
            guard !cell.markView.hidden else {
                continue
            }
            // 真实的状态
            let rmark = picker?.checkItem(cell.asset) ?? false
            // 取出
            if selectedType == nil {
                selectedType = !cell.mark
            }
            // 临时标记
            cell.mark = selectedType ?? true
            // 需要修改
            if let type = selectedType where cell.mark != rmark {
                if type {
                    count++
                } else {
                    count--
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
                cell.mark = picker?.checkItem(cell.asset) ?? false
            }
        }
        
        // 数量改变
        selectedCountChanged(count)
    }
}

// MARK: -  SIMChatPhotoBrowseDataSource
extension NSArray : SIMChatPhotoBrowseDataSource {
    public func fetch(index: Int, block: SIMChatPhotoBrowseElement? -> Void) {
        if index < count {
            block(self[index] as? SIMChatPhotoBrowseElement)
        } else {
            block(nil)
        }
    }
}