//
//  BrowserCollectionController.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserAlbumController: UICollectionViewController {
    
    init(source: Source, library: Library) {
        _source = source
        _library = library.ub_cache
        
        super.init(collectionViewLayout: BrowserAlbumLayout())
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        // clear all cache request when destroyed
        _resetCachedAssets()
    }
    
    func reloadData(with auth: AuthorizationStatus) {
        
        // check for authorization status
        guard auth == .authorized else {
            // no permission
            _showError(with: "No Access Permissions", subtitle: "") // 此应用程序没有权限访问您的照片\n在\"设置-隐私-图片\"中开启后即可查看
            return
        }
        let count = (0 ..< _source.numberOfSections).reduce(0) {
            $0 + _source.numberOfItems(inSection: $1)
        }
        // check for assets count
        guard count != 0 else {
            // no data
            _showError(with: "No Photos or Videos", subtitle: "")
            return
        }
        // clear error info & display asset
        _authorized = true
        _clearError()
        _resetCachedAssets()
    }
    
    override func loadView() {
        super.loadView()
        // setup controller
        title = "Collection"
        
        // setup colleciton view
        collectionView?.register(BrowserAlbumCell.dynamic(with: UIImageView.self), forCellWithReuseIdentifier: "ASSET-IMAGE")
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // update with authorization status
        _authorized = false
        _library.ub_requestAuthorization { status in
            DispatchQueue.main.async {
                self.reloadData(with: status)
            }
        }
        
        // config
        title = _source.title
        
        navigationController?.isToolbarHidden = false
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // if the info view is show, update the layout
        if let infoView = _infoView {
            infoView.frame = view.bounds
        }
    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        // update the cache
//        _updateCachedAssets()
//    }
    
    fileprivate let _source: Source
    fileprivate let _library: Library
    
    fileprivate var _authorized: Bool = false
    fileprivate var _previousPreheatRect: CGRect = .zero
    
    fileprivate var _infoView: ErrorInfoView?
}

///
/// Provide collection view display support
///
extension BrowserAlbumController: UICollectionViewDelegateFlowLayout {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // without authorization, shows blank
        guard _authorized else {
            return 0
        }
        return _source.numberOfSections
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // without authorization, shows blank
        guard _authorized else {
            return 0
        }
        return _source.numberOfItems(inSection: section)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ASSET-IMAGE", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        return layout.itemSize
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // try fetch cell
        // try fetch asset
        guard let asset = _source.asset(at: indexPath), let cell = cell as? BrowserAlbumCell else {
            return
        }
        cell.willDisplay(with: asset, in: _library, orientation: .up)
    }
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // try fetch cell
        // try fetch asset
        guard let asset = _source.asset(at: indexPath), let cell = cell as? BrowserAlbumCell else {
            return
        }
        cell.endDisplay(with: asset, in: _library)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        logger.trace?.write(indexPath)
        
        // try fetch cell
        // try fetch asset
        guard let asset = _source.asset(at: indexPath), let cell = collectionView.cellForItem(at: indexPath) as? BrowserAlbumCell else {
            return
        }
        // cache contents
        (_library as? CacheLibrary)?.fastCache(for: asset, contents: cell.contents)
        
        logger.debug?.write("show detail with: \(indexPath)")
        
        // make
        let controller = BrowserDetailController(source: _source, library: _library, at: indexPath)
        controller.animator = Animator(source: self, destination: controller)
        show(controller, sender: indexPath)
    }
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        // update the cache
//        _updateCachedAssets()
//    }
}

///
/// Provide animatable transitioning support
///
extension BrowserAlbumController: TransitioningDataSource {
    
    func ub_transitionView(using animator: Animator, for operation: Animator.Operation) -> TransitioningView? {
        logger.trace?.write()
        
        guard let indexPath = animator.indexPath else {
            return nil
        }
        // get at current index path the cell
        return collectionView?.cellForItem(at: indexPath) as? BrowserAlbumCell
    }
    
    func ub_transitionShouldStart(using animator: Animator, for operation: Animator.Operation) -> Bool {
        logger.trace?.write()
        return true
    }
    func ub_transitionShouldStartInteractive(using animator: Animator, for operation: Animator.Operation) -> Bool {
        logger.trace?.write()
        return false
    }
    
    func ub_transitionDidPrepare(using animator: Animator, context: TransitioningContext) {
        logger.trace?.write()
        
        // must be attached to the collection view
        guard let collectionView = collectionView, let indexPath = animator.indexPath  else {
            return
        }
        // check the index path is displaying
        if !collectionView.indexPathsForVisibleItems.contains(indexPath) {
            // no, scroll to the cell at index path
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            // must call the layoutIfNeeded method, otherwise cell may not create
            collectionView.layoutIfNeeded()
        }
        // fetch cell at index path, if is displayed
        guard let cell = collectionView.cellForItem(at: indexPath) as? BrowserAlbumCell else {
            return
        }
        // if it is to, reset cell boundary
        if context.ub_operation == .pop || context.ub_operation == .dismiss {
            let edg = collectionView.contentInset
            let frame = cell.convert(cell.bounds, to: view)
            let height = view.frame.height - topLayoutGuide.length - bottomLayoutGuide.length
            
            let y1 = -edg.top + frame.minY
            let y2 = -edg.top + frame.maxY
            
            // reset content offset if needed
            if y2 > height {
                // bottom over boundary, reset to y2(bottom)
                collectionView.contentOffset.y += y2 - height
            } else if y1 < 0 {
                // top over boundary, rest to y1(top)
                collectionView.contentOffset.y += y1
            }
        }
        cell.isHidden = true
    }
    func ub_transitionWillEnd(using animator: Animator, context: TransitioningContext, transitionCompleted: Bool) {
        logger.trace?.write(transitionCompleted)
        // if the disappear operation and indexPath is exists
        guard let indexPath = animator.indexPath, context.ub_operation.disappear else {
            return
        }
        // fetch cell at index path, if is displayed
        guard let cell = collectionView?.cellForItem(at: indexPath) as? BrowserAlbumCell else {
            return
        }
        guard let snapshotView = context.ub_snapshotView, let newSnapshotView = snapshotView.snapshotView(afterScreenUpdates: false) else {
            return
        }
        newSnapshotView.transform = snapshotView.transform
        newSnapshotView.bounds = .init(origin: .zero, size: snapshotView.bounds.size)
        newSnapshotView.center = .init(x: snapshotView.bounds.midX, y: snapshotView.bounds.midY)
        cell.addSubview(newSnapshotView)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            newSnapshotView.alpha = 0
        }, completion: { finished in
            newSnapshotView.removeFromSuperview()
        })
    }
    func ub_transitionDidEnd(using animator: Animator, transitionCompleted: Bool) {
        logger.trace?.write(transitionCompleted)
        // fetch cell at index path, if index path is nil ignore
        guard let indexPath = animator.indexPath, let cell = collectionView?.cellForItem(at: indexPath) as? BrowserAlbumCell else {
            return
        }
        cell.isHidden = false
    }
}

/// library asset cache support
internal extension BrowserAlbumController {
    
    fileprivate func _resetCachedAssets() {
//        // clean all cache
//        _library.ub_stopCachingImagesForAllAssets()
//        _previousPreheatRect = .zero
    }

    fileprivate func _updateCachedAssets() {
//        // Update only if the view is visible.
//        guard let collectionView = collectionView, isViewLoaded && view.window != nil, _authorized else {
//            return
//        }
//        // The preheat window is twice the height of the visible rect.
//        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
//        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
//
//        // Update only if the visible area is significantly different from the last preheated area.
//        let delta = abs(preheatRect.midY - _previousPreheatRect.midY)
//        guard delta > view.bounds.height / 3 else {
//            return
//        }
//        logger.debug?.write("\(_previousPreheatRect) => \(preheatRect)")
//        // Compute the assets to start caching and to stop caching.
//        let (addedRects, removedRects) = _differencesBetweenRects(_previousPreheatRect, preheatRect)
//        let addedAssets = addedRects
//            .flatMap { _indexPathsForElements(in: $0) }
//            .flatMap { _source.asset(at: $0) }
//        let removedAssets = removedRects
//            .flatMap { _indexPathsForElements(in: $0) }
//            .flatMap { _source.asset(at: $0) }
//
//        // Update the assets the PHCachingImageManager is caching.
//        DispatchQueue.main.async { [weak _library] in
//            _library?.ub_stopCachingImages(for: removedAssets, targetSize: BrowserAlbumLayout.thumbnailItemSize, contentMode: .aspectFill, options: nil)
//            _library?.ub_startCachingImages(for: addedAssets, targetSize: BrowserAlbumLayout.thumbnailItemSize, contentMode: .aspectFill, options: nil)
//        }
//        
//        // Store the preheat rect to compare against in the future.
//        _previousPreheatRect = preheatRect
    }

    fileprivate func _differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                    width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                    width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                      width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                      width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    fileprivate func _indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

/// library error display support
internal extension BrowserAlbumController {
    
    fileprivate func _showError(with title: String, subtitle: String) {
        logger.trace?.write(title, subtitle)
        
        // clear view
        _infoView?.removeFromSuperview()
        _infoView = nil
        
        let infoView = ErrorInfoView(frame: view.bounds)
        
        infoView.title = title
        infoView.subtitle = subtitle
        infoView.backgroundColor = .white
        infoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // show view
        view.addSubview(infoView)
        _infoView = infoView
        
        // disable scroll
        collectionView?.isScrollEnabled = false
        collectionView?.reloadData()
    }
    
    fileprivate func _clearError() {
        logger.trace?.write()
        
        // enable scroll
        collectionView?.isScrollEnabled = true
        collectionView?.reloadData()
        
        // clear view
        _infoView?.removeFromSuperview()
        _infoView = nil
    }
}
