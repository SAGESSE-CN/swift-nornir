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
        _collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.backgroundColor = UIColor.black
        view.addSubview(_collectionView)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SIMLog.trace()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SIMLog.trace()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
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
    
    public func browse(_ media: SIMChatMediaProtocol, withTarget: SIMChatBrowseAnimatedTransitioningTarget) {
        SIMLog.trace()
        
        _datas.append(media)
        _collectionView.reloadData()
        
        let indexPath = IndexPath(item: 0, section: 0)
        
        _defaultIndexPath = indexPath
        _collectionView.scrollToItem(at: indexPath,
            at: UICollectionViewScrollPosition(),
            animated: false)
        
        guard let window = withTarget.targetView?.window, let rootViewController = window.rootViewController else {
            return // 并没有显示
        }
        
        SIMLog.trace()
        
        _browseTransitioning = SIMChatBrowseAnimatedTransitioning(from: withTarget, to: self)
        
        transitioningDelegate = _browseTransitioning
        modalPresentationStyle = .custom
        
        DispatchQueue.main.async {
            // 不允许为空
            self.targetView?.image = self.targetView?.image ?? withTarget.targetView?.image
            
//            if let nav = rootViewController as? UINavigationController, let top = nav.topViewController {
//                top.present(self, animated: true, completion: nil)
//            } else {
                rootViewController.present(self, animated: true, completion: nil)
//            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = _defaultCell , (indexPath as NSIndexPath).row == _defaultIndexPath?.row {
            return cell
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Image", for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? SIMChatMediaPhotoBrowserView {
            cell.media = _datas[(indexPath as NSIndexPath).row]
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.bounds.size
    }
    
    /// 获取当前
    private func _currentDisplayCell() -> UICollectionViewCell? {
        guard let indexPath = _collectionView.indexPathsForVisibleItems.first ?? _defaultIndexPath else {
            return nil
        }
        return _collectionView.cellForItem(at: indexPath) ?? _defaultCell ?? {
            let cell = _collectionView.dequeueReusableCell(withReuseIdentifier: "Image", for: indexPath)
            cell.frame = view.bounds
            collectionView(_collectionView, willDisplay: cell, forItemAt: indexPath)
            _defaultCell = cell
            return cell
        }()
    }
    
    private var _defaultCell: UICollectionViewCell?
    private var _defaultIndexPath: IndexPath?
    
    private var _browseTransitioning: SIMChatBrowseAnimatedTransitioning?
    
    private lazy var _datas: Array<SIMChatMediaProtocol> = []
    
    private lazy var _collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        //view.delaysContentTouches = false
        view.scrollsToTop = false
        view.dataSource = self
        view.delegate = self
        view.isPagingEnabled = true
        view.register(SIMChatMediaPhotoBrowserView.self, forCellWithReuseIdentifier: "Image")
        view.backgroundColor = UIColor.black
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
        
        backgroundColor = UIColor.clear
        contentView.addSubview(_scrollView)
    }
    
    private func _resetFrame() {
        if _scrollView.frame.size != bounds.size {
            _scrollView.frame = bounds
        }
    }
    
    private func _resetZoomScale() {
        let from = _imageView.bounds.size
        var to = media?.size ?? _imageView.image?.size ?? CGSize.zero
        
        to.width = max(to.width, 1)
        to.height = max(to.height, 1)
        
        // 计算出最小的.
        let scale = min(min(bounds.width, to.width) / to.width, min(bounds.height, to.height) / to.height)
        let fit = CGRect(x: 0, y: 0, width: scale * to.width, height: scale * to.height)
        
        _scrollView.zoomScale = 1
        _scrollView.minimumZoomScale = 1
        _scrollView.maximumZoomScale = max(max(to.width / fit.width, to.height / fit.height), 2)
        
        SIMLog.trace("from: \(from), to: \(to), scale: \(_scrollView.maximumZoomScale)")
        
        _imageView.bounds = fit
        _imageView.center = CGPoint(
            x: max(fit.width, _scrollView.bounds.width) / 2,
            y: max(fit.height, _scrollView.bounds.height) / 2)
    }
    
    /// 单击退出
    private dynamic func _tap(_ sender: UIGestureRecognizer) {
        SIMLog.trace()
        if sender.state == .ended {
            viewController()?.dismiss(animated: true, completion: nil)
//            if let view = delegate as? SIMChatPhotoBrowseView {
//                delegate?.browseViewDidClick?(view)
//            }
        }
    }
    /// 旋转
    private dynamic func _rotation(_ recognizer: UIRotationGestureRecognizer) {
        SIMLog.debug("\(recognizer.rotation) => \(recognizer.velocity)")
        
        _scrollView.panGestureRecognizer.isEnabled = false
        
        let t = CGAffineTransform(scaleX: _scrollView.zoomScale, y: _scrollView.zoomScale)
        _imageView.transform = t.rotated(by: recognizer.rotation)
    }
    /// 双击
    private dynamic func _doubleTap(_ sender: AnyObject) {
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: UIScrollViewDelegate
    
    /// yp
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return _imageView
    }
    /// xp
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let size = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        _imageView.center = CGPoint(
            x: contentSize.width / 2 + max((size.width - contentSize.width) / 2, 0),
            y: contentSize.height / 2 + max((size.height - contentSize.height) / 2, 0))
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
        
        _imageView.center = CGPoint(x: width / 2, y: height / 2)
    }
    
    var media: SIMChatMediaProtocol? {
        didSet {
            guard let media = media , media !== oldValue else {
                return
            }
            
            // 重置大小
            _isLoadOrigin = false
            _resetFrame()
            _resetZoomScale()
            
            // TODO: no imp
//            let fp = SIMChatFileProvider.sharedInstance()
//            
//            // 加载缩略图
//            fp.loadResource(media.thumbnail) { [weak self] in
//                guard let image = $0.value as? UIImage
//                    , media === self?.media
//                        && !(self?._isLoadOrigin ?? false) else {
//                            return
//                }
//                self?._imageView.image = image
//            }
//            // 加载原图
//            fp.loadResource(media.origin, canCache: false) { [weak self] in
//                guard let image = $0.value as? UIImage
//                    , media === self?.media else {
//                        return
//                }
//                self?._isLoadOrigin = true
//                self?._imageView.image = image
//            }
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(type(of: self)._tap(_:)))
        tap.require(toFail: self._doubleTapGestureRecognizer)
        return tap
    }()
    private lazy var _doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(type(of: self)._doubleTap(_:)))
        tap.numberOfTapsRequired = 2
        return tap
    }()
    private lazy var _rotationGestureRecognizer: UIRotationGestureRecognizer = {
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(type(of: self)._rotation(_:)))
        rotation.delegate = self
        return rotation
    }()
}
