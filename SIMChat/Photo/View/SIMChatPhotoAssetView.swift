//
//  SIMChatPhotoAssetView.swift
//  SIMChat
//
//  Created by sagesse on 11/22/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

internal class SIMChatPhotoAssetView: SIMView {
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
        contentLayer.frame = bounds
        if badgeView.superview != nil {
            badgeView.frame = CGRectMake(0, bounds.height - 20, bounds.width, 20)
        }
    }
    
    var asset: SIMChatPhotoAsset? {
        didSet {
            guard asset != oldValue else {
                return
            }
            
            CATransaction.setDisableActions(true)
            // 先清空
            contentLayer.contents = nil
            asset?.thumbnail(bounds.size) { img in
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
    var badgeStyle: SIMChatPhotoAssetBadgeStyle {
        set {
            // 必须要有所改变才处理
            guard newValue != badgeStyle else {
                return
            }
            // 检查是否是需要显示
            if newValue == .None {
                if badgeView.superview != nil {
                    badgeView.removeFromSuperview()
                }
            } else {
                if badgeView.superview != self {
                    addSubview(badgeView)
                }
            }
            badgeView.style = newValue
        }
        get { return badgeView.style }
    }
    
    /// 显示内容
    var badgeValue: String? {
        set { return badgeView.content = newValue }
        get { return badgeView.content }
    }
    
    private lazy var badgeView = SIMChatPhotoAssetBadgeView(frame: CGRectZero)
    private lazy var contentLayer = CALayer()
}
