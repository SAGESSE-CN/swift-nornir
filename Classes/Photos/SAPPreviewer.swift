//
//  SAPPreviewer.swift
//  SAC
//
//  Created by SAGESSE on 9/21/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos

internal enum SAPPickerPreviewDirection {
    case normal
    case reverse
}

internal class SAPPreviewer: UIViewController {
    
    var direction: SAPPickerPreviewDirection = .normal
    var allowsMultipleSelection: Bool = true {
        didSet {
            _selectedView.isHidden = !allowsMultipleSelection
        }
    }
    
    weak var picker: SAPPickerInternal?
    weak var selection: SAPSelectionable?
    
    var previewingItem: AnyObject?
    weak var previewingDelegate: SAPPreviewableDelegate?
    
    override var toolbarItems: [UIBarButtonItem]? {
        set { }
        get {
            if let toolbarItems = _toolbarItems {
                return toolbarItems
            }
            let toolbarItems = picker?.makeToolbarItems(for: .preview)
            _toolbarItems = toolbarItems
            return toolbarItems
        }
    }
    
    func scroll(to photo: SAPAsset?, animated: Bool) {
        guard let photo = photo, let index = _photos.index(of: photo) else {
            return
        }
        _logger.trace(index)
        guard isViewLoaded else {
            _currentIndex = index
            return
        }
        _updatePage(at: _currentIndex, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ts: CGFloat = 20
        
//        _toolbar.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 44)
//        _toolbar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
//        _toolbar.items = toolbarItems
        
        _selectedView.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        _selectedView.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        _selectedView.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        _selectedView.setTitleColor(.white, for: .normal)
        _selectedView.isHidden = !allowsMultipleSelection
        _selectedView.setBackgroundImage(UIImage.sap_init(named: "photo_checkbox_normal"), for: .normal)
        _selectedView.setBackgroundImage(UIImage.sap_init(named: "photo_checkbox_normal"), for: .highlighted)
        _selectedView.setBackgroundImage(UIImage.sap_init(named: "photo_checkbox_selected"), for: [.selected, .normal])
        _selectedView.setBackgroundImage(UIImage.sap_init(named: "photo_checkbox_selected"), for: [.selected, .highlighted])
        _selectedView.addTarget(self, action: #selector(selectHandler(_:)), for: .touchUpInside)
        
        _contentViewLayout.scrollDirection = .horizontal
        _contentViewLayout.minimumLineSpacing = ts * 2
        _contentViewLayout.minimumInteritemSpacing = ts * 2
        _contentViewLayout.headerReferenceSize = CGSize(width: ts, height: 0)
        _contentViewLayout.footerReferenceSize = CGSize(width: ts, height: 0)
        
        _contentView.frame = view.bounds.inset(by: UIEdgeInsets(top: 0, left: -ts, bottom: 0, right: -ts))
        _contentView.backgroundColor = .clear
        _contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _contentView.showsVerticalScrollIndicator = false
        _contentView.showsHorizontalScrollIndicator = false
        _contentView.scrollsToTop = false
        _contentView.allowsSelection = false
        _contentView.allowsMultipleSelection = false
        _contentView.isPagingEnabled = true
        _contentView.register(SAPPreviewerCell.self, forCellWithReuseIdentifier: "Unknow")
        _contentView.register(SAPPreviewerCell.self, forCellWithReuseIdentifier: "Image")
        _contentView.register(SAPPreviewerCell.self, forCellWithReuseIdentifier: "Video")
        _contentView.dataSource = self
        _contentView.delegate = self
        //_contentView.isDirectionalLockEnabled = true
        //_contentView.isScrollEnabled = false
        
        view.backgroundColor = .white
        //view.backgroundColor = .black
        view.addSubview(_contentView)
//        view.addSubview(_toolbar)
        
        _updatePage(at: _currentIndex, animated: false)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if _cacheBounds?.width != view.bounds.width {
            _cacheBounds = view.bounds
            
            if let idx = _contentViewLayout.lastIndexPath {
                // 恢复contentOffset
                _restorePage(at: idx.item, animated: false)
                _contentViewLayout.lastIndexPath = nil
            }
            
//            // 更新toolbar
//            var nframe = navigationController?.toolbar.frame ?? .zero
//            nframe.origin.x = 0
//            nframe.origin.y = view.bounds.height
//            
//            _toolbar.transform = .identity
//            _toolbar.frame = nframe
//            _updateToolbar(_isFullscreen, animated: false)
        }
    }
    
    @objc private func selectHandler(_ sender: Any) {
        let photo = _photos[_currentIndex]
        
        if _selectedView.isSelected {
            guard selection?.selection(self, shouldDeselectItemFor: photo) ?? true else {
                return
            }
            selection?.selection(self, didDeselectItemFor: photo)
        } else {
            guard selection?.selection(self, shouldSelectItemFor: photo) ?? true else {
                return
            }
            selection?.selection(self, didSelectItemFor: photo)
        }
        //_updateSelection(at: _currentIndex, animated: true)
        
        selection?.selection(self, willEditing: sender)
        selection?.selection(self, didEditing: sender)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _logger.trace()
        
        navigationController?.isNavigationBarHidden = false
        
        _updateToolbar(false, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override var prefersStatusBarHidden: Bool {
        if _isFullscreen {
            return true
        }
        return super.prefersStatusBarHidden
    }

    fileprivate func _updateIndex(at index: Int) {
        _logger.trace(index)
        
        let count = _photos.count
        var nindex = index
        if !_ascending {
            nindex = count - index - 1
        }
        title = "\(nindex + 1) / \(count)"
        
        _currentIndex = index
        
        if index < _photos.count {
            previewingItem = _photos[index]
        } else {
            previewingItem = nil
        }
    }
    
    
    fileprivate func _restorePage(at index: Int, animated: Bool) {
        _logger.trace(index)
        
        _updatePage(at: index, animated: animated)
    }
    fileprivate func _updatePage(at index: Int, animated: Bool) {
        _logger.trace(index)
 
        let x = _contentView.frame.width * CGFloat(index)
        
        _updateIndex(at: index)
        _updateSelection(at: index, animated: animated)
        
        _contentView.setContentOffset(CGPoint(x: x, y: 0), animated: animated)
    }
    
    fileprivate func _updateSelection(at index: Int, animated: Bool) {
        guard index < _photos.count else {
            return
        }
        _logger.trace(index)
        
        let photo = _photos[index]
        if let index = selection?.selection(self, indexOfSelectedItemsFor: photo), index != NSNotFound {
            
            _selectedView.isSelected = true
            _selectedView.setTitle("\(index + 1)", for: .selected)
            
        } else {
            
            _selectedView.isSelected = false
        }
        
        // 选中时, 加点特效
        if animated {
            let a = CAKeyframeAnimation(keyPath: "transform.scale")
            
            a.values = [0.8, 1.2, 1]
            a.duration = 0.25
            a.calculationMode = CAAnimationCalculationMode.cubic
            
            _selectedView.layer.add(a, forKey: "v")
        }
    }
    fileprivate func _updateToolbar(_ newValue: Bool, animated: Bool) {
        
        let isHidden = newValue || toolbarItems?.isEmpty ?? true
        navigationController?.setToolbarHidden(isHidden, animated: animated)

    }
    fileprivate func _updateIsFullscreen(_ newValue: Bool, animated: Bool) {
        guard newValue != _isFullscreen else {
            return // no change
        }
        _logger.trace()
        
        navigationController?.navigationBar.isUserInteractionEnabled = !newValue
        navigationController?.toolbar.isUserInteractionEnabled = !newValue
        
        navigationController?.setNavigationBarHidden(newValue, animated: true)
        
        _updateToolbar(newValue, animated: animated)
        
        _isFullscreen = newValue
        
        UIView.animate(withDuration: 0.2) {
            if newValue {
                self.view.backgroundColor = .black
            } else {
                self.view.backgroundColor = .white
            }
        }
        
        DispatchQueue.main.async {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    
    init(picker: SAPPickerInternal, options: SAPPickerOptions) {
        super.init(nibName: nil, bundle: nil)
        logger.trace()
        
        _album = options.album
        _photos = options.photos ?? {
            if let album = options.album, let newResult = album.fetchResult {
                return album.photos(with: newResult)
            }
            return []
        }()
        _photosResult = options.album?.fetchResult
        _ascending = options.ascending
        
        self.picker = picker
        self.previewingItem = options.default
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: _selectedView)
        self.automaticallyAdjustsScrollViewInsets = false
        
        // 反转显示
        if !_ascending {
            _photos.reverse()
        }
        // 显示默认的.
        self.scroll(to: options.default, animated: false)
        
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
    
    private var _cacheBounds: CGRect?
    
    private var _toolbarItems: [UIBarButtonItem]??
    
    fileprivate var _isFullscreen: Bool = false
    
    fileprivate lazy var _contentViewLayout: SAPPreviewerLayout = SAPPreviewerLayout()
    fileprivate lazy var _contentView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self._contentViewLayout)
    
    fileprivate lazy var _toolbar: SAPToolbar = SAPToolbar()
    fileprivate lazy var _selectedView: UIButton = UIButton()
    
    fileprivate var _album: SAPAlbum?
    fileprivate var _currentIndex: Int = 0
    
    fileprivate var _photos: Array<SAPAsset> = []
    fileprivate var _photosResult: PHFetchResult<PHAsset>?
    
    fileprivate var _ascending: Bool = true
    
    fileprivate var _allPhotoInfos: [Int: UIImage.Orientation] = [:]
}

// MARK: - Events

extension SAPPreviewer {
    
    @objc func didSelectItem(_ sender: Notification) {
        guard let photo = sender.object as? SAPAsset else {
            return
        }
        // 检查是不是正在显示的
        guard _currentIndex < _photos.count, _photos[_currentIndex] == photo else {
            return
        }
        _logger.trace()
        _updateSelection(at: _currentIndex, animated: true)
    }
    @objc func didDeselectItem(_ sender: Notification) {
        guard let photo = sender.object as? SAPAsset else {
            return
        }
        // 检查是不是正在显示的
        guard _currentIndex < _photos.count, _photos[_currentIndex] == photo else {
            return
        }
        _logger.trace()
        _updateSelection(at: _currentIndex, animated: true)
    }
}

extension SAPPreviewer: SAPPreviewableDelegate {
    
    func fromPreviewable(with item: AnyObject) -> SAPPreviewable? {
        _logger.trace()
        
        guard let photo = item as? SAPAsset else {
            return nil
        }
        guard let index = _photos.index(of: photo) else {
            return nil
        }
        guard let cell = _contentView.cellForItem(at: IndexPath(item: index, section: 0)) else {
            return nil
        }
        return cell as? SAPPreviewerCell
    }
    
    func toPreviewable(with item: AnyObject) -> SAPPreviewable? {
        _logger.trace()
        
        guard let photo = item as? SAPAsset else {
            return nil
        }
        guard let _ = _photos.index(of: photo) else {
            return nil
        }
        // 第一次肯定是没有加载的, 所以生成一个SAPBrowserViewFastPreviewing
        return SAPBrowserViewFastPreviewing(photo: photo, view: view)
    }
    
    func previewable(_ previewable: SAPPreviewable, willShowItem item: AnyObject) {
        _logger.trace()
        view.isHidden = true
    }
    func previewable(_ previewable: SAPPreviewable, didShowItem item: AnyObject) {
        _logger.trace()
        view.isHidden = false
    }
}


// MARK: - SAPBrowserViewDelegate

extension SAPPreviewer: SAPPreviewerCellDelegate {
    
    func previewerCell(_ previewerCell: SAPPreviewerCell, didTap photo: SAPAsset) {
        _logger.trace()
        
        _updateIsFullscreen(!_isFullscreen, animated: true)
    }
    func previewerCell(_ previewerCell: SAPPreviewerCell, didDoubleTap photo: SAPAsset) {
        _logger.trace()
        
        // 双击的时候进入全屏
        _updateIsFullscreen(true, animated: true)
    }
    
    func previewerCell(_ previewerCell: SAPPreviewerCell, shouldRotation photo: SAPAsset) -> Bool {
        _logger.trace()
        
        _contentView.isScrollEnabled = false
        return true
    }
    
    func previewerCell(_ previewerCell: SAPPreviewerCell, didRotation photo: SAPAsset, orientation: UIImage.Orientation) {
        _logger.trace()
        
        _contentView.isScrollEnabled = true
        _allPhotoInfos[photo.hash] = orientation
    }
}

extension SAPPreviewer: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        if _currentIndex != index {
            _currentIndex = index
            _updateIndex(at: index)
            _updateSelection(at: index, animated: false)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _photos.count
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch _photos[indexPath.item].mediaType {
        case .image:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "Image", for: indexPath)
            
        case .video:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "Video", for: indexPath)
            
        default:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "Unknow", for: indexPath)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SAPPreviewerCell else {
            return
        }
        let photo = _photos[indexPath.item]
        
        cell.delegate = self
        cell.orientation = _allPhotoInfos[photo.hash] ?? .up
        cell.photo = photo
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.frame.size
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension SAPPreviewer: PHPhotoLibraryChangeObserver {
    
    private func _updateContentView(_ newResult: PHFetchResult<PHAsset>, _ inserts: [IndexPath], _ changes: [IndexPath], _ removes: [IndexPath]) {
        _logger.trace("inserts: \(inserts), changes: \(changes), removes: \(removes)")
        
        
        let oldPhotos = _photos
        var newPhotos = _album?.photos(with: newResult) ?? []
        
        // 反转
        if !_ascending {
            newPhotos.reverse()
        }
        let remainingIndex: Int = {
            var index = _currentIndex
            guard index < oldPhotos.count else {
                return 0
            }
            let step = _ascending ? 1 : -1
            
            while index >= 0 && index < oldPhotos.count {
                if let nidx = newPhotos.index(of: oldPhotos[index]) {
                    return nidx
                }
                index += step
            }
            if index < 0 {
                return 0
            }
            return newPhotos.count - 1
        }()
        
        // 更新数据
        _photos = newPhotos
        _photosResult = newResult
        
        // 更新视图
        if !(inserts.isEmpty && changes.isEmpty && removes.isEmpty) {
            _contentView.performBatchUpdates({ [_contentView] in
                
                _contentView.reloadItems(at: changes)
                _contentView.deleteItems(at: removes)
                _contentView.insertItems(at: inserts)
                
            }, completion: nil)
        }
        
        _updatePage(at: max(min(remainingIndex, newPhotos.count - 1), 0), animated: false)
    }
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        // 检查有没有变更
        guard let result = _photosResult, let change = changeInstance.changeDetails(for: result), change.hasIncrementalChanges else {
            // 如果asset没有变更, 检查album是否存在
            if let album = _album, !SAPAlbum.albums.contains(album) {
                _contentView.reloadData()
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
        
        _photosResult = change.fetchResultAfterChanges
        _updateContentView(change.fetchResultAfterChanges, inserts, /*changes*/[], removes)
    }
}
