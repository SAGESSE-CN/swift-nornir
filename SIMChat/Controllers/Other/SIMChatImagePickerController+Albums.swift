//
//  SIMChatImagePickerController+Albums.swift
//  SIMChat
//
//  Created by sagesse on 11/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SIMChatImageStackView : SIMView {
    override func build() {
        super.build()
        for i in 0 ..< 3 {
            let s = CGFloat(i)
            let photo = SIMChatImagePhotoView()
            
            photo.frame = CGRectMake(0, 0, 70 - 4 * s, 70 - 4 * s)
            photo.center = CGPointMake(center.x, center.y - 4 * s)
            photo.layer.borderWidth = 0.5
            photo.layer.borderColor = UIColor.whiteColor().CGColor
            photo.layer.masksToBounds = true
            photo.userInteractionEnabled = false
            
            self.photos.append(photo)
        }
        
    }
    var album: SIMChatImageAlbum? {
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
    private lazy var photos: [SIMChatImagePhotoView] = []
}
class SIMChatImagePhotoView : SIMView {
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
    
    var asset: SIMChatImageAsset? {
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
    var badgeStyle: SIMChatImageBadgeView.Style {
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
    
    private lazy var badgeView = SIMChatImageBadgeView(frame: CGRectZero)
    private lazy var contentLayer = CALayer()
}
class SIMChatImageBadgeView : SIMView {
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

/// 图集控制器
class SIMChatImageAlbumsViewController : UITableViewController {
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
        let vc = SIMChatImageAssetsViewController(album: albums[indexPath.row])
        // 显示
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /// 数据
    private lazy var albums: [SIMChatImageAlbum] = []
}

// MARK: - Type
extension SIMChatImageAlbumsViewController {
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
        
        var album: SIMChatImageAlbum? {
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
        private lazy var stackView = SIMChatImageStackView(frame: CGRectMake(0, 0, 86, 86))
        private lazy var titleLabel = UILabel()
        private lazy var detailLabel = UILabel()
    }
}

// MARK: - Event
extension SIMChatImageAlbumsViewController {
    /// 取消
    private dynamic func onCancel(sender: AnyObject) {
        SIMLog.trace()
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    /// 加载数据
    private dynamic func onRefresh(sender: AnyObject) {
        SIMLog.trace()
        
        SIMChatImageLibrary.sharedLibrary().albums { a in
            self.albums = a ?? []
            self.tableView.reloadData()
        }
    }
}