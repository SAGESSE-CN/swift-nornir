//
//  SAPPickerInternal.swift
//  SAC
//
//  Created by SAGESSE on 10/11/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos

internal class SAPPickerInternal: UINavigationController {
    
    dynamic weak var picker: SAPPicker!
    dynamic weak var delegater: SAPPickerDelegate?
    
    dynamic var allowsEditing: Bool {
        set { return (_rootViewController?.allowsEditing = newValue) ?? Void() }
        get { return (_rootViewController?.allowsEditing) ?? false }
    }
    dynamic var allowsMultipleDisplay: Bool {
        set { return (_rootViewController?.allowsMultipleDisplay = newValue) ?? Void() }
        get { return (_rootViewController?.allowsMultipleDisplay) ?? false }
    }
    dynamic var allowsMultipleSelection: Bool {
        set { return (_rootViewController?.allowsMultipleSelection = newValue) ?? Void() }
        get { return (_rootViewController?.allowsMultipleSelection) ?? false }
    }
    
    dynamic var alwaysSelectOriginal: Bool = false {
        didSet {
            originItem.isSelected = alwaysSelectOriginal
            
            _updateBytesLenght()
        }
    }
    
    
    dynamic var selectedPhotos: Array<SAPAsset> {
        set {
            _selectedPhotos = newValue
            _selectedPhotoSets = Set(newValue)
            _updateCount(newValue.count)
        }
        get {
            return _selectedPhotos
        }
    }
    
    dynamic func pick(with album: SAPAlbum, animated: Bool) {
        _logger.trace()
        
        let vc = makePickerForAssets(with: album)
        
        // 显示
        pushViewController(vc, animated: animated)
    }
    dynamic func preview(with options: SAPPickerOptions, animated: Bool) {
        _logger.trace()
        
        let vc = makePreviewer(options)
        
        // 因为设置delegate并实现animationControllerFor方法后,
        // 侧滑返回事件将会无效, 所以在push的时候再设置delegate
        // 然后在返回的时候清除delegate
        delegate = self
        
        // 显示
        pushViewController(vc, animated: animated)
    }
    
    dynamic override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        _updateCount(_selectedPhotos.count)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 通知用户将要显示
        delegater?.picker?(picker, willShow: animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 通知用户显示完成
        self.delegater?.picker?(picker, didShow: animated)
    }
    
    dynamic override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        
        // 通知用户将要解散
        delegater?.picker?(picker, willDismiss: flag)
        
        super.dismiss(animated: flag) { [delegater, picker] in
            completion?()
            // 通知用户己经解散
            delegater?.picker?(picker!, didDismiss: flag)
        }
    }
    
    dynamic init() {
        super.init(navigationBarClass: SAPNavigationBar.self, toolbarClass: SAPToolbar.self)
        logger.trace()
        
        let viewController = makePickerForAlbums()
        
        _rootViewController = viewController
        
        self.title = "Photos"
        self.setValue(self, forKey: "picker") // 强制更新转换(因为as会失败)
        self.setViewControllers([viewController], animated: false)
        
        self.originItem.isSelected = self.alwaysSelectOriginal
        self.navigationItem.rightBarButtonItem = cancelItem
        
        SAPLibrary.shared.register(self)
    }
    dynamic convenience init(pick album: SAPAlbum) {
        self.init()
        self.pick(with: album, animated: false)
        self.allowsMultipleDisplay = false
    }
    dynamic convenience init(preview options: SAPPickerOptions) {
        self.init()
        self.preview(with: options, animated: false)
        self.allowsMultipleDisplay = false
        
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not imp")
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    deinit {
        logger.trace()
        
        //SAPLibrary.shared.clearInvaildCaches()
        SAPLibrary.shared.unregisterChangeObserver(self)
    }
    
    lazy var spaceItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    lazy var cancelItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelHandler(_:)))
    
    lazy var editItem: SAPButtonBarItem = SAPButtonBarItem(title: "编辑", type: .normal, target: self, action: #selector(editHandler(_:)))
    lazy var previewItem: SAPButtonBarItem = SAPButtonBarItem(title: "预览", type: .normal, target: self, action: #selector(previewHandler(_:)))
    lazy var originItem: SAPButtonBarItem = SAPButtonBarItem(title: "原图", type: .original, target: self, action: #selector(originHandler(_:)))
    lazy var sendItem: SAPButtonBarItem = SAPButtonBarItem(title: "发送", type: .send, target: self, action: #selector(confirmHandler(_:)))
    
    fileprivate var _changeTaskId: String?
    
    fileprivate weak var _rootViewController: SAPPickerAlbums?
    
    fileprivate lazy var _selectedPhotos: Array<SAPAsset> = []
    fileprivate lazy var _selectedPhotoSets: Set<SAPAsset> = []
}

// MARK: - Events

fileprivate extension SAPPickerInternal {
    
    dynamic func backHandler(_ sender: Any) {
        // 后退
        dismiss(animated: true, completion: nil)
    }
    @objc dynamic func cancelHandler(_ sender: Any) {
        // 取消
        dismiss(animated: true, completion: nil)
        delegater?.picker?(picker, cancel: _selectedPhotos)
    }
    @objc dynamic func confirmHandler(_ sender: Any) {
        // 确认
        dismiss(animated: true, completion: nil)
        delegater?.picker?(picker, confrim: _selectedPhotos)
    }
    
    
    @objc dynamic func previewHandler(_ sender: Any) {
        // 显示预览
        preview(with: SAPPickerOptions(photos: _selectedPhotos), animated: true)
    }
    @objc dynamic func originHandler(_ sender: Any) {
        // 切换选项
        alwaysSelectOriginal = !alwaysSelectOriginal
    }
    @objc dynamic func editHandler(_ sender: Any) {
        _logger.trace()
    }
    
    
    dynamic func selectItem(_ photo: SAPAsset) {
        _logger.trace()
        
        if !_selectedPhotoSets.contains(photo) {
            _selectedPhotoSets.insert(photo)
            _selectedPhotos.append(photo)
            
            _updateCountForPhoto(photo)
        }
        
        delegater?.picker?(picker, didSelectItemFor: photo)
    }
    dynamic func deselectItem(_ photo: SAPAsset) {
        _logger.trace()
        
        if let index = _selectedPhotos.index(of: photo) {
            _selectedPhotoSets.remove(photo)
            _selectedPhotos.remove(at: index)
            
            _updateCountForPhoto(photo)
        }
        delegater?.picker?(picker, didDeselectItemFor: photo)
    }
}

extension SAPPickerInternal {
    
    fileprivate func _updateBytesLenght() {
        //_logger.trace()
        
        guard alwaysSelectOriginal else {
            _updateBytesLenght(with: 0)
            return
        }
        var count: Int = 0
        let group: DispatchGroup = DispatchGroup()
        
        selectedPhotos.forEach { photo in
            group.enter()
            photo.data(with: { data in
                
                if let data = data, count != -1 {
                    count += data.count
                } else {
                    count = -1 // 存在-1表明有图片在iclund上面
                }
                group.leave()
            })
        }
        
        group.notify(queue: .main) { [weak self] in
            self?._updateBytesLenght(with: count)
        }
    }
    fileprivate func _updateBytesLenght(with lenght: Int) {
        _logger.trace(lenght)
        
        if !alwaysSelectOriginal || lenght <= 0 {
            originItem.title = "原图"
        } else {
            originItem.title = "原图(\(SAPStringForBytesLenght(lenght)))"
        }
        
        delegater?.picker?(self.picker, didChangeBytes: lenght)
    }
    
    
    fileprivate func _updateCount(_ count: Int) {
        _logger.trace()
        
        let count = _selectedPhotos.count
        
        previewItem.isEnabled = count != 0
        originItem.isEnabled = count != 0
        sendItem.isEnabled = count != 0
        
        if count == 0 {
            sendItem.title = "发送"
        } else {
            sendItem.title = "发送(\(count))"
        }
    }
    fileprivate func _updateCountForPhoto(_ photo: SAPAsset) {
        _logger.trace()
        
        let count = _selectedPhotos.count
        let enabled = delegater?.picker?(picker, canConfrim: _selectedPhotos) ?? (count != 0)
        
        _updateCount(count)
        sendItem.isEnabled =  enabled
    }
    fileprivate func _updateSelectionForRemove(_ photo: SAPAsset) {
        // 检查这个图片有没有被删除
        guard !SAPLibrary.shared.isExists(of: photo) else {
            return
        }
        _logger.trace(photo.identifier)
        // 需要强制删除?
        if selection(self, shouldDeselectItemFor: photo) {
            selection(self, didDeselectItemFor: photo)
        }
    }
}


// MARK: - Maker

extension SAPPickerInternal {
    
    func makeToolbarItems(for context: SAPToolbarContext) -> [UIBarButtonItem]? {
        switch context {
        case .list:
            return [previewItem, originItem, spaceItem, sendItem]
            
        case .preview:
            if allowsEditing {
                return [editItem, originItem, spaceItem, sendItem]
            } else {
                return [originItem, spaceItem, sendItem]
            }
            
        default: return nil
        }
    }
    
    func makePickerForAlbums() -> SAPPickerAlbums {
        let vc = SAPPickerAlbums(picker: self)
        
        vc.selection = self
        
        return vc
    }
    func makePickerForAssets(with album: SAPAlbum) -> SAPPickerAssets {
        let vc = SAPPickerAssets(picker: self, album: album)
        
        vc.selection = self
        vc.allowsMultipleSelection = allowsMultipleSelection
        
        return vc
    }
    func makePreviewer(_ options: SAPPickerOptions) -> SAPPreviewer {
        let vc = SAPPreviewer(picker: self, options: options)
        
        vc.selection = self
        vc.previewingDelegate = options.previewingDelegate
        vc.allowsMultipleSelection = allowsMultipleSelection
        
        return vc
    }
}

extension SAPPickerInternal: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        let task = UUID().uuidString
        self._changeTaskId = task
        DispatchQueue.main.async {
            guard self._changeTaskId == task else  {
                return // task is change
            }
            // 清除无效的item
            self._selectedPhotos.forEach {
                self._updateSelectionForRemove($0)
            }
            // 全部更新, 防止有选中图片删除/更新
            self._updateBytesLenght()
            // 通知子控制器
            self.viewControllers.forEach {
                ($0 as? PHPhotoLibraryChangeObserver)?.photoLibraryDidChange(changeInstance)
            }
        }
    }
}

// MARK: - UINavigationControllerDelegate & SAPNavigationBarDelegate

extension SAPPickerInternal: UINavigationControllerDelegate, UIViewControllerTransitioningDelegate, SAPNavigationBarDelegate {
    
    // SAPNavigationBarDelegate
    
    func sap_navigationBar(_ navigationBar: SAPNavigationBar, shouldPop item: UINavigationItem) -> Bool {
        guard !allowsMultipleDisplay else {
            return true
        }
        backHandler(self)
        return false
    }
    func sap_navigationBar(_ navigationBar: SAPNavigationBar, didPop item: UINavigationItem) {
        // is empty
    }
    
    // UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    // UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // ??
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // 清除代理, 让侧滑手势恢复
        if viewController is SAPPickerAssets 
            || viewController is SAPPickerAlbums {
            delegate = nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .pop:
            guard let previewer = fromVC as? SAPPreviewer, let previewing = previewer.previewingDelegate, let item = previewer.previewingItem else {
                return nil
            }
            return SAPPreviewableAnimator.pop(item: item, from: previewer, to: previewing)
            
        case .push:
            guard let previewer = toVC as? SAPPreviewer, let previewing = previewer.previewingDelegate, let item = previewer.previewingItem else {
                return nil
            }
            return SAPPreviewableAnimator.push(item: item, from: previewing, to: previewer)
            
        case .none:
            return nil
        }
    }
}


// MARK: - SAPAssetViewDelegate(Forwarding)

extension SAPPickerInternal: SAPSelectionable {
    
    /// gets the index of the selected item, if item does not select to return NSNotFound
    func selection(_ selection: Any, indexOfSelectedItemsFor photo: SAPAsset) -> Int {
        return _selectedPhotos.index(of: photo) ?? NSNotFound
    }
   
    // check whether item can select
    func selection(_ selection: Any, shouldSelectItemFor photo: SAPAsset) -> Bool {
        return delegater?.picker?(picker, shouldSelectItemFor: photo) ?? true
    }
    func selection(_ selection: Any, didSelectItemFor photo: SAPAsset) {
        //_logger.trace()
        
        selectItem(photo)
        // 通知UI更新
        NotificationCenter.default.post(name: .SAPSelectionableDidSelectItem, object: photo)
    }
    
    // check whether item can deselect
    func selection(_ selection: Any, shouldDeselectItemFor photo: SAPAsset) -> Bool {
        return delegater?.picker?(picker, shouldDeselectItemFor: photo) ?? true
    }
    func selection(_ selection: Any, didDeselectItemFor photo: SAPAsset) {
        //_logger.trace()
        
        deselectItem(photo)
        // 通知UI更新
        NotificationCenter.default.post(name: .SAPSelectionableDidDeselectItem, object: photo)
    }
    
    // editing
    func selection(_ selection: Any, willEditing sender: Any) {
        _logger.trace()
        
        // 清除0, 然后重新计算
        _updateBytesLenght(with: 0)
    }
    func selection(_ selection: Any, didEditing sender: Any) {
        _logger.trace()
        
        // 开始重新计算
        _updateBytesLenght()
    }
    
    // tap item
    func selection(_ selection: Any, tapItemFor photo: SAPAsset, with sender: Any) {
        _logger.trace()
        
        let options = SAPPickerOptions(album: photo.album, default: photo)
        options.previewingDelegate = selection as? SAPPreviewableDelegate
        preview(with: options, animated: true)
        
        delegater?.picker?(picker, tapItemFor: photo, with: selection)
    }
}

