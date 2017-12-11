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
        scrollView.autoresizingMask = UIViewAutoresizing.flexibleWidth | UIViewAutoresizing.flexibleHeight
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
        
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        
        // TODO: 旋转手势和scrollview有冲突, 先不处理
        //addGestureRecognizer(rotationGestureRecognizer)
        
    }
    ///
    /// 缩放到最合适
    ///
    func zoomToFit(animated flag: Bool) {
        let from = imageView.bounds.size
        var to = imageView.image?.size ?? CGSize.zero
        
        to.width = max(to.width, 1)
        to.height = max(to.height, 1)
        
        // 计算出最小的.
        let scale = min(min(bounds.width, to.width) / to.width, min(bounds.height, to.height) / to.height)
        let fit = CGRect(x: 0, y: 0, width: scale * to.width, height: scale * to.height)
        
        // 还有中心点问题
        let pt = CGPoint(x: max(fit.width, scrollView.bounds.width) / 2, y: max(fit.height, scrollView.bounds.height) / 2)
        
        scrollView.zoomScale = 1
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = max(max(to.width / fit.width, to.height / fit.height), 2)
        
        
        SIMLog.trace("from: \(from), to: \(to), scale: \(scrollView.maximumZoomScale)")
        
        if flag {
            UIView.animate(withDuration: 0.25) {
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
        
        imageView.center = CGPoint(x: width / 2, y: height / 2)
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
                element?.thumbnail(CGSize(width: 80, height: 80)) { [weak self] img in
                    guard self?.element !== oldValue else {
                        return
                    }
                    self?.imageView.image = img
                    self?.zoomToFit(animated: false)
                }
            }
            // 需要加载大图?
            element?.fullscreen { [weak self] img in
                DispatchQueue.main.async {
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
//    var image: SIMChatMessageContentImage!
//    /// 代理
//    weak var delegate: SIMChatPhotoViewDelegate?
    
    private var isRotation = false
    private var tttt: CGAffineTransform?
    
    private(set) lazy var imageView = UIImageView()
    private(set) lazy var scrollView = UIScrollView()
    private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(type(of: self).onTap(_:)))
    }()
    private(set) lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(type(of: self).onDoubleTap(_:)))
        tap.numberOfTapsRequired = 2
        return tap
    }()
    private(set) lazy var rotationGestureRecognizer: UIRotationGestureRecognizer = {
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(type(of: self).onRotation(_:)))
        rotation.delegate = self
        return rotation
    }()
    
    /// 代理
    weak var delegate: SIMChatPhotoBrowseDelegate?
}

// MARK: - Content
extension SIMChatPhotoBrowseViewImage : UIScrollViewDelegate, UIGestureRecognizerDelegate {
    /// yp
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    /// xp
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let x = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) / 2 : 0;
        let y = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) / 2 : 0;
        // 更新
        self.imageView.center = CGPoint(x: scrollView.contentSize.width / 2 + x, y: scrollView.contentSize.height / 2 + y)
    }
    
}

// MARK: - Events
extension SIMChatPhotoBrowseViewImage {
    /// 单击退出
    private dynamic func onTap(_ sender: UIGestureRecognizer) {
        SIMLog.trace()
        if sender.state == .ended {
            if let view = delegate as? SIMChatPhotoBrowseView {
                delegate?.browseViewDidClick?(view)
            }
        }
    }
    /// 旋转
    private dynamic func onRotation(_ recognizer: UIRotationGestureRecognizer) {
    }
    /// 双击
    private dynamic func onDoubleTap(_ sender: AnyObject) {
        SIMLog.trace()
        if sender.state == .ended {
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

