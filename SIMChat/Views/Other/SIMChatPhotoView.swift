//
//  SIMChatPhotoView.swift
//  SIMChat
//
//  Created by sagesse on 9/26/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///// 图片
//class SIMChatPhotoView: SIMView {
//    /// 构建
//    override func build() {
//        super.build()
//        
//        self.scrollView.frame = self.bounds
//        self.scrollView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
//        self.scrollView.zoomScale = 1.0
//        self.scrollView.minimumZoomScale = 1.0
//        self.scrollView.maximumZoomScale = 2.0
//        self.scrollView.delegate = self
//        
//        //self.scrollView.contentSize = self.bounds.size
//        
//        self.scrollView.addSubview(imageView)
//        self.addSubview(scrollView)
//        
//        let tap = UITapGestureRecognizer(target: self, action: "onTap:")
//        let dtap = UITapGestureRecognizer(target: self, action: "onDoubleTap:")
//        
//        dtap.numberOfTapsRequired = 2
//        tap.requireGestureRecognizerToFail(dtap)
//        
//        self.addGestureRecognizer(tap)
//        self.addGestureRecognizer(dtap)
//    }
//    ///
//    /// 加载原图
//    ///
//    func showOriginImage() {
//        SIMLog.trace()
//        // 只有没有加载过才开始加载原图
//        if !self.image.origin.storaged {
//            self.image.origin.didSet({ [weak self] newValue in
//                self?.imageView.image = newValue!
//                self?.zoomToFit(animated: true)
//            })
//            self.image.origin.get()
//        } else {
//            // 安全着想, 加载缩略图
//            self.showThumbnailImage()
//        }
//    }
//    ///
//    /// 加载缩略图
//    ///
//    func showThumbnailImage() {
//        SIMLog.trace()
//        
//        // 如果有原图, 使用原图。 
//        // 如果没有原图, 使用缩略图
//        if let img = image.origin.get() ?? image.thumbnail.get() {
//            self.imageView.image = img
//            self.zoomToFit(animated: true)
//        }
//    }
//    ///
//    /// 缩放到最合适
//    ///
//    func zoomToFit(animated flag: Bool) {
//        let from = imageView.bounds.size
//        var to = imageView.image?.size ?? CGSizeZero
//        
//        to.width = max(to.width, 1)
//        to.height = max(to.height, 1)
//        
//        // 计算出最小的.
//        let scale = min(min(self.bounds.width, to.width) / to.width, min(self.bounds.height, to.height) / to.height)
//        let fit = CGRectMake(0, 0, scale * to.width, scale * to.height)
//        
//        // 还有中心点问题
//        let pt = CGPointMake(max(scrollView.contentSize.width, scrollView.bounds.width) / 2, max(scrollView.contentSize.height, scrollView.bounds.height) / 2)
//        
//        scrollView.zoomScale = 1
//        scrollView.minimumZoomScale = 1
//        scrollView.maximumZoomScale = max(max(to.width / fit.width, to.height / fit.height), 2)
//        
//        
//        SIMLog.trace("from: \(from), to: \(to), scale: \(scrollView.maximumZoomScale)")
//        
//        if flag {
//            UIView.animateWithDuration(0.25) {
//                self.imageView.bounds = fit
//                self.imageView.center = pt
//            }
//        } else {
//            self.imageView.bounds = fit
//            self.imageView.center = pt
//        }
//    }
//    /// 更新布局
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        let width = max(scrollView.contentSize.width, scrollView.bounds.width)
//        let height = max(scrollView.contentSize.height, scrollView.bounds.height)
//        
//        self.imageView.center = CGPointMake(width / 2, height / 2)
//    }
//    
////    /// 需要显示的图片:)
////    var image: SIMChatMessageContentImage!
//    /// 代理
//    weak var delegate: SIMChatPhotoViewDelegate?
//    
//    private(set) lazy var imageView = UIImageView()
//    private(set) lazy var scrollView = UIScrollView()
//}
//
//// MARK: - Content
//extension SIMChatPhotoView : UIScrollViewDelegate {
//    /// yp
//    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
//        return self.imageView
//    }
//    /// xp
//    func scrollViewDidZoom(scrollView: UIScrollView) {
//        let x = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) / 2 : 0;
//        let y = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) / 2 : 0;
//        // 更新
//        self.imageView.center = CGPointMake(scrollView.contentSize.width / 2 + x, scrollView.contentSize.height / 2 + y)
//    }
//}
//
//// MARK: - Events
//extension SIMChatPhotoView {
//    /// 单击退出
//    private dynamic func onTap(sender: AnyObject) {
//        self.delegate?.chatPhotoView?(self, didTap: sender)
//    }
//    /// 双击
//    private dynamic func onDoubleTap(sender: AnyObject) {
//        if scrollView.zoomScale > scrollView.minimumZoomScale {
//            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
//        } else {
//            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
//        }
//    }
//}
//
//// MARK: - Delegate
//@objc protocol SIMChatPhotoViewDelegate : NSObjectProtocol {
//    optional func chatPhotoView(chatPhotoView: SIMChatPhotoView, didTap sender: AnyObject)
//}
