//
//  SIMChatAlbumsViewController.swift
//  SIMChat
//
//  Created by sagesse on 11/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

import Photos
import AssetsLibrary

class SIMChatAlbumsViewController: UITableViewController {
    /// 加载完成
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Albums"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "onCancel:")
        
        self.tableView.registerClass(SIMChatAlbumCell.self, forCellReuseIdentifier: "Album")
        self.tableView.separatorStyle = .None
        
        self.onRefresh(self)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Album", forIndexPath: indexPath) as! SIMChatAlbumCell
        cell.album = albums[indexPath.row]
        return cell
    }
    /// 选中
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = SIMChatAssetsViewController(album: albums[indexPath.row])
        // 显示
        self.navigationController?.pushViewController(vc, animated: true)
        // 取消选中
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    /// 数据
    private lazy var albums = [SIMChatImagePickerAlbum]()
}

/// MARK: - Type
extension SIMChatAlbumsViewController {
    /// 图集单元格
    class SIMChatAlbumCell : UITableViewCell {
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.build()
        }
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.build()
        }
        private func build() {
            let view = UIView(frame: CGRectMake(0, 0, 70, 70))
            
            for i in 0 ..< 3 {
                let s = CGFloat(i)
                let layer = CALayer()
                
                layer.frame = CGRectMake(0 + 2 * s, 0 - 2 * s, view.bounds.width - 4 * s, view.bounds.height - 4 * s)
                layer.hidden = true
                layer.borderWidth = 0.5
                layer.borderColor = UIColor.whiteColor().CGColor
                layer.masksToBounds = true
                layer.contentsGravity = kCAGravityResizeAspectFill
                layer.backgroundColor = layer.borderColor
                
                view.layer.insertSublayer(layer, atIndex: 0)
                layers.append(layer)
            }
            
            view.clipsToBounds = false
            view.translatesAutoresizingMaskIntoConstraints = false
            
            titleLabel.font = UIFont.systemFontOfSize(18)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            detailLabel.font = UIFont.systemFontOfSize(12)
            detailLabel.translatesAutoresizingMaskIntoConstraints = false
            
            self.accessoryType = .DisclosureIndicator
            self.contentView.addSubview(view)
            self.contentView.addSubview(titleLabel)
            self.contentView.addSubview(detailLabel)
            
            self.addConstraint(NSLayoutConstraintMake(view, .Width,   .Equal, nil,         .Width,  70))
            self.addConstraint(NSLayoutConstraintMake(view, .Height,  .Equal, view,        .Width))
            self.addConstraint(NSLayoutConstraintMake(view, .Left,    .Equal, contentView, .Left,   9))
            self.addConstraint(NSLayoutConstraintMake(view, .CenterY, .Equal, contentView, .CenterY))
            
            self.addConstraint(NSLayoutConstraintMake(titleLabel,  .Left,    .Equal, view,        .Right,  16))
            self.addConstraint(NSLayoutConstraintMake(titleLabel,  .Right,   .Equal, contentView, .Right,  0))
            self.addConstraint(NSLayoutConstraintMake(detailLabel, .Left,    .Equal, view,        .Right,  16))
            self.addConstraint(NSLayoutConstraintMake(detailLabel, .Right,   .Equal, contentView, .Right,  0))
            
            self.addConstraint(NSLayoutConstraintMake(titleLabel,  .Bottom,  .Equal, contentView, .CenterY, 0))
            self.addConstraint(NSLayoutConstraintMake(detailLabel, .Top,     .Equal, contentView, .CenterY, 0))
        }
        
        var album: SIMChatImagePickerAlbum? {
            didSet {
                let img = UIImage(named: "t1.jpg")?.CGImage
                for layer in layers {
                    layer.hidden = false
                    layer.contents = img
                }
                
                self.titleLabel.text = album?.title
                self.detailLabel.text = "\(album?.count ?? 0)"
            }
        }
        
        private lazy var layers = [CALayer]()
        private lazy var titleLabel = UILabel()
        private lazy var detailLabel = UILabel()
    }
    
}

// MARK: - Event

extension SIMChatAlbumsViewController {
    /// 取消
    private dynamic func onCancel(sender: AnyObject) {
        SIMLog.trace()
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    /// 加载数据
    private dynamic func onRefresh(sender: AnyObject) {
        SIMLog.trace()
        
        // 加锁
        objc_sync_enter(self.albums)
        
        if #available(iOS 8.0, *) {
            
            let r1 = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .Any, options: nil)
            let r2 = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: nil)
            
            self.albums.removeAll()
            
            for i in 0 ..< r1.count {
                if let v = r1[i] as? PHAssetCollection {
                    self.albums.append(SIMChatImagePickerAlbum(v))
                }
            }
            for i in 0 ..< r2.count {
                if let v = r2[i] as? PHAssetCollection {
                    self.albums.append(SIMChatImagePickerAlbum(v))
                }
            }
            
        }
        
        // 解锁
        objc_sync_exit(self.albums)
        // 重新加载
        self.tableView.reloadData()
    }
}

