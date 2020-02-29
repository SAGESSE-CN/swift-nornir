//
//  SAPPickerAssets.swift
//  SAC
//
//  Created by SAGESSE on 9/21/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos

internal class SAPPickerAssets: UICollectionViewController, UIGestureRecognizerDelegate {
    
    var scrollsToBottomOfLoad: Bool = false
    
    var allowsMultipleSelection: Bool = true
    
    weak var picker: SAPPickerInternal?
    weak var selection: SAPSelectionable?
    
    override var toolbarItems: [UIBarButtonItem]? {
        set { }
        get {
            if let toolbarItems = _toolbarItems {
                return toolbarItems
            }
            let toolbarItems = picker?.makeToolbarItems(for: .list)
            _toolbarItems = toolbarItems
            return toolbarItems
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = navigationController?.navigationItem.rightBarButtonItems
        
        collectionView?.backgroundColor = .white
        collectionView?.allowsSelection = false
        collectionView?.allowsMultipleSelection = false
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        collectionView?.register(SAPPickerAssetsCell.self, forCellWithReuseIdentifier: "Item")
        collectionView?.register(SAPPickerAssetsFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        
        // 添加手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandler(_:)))
        pan.delegate = self
        //pan.isEnabled = picker?.allowsMultipleSelection ?? false
        collectionView?.panGestureRecognizer.require(toFail: pan)
        collectionView?.addGestureRecognizer(pan)
        
        _reloadPhotos()
        
        guard !_photos.isEmpty else {
            return
        }
        collectionView?.scrollToItem(at: IndexPath(item: _photos.count - 1, section: 0), at: .bottom, animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let isHidden = _photos.isEmpty || toolbarItems?.isEmpty ?? true
        navigationController?.isToolbarHidden = isHidden
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        _statusView?.frame = view.convert(CGRect(origin: .zero, size: view.bounds.size), from: view.window)
    }
    
    /// 手势将要开始的时候检查一下是否允许使用
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let velocity = pan.velocity(in: collectionView)
        let point = pan.location(in: collectionView)
        // 检测手势的方向
        // 如果超出阀值视为放弃该手势
        if fabs(velocity.y) > 80 || fabs(velocity.y / velocity.x) > 2.5 {
            return false
        }
        guard let idx = _index(at: point), idx < (collectionView?.numberOfItems(inSection: 0) ?? 0) else {
            return false
        }
        _batchStartIndex = idx
        _batchIsSelectOperator = nil
        _batchOperatorItems.removeAll()
        return true
    }
    
    @objc private func panHandler(_ sender: UIPanGestureRecognizer) {
        guard let start = _batchStartIndex else {
            return
        }
        // step0: 计算选按下的位置所在的index, 这样子就会形成一个区域(start ~ end)
        let end = _index(at: sender.location(in: collectionView)) ?? 0
        let count = collectionView?.numberOfItems(inSection: 0) ?? 0
        
        // step1: 获取区域的第一个有效的元素为操作类型
        let operatorType = _batchIsSelectOperator ?? {
            let nidx = min(max(start, 0), count - 1)
            guard let cell = collectionView?.cellForItem(at: IndexPath(item: nidx, section: 0)) as? SAPPickerAssetsCell else {
                return false
            }
            _batchIsSelectOperator = !cell.photoView.isSelected
            return !cell.photoView.isSelected
        }()
        
        let sl = min(max(start, 0), count - 1)
        let nel = min(max(end, 0), count - 1)
        
        let ts = sl <= nel ? 1 : -1
        let tnsl = min(sl, nel)
        let tnel = max(sl, nel)
        let tosl = min(sl, _batchEndIndex ?? sl)
        let toel = max(sl, _batchEndIndex ?? sl)
        
        // step2: 对区域内的元素正向进行操作, 保存在_batchSelectedItems
        
        (tnsl ... tnel).enumerated().forEach {
            let idx = sl + $0.offset * ts
            guard !_batchOperatorItems.contains(idx) else {
                return // 己经添加
            }
            if _updateSelection(operatorType, at: idx) {
                _batchOperatorItems.insert(idx)
            }
        }
        // step3: 对区域外的元素进行反向操作, 针对在_batchSelectedItems
        (tosl ... toel).forEach { idx in
            if idx >= tnsl && idx <= tnel {
                return
            }
            guard _batchOperatorItems.contains(idx) else {
                return // 并没有添加
            }
            if _updateSelection(!operatorType, at: idx) {
                _batchOperatorItems.remove(idx)
            }
        }
        // step4: 更新结束点
        _batchEndIndex = nel
        
        
        // 如果结束了, 重置
        guard sender.state == .cancelled || sender.state == .ended || sender.state == .failed else {
            return
        }
        _batchIsSelectOperator = nil
        _batchOperatorItems.removeAll()
    }

    
    private func _index(at point: CGPoint) -> Int? {
        let x = point.x
        let y = point.y
        // 超出响应范围
        guard point.y > 10 && _itemSize.width > 0 && _itemSize.height > 0 else {
            return nil
        }
        let column = Int(x / (_itemSize.width + _minimumInteritemSpacing))
        let row = Int(y / (_itemSize.height + _minimumLineSpacing))
        // 超出响应范围
        guard row >= 0 else {
            return nil
        }
        
        return row * _columnCount + column
    }
    
    private func _cachePhotos(_ photos: [SAPAsset]) {
//        // 缓存加速
//        let options = PHImageRequestOptions()
//        let scale = UIScreen.main.scale
//        let size = CGSize(width: 120 * scale, height: 120 * scale)
//        
//        options.deliveryMode = .fastFormat
//        options.resizeMode = .fast
//        
//        SAPLibrary.shared.startCachingImages(for: photos, targetSize: size, contentMode: .aspectFill, options: options)
        //SAPLibrary.shared.stopCachingImages(for: photos, targetSize: size, contentMode: .aspectFill, options: options)
    }
    
    fileprivate func _updateStatus(_ newValue: SAPhotoStatus) {
        //_logger.trace(newValue)
        
        _status = newValue
        
        switch newValue {
        case .notError:
            
            _statusView?.removeFromSuperview()
            _statusView = nil
            collectionView?.isScrollEnabled = true
            
        case .notData:
            let error = _statusView ?? SAPErrorView()
        
            error.title = "没有图片或视频"
            error.subtitle = "拍点照片和朋友们分享吧"
            error.frame = CGRect(origin: .zero, size: view.frame.size)
            
            _statusView = error
            
            view.addSubview(error)
            collectionView?.isScrollEnabled = false
            
        case .notPermission:
            let error = _statusView ?? SAPErrorView()
            
            error.title = "没有权限"
            error.subtitle = "此应用程序没有权限访问您的照片\n在\"设置-隐私-图片\"中开启后即可查看"
            error.frame = CGRect(origin: .zero, size: view.frame.size)
            
            _statusView = error
            view.addSubview(error)
            collectionView?.isScrollEnabled = false
        }
        
        _updateFooter()
    }
    fileprivate func _updateFooter() {
        _logger.trace()
        
        _footer?.isHidden = _photos.isEmpty
        _footer?.title = "共\(_photos.count)张照片"
        
        // toolbar
        let isHidden = _photos.isEmpty || toolbarItems?.isEmpty ?? true
        navigationController?.isToolbarHidden = isHidden
    }
    fileprivate func _updateSelection(_ newValue: Bool, at index: Int) -> Bool {
        let photo = _photos[index]
        
        // step0: 查询选中的状态
        let selected = selection(self, indexOfSelectedItemsFor: photo) != NSNotFound
        // step1: 检查是否和newValue匹配, 如果匹配说明之前就是这个状态了, 更新失败
        guard selected != newValue else {
            return false
        }
        // step2: 更新状态, 如果被拒绝忽略该操作, 并且更新失败
        if newValue {
            guard selection?.selection(self, shouldSelectItemFor: photo) ?? true else {
                return false
            }
            selection?.selection(self, didSelectItemFor: photo)
        } else {
            guard selection?.selection(self, shouldDeselectItemFor: photo) ?? true else {
                return false
            }
            selection?.selection(self, didDeselectItemFor: photo)
        }
        // step4: 如果是正在显示的, 更新UI
        let idx = IndexPath(item: index, section: 0)
        if let cell = collectionView?.cellForItem(at: idx) as? SAPPickerAssetsCell {
            cell.photoView.isSelected = newValue
        }
        // step5: 更新成功
        return true
    }
    
    fileprivate func _updateContentView(_ newResult: PHFetchResult<PHAsset>, _ inserts: [IndexPath], _ changes: [IndexPath], _ removes: [IndexPath]) {
        _logger.trace("inserts: \(inserts), changes: \(changes), removes: \(removes)")
        
        // 更新数据
        _photos = _album?.photos(with: newResult) ?? []
        _photosResult = newResult
        
        // 更新视图
        if !(inserts.isEmpty && changes.isEmpty && removes.isEmpty) {
            collectionView?.performBatchUpdates({ [collectionView] in
                
                collectionView?.reloadItems(at: changes)
                collectionView?.deleteItems(at: removes)
                collectionView?.insertItems(at: inserts)
                
            }, completion: nil)
        }
        
        guard !_photos.isEmpty else {
            _updateStatus(.notData)
            return
        }
        
        _cachePhotos(_photos)
        _updateStatus(.notError)
    }
    
    fileprivate func _reloadPhotos() {
        //_logger.trace()
        
        if let album = _album, let newResult = album.fetchResult {
            _photos = album.photos(with: newResult)
            _photosResult = newResult
        }
        
        // 更新.
        collectionView?.reloadData()
        
        guard !_photos.isEmpty else {
            _updateStatus(.notData)
            return
        }
        
        _updateStatus(.notError)
    }
    fileprivate func _clearPhotos() {
        _logger.trace()
        
        // 清空
        _album = nil
        _reloadPhotos()
    }
    
    init(picker: SAPPickerInternal, album: SAPAlbum) {
        super.init(collectionViewLayout: {
            let layout = SAPPickerAssetsLayout()
            
            layout.itemSize = CGSize(width: 78, height: 78)
            layout.minimumLineSpacing = 2
            layout.minimumInteritemSpacing = 2
            //layout.headerReferenceSize = CGSize(width: 0, height: 10)
            //layout.footerReferenceSize = CGSize.zero
        
            return layout
        }())
        logger.trace()
        
        _album = album
        
        self.title = album.title
        self.picker = picker
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectItem(_:)), name: .SAPSelectionableDidSelectItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDeselectItem(_:)), name: .SAPSelectionableDidDeselectItem, object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not imp")
    }
    deinit {
        logger.trace()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate var _itemSize: CGSize = .zero
    fileprivate var _columnCount: Int = 0
    fileprivate var _minimumLineSpacing: CGFloat = 0
    fileprivate var _minimumInteritemSpacing: CGFloat = 0
    fileprivate var _cacheBounds: CGRect?
    
    private var _batchEndIndex: Int?
    private var _batchStartIndex: Int?
    private var _batchOperatorItems: Set<Int> = []
    private var _batchIsSelectOperator: Bool? { // true选中操作，false取消操作
        willSet {
            guard _batchIsSelectOperator != newValue else {
                return
            }
            if _batchIsSelectOperator == nil {
                _editingTask = UUID().uuidString
            } else if newValue == nil {
                _editingTask = nil
            }
        }
    }

    private var _status: SAPhotoStatus = .notError
    private var _statusView: SAPErrorView?
    
    private var _toolbarItems: [UIBarButtonItem]??
    
    fileprivate weak var _footer: SAPPickerAssetsFooter?
    
    fileprivate var _editingTask: Any? {
        willSet {
            if let newValue = newValue {
                selection?.selection(self, willEditing: newValue)
            }
            if let oldValue = _editingTask {
                selection?.selection(self, didEditing: oldValue)
            }
        }
    }
    
    fileprivate var _album: SAPAlbum?
    
    fileprivate var _photos: [SAPAsset] = []
    fileprivate var _photosResult: PHFetchResult<PHAsset>?
    
}

// MARK: - Events

extension SAPPickerAssets {
    
    @objc func didSelectItem(_ sender: Notification) {
        guard let photo = sender.object as? SAPAsset else {
            return
        }
        logger.trace()
        collectionView?.visibleCells.forEach {
            let cell = $0 as? SAPPickerAssetsCell
            guard cell?.photoView.photo == photo && !(cell?.photoView.isSelected ?? false) else {
                return
            }
            cell?.photoView.updateSelection()
        }
    }
    @objc func didDeselectItem(_ sender: Notification) {
        guard let _ = sender.object as? SAPAsset else {
            return
        }
        logger.trace()
        collectionView?.visibleCells.forEach {
            let cell = $0 as? SAPPickerAssetsCell
            guard cell?.photoView.isSelected ?? false else {
                return
            }
            cell?.photoView.updateSelection()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SAPPickerAssets: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Item", for: indexPath)
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
        if let footer = view as? SAPPickerAssetsFooter {
            _footer = footer
            _updateFooter()
        }
        return view
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SAPPickerAssetsCell else {
            return
        }
        cell.photoView.delegate = self
        cell.photoView.photo = _photos[indexPath.item]
        cell.photoView.allowsSelection = allowsMultipleSelection
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        let rect = collectionView.bounds.inset(by: collectionView.contentInset)
        guard _cacheBounds?.width != rect.width else {
            return _itemSize
        }
        let mis = layout.minimumInteritemSpacing
        let size = layout.itemSize
        
        let column = Int((rect.width + mis) / (size.width + mis))
        let fcolumn = CGFloat(column)
        let width = trunc(((rect.width + mis) / fcolumn) - mis)
        
        _cacheBounds = rect
        _columnCount = column
        _minimumInteritemSpacing = (rect.width - width * fcolumn) / (fcolumn - 1)
        _minimumLineSpacing = _minimumInteritemSpacing
        _itemSize = CGSize(width: width, height: width)
        
        return _itemSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 48)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return _minimumLineSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return _minimumInteritemSpacing
    }
}

extension SAPPickerAssets: SAPPreviewableDelegate {
    
    /// 起点
    func fromPreviewable(with item: AnyObject) -> SAPPreviewable? {
        _logger.trace()
        
        guard let photo = item as? SAPAsset else {
            return nil
        }
        guard let index = _photos.index(of: photo) else {
            return nil
        }
        // 这个一定会存在的, 否则你点击不了
        guard let cell = collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) else {
            return nil
        }
        return (cell as? SAPPickerAssetsCell)?.photoView
    }
    
    /// 终点
    func toPreviewable(with item: AnyObject) -> SAPPreviewable? {
        _logger.trace()
        
        guard let photo = item as? SAPAsset else {
            return nil
        }
        guard let collectionView = collectionView, let index = _photos.index(of: photo) else {
            return nil
        }
        // 只有返回的时候才需要检查
        let indexPath = IndexPath(item: index, section: 0)
        if !collectionView.indexPathsForVisibleItems.contains(indexPath) {
            // 是空的
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            
            var pt = collectionView.contentOffset 
            pt.y += _itemSize.height / 2
            collectionView.contentOffset = pt
            
            // 必须调用layoutIfNeeded, 否则cell并没有创建
            collectionView.layoutIfNeeded()
        }
        // 检查这个indexPath是不是正在显示
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return nil
        }
        let frame = cell.convert(cell.bounds, to: view)
        let height = view.frame.height - topLayoutGuide.length - bottomLayoutGuide.length 
        
        // 重置位置(如果需要的话)
        if frame.minY < 0 {
            // 上部越界
            var pt = collectionView.contentOffset
            pt.y += frame.minY
            collectionView.contentOffset = pt
            
        } else if frame.maxY > height {
            // 下部越界
            var pt = collectionView.contentOffset 
            pt.y += frame.maxY - height
            collectionView.contentOffset = pt
        }
        
        // 己找到
        return (cell as? SAPPickerAssetsCell)?.photoView
    }
    
    func previewable(_ previewable: SAPPreviewable, willShowItem item: AnyObject) {
        _logger.trace()
        guard let view = previewable as? UIView else {
            return
        }
        view.isHidden = true
    }
    func previewable(_ previewable: SAPPreviewable, didShowItem item: AnyObject) {
        _logger.trace()
        guard let view = previewable as? UIView else {
            return
        }
        view.isHidden = false
    }
}

// MARK: - SAPAssetViewDelegate(Forwarding)

extension SAPPickerAssets: SAPSelectionable {
    
    /// gets the index of the selected item, if item does not select to return NSNotFound
    func selection(_ selection: Any, indexOfSelectedItemsFor photo: SAPAsset) -> Int {
        return self.selection?.selection(self, indexOfSelectedItemsFor: photo) ?? NSNotFound
    }
   
    // check whether item can select
    func selection(_ selection: Any, shouldSelectItemFor photo: SAPAsset) -> Bool {
        return self.selection?.selection(self, shouldSelectItemFor: photo) ?? true
    }
    func selection(_ selection: Any, didSelectItemFor photo: SAPAsset) {
        self.selection?.selection(self, didSelectItemFor: photo)
    }
    
    // check whether item can deselect
    func selection(_ selection: Any, shouldDeselectItemFor photo: SAPAsset) -> Bool {
        return self.selection?.selection(self, shouldDeselectItemFor: photo) ?? true
    }
    func selection(_ selection: Any, didDeselectItemFor photo: SAPAsset) {
        self.selection?.selection(self, didDeselectItemFor: photo)
    }
    
    // editing
    func selection(_ selection: Any, willEditing sender: Any) {
        self.selection?.selection(self, willEditing: sender)
    }
    func selection(_ selection: Any, didEditing sender: Any) {
        self.selection?.selection(self, didEditing: sender)
    }
    
    // tap item
    func selection(_ selection: Any, tapItemFor photo: SAPAsset, with sender: Any) {
        self.selection?.selection(self, tapItemFor: photo, with: sender)
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension SAPPickerAssets: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // 检查有没有变更
        guard let result = _photosResult, let change = changeInstance.changeDetails(for: result), change.hasIncrementalChanges else {
            // 如果asset没有变更, 检查album是否存在
            if let album = _album, !SAPAlbum.albums.contains(album) {
                _clearPhotos()
            }
            return
        }
        
        let inserts = change.insertedIndexes?.map { idx -> IndexPath in
            return IndexPath(item: idx, section: 0)
        } ?? []
        let changes = change.changedObjects.flatMap { asset -> IndexPath? in
            if let idx = _photos.index(where: { $0.asset.localIdentifier == asset.localIdentifier }) {
                return IndexPath(item: idx, section: 0)
            }
            return nil
        }
        let removes = change.removedObjects.flatMap { asset -> IndexPath? in
            if let idx = _photos.index(where: { $0.asset.localIdentifier == asset.localIdentifier }) {
                return IndexPath(item: idx, section: 0)
            }
            return nil
        }
        guard !inserts.isEmpty || !removes.isEmpty else {
            return
        }
        
        _album?.clearCache()
        _photosResult = change.fetchResultAfterChanges
        
        _updateContentView(change.fetchResultAfterChanges, inserts, /*changes*/[], removes)
    }
}
