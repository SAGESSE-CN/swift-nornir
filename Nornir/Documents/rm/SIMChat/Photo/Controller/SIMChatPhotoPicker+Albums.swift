//
//  SIMChatPhotoPicker+Albums.swift
//  SIMChat
//
//  Created by sagesse on 11/22/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 图集
///
internal class SIMChatPhotoPickerAlbums : UITableViewController {
    
    init(_ picker: SIMChatPhotoPicker?) {
        self.picker = picker
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        self.picker = nil
        super.init(coder: aDecoder)
    }
    
    /// 加载完成
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Albums"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(type(of: self).onCancel(_:)))
        
        tableView.register(AlbumCell.self, forCellReuseIdentifier: "Album")
        tableView.separatorStyle = .none
        
        // 监听
        NotificationCenter.default.addObserver(self, selector: #selector(type(of: self).onLibraryDidChanged(_:)), name: NSNotification.Name(rawValue: SIMChatPhotoLibraryDidChangedNotification), object: nil)
        
        // 默认, 未加载的页面显示
        onRefresh(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SIMLog.trace()
        navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SIMLog.trace()
    }
    
    /// 行数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    /// 行高
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    /// 内容
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Album", for: indexPath) as! AlbumCell
        cell.album = albums[(indexPath as NSIndexPath).row]
        return cell
    }
    /// 选中
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = SIMChatPhotoPickerAssets(albums[(indexPath as NSIndexPath).row], picker)
        // 显示
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 数据
    private lazy var albums: [SIMChatPhotoAlbum] = []
    
    /// 选择器
    weak var picker: SIMChatPhotoPicker?
}

// MARK: - Type
extension SIMChatPhotoPickerAlbums {
    /// 图集单元格
    private class AlbumCell : UITableViewCell {
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            build()
        }
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            build()
        }
        private func build() {
            stackView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = UIFont.systemFont(ofSize: 18)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            detailLabel.font = UIFont.systemFont(ofSize: 12)
            detailLabel.translatesAutoresizingMaskIntoConstraints = false
            
            accessoryType = .disclosureIndicator
            contentView.addSubview(stackView)
            contentView.addSubview(titleLabel)
            contentView.addSubview(detailLabel)
            
            addConstraint(NSLayoutConstraintMake(stackView, .width,   .equal, nil,         .width,  86))
            addConstraint(NSLayoutConstraintMake(stackView, .height,  .equal, stackView,   .width))
            addConstraint(NSLayoutConstraintMake(stackView, .left,    .equal, contentView, .left,   0))
            addConstraint(NSLayoutConstraintMake(stackView, .centerY, .equal, contentView, .centerY))
            
            addConstraint(NSLayoutConstraintMake(titleLabel,  .left,    .equal, stackView,   .right,  8))
            addConstraint(NSLayoutConstraintMake(titleLabel,  .right,   .equal, contentView, .right,  0))
            addConstraint(NSLayoutConstraintMake(detailLabel, .left,    .equal, stackView,   .right,  8))
            addConstraint(NSLayoutConstraintMake(detailLabel, .right,   .equal, contentView, .right,  0))
            
            addConstraint(NSLayoutConstraintMake(titleLabel,  .bottom,  .equal, contentView, .centerY, 0))
            addConstraint(NSLayoutConstraintMake(detailLabel, .top,     .equal, contentView, .centerY, 0))
        }
        
        var album: SIMChatPhotoAlbum? {
            didSet {
                stackView.album = album
                titleLabel.text = album?.title
                detailLabel.text = "\(album?.count ?? 0)"
            }
        }
        
        private lazy var stackView = SIMChatPhotoAlbumView(frame: CGRect(x: 0, y: 0, width: 86, height: 86))
        private lazy var titleLabel = UILabel()
        private lazy var detailLabel = UILabel()
    }
}

// MARK: - Event
extension SIMChatPhotoPickerAlbums {
    /// 取消
    private dynamic func onCancel(_ sender: AnyObject) {
        SIMLog.trace()
        picker?.cancel()
    }
    /// 加载数据
    private dynamic func onRefresh(_ sender: AnyObject) {
        SIMLog.trace()
        
        SIMChatPhotoLibrary.sharedLibrary().albums { a in
            self.albums = a ?? []
            self.tableView.reloadData()
        }
    }
    /// 图库发生改变
    private dynamic func onLibraryDidChanged(_ sender: Notification) {
        onRefresh(sender as AnyObject)
    }
}
