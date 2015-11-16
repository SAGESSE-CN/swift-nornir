//
//  SIMChatImagePickerController+Albums.swift
//  SIMChat
//
//  Created by sagesse on 11/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

import Photos
import AssetsLibrary

extension SIMChatImagePickerController {
    /// 图集模型
    class Album : NSObject {
        /// 初始化
        init(_ group: AnyObject) {
            self.data = group
            super.init()
        }
        
        /// 标题
        var title: String? {
            if #available(iOS 8.0, *) {
                return self.collection.localizedTitle
            } else {
                //return self.group.valueForProperty(ALAssetsGroupPropertyName) as? String
                return "<Unknow>"
            }
        }
        /// 图片数量
        var count: Int {
            if #available(iOS 8.0, *) {
                return self.assets.count
            } else {
                //return self.group.numberOfAssets() ?? 0
                return 0
            }
        }
        
        // iOS 8.x and later
        @available(iOS, introduced=8.0) var collection: PHAssetCollection {
            return self.data as! PHAssetCollection
        }
        // iOS 6.x, iOS 7.x
        @available(iOS, introduced=4.0, deprecated=9.0) var group: ALAssetsGroup {
            return self.data as! ALAssetsGroup
        }
        
        /// 内部数据
        private var data: AnyObject
        private lazy var assets: [SIMChatImagePickerController.Asset] = {
            var rs: [SIMChatImagePickerController.Asset] = []
            if #available(iOS 8.0, *) {
                let op = PHFetchOptions()
                
                op.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                
                let a = PHAsset.fetchAssetsInAssetCollection(self.collection, options: op)
                for i in 0 ..< a.count {
                    if let v = a[i] as? PHAsset {
                        rs.append(SIMChatImagePickerController.Asset(v))
                    }
                }
            } else {
                // ..
            }
            return rs
        }()
    }
}

extension SIMChatImagePickerController {
    /// 图集控制器
    internal class AlbumsViewController : UITableViewController {
        /// 加载完成
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.title = "Albums"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "onCancel:")
            
            self.tableView.registerClass(AlbumCell.self, forCellReuseIdentifier: "Album")
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
            let cell = tableView.dequeueReusableCellWithIdentifier("Album", forIndexPath: indexPath) as! AlbumCell
            cell.album = albums[indexPath.row]
            return cell
        }
        /// 选中
        override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let vc = SIMChatImagePickerController.AssetsViewController(album: albums[indexPath.row])
            // 显示
            self.navigationController?.pushViewController(vc, animated: true)
            // 取消选中
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        /// 数据
        private lazy var albums: [SIMChatImagePickerController.Album] = []
    }
}
extension SIMChatImagePickerController.AlbumsViewController {
    /// 图集单元格
    private class AlbumCell : UITableViewCell {
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
        
        var album: SIMChatImagePickerController.Album? {
            didSet {
                for i in 0 ..< layers.count {
                    let layer = layers[i]
                    if i < album?.count ?? 0 {
                        // 存在
                        layer.hidden = false
                        
                        album?.assets[(album?.count ?? 0) - i - 1].s { img in
                            layer.contents = img?.CGImage
                        }
                        
                    } else {
                        // 不存在, 隐藏
                        layer.hidden = true
                    }
                }
//                
//                for layer in layers {
//                    layer.hidden = false
//                    layer.contents = img
//                }
                
                self.titleLabel.text = album?.title
                self.detailLabel.text = "\(album?.count ?? 0)"
            }
        }
        
        private lazy var layers = [CALayer]()
        private lazy var titleLabel = UILabel()
        private lazy var detailLabel = UILabel()
    }
}
extension SIMChatImagePickerController.AlbumsViewController {
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
                    self.albums.append(SIMChatImagePickerController.Album(v))
                }
            }
            for i in 0 ..< r2.count {
                if let v = r2[i] as? PHAssetCollection {
                    self.albums.append(SIMChatImagePickerController.Album(v))
                }
            }
            
        }
        
        // 解锁
        objc_sync_exit(self.albums)
        // 重新加载
        self.tableView.reloadData()
    }
}