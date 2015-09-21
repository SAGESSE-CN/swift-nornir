//
//  SIMChatCell+Audio.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SIMChatCellAudio: SIMChatCellBubble {
    /// 构建
    override func build() {
        super.build()
        
        let vs = ["c": titleLabel,
                  "i": animationView]
        
        let ms = ["s0": 20,
                  "m0": 0,
                  "hp0": hPriority,
                  "hp1": hPriority - 1]
        
        let addConstraints = bubbleView.contentView.addConstraints
        
        // config
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        // add views
        bubbleView.contentView.addSubview(animationView)
        bubbleView.contentView.addSubview(titleLabel)
        
        // add constraints
        addConstraints(NSLayoutConstraintMake("H:|-12@hp1-[c]-10@hp1-[i]-10@hp1-|", views: vs, options: .AlignAllCenterY, metrics: ms))
        addConstraints(NSLayoutConstraintMake("H:|-10@hp0-[i]-10@hp0-[c]-12@hp0-|", views: vs, options: .AlignAllCenterY, metrics: ms))
        addConstraints(NSLayoutConstraintMake("V:|->=8-[i]->=8-|", views: vs))
        addConstraints(NSLayoutConstraintMake("H:[i(s0)]", views: vs))
        addConstraints(NSLayoutConstraintMake("V:[i(s0)]", views: vs))
        
        // get constraints
        for c in bubbleView.contentView.constraints {
            if c.priority == hPriority {
                leftConstraints.append(c)
            }
        }
        
//        // add kvo
//        NSNotificationCenter.simInternalCenter().addObserver(self, selector: "onAudioStop:", name: SIMChatAudioWillStopNotification, object: nil)
//        NSNotificationCenter.simInternalCenter().addObserver(self, selector: "onAudioStop:", name: SIMChatAudioWillRecordNotification, object: nil)
//        NSNotificationCenter.simInternalCenter().addObserver(self, selector: "onAudioPlay:", name: SIMChatAudioWillPlayNotification, object: nil)
//        
//        NSNotificationCenter.simInternalCenter().addObserver(self, selector: "onAudioLoading:", name: SIMChatAudioWillLoadNotification, object: nil)
//        NSNotificationCenter.simInternalCenter().addObserver(self, selector: "onAudioLoaded:", name: SIMChatAudioDidLoadNotification, object: nil)
    }
    //
    /// 重新加载数据.
    ///
    /// :param: u   当前用户
    /// :param: m   需要显示的消息
    ///
    override func reloadData(m: SIMChatMessage, ofUser u: SIMChatUser?) {
        super.reloadData(m, ofUser: u)
        // 更新内容
        if let ctx = m.content as? SIMChatContentAudio {
            titleLabel.text = "\(ctx.duration)"
            // 播放中.
            if ctx.playing {
                animationView.startAnimating()
            }
        }
    }
    ///
    /// 显示类型
    ///
    override var style: SIMChatCellStyle {
        willSet {
            switch newValue {
            case .Left:
                
                animationView.stopAnimating()
                animationView.animationDuration = 1
                titleLabel.textColor = UIColor.blackColor()
                (animationView.image, animationView.animationImages) = self.dynamicType.leftImages
                
            case .Right:
                
                titleLabel.textColor = UIColor.whiteColor()
                animationView.stopAnimating()
                animationView.animationDuration = 1
                (animationView.image, animationView.animationImages) = self.dynamicType.rightImages
            }
            
            for c in leftConstraints {
                c.priority = newValue == .Left ? hPriority : 1
            }
            
            setNeedsLayout()
        }
    }
    
    private let hPriority = UILayoutPriority(750)
    private lazy var leftConstraints = [NSLayoutConstraint]()
    
    private lazy var titleLabel = UILabel()
    private lazy var animationView = UIImageView()
}


/// MARK: - /// Resources
extension SIMChatCellAudio {

    /// 左边
    static let leftImages: (UIImage?, [UIImage]?) = {
        let a = NSMutableArray()
        for n in ["voice_receive_icon_nor",
                  "voice_receive_icon_1",
                  "voice_receive_icon_2",
                  "voice_receive_icon_3"] {
            if let img = UIImage(named: n) {
                a.addObject(img)
            }
        }
        return (a[0] as? UIImage, a.subarrayWithRange(NSMakeRange(1, a.count - 1)) as? [UIImage])
    }()
    
    /// 右边
    static let rightImages: (UIImage?, [UIImage]?) = {
        let a = NSMutableArray()
        for n in ["voice_send_icon_nor",
                  "voice_send_icon_1",
                  "voice_send_icon_2",
                  "voice_send_icon_3"] {
            if let img = UIImage(named: n) {
                a.addObject(img)
            }
        }
        return (a[0] as? UIImage, a.subarrayWithRange(NSMakeRange(1, a.count - 1)) as? [UIImage])
    }()
}