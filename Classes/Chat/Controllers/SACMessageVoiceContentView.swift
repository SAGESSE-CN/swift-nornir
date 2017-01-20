//
//  SACMessageVoiceContentView.swift
//  SAChat
//
//  Created by sagesse on 05/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

open class SACMessageVoiceContentView: UIView, SACMessageContentViewType {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }

    
    open func apply(_ message: SACMessageType) {
        guard let content = message.content as? SACMessageVoiceContent else {
            return
        }
        
        _updateViewLayouts(message.options)
        _titleLabel.attributedText = content.attributedText
    }
    
    private func _updateViewLayouts(_ options: SACMessageOptions) {
        guard _alignment != options.alignment else {
            return
        }
        _alignment = options.alignment
        
        let aw = CGFloat(20)
        let tw = bounds.maxX - 8 - aw
        
        if _alignment == .left {
            
            _titleLabel.textColor = .black
            _titleLabel.textAlignment = .left
            
            _animationView.image = UIImage.sac_init(named: "chat_voice_receive_icon_nor")
            _animationView.animationImages = [
                UIImage.sac_init(named: "chat_voice_receive_icon_1"),
                UIImage.sac_init(named: "chat_voice_receive_icon_2"),
                UIImage.sac_init(named: "chat_voice_receive_icon_3"),
            ].flatMap { $0 }
            
            _animationView.frame = CGRect(x: bounds.minX, y: 0, width: aw, height: 20)
            _titleLabel.frame = CGRect(x: bounds.maxX - tw, y: 0, width: tw, height: 20)
            
        } else {
            
            _titleLabel.textColor = .white
            _titleLabel.textAlignment = .right
            
            _animationView.image = UIImage.sac_init(named: "chat_voice_send_icon_nor")
            _animationView.animationImages = [
                UIImage.sac_init(named: "chat_voice_send_icon_1"),
                UIImage.sac_init(named: "chat_voice_send_icon_2"),
                UIImage.sac_init(named: "chat_voice_send_icon_3"),
            ].flatMap { $0 }
            
            _animationView.frame = CGRect(x: bounds.maxX - aw, y: 0, width: aw, height: 20)
            _titleLabel.frame = CGRect(x: bounds.minX, y: 0, width: tw, height: 20)
        }
        
    }
    
    private func _commonInit() {
        
        //_titleLabel.font = UIFont.systemFont(ofSize: 12)
        
        _animationView.animationDuration = 0.8
        _animationView.animationRepeatCount = 0
        
        addSubview(_animationView)
        addSubview(_titleLabel)
    }
    
    private lazy var _animationView: UIImageView = UIImageView()
    private lazy var _titleLabel: UILabel = UILabel()
    
    private var _alignment: SACMessageAlignment = .center
}

///// 左边
//static let leftImages: (UIImage?, [UIImage]?) = {
//    let a = NSMutableArray()
//    for n in ["simchat_audio_receive_icon_nor",
//              "simchat_audio_receive_icon_1",
//              "simchat_audio_receive_icon_2",
//              "simchat_audio_receive_icon_3"] {
//                if let img = UIImage(named: n) {
//                    a.add(img)
//                }
//    }
//    return (a[0] as? UIImage, a.subarray(with: NSMakeRange(1, a.count - 1)) as? [UIImage])
//}()
//
///// 右边
//static let rightImages: (UIImage?, [UIImage]?) = {
//    let a = NSMutableArray()
//    for n in ["simchat_audio_send_icon_nor",
//              "simchat_audio_send_icon_1",
//              "simchat_audio_send_icon_2",
//              "simchat_audio_send_icon_3"] {
//                if let img = UIImage(named: n) {
//                    a.add(img)
//                }
//    }
//    return (a[0] as? UIImage, a.subarray(with: NSMakeRange(1, a.count - 1)) as? [UIImage])
//}()
