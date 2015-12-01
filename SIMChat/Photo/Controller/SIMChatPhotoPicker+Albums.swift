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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "onCancel:")
        
        tableView.registerClass(AlbumCell.self, forCellReuseIdentifier: "Album")
        tableView.separatorStyle = .None
        
        // 监听
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onLibraryDidChanged:", name: SIMChatPhotoLibraryDidChangedNotification, object: nil)
        
        // 默认, 未加载的页面显示
        onRefresh(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SIMLog.trace()
        navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        SIMLog.trace()
    }
    
    /// 行数
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    /// 行高
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
    /// 内容
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Album", forIndexPath: indexPath) as! AlbumCell
        cell.album = albums[indexPath.row]
        return cell
    }
    /// 选中
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = SIMChatPhotoPickerAssets(albums[indexPath.row], picker)
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
            titleLabel.font = UIFont.systemFontOfSize(18)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            detailLabel.font = UIFont.systemFontOfSize(12)
            detailLabel.translatesAutoresizingMaskIntoConstraints = false
            
            accessoryType = .DisclosureIndicator
            contentView.addSubview(stackView)
            contentView.addSubview(titleLabel)
            contentView.addSubview(detailLabel)
            
            addConstraint(NSLayoutConstraintMake(stackView, .Width,   .Equal, nil,         .Width,  86))
            addConstraint(NSLayoutConstraintMake(stackView, .Height,  .Equal, stackView,   .Width))
            addConstraint(NSLayoutConstraintMake(stackView, .Left,    .Equal, contentView, .Left,   0))
            addConstraint(NSLayoutConstraintMake(stackView, .CenterY, .Equal, contentView, .CenterY))
            
            addConstraint(NSLayoutConstraintMake(titleLabel,  .Left,    .Equal, stackView,   .Right,  8))
            addConstraint(NSLayoutConstraintMake(titleLabel,  .Right,   .Equal, contentView, .Right,  0))
            addConstraint(NSLayoutConstraintMake(detailLabel, .Left,    .Equal, stackView,   .Right,  8))
            addConstraint(NSLayoutConstraintMake(detailLabel, .Right,   .Equal, contentView, .Right,  0))
            
            addConstraint(NSLayoutConstraintMake(titleLabel,  .Bottom,  .Equal, contentView, .CenterY, 0))
            addConstraint(NSLayoutConstraintMake(detailLabel, .Top,     .Equal, contentView, .CenterY, 0))
        }
        
        var album: SIMChatPhotoAlbum? {
            didSet {
                stackView.album = album
                titleLabel.text = album?.title
                detailLabel.text = "\(album?.count ?? 0)"
            }
        }
        
        private lazy var stackView = SIMChatPhotoAlbumView(frame: CGRectMake(0, 0, 86, 86))
        private lazy var titleLabel = UILabel()
        private lazy var detailLabel = UILabel()
    }
}

// MARK: - Event
extension SIMChatPhotoPickerAlbums {
    /// 取消
    private dynamic func onCancel(sender: AnyObject) {
        SIMLog.trace()
        picker?.cancel()
    }
    /// 加载数据
    private dynamic func onRefresh(sender: AnyObject) {
        SIMLog.trace()
        
        SIMChatPhotoLibrary.sharedLibrary().albums { a in
            self.albums = a ?? []
            self.tableView.reloadData()
        }
    }
    /// 图库发生改变
    private dynamic func onLibraryDidChanged(sender: NSNotification) {
        onRefresh(sender)
    }
}