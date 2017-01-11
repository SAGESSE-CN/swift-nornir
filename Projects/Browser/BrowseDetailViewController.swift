//
//  BrowseDetailViewController.swift
//  Browser
//
//  Created by sagesse on 11/14/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class BrowseDetailViewController: UIViewController, IBControllerContextTransitioning {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _commonInit()
    }
    
    weak var delegate: BrowseDelegate? {
        willSet {
//            indicatorView.delegate = delegate
        }
    }
    weak var dataSource: BrowseDataSource? {
        willSet {
            indicatorView.dataSource = newValue
        }
    }
    
    lazy var extraContentInset = UIEdgeInsetsMake(0, -20, 0, -20)
    lazy var interactiveDismissGestureRecognizer = UIPanGestureRecognizer()
    
    lazy var indicatorView: IBIndicatorView = IBIndicatorView()
    
    lazy var collectionViewLayout: BrowseDetailViewLayout = BrowseDetailViewLayout()
    lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
    
    var browseIndexPath: IndexPath? { 
        return collectionView.indexPathsForVisibleItems.last
    }
    var browseInteractiveDismissGestureRecognizer: UIGestureRecognizer? {
        return interactiveDismissGestureRecognizer
    }
    
    func browseContentSize(at indexPath: IndexPath) -> CGSize {
        return dataSource?.browser(self, assetForItemAt: indexPath).browseContentSize ?? .zero
    }
    func browseContentMode(at indexPath: IndexPath) -> UIViewContentMode {
        return .scaleAspectFill
    }
    func browseContentOrientation(at indexPath: IndexPath) -> UIImageOrientation {
        guard let cell = collectionView.cellForItem(at: indexPath) as? BrowseDetailViewCell else {
            return .up
        }
        return cell.orientation
    }
    
    func browseTransitioningView(at indexPath: IndexPath, forKey key: UITransitionContextViewKey) -> UIView? {
        if let cell = collectionView.cellForItem(at: indexPath) as? BrowseDetailViewCell {
            return cell.detailView
        }
        _performWithoutContentOffsetChange {
            _currentIndexPath = indexPath
            // update indicator
            indicatorView.indexPath = indexPath
            indicatorView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 40)
            indicatorView.layoutIfNeeded()
            // update content
            collectionView.frame = UIEdgeInsetsInsetRect(view.bounds, extraContentInset)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            collectionView.layoutIfNeeded()
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? BrowseDetailViewCell {
            return cell.detailView
        }
        return nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Detail"
        
        view.backgroundColor = .white
        view.addSubview(collectionView)
        
        view.addGestureRecognizer(interactiveDismissGestureRecognizer)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        _updateVisableCellContentInsetIfNeeded()
        
        let nframe = UIEdgeInsetsInsetRect(view.bounds, extraContentInset)
        guard collectionView.frame != nframe else {
            return
        }
        _performWithoutContentOffsetChange {
            let cell = collectionView.visibleCells.first
            let indexPath = collectionView.indexPathsForVisibleItems.first
            collectionView.frame = nframe
            if let indexPath = indexPath, let cell = cell {
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                collectionView.layoutIfNeeded()
                collectionView.bringSubview(toFront: cell)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.pop_delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.pop_delegate = nil
    }
    
    func dismissHandler(_ sender: UIPanGestureRecognizer) {
        
        if !_isInteractiving {
            let velocity = sender.velocity(in: view)
            guard velocity.y > 0 && fabs(velocity.x / velocity.y) < 1.5 else {
                return
            }
            guard let cell = collectionView.visibleCells.last as? BrowseDetailViewCell else {
                return 
            }
            // 检查这个是否己经触发了bounces
            let mh = interactiveDismissGestureRecognizer.location(in: view).y
            let point = interactiveDismissGestureRecognizer.location(in: cell.detailView.superview)
            
            guard point.y - mh < 0 || cell.detailView.frame.height <= view.frame.height else {
                return
            }
            let offset = cell.containterView.contentOffset
            let frame = cell.detailView.frame
            let size = cell.containterView.frame.size
            let x = min(max(offset.x, frame.minX), max(frame.width, size.width) - size.width)
            let y = min(max(offset.y, frame.minY), max(frame.height, size.height) - size.height)
            
            _isInteractiving = true
            _lastContentOffset = CGPoint(x: x, y: y)
            
            DispatchQueue.main.async {
                cell.containterView.setContentOffset(self._lastContentOffset, animated: false)
                
                guard let nav = self.navigationController else {
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                nav.popViewController(animated: true)
            }
        } else {
            guard sender.state != .changed else {
                // change
                return
            }
            // 关闭
            _isInteractiving = false
            
            guard let cell = collectionView.visibleCells.last as? BrowseDetailViewCell else {
                return 
            }
            DispatchQueue.main.async {
                cell.containterView.setContentOffset(self._lastContentOffset, animated: false)
            }
        }
    }
    
    func _performWithoutContentOffsetChange(_ actionsWithoutAnimation: () -> Void) {
        _ignoreContentOffsetChange = true
        actionsWithoutAnimation()
        _ignoreContentOffsetChange = false
    }
    
    fileprivate var _isInteractiving: Bool = false
    fileprivate var _lastContentOffset: CGPoint = .zero
    
    fileprivate var _ignoreContentOffsetChange: Bool = false
    
    fileprivate var _currentItem: UICollectionViewLayoutAttributes?
    fileprivate var _currentIndexPath: IndexPath?
    
    fileprivate var _currentContentInset: UIEdgeInsets = .zero
    
    // 插入删除的时候必须清除
    fileprivate var _interactivingFromIndex: Int?
    fileprivate var _interactivingFromIndexPath: IndexPath?
    fileprivate var _interactivingToIndex: Int?
    fileprivate var _interactivingToIndexPath: IndexPath?
    
    fileprivate func _commonInit() {
      
        //UIActivityIndicatorView
        
       
        automaticallyAdjustsScrollViewInsets = false
        
        indicatorView.delegate = self
        
        interactiveDismissGestureRecognizer.delegate = self
        interactiveDismissGestureRecognizer.maximumNumberOfTouches = 1
        interactiveDismissGestureRecognizer.addTarget(self, action: #selector(dismissHandler(_:)))
        
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = -extraContentInset.left * 2
        collectionViewLayout.minimumInteritemSpacing = -extraContentInset.right * 2
        collectionViewLayout.headerReferenceSize = CGSize(width: -extraContentInset.left, height: 0)
        collectionViewLayout.footerReferenceSize = CGSize(width: -extraContentInset.right, height: 0)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.scrollsToTop = false
        collectionView.allowsSelection = false
        collectionView.allowsMultipleSelection = false
        collectionView.addGestureRecognizer(interactiveDismissGestureRecognizer)
        
        collectionView.register(BrowseDetailViewCell.self, forCellWithReuseIdentifier: "Asset")
//        collectionView.register(SAPPreviewerCell.self, forCellWithReuseIdentifier: "Image")
//        collectionView.register(SAPPreviewerCell.self, forCellWithReuseIdentifier: "Video")
        
        toolbarItems = [
            IBExtendedItem(height: 40, view: indicatorView),
            
            UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil)
        ]
    //public convenience init(title: String?, style: UIBarButtonItemStyle, target: Any?, action: Selector?)
    }
}

extension BrowseDetailViewController: BrowseDetailViewDelegate, UINavigationBarDelegate {
    
    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        // 正在旋转的时候不允许返回
        guard collectionView.isScrollEnabled else {
            return false
        }
        
        return true
    }
    
    func browseDetailView(_ browseDetailView: Any, _ containterView: IBContainterView, shouldBeginRotationing view: UIView?) -> Bool {
        collectionView.isScrollEnabled = false
        return true
    }
    func browseDetailView(_ browseDetailView: Any, _ containterView: IBContainterView, didEndRotationing view: UIView?, atOrientation orientation: UIImageOrientation) {
        collectionView.isScrollEnabled = true
    }
}

extension BrowseDetailViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if  interactiveDismissGestureRecognizer == gestureRecognizer  {
            let velocity = interactiveDismissGestureRecognizer.velocity(in: collectionView)
            // 检测手势的方向 => 上下
            guard fabs(velocity.x / velocity.y) < 1.5 else {
                return false
            }
            guard let cell = collectionView.visibleCells.last as? BrowseDetailViewCell else {
                return false
            }
            // 检查这个手势事件能不能超触发bounces
            let point = interactiveDismissGestureRecognizer.location(in: cell.detailView.superview)
            guard (point.y - view.frame.height) <= 0 else {
                return false
            }
            return true
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if interactiveDismissGestureRecognizer == gestureRecognizer  {
            // 如果己经开始交互, 那就是是独占模式
            guard !_isInteractiving else {
                return false
            }
            guard let panGestureRecognizer = otherGestureRecognizer as? UIPanGestureRecognizer else {
                return true
            }
            guard let view = panGestureRecognizer.view, view.superview is IBContainterView else {
                return false
            }
            return true
        }
        return false
    }
}

extension BrowseDetailViewController: IBIndicatorViewDelegate {
    
    func indicatorWillBeginDragging(_ indicator: IBIndicatorView) {
        logger.trace()
        
//        collectionView.isScrollEnabled = false
//        interactiveDismissGestureRecognizer.isEnabled = false
    }
    func indicatorDidEndDragging(_ indicator: IBIndicatorView) {
        logger.trace()
        
//        collectionView.isScrollEnabled = true
//        interactiveDismissGestureRecognizer.isEnabled = true
    }
    
    func indicator(_ indicator: IBIndicatorView, didSelectItemAt indexPath: IndexPath) {
//        _logger.debug(indexPath)
//        guard !_isInteractiving else {
//            return // 正在交互
//        }
        UIView.performWithoutAnimation {
            _performWithoutContentOffsetChange {
                // 可能会产生动画 
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            }
        }
    }
}

extension BrowseDetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    fileprivate func _updateCurrentItem(_ offset: CGPoint) {
        // 检查是否存在变更
        let x = offset.x + collectionView.bounds.width / 2
        if let item = _currentItem, item.frame.minX <= x && x < item.frame.maxX {
            return // hit cache
        }
        guard let indexPath = collectionView.indexPathForItem(at: CGPoint(x: x, y: 0)) else {
            return // not found, use old
        }
        //let oldValue = _currentItem
        let newValue = collectionView.layoutAttributesForItem(at: indexPath)
        // up
        _currentItem = newValue
        _currentIndexPath = newValue?.indexPath
    }
    fileprivate func _updateCurrentIndexForIndicator(_ offset: CGPoint) {
        let value = offset.x / collectionView.bounds.width
        let percent = modf(value + 1).1
        
        let fromIndex = Int(floor(value))
        var fromIndexPath = _interactivingFromIndexPath
        
        let toIndex = Int(ceil(value))
        var toIndexPath = _interactivingToIndexPath
        
        if _interactivingFromIndex != fromIndex {
            fromIndexPath = collectionView.indexPathForItem(at: CGPoint(x: (CGFloat(fromIndex) + 0.5) * collectionView.bounds.width , y: 0))
            _interactivingToIndex = fromIndex
            _interactivingToIndexPath = fromIndexPath
        }
        if _interactivingToIndex != toIndex {
            toIndexPath = collectionView.indexPathForItem(at: CGPoint(x: (CGFloat(toIndex) + 0.5) * collectionView.bounds.width , y: 0))
            _interactivingToIndex = toIndex
            _interactivingToIndexPath = toIndexPath
        }
        // 使用百分比更新index
        indicatorView.updateIndexPath(from: fromIndexPath, to: toIndexPath, percent: percent)
    }
    fileprivate func _updateVisableCellContentInsetIfNeeded() {
        let top = topLayoutGuide.length
        let bottom = (navigationController?.toolbar?.sizeThatFits(.zero).height ?? 0) + indicatorView.frame.height
        
        guard _currentContentInset.top != top || _currentContentInset.bottom != bottom else {
            return // no change
        }
        _currentContentInset.top = top
        _currentContentInset.bottom = bottom
        
        collectionView.visibleCells.forEach { 
            ($0 as? BrowseDetailViewCell)?.contentInset =  _currentContentInset
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !_ignoreContentOffsetChange else {
            return
        }
        _updateCurrentItem(scrollView.contentOffset)
        _updateCurrentIndexForIndicator(scrollView.contentOffset)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indicatorView.beginInteractiveMovement()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        indicatorView.endInteractiveMovement()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        indicatorView.endInteractiveMovement()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfSections(in: self) ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.browser(self, numberOfItemsInSection: section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Asset", for: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? BrowseDetailViewCell else {
            return
        }
        // 更新属性
        cell.apply(dataSource?.browser(self, assetForItemAt: indexPath))
        
        cell.delegate = self
        cell.contentInset = _currentContentInset
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? BrowseDetailViewCell else {
            return
        }
        // 清除属性
        cell.apply(nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //dismissHandler(indexPath)
    }
}
