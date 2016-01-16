//
//  SIMChatPhotoBrowserController.swift
//  SIMChat
//
//  Created by sagesse on 9/26/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///// 图片浏览器
//class SIMChatPhotoBrowserController: SIMViewController {
//    ///
//    /// 视图加载完成
//    ///
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.imageView.frame = self.view.bounds
//        self.imageView.delegate = self
//        self.imageView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
//        
//        self.view.addSubview(self.imageView)
//        self.view.backgroundColor = UIColor.blackColor()
//        
//        self.view.layoutIfNeeded()
//        self.imageView.showThumbnailImage()
//    }
//    /// 隐藏状态栏
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
//    ///
//    /// 加载详情, 如果需要的话
//    ///
//    func showDetailIfNeed() {
//        self.imageView.showOriginImage()
//    }
////    ///
////    /// 内容1
////    ///
////    var content: SIMChatMessageContentImage! {
////        set { return imageView.image = newValue }
////        get { return imageView.image }
////    }
//    ///
//    /// 弹出的时候显示的view
//    ///
//    override var presentingView: UIView? {
//        return self.imageView.imageView
//    }
//    
//    private(set) lazy var imageView = SIMChatPhotoView(frame: CGRectZero)
//}
//
//// MARK: - Image
//extension SIMChatPhotoBrowserController : SIMChatPhotoViewDelegate {
//    /// 点击了
//    func chatPhotoView(chatPhotoView: SIMChatPhotoView, didTap sender: AnyObject) {
//        self.dismissViewControllerAnimated(true, fromView: imageView, completion: nil)
//    }
//}
//
