//
//  SIMChatPhotoAssetView+Badge.swift
//  SIMChat
//
//  Created by sagesse on 11/22/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 标记类型
///
internal enum SIMChatPhotoAssetBadgeStyle : Int {
    case none = 0
    
    case image
    case video
    case audio
    
    case camera
}

///
/// 标记
///
internal class SIMChatPhotoAssetBadgeView: SIMView {
    override func build() {
        super.build()
        
        iconView.frame = CGRect(x: 4, y: 0, width: bounds.height, height: bounds.height)
        iconView.contentMode = .left
        
        backgroundLayer.frame = bounds
        backgroundLayer.colors = [UIColor.clear.cgColor, UIColor(white: 0, alpha: 0.8).cgColor]
        
        titleLabel.textAlignment = .right
        titleLabel.textColor = .white()
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.adjustsFontSizeToFitWidth = true
        
        layer.addSublayer(backgroundLayer)
        
        addSubview(iconView)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.frame = bounds
        iconView.frame = CGRect(x: 4, y: 0, width: bounds.height, height: bounds.height)
        if titleLabel.superview != nil {
            titleLabel.frame = CGRect(x: bounds.height + 4, y: 0, width: bounds.width - bounds.height - 4 - 4, height: bounds.height)
        }
    }
    
    // 显示类型
    var style: SIMChatPhotoAssetBadgeStyle = .none {
        didSet {
            switch style {
            case .video:    iconView.image = SIMChatPhotoLibrary.Images.iconVideo
            case .camera:   iconView.image = SIMChatPhotoLibrary.Images.iconPhone
            default:        iconView.image = nil
            }
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
                if titleLabel.superview != nil {
                    titleLabel.removeFromSuperview()
                }
            } else {
                if titleLabel.superview != self {
                    addSubview(titleLabel)
                }
            }
            titleLabel.text = newValue
        }
        get { return titleLabel.text }
    }
    
    private lazy var iconView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var backgroundLayer = CAGradientLayer()
}
