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

let lib = ALAssetsLibrary()

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
                return self.group.valueForProperty(ALAssetsGroupPropertyName) as? String
            }
        }
        /// 图片数量
        var count: Int {
            if #available(iOS 8.0, *) {
                // 如果没有加载, 请求第一张.
                if !self.isLoading {
                    self.asset(0, complete: nil)
                }
                // 然后就ok了
                return self.assets.count
            } else {
                return self.group.numberOfAssets()
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
       
        private lazy var assets = Array<SIMChatImagePickerController.Asset>()
        private lazy var isLoading = false
        private lazy var waitQueues = Dictionary<Int, [Asset? -> Void]>()
        
        func asset(index: Int, complete: (Asset? -> Void)?) {
            // 加锁， 防止修改assets
            objc_sync_enter(self)
            // 如果己经存在，直接回调
            if index < self.assets.count {
                let asset = self.assets[index]
                
                // 必须要先取出来再解锁
                objc_sync_exit(self)
                
                return complete?(asset) ?? Void()
            }
            // 添加到等待队列
            if let complete = complete {
                if self.waitQueues[index] == nil {
                    self.waitQueues[index] = [complete]
                } else {
                    self.waitQueues[index]?.append(complete)
                }
            }
            // 解锁必须的。。
            objc_sync_exit(self)
            
            // 正在加载中?
            guard !self.isLoading else {
                return
            }
            // 如果没有加载, 请求加载
            self.isLoading = true
            
            // iOS 8.x是同步的, iOS 7.x是异步的
            if #available(iOS 8.0, *) {
                // 查询图片
                let op = PHFetchOptions()
                op.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                let assets = PHAsset.fetchAssetsInAssetCollection(self.collection, options: op)
                
                // 加锁assets
                objc_sync_enter(self)
                
                // 处理
                for index in 0 ..< assets.count {
                    // 创建
                    let sa = assets[index] as! PHAsset
                    let asset = SIMChatImagePickerController.Asset(sa)
                    
                    // 更新
                    self.assets.append(asset)
                    // 取出并清除正在等待的
                    let queue = self.waitQueues[index]
                    self.waitQueues.removeValueForKey(index)
                    
                    // 通知
                    queue?.forEach { $0(asset) }
                }
                
                self.waitQueues.removeAll()
                
                objc_sync_exit(self)
            } else {
                // 这是异步的
                self.group.enumerateAssetsUsingBlock { sa, index, stop in
                    // 创建
                    guard let sa = sa else {
                        // 清空
                        objc_sync_enter(self)
                        self.waitQueues.removeAll()
                        objc_sync_exit(self)
                        return
                    }
                    let asset = SIMChatImagePickerController.Asset(sa)
                    
                    // 加锁assets
                    objc_sync_enter(self)
                    
                    // 更新
                    self.assets.append(asset)
                    // 取出并清除正在等待的
                    let queue = self.waitQueues[index]
                    self.waitQueues.removeValueForKey(index)
                    
                    // 解锁必须的。。
                    objc_sync_exit(self)
                    
                    // 通知
                    queue?.forEach { $0(asset) }
                }
            }
        }
        
        class func fetchAlbums(finish: ([Album] -> Void)?, fail: (NSError? -> Void)?) {
            var rs: [Album] = []
            if #available(iOS 8.0, *) {
                
                let r1 = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .Any, options: nil)
                let r2 = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: nil)
                
                for i in 0 ..< r1.count {
                    if let v = r1[i] as? PHAssetCollection {
                        rs.append(SIMChatImagePickerController.Album(v))
                    }
                }
                for i in 0 ..< r2.count {
                    if let v = r2[i] as? PHAssetCollection {
                        rs.append(SIMChatImagePickerController.Album(v))
                    }
                }
                
                finish?(rs)
                
            } else {
                
                // 遍历， 这是异步的
                lib.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: { group, stop in
                    // ok
                    guard let group = group else {
                        // 完成?
                        finish?(rs)
                        return
                    }
                    
                    group.setAssetsFilter(ALAssetsFilter.allAssets())
                    
                    rs.append(SIMChatImagePickerController.Album(group))
                    // 完成?
                }, failureBlock: { error in
                    fail?(error)
                })
            }
        }
        
        /// 内部数据
        private var data: AnyObject
    }
    /// 图片模型
    class Asset : NSObject {
        /// 初始化
        init(_ asset: AnyObject) {
            self.data = asset
            super.init()
        }
        
        var cacheImage: UIImage?
        
        func s(handler: (UIImage? -> Void)?) {
            // 如果己经加载了
            if let img = self.cacheImage {
                handler?(img)
                return
            }
            if #available(iOS 8.0, *) {
                
                if let v = self.data as? PHAsset {
                    PHImageManager.defaultManager().requestImageForAsset(v, targetSize: CGSizeMake(70 * 2, 70 * 2), contentMode: .AspectFill, options: nil) { [weak self]img, info in
                        self?.cacheImage = img
                        handler?(img)
                    }
                }
            } else {
                if let v = self.data as? ALAsset {
                    let img = UIImage(CGImage: v.thumbnail().takeUnretainedValue())
                    self.cacheImage = img
                    handler?(img)
                }
            }
        }
        
        private var data: AnyObject
    }
}

extension SIMChatImagePickerController {
    class StackView : SIMView {
        override func build() {
            super.build()
            for i in 0 ..< 3 {
                let s = CGFloat(i)
                let photo = PhotoView()
                
                photo.frame = CGRectMake(0, 0, 70 - 4 * s, 70 - 4 * s)
                photo.center = CGPointMake(center.x, center.y - 4 * s)
                photo.layer.borderWidth = 0.5
                photo.layer.borderColor = UIColor.whiteColor().CGColor
                photo.layer.masksToBounds = true
                photo.userInteractionEnabled = false
                
                self.photos.append(photo)
            }
            
        }
        var album: Album? {
            didSet {
                CATransaction.setDisableActions(true)
                for i in 0 ..< photos.count {
                    let photo = photos[i]
                    if i < album?.count ?? 0 {
                        // 更新
                        album?.asset((album?.count ?? 0) - i - 1) { asset in
                            photo.asset = asset
                            // 检查集合的类型
                            photo.badgeStyle = .None //(i == 0) ? .Simple : .None
                        }
                        // 显示
                        if photo.superview != self {
                            self.insertSubview(photo, atIndex: 0)
                        }
                    } else {
                        // 直接移除.
                        if photo.superview != nil {
                            photo.asset = nil
                            photo.removeFromSuperview()
                        }
                    }
                }
                CATransaction.setDisableActions(false)
            }
        }
        private lazy var photos: [PhotoView] = []
    }
    class PhotoView : SIMView {
        override func build() {
            super.build()
            
            contentLayer.frame = bounds
            contentLayer.contentsGravity = kCAGravityResizeAspectFill
            contentLayer.backgroundColor = UIColor.whiteColor().CGColor
            
            layer.addSublayer(contentLayer)
            
            badgeView.frame = CGRectMake(0, bounds.height - 20, bounds.width, 20)
        }
        override func layoutSubviews() {
            super.layoutSubviews()
            self.contentLayer.frame = bounds
            if self.badgeView.superview != nil {
                self.badgeView.frame = CGRectMake(0, bounds.height - 20, bounds.width, 20)
            }
        }
        
        var asset: Asset? {
            didSet {
                CATransaction.setDisableActions(true)
                // 清空
                self.contentLayer.contents = nil
                // 请求图片
                self.asset?.s { img in
                    // 必须关闭动画, 否则会卡顿
                    CATransaction.setDisableActions(true)
                    // 更新内容(图片)
                    self.contentLayer.contents = img?.CGImage
                    CATransaction.setDisableActions(false)
                }
                
                CATransaction.setDisableActions(false)
            }
        }
        
        /// 显示类型
        var badgeStyle: BadgeView.Style {
            set {
                // 必须要有所改变才处理
                guard newValue != badgeStyle else {
                    return
                }
                // 检查是否是需要显示
                if newValue == .None {
                    if self.badgeView.superview != nil {
                        self.badgeView.removeFromSuperview()
                    }
                } else {
                    if self.badgeView.superview != self {
                        self.addSubview(self.badgeView)
                    }
                }
                self.badgeView.style = newValue
            }
            get { return self.badgeView.style }
        }
        
        private lazy var badgeView = BadgeView(frame: CGRectZero)
        private lazy var contentLayer = CALayer()
    }
    class BadgeView : SIMView {
        /// 显示类型
        enum Style : Int {
            case None = 0
            case Video = 1
            case Camera = 2
        }
        override func build() {
            super.build()
            
            iconView.frame = CGRectMake(0, 0, bounds.height, bounds.height)
            addSubview(iconView)
            
            backgroundLayer.frame = bounds
            backgroundLayer.colors = [UIColor.clearColor().CGColor, UIColor(white: 0, alpha: 0.8).CGColor]
            
            layer.addSublayer(backgroundLayer)
        }
        override func layoutSubviews() {
            super.layoutSubviews()
            self.backgroundLayer.frame = self.bounds
            self.iconView.frame = CGRectMake(0, 0, bounds.height, bounds.height)
            if self.titleLabel.superview != nil {
                self.titleLabel.frame = CGRectMake(bounds.height, 0, bounds.width - bounds.height, bounds.height)
            }
        }
        
        // 显示类型
        var style: Style = .None {
            didSet {
                // 更新.
            }
        }
        // 显示内容
        var content: String? {
            set {
                // 必须要有所改变才处理
                guard newValue != content else {
                    return
                }
                // 只有存在内容的时候才显示
                if newValue?.isEmpty ?? true {
                    if self.titleLabel.superview != nil {
                        self.titleLabel.removeFromSuperview()
                    }
                } else {
                    if self.titleLabel.superview != self {
                        self.addSubview(self.titleLabel)
                    }
                }
                self.titleLabel.text = newValue
            }
            get { return self.titleLabel.text }
        }
        
        private lazy var iconView = UIImageView()
        private lazy var titleLabel = UILabel()
        private lazy var backgroundLayer = CAGradientLayer()
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
            
            // 监听
//            // Register observer
//            [[NSNotificationCenter defaultCenter] addObserver:self
//                selector:@selector(assetsLibraryChanged:)
//            name:ALAssetsLibraryChangedNotification
//            object:nil];
//        
//        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
            
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
//            let view = UIView(frame: CGRectMake(0, 0, 70, 70))
//            
//            for i in 0 ..< 3 {
//                let s = CGFloat(i)
//                let layer = CALayer()
//                
//                layer.frame = CGRectMake(0 + 2 * s, 0 - 2 * s, view.bounds.width - 4 * s, view.bounds.height - 4 * s)
//                layer.hidden = true
//                layer.borderWidth = 0.5
//                layer.borderColor = UIColor.whiteColor().CGColor
//                layer.masksToBounds = true
//                layer.contentsGravity = kCAGravityResizeAspectFill
//                layer.backgroundColor = layer.borderColor
//                
//                view.layer.insertSublayer(layer, atIndex: 0)
//                layers.append(layer)
//            }
//            
//            view.clipsToBounds = false
//            view.translatesAutoresizingMaskIntoConstraints = false
            stackView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = UIFont.systemFontOfSize(18)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            detailLabel.font = UIFont.systemFontOfSize(12)
            detailLabel.translatesAutoresizingMaskIntoConstraints = false
            
            self.accessoryType = .DisclosureIndicator
            self.contentView.addSubview(stackView)
            self.contentView.addSubview(titleLabel)
            self.contentView.addSubview(detailLabel)
            
            self.addConstraint(NSLayoutConstraintMake(stackView, .Width,   .Equal, nil,         .Width,  86))
            self.addConstraint(NSLayoutConstraintMake(stackView, .Height,  .Equal, stackView,   .Width))
            self.addConstraint(NSLayoutConstraintMake(stackView, .Left,    .Equal, contentView, .Left,   0))
            self.addConstraint(NSLayoutConstraintMake(stackView, .CenterY, .Equal, contentView, .CenterY))
            
            self.addConstraint(NSLayoutConstraintMake(titleLabel,  .Left,    .Equal, stackView,   .Right,  8))
            self.addConstraint(NSLayoutConstraintMake(titleLabel,  .Right,   .Equal, contentView, .Right,  0))
            self.addConstraint(NSLayoutConstraintMake(detailLabel, .Left,    .Equal, stackView,   .Right,  8))
            self.addConstraint(NSLayoutConstraintMake(detailLabel, .Right,   .Equal, contentView, .Right,  0))
            
            self.addConstraint(NSLayoutConstraintMake(titleLabel,  .Bottom,  .Equal, contentView, .CenterY, 0))
            self.addConstraint(NSLayoutConstraintMake(detailLabel, .Top,     .Equal, contentView, .CenterY, 0))
        }
        
        var album: SIMChatImagePickerController.Album? {
            didSet {
//                CATransaction.setDisableActions(true)
                
//                for i in 0 ..< layers.count {
//                    let layer = layers[i]
//                    if i < album?.count ?? 0 {
//                        // 存在
//                        layer.hidden = false
//                        
//                        album?.assets[(album?.count ?? 0) - i - 1].s { img in
//                            layer.contents = img?.CGImage
//                        }
//                    } else {
//                        // 不存在, 隐藏
//                        layer.hidden = true
//                    }
//                }
                
                self.stackView.album = album
                self.titleLabel.text = album?.title
                self.detailLabel.text = "\(album?.count ?? 0)"
                
//                CATransaction.setDisableActions(false)
            }
        }
        
//        private lazy var layers = [CALayer]()
        private lazy var stackView = SIMChatImagePickerController.StackView(frame: CGRectMake(0, 0, 86, 86))
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
        
        SIMChatImagePickerController.Album.fetchAlbums({ a in
            self.albums = a
            self.tableView.reloadData()
        }, fail: { e in
            self.albums.removeAll()
            self.tableView.reloadData()
        })
    }
}
