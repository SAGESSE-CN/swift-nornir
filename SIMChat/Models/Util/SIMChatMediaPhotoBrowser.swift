//
//  SIMChatMediaPhotoBrowser.swift
//  SIMChat
//
//  Created by sagesse on 2/23/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation

public class SIMChatMediaPhotoBrowser: UIViewController, SIMChatMediaBrowserProtocol, SIMChatBrowseAnimatedTransitioningTarget, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        _collectionView.frame = view.bounds
        _collectionView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        view.backgroundColor = UIColor.blackColor()
        view.addSubview(_collectionView)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SIMLog.trace()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        SIMLog.trace()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
//    public func browse(URL: NSURL, withTarget: SIMChatBrowseAnimatedTransitioningTarget) {
//        SIMLog.trace(URL)
//        
//        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
//        
//        _defaultIndexPath = indexPath
//        _collectionView.scrollToItemAtIndexPath(indexPath,
//            atScrollPosition: .None,
//            animated: false)
//        
//        guard let window = withTarget.targetView?.window, rootViewController = window.rootViewController else {
//            return // 并没有显示
//        }
//        
//        SIMLog.trace()
//        
//        _browseTransitioning = SIMChatBrowseAnimatedTransitioning(from: withTarget, to: self)
//        
//        transitioningDelegate = _browseTransitioning
//        modalPresentationStyle = .Custom
//        
//        rootViewController.presentViewController(self, animated: true, completion: nil)
//    }
//    
//    public func close() {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
    // MARK: SIMChatBrowseAnimatedTransitioningTarget
    
    public var targetView: UIImageView? {
        guard let target = _currentDisplayCell() as? SIMChatBrowseAnimatedTransitioningTarget else {
            return nil
        }
        return target.targetView
    }
    
    // MARK: SIMChatMediaBrowserProtocol
    
    public func browse(media: SIMChatMediaProtocol, withTarget: SIMChatBrowseAnimatedTransitioningTarget) {
        SIMLog.trace()
        
        _datas.append(media)
        _collectionView.reloadData()
        
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        
        _defaultIndexPath = indexPath
        _collectionView.scrollToItemAtIndexPath(indexPath,
            atScrollPosition: .None,
            animated: false)
        
        guard let window = withTarget.targetView?.window, rootViewController = window.rootViewController else {
            return // 并没有显示
        }
        
        SIMLog.trace()
        
        _browseTransitioning = SIMChatBrowseAnimatedTransitioning(from: withTarget, to: self)
        
        transitioningDelegate = _browseTransitioning
        modalPresentationStyle = .Custom
        
        dispatch_async(dispatch_get_main_queue()) {
            rootViewController.presentViewController(self, animated: true, completion: nil)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = _defaultCell where indexPath.row == _defaultIndexPath?.row {
            return cell
        }
        return collectionView.dequeueReusableCellWithReuseIdentifier("Image", forIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? SIMChatMediaPhotoBrowserView {
            cell.media = _datas[indexPath.row]
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return view.bounds.size
    }
    
    /// 获取当前
    private func _currentDisplayCell() -> UICollectionViewCell? {
        guard let indexPath = _collectionView.indexPathsForVisibleItems().first ?? _defaultIndexPath else {
            return nil
        }
        return _collectionView.cellForItemAtIndexPath(indexPath) ?? _defaultCell ?? {
            let cell = _collectionView.dequeueReusableCellWithReuseIdentifier("Image", forIndexPath: indexPath)
            cell.frame = view.bounds
            collectionView(_collectionView, willDisplayCell: cell, forItemAtIndexPath: indexPath)
            _defaultCell = cell
            return cell
        }()
    }
    
    private var _defaultCell: UICollectionViewCell?
    private var _defaultIndexPath: NSIndexPath?
    
    private var _browseTransitioning: SIMChatBrowseAnimatedTransitioning?
    
    private lazy var _datas: Array<SIMChatMediaProtocol> = []
    
    private lazy var _collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        //view.delaysContentTouches = false
        view.scrollsToTop = false
        view.dataSource = self
        view.delegate = self
        view.pagingEnabled = true
        view.registerClass(SIMChatMediaPhotoBrowserView.self, forCellWithReuseIdentifier: "Image")
        view.backgroundColor = UIColor.blackColor()
        return view
    }()
}

internal class SIMChatMediaPhotoBrowserView: UICollectionViewCell, UIScrollViewDelegate, UIGestureRecognizerDelegate, SIMChatBrowseAnimatedTransitioningTarget {
    override init(frame: CGRect) {
        super.init(frame: frame)
        _build()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _build()
    }
    
    private func _build() {
        
        SIMLog.trace(self)
        
        
        _scrollView.addSubview(_imageView)
        _scrollView.addGestureRecognizer(_tapGestureRecognizer)
        _scrollView.addGestureRecognizer(_doubleTapGestureRecognizer)
        
        backgroundColor = UIColor.clearColor()
        contentView.addSubview(_scrollView)
    }
    
    private func _resetFrame() {
        if _scrollView.frame.size != bounds.size {
            _scrollView.frame = bounds
        }
    }
    
    private func _resetZoomScale() {
        let from = _imageView.bounds.size
        var to = media?.size ?? _imageView.image?.size ?? CGSizeZero
        
        to.width = max(to.width, 1)
        to.height = max(to.height, 1)
        
        // 计算出最小的.
        let scale = min(min(bounds.width, to.width) / to.width, min(bounds.height, to.height) / to.height)
        let fit = CGRectMake(0, 0, scale * to.width, scale * to.height)
        
        _scrollView.zoomScale = 1
        _scrollView.minimumZoomScale = 1
        _scrollView.maximumZoomScale = max(max(to.width / fit.width, to.height / fit.height), 2)
        
        SIMLog.trace("from: \(from), to: \(to), scale: \(_scrollView.maximumZoomScale)")
        
        _imageView.bounds = fit
        _imageView.center = CGPointMake(
            max(fit.width, _scrollView.bounds.width) / 2,
            max(fit.height, _scrollView.bounds.height) / 2)
    }
    
    /// 单击退出
    private dynamic func _tap(sender: UIGestureRecognizer) {
        SIMLog.trace()
        if sender.state == .Ended {
            viewController()?.dismissViewControllerAnimated(true, completion: nil)
//            if let view = delegate as? SIMChatPhotoBrowseView {
//                delegate?.browseViewDidClick?(view)
//            }
        }
    }
    /// 旋转
    private dynamic func _rotation(recognizer: UIRotationGestureRecognizer) {
        SIMLog.debug("\(recognizer.rotation) => \(recognizer.velocity)")
        
        _scrollView.panGestureRecognizer.enabled = false
        
        let t = CGAffineTransformMakeScale(_scrollView.zoomScale, _scrollView.zoomScale)
        _imageView.transform = CGAffineTransformRotate(t, recognizer.rotation)
    }
    /// 双击
    private dynamic func _doubleTap(sender: AnyObject) {
        SIMLog.trace()
//        if sender.state == .Ended {
//            if let view = delegate as? SIMChatPhotoBrowseView {
//                delegate?.browseViewDidDoubleClick?(view)
//            }
//        }
        if _scrollView.zoomScale > _scrollView.minimumZoomScale {
            _scrollView.setZoomScale(_scrollView.minimumZoomScale, animated: true)
        } else {
            _scrollView.setZoomScale(_scrollView.maximumZoomScale, animated: true)
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: UIScrollViewDelegate
    
    /// yp
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return _imageView
    }
    /// xp
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let size = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        _imageView.center = CGPointMake(
            contentSize.width / 2 + max((size.width - contentSize.width) / 2, 0),
            contentSize.height / 2 + max((size.height - contentSize.height) / 2, 0))
    }
    
    /// 准备复用
    override func prepareForReuse() {
        super.prepareForReuse()
        // 重置
        _resetFrame()
        _resetZoomScale()
    }
    
    /// 更新布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = max(_scrollView.contentSize.width, _scrollView.bounds.width)
        let height = max(_scrollView.contentSize.height, _scrollView.bounds.height)
        
        _imageView.center = CGPointMake(width / 2, height / 2)
    }
    
    var media: SIMChatMediaProtocol? {
        didSet {
            guard let media = media where media !== oldValue else {
                return
            }
            
            // 重置大小
            _isLoadOrigin = false
            _resetFrame()
            _resetZoomScale()
            
            let fp = SIMChatFileProvider.sharedInstance()
            
            // 加载原图
            fp.loadResource(media.origin) { [weak self] in
                guard let image = $0.value as? UIImage
                    where media === self?.media else {
                        return
                }
                SIMLog.trace("use image in origin")
                self?._isLoadOrigin = true
                self?._imageView.image = image
            }
            // 检查是否加载了原图
            guard !_isLoadOrigin else {
                return
            }
            // 加载缩略图
            fp.loadResource(media.thumbnail) { [weak self] in
                guard let image = $0.value as? UIImage
                    where media === self?.media
                        && !(self?._isLoadOrigin ?? false) else {
                            return
                }
                SIMLog.trace("use image in thumbnail")
                self?._imageView.image = image
            }
        }
    }
    
    private var _isLoadOrigin = false
    
    var targetView: UIImageView? {
        return _imageView
    }
    
    private lazy var _imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    private lazy var _scrollView: UIScrollView = {
        let view = UIScrollView()
        view.zoomScale = 1.0
        view.minimumZoomScale = 1.0
        view.maximumZoomScale = 2.0
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        view.clipsToBounds = false
        return view
    }()
    
    // 手势
    private lazy var _tapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: "_tap:")
        tap.requireGestureRecognizerToFail(self._doubleTapGestureRecognizer)
        return tap
    }()
    private lazy var _doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: "_doubleTap:")
        tap.numberOfTapsRequired = 2
        return tap
    }()
    private lazy var _rotationGestureRecognizer: UIRotationGestureRecognizer = {
        let rotation = UIRotationGestureRecognizer(target: self, action: "_rotation:")
        rotation.delegate = self
        return rotation
    }()
}
