//
//  SIMChatPhotoAlbumView.swift
//  SIMChat
//
//  Created by sagesse on 11/22/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

internal class SIMChatPhotoAlbumView: SIMView {
    override func build() {
        super.build()
        for i in 0 ..< 3 {
            let s = CGFloat(i)
            let photo = SIMChatPhotoAssetView()
            
            photo.frame = CGRect(x: 0, y: 0, width: 70 - 4 * s, height: 70 - 4 * s)
            photo.center = CGPoint(x: center.x, y: center.y - 4 * s)
            photo.layer.borderWidth = 0.5
            photo.layer.borderColor = UIColor.white.cgColor
            photo.layer.masksToBounds = true
            photo.isUserInteractionEnabled = false
            
            photos.append(photo)
        }
    }
    var album: SIMChatPhotoAlbum? {
        didSet {
            CATransaction.setDisableActions(true)
            for i in 0 ..< photos.count {
                let photo = photos[i]
                if i < album?.count ?? 0 {
                    // 更新
                    album?.asset((album?.count ?? 0) - i - 1) { asset in
                        photo.asset = asset
                        // 检查集合的类型
                        photo.badgeStyle = .none //(i == 0) ? .Simple : .None
                    }
                    // 显示
                    if photo.superview != self {
                        insertSubview(photo, at: 0)
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
    private lazy var photos: [SIMChatPhotoAssetView] = []
}
