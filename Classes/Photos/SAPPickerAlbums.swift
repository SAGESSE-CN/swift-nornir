//
//  SAPPickerAlbums.swift
//  SAC
//
//  Created by SAGESSE on 9/21/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos

internal class SAPPickerAlbums: UITableViewController {
    
    var allowsEditing: Bool = false
    var allowsMultipleDisplay: Bool = true
    var allowsMultipleSelection: Bool = true {
        didSet {
            _previewerViewController?.allowsMultipleSelection = allowsMultipleSelection
        }
    }
    
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
        
        view.backgroundColor = .white
        navigationItem.rightBarButtonItems = navigationController?.navigationItem.rightBarButtonItems
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(SAPPickerAlbumsCell.self, forCellReuseIdentifier: "Item")
        
        // 如果不允许显示多个(即可以选择用户提供的之外), 那么不请求权限
        guard allowsMultipleDisplay else {
            return
        }
        // 如果不允许显示多个, 那么就需要请求权限了
        SAPLibrary.shared.requestAuthorization {
            self._reloadAlbums($0)
            self._initController($0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isToolbarHidden = true
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        _statusView?.frame = view.convert(CGRect(origin: .zero, size: view.bounds.size), from: view.window)
    }

    
    private func _updateStatus(_ newValue: SAPhotoStatus) {
        //_logger.trace(newValue)
        
        _status = newValue
        
        switch newValue {
        case .notError:
            
            _statusView?.removeFromSuperview()
            _statusView = nil
            
            tableView.reloadData()
            tableView.isScrollEnabled = true
            
        case .notData:
            let error = _statusView ?? SAPErrorView()
        
            error.title = "没有图片或视频"
            error.subtitle = "拍点照片和朋友们分享吧"
            error.frame = CGRect(origin: .zero, size: view.frame.size)
            
            _statusView = error
            
            view.addSubview(error)
            tableView.isScrollEnabled = false
            
        case .notPermission:
            let error = _statusView ?? SAPErrorView()
            
            error.title = "没有权限"
            error.subtitle = "此应用程序没有权限访问您的照片\n在\"设置-隐私-图片\"中开启后即可查看"
            error.frame = CGRect(origin: .zero, size: view.frame.size)
            
            _statusView = error
            view.addSubview(error)
            tableView.isScrollEnabled = false
        }
    }
    
    private func _albumsIsEmpty(_ albums: [SAPAlbum]) -> Bool {
        guard !albums.isEmpty else {
            return true
        }
        for album in albums {
            if album.count != 0 {
                // 只要有一个不是空的就返回false
                return false
            }
        }
        return true
    }
    
    fileprivate func _reloadAlbums(_ hasPermission: Bool) {
        //_logger.trace(hasPermission)
        
        guard hasPermission else {
            _updateStatus(.notPermission)
            return
        }
        _albums = SAPAlbum.albums
        guard let albums = _albums, !_albumsIsEmpty(albums) else {
            _updateStatus(.notData)
            return
        }
        _updateStatus(.notError)
    }
    
    private func _initController(_ hasPermission: Bool) {
        //_logger.trace()
        guard hasPermission else {
            return
        }
        if let album = _albumForPicker ?? _albums?.first, let vc = picker?.makePickerForAssets(with: album) {
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    init(picker: SAPPickerInternal) {
        super.init(nibName: nil, bundle: nil)
        logger.trace()
        
        self.title = "Albums"
        self.picker = picker
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not imp")
    }
    deinit {
        logger.trace()
    }
    
    private var _status: SAPhotoStatus = .notError
    private var _statusView: SAPErrorView?
    
    private weak var _assetsViewController: SAPPickerAssets?
    private weak var _previewerViewController: SAPPreviewer?
    
    private var _toolbarItems: [UIBarButtonItem]??
    
    fileprivate var _initPreviewer: SAPPreviewer?
    
    fileprivate var _albums: [SAPAlbum]?
    fileprivate var _albumForPicker: SAPAlbum?
}

// MARK: - UITableViewDelegate & UITableViewDataSource 

extension SAPPickerAlbums {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _albums?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? SAPPickerAlbumsCell else {
            return
        }
        cell.album = _albums?[indexPath.row]
        cell.accessoryType = .disclosureIndicator
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let album = _albums?[indexPath.row], let vc = picker?.makePickerForAssets(with: album) else {
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension SAPPickerAlbums: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        _albums?.forEach {
            $0.clearCache()
        }
        _reloadAlbums(true)
    }
}
