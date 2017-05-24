//
//  BrowserAlbumListController.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserAlbumListController: UITableViewController {
    
    init(library: Library) {
        _library = library
        
        super.init(style: .plain)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData(with auth: AuthorizationStatus) {
        
        // check for authorization status
        guard auth == .authorized else {
            // no permission
            _showError(with: "没有权限", subtitle: "此应用程序没有权限访问您的照片\n在\"设置-隐私-图片\"中开启后即可查看")
            return
        }
        // get all photo albums
        let collections = _library.ub_collections(with: .regular)
        // check for photos albums count
        guard !collections.isEmpty else {
            // no data
            _showError(with: "没有图片或视频", subtitle: "拍点照片和朋友们分享吧")
            return
        }
        // clear error info & display album
        _collections = collections
        _clearError()
    }
    
    override func loadView() {
        super.loadView()
        // setup controller
        title = "Albums"
        
        // setup table view
        tableView.register(BrowserAlbumListCell.self, forCellReuseIdentifier: "ASSET")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // request permission with show
        _library.ub_requestAuthorization { status in
            DispatchQueue.main.async {
                self.reloadData(with: status)
            }
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // if the info view is show, update the layout
        if let infoView = _infoView {
            infoView.frame = view.bounds
        }
    }
    
    fileprivate var _library: Library
    fileprivate var _collections: Array<Collection>?
    
    fileprivate var _infoView: ErrorInfoView?
}

internal extension BrowserAlbumListController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _collections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ASSET", for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // try fetch cell
        // try fetch collection
        guard let collection = _collections?.ub_get(at: indexPath.row), let cell = cell as? BrowserAlbumListCell else {
            return
        }
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .white
        // update data for displaying
        cell.willDisplay(with: collection, library: _library)
    }
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // try fetch cell
        // try fetch collection
        guard let collection = _collections?.ub_get(at: indexPath.row), let cell = cell as? BrowserAlbumListCell else {
            return
        }
        // clear data for end display
        cell.endDisplay(with: collection, library: _library)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        logger.trace?.write(indexPath)
        
        // try fetch collection
        guard let collection = _collections?.ub_get(at: indexPath.row) else {
            return
        }
        let controller = BrowserAlbumController(source: .init(collection), library: _library)
        // push to next page
        show(controller, sender: indexPath)
    }
}

/// library load support
internal extension BrowserAlbumListController {
    
    fileprivate func _showError(with title: String, subtitle: String) {
        logger.trace?.write(title, subtitle)
        
        // clear view
        _infoView?.removeFromSuperview()
        _infoView = nil
        
        let infoView = ErrorInfoView()
        
        // show view
        view.addSubview(infoView)
        _infoView = infoView
        
        infoView.title = title
        infoView.subtitle = subtitle
        infoView.backgroundColor = .white
        
        // disable scroll
        tableView.isScrollEnabled = false
        tableView.reloadData()
    }
    
    fileprivate func _clearError() {
        logger.trace?.write()
        
        // enable scroll
        tableView.isScrollEnabled = true
        tableView.reloadData()
        
        // clear view
        _infoView?.removeFromSuperview()
        _infoView = nil
    }
}
