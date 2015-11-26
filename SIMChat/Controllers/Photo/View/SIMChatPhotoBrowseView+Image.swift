//
//  SIMChatPhotoBrowseView+Image.swift
//  SIMChat
//
//  Created by sagesse on 11/22/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 图片浏览
///
internal class SIMChatPhotoBrowseViewImage: SIMView {
    /// 构建
    override func build() {
        super.build()
        
        scrollView.frame = self.bounds
        scrollView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        
        scrollView.addSubview(imageView)
        addSubview(scrollView)
        
        addGestureRecognizer(tapGestureRecognizer)
        addGestureRecognizer(doubleTapGestureRecognizer)
        
        tapGestureRecognizer.requireGestureRecognizerToFail(doubleTapGestureRecognizer)
        
        // TODO: 旋转手势和scrollview有冲突, 先不处理
        //addGestureRecognizer(rotationGestureRecognizer)
        
    }
    ///
    /// 缩放到最合适
    ///
    func zoomToFit(animated flag: Bool) {
        let from = imageView.bounds.size
        var to = imageView.image?.size ?? CGSizeZero
        
        to.width = max(to.width, 1)
        to.height = max(to.height, 1)
        
        // 计算出最小的.
        let scale = min(min(bounds.width, to.width) / to.width, min(bounds.height, to.height) / to.height)
        let fit = CGRectMake(0, 0, scale * to.width, scale * to.height)
        
        // 还有中心点问题
        let pt = CGPointMake(max(fit.width, scrollView.bounds.width) / 2, max(fit.height, scrollView.bounds.height) / 2)
        
        scrollView.zoomScale = 1
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = max(max(to.width / fit.width, to.height / fit.height), 2)
        
        
        SIMLog.trace("from: \(from), to: \(to), scale: \(scrollView.maximumZoomScale)")
        
        if flag {
            UIView.animateWithDuration(0.25) {
                self.imageView.bounds = fit
                self.imageView.center = pt
            }
        } else {
            imageView.bounds = fit
            imageView.center = pt
        }
    }
    /// 更新布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = max(scrollView.contentSize.width, scrollView.bounds.width)
        let height = max(scrollView.contentSize.height, scrollView.bounds.height)
        
        imageView.center = CGPointMake(width / 2, height / 2)
    }
    
    // 需要显示的元素
    var element: SIMChatPhotoBrowseElement? {
        didSet {
            guard element !== oldValue else {
                return
            }
            
            let fullIsLoaded = element?.fullscreenIsLoaded() ?? false
            
            // 需要加载缩略图?
            if !fullIsLoaded {
                imageView.image = nil
                element?.thumbnail(CGSizeMake(80, 80)) { [weak self] img in
                    guard self?.element !== oldValue else {
                        return
                    }
                    self?.imageView.image = img
                    self?.zoomToFit(animated: false)
                }
            }
            // 需要加载大图?
            element?.fullscreen { [weak self] img in
                dispatch_async(dispatch_get_main_queue()) {
                    guard self?.element !== oldValue else {
                        return
                    }
                    self?.imageView.image = img
                    self?.zoomToFit(animated: !fullIsLoaded)
                }
            }
        }
    }
    
    
    /// 需要显示的图片:)
    var image: SIMChatMessageContentImage!
//    /// 代理
//    weak var delegate: SIMChatPhotoViewDelegate?
    
    private var isRotation = false
    private var tttt: CGAffineTransform?
    
    private(set) lazy var imageView = UIImageView()
    private(set) lazy var scrollView = UIScrollView()
    private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: "onTap:")
    }()
    private(set) lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: "onDoubleTap:")
        tap.numberOfTapsRequired = 2
        return tap
    }()
    private(set) lazy var rotationGestureRecognizer: UIRotationGestureRecognizer = {
        let rotation = UIRotationGestureRecognizer(target: self, action: "onRotation:")
        rotation.delegate = self
        return rotation
    }()
    
    /// 代理
    weak var delegate: SIMChatPhotoBrowseDelegate?
}

// MARK: - Content
extension SIMChatPhotoBrowseViewImage : UIScrollViewDelegate, UIGestureRecognizerDelegate {
    /// yp
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    /// xp
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let x = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) / 2 : 0;
        let y = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) / 2 : 0;
        // 更新
        self.imageView.center = CGPointMake(scrollView.contentSize.width / 2 + x, scrollView.contentSize.height / 2 + y)
    }
    
}

// MARK: - Events
extension SIMChatPhotoBrowseViewImage {
    /// 单击退出
    private dynamic func onTap(sender: UIGestureRecognizer) {
        SIMLog.trace()
        if sender.state == .Ended {
            if let view = delegate as? SIMChatPhotoBrowseView {
                delegate?.browseViewDidClick?(view)
            }
        }
    }
    /// 旋转
    private dynamic func onRotation(recognizer: UIRotationGestureRecognizer) {
    }
    /// 双击
    private dynamic func onDoubleTap(sender: AnyObject) {
        SIMLog.trace()
        if sender.state == .Ended {
            if let view = delegate as? SIMChatPhotoBrowseView {
                delegate?.browseViewDidDoubleClick?(view)
            }
        }
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
}

