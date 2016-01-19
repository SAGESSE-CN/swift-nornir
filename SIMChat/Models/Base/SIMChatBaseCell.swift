//
//  SIMChatBaseCell.swift
//  SIMChat
//
//  Created by sagesse on 1/17/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

///
/// 打包起来
///
public struct SIMChatBaseCell {}


// MARK: - Base

extension SIMChatBaseCell {
    ///
    /// 最基本的实现
    ///
    public class Base: UITableViewCell, SIMChatCellProtocol {
        public var message: SIMChatMessageProtocol?
        public var conversation: SIMChatConversationProtocol?
    }
    ///
    /// 包含一个气泡
    ///
    public class Bubble: UITableViewCell, SIMChatCellProtocol {
        public enum Style {
            case Unknow
            case Left
            case Right
        }
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            // TODO: 有性能问题, 需要重新实现
        
            let vs = ["p" : portraitView,
                "c" : visitCardView,
                "s" : stateView,
                "b" : bubbleView]
            
            let ms = ["s0" : 50,
                "s1" : 16,
                
                "mh0" : 7,
                "mh1" : 0,
                "mh2" : 57,
                
                "mv0" : 8,
                "mv1" : 13,
                
                "ph0" : hPriority,
                "ph1" : hPriority - 1,
                "ph2" : hPriority - 2,
                
                "pv0" : vPriority,
                "pv1" : vPriority - 1]
            
            let addConstraints = contentView.addConstraints
            
            /// config
            stateView.translatesAutoresizingMaskIntoConstraints = false
            bubbleView.translatesAutoresizingMaskIntoConstraints = false
            portraitView.translatesAutoresizingMaskIntoConstraints = false
            visitCardView.translatesAutoresizingMaskIntoConstraints = false
            
            // add views
            contentView.addSubview(visitCardView)
            contentView.addSubview(portraitView)
            contentView.addSubview(bubbleView)
            contentView.addSubview(stateView)
            
            // add constraints
            
            addConstraints(NSLayoutConstraintMake("H:[p]-mh1@ph0-[b]-mh1@ph1-[p]", views: vs, metrics: ms))
            addConstraints(NSLayoutConstraintMake("H:[p]-mh1@ph0-[c]-mh1@ph1-[p]", views: vs, metrics: ms))
            addConstraints(NSLayoutConstraintMake("H:|-==mh0@ph0-[p(s0)]-mh0@ph2-|", views: vs, metrics: ms))
            addConstraints(NSLayoutConstraintMake("H:|->=mh2-[b]->=mh2-|", views: vs, metrics: ms))
            addConstraints(NSLayoutConstraintMake("H:|->=mh2-[c]->=mh2-|", views: vs, metrics: ms))
            addConstraints(NSLayoutConstraintMake("V:|-(==mv0)-[p(s0)]-(>=0@850)-|", views: vs, metrics: ms))
            addConstraints(NSLayoutConstraintMake("V:|-(==mv1)-[c(s1)]-(==2@pv1)-[b]|", views: vs, metrics: ms))
            addConstraints(NSLayoutConstraintMake("V:|-(mv0@pv0)-[b(>=p)]", views: vs, metrics: ms))
            addConstraints(NSLayoutConstraintMake("V:|-(mv0@pv0)-[b(>=p)]", views: vs, metrics: ms))
            addConstraints(NSLayoutConstraintMake("H:[b]-(4@ph0)-[s]-(4@ph1)-[b]", views: vs, metrics: ms))
            addConstraints(NSLayoutConstraintMake("V:[s]-(mv0)-|", views: vs, metrics: ms))
            
            // get constraints
            contentView.constraints.forEach {
                if $0.priority == self.hPriority {
                    leftConstraints.append($0)
                } else if $0.priority == self.vPriority {
                    topConstraints.append($0)
                }
            }
            
            // add kvos
            addObserver(self, forKeyPath: "visitCardView.hidden", options: .New, context: nil)
        }
        /// 销毁
        deinit {
            removeObserver(self, forKeyPath: "visitCardView.hidden")
        }
        /// kvo
        public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            if keyPath ==  "visitCardView.hidden" {
                // 直接更新
                topConstraints.forEach {
                    $0.priority = self.visitCardView.hidden ? self.vPriority : 1
                }
                // 需要更新约束
                setNeedsLayout()
            }
        }
        /// 关联的内容
        public var message: SIMChatMessageProtocol? {
            didSet {
                guard let m = message else {
                    return
                }
                // 气泡方向
                style = m.isSelf ? .Right : .Left
                // 关于头像
                portraitView.user = m.sender
                visitCardView.user = m.sender
                // 关于名片显示
                if m.option.contains(.ContactShow) {
                    // 强制显示
                    visitCardView.hidden = false
                } else if m.option.contains(.ContactHidden) {
                    // 强制隐藏
                    visitCardView.hidden = true
                } else {
                    // 自动选择
                    if m.isSelf || m.receiver.type == .User {
                        visitCardView.hidden = true
                    } else {
                        visitCardView.hidden = false
                    }
                }
            }
        }
        /// 更新类型.
        public private(set) var style: Style = .Unknow {
            willSet {
                // 没有改变
                guard newValue != style else {
                    return
                }
                // 检查
                switch newValue {
                case .Left:     bubbleView.backgroundImage = SIMChatImageManager.defaultBubbleRecive
                case .Right:    bubbleView.backgroundImage = SIMChatImageManager.defaultBubbleSend
                case .Unknow:   break
                }
                // 修改约束
                leftConstraints.forEach {
                    $0.priority = newValue == .Left ? self.hPriority : 1
                }
                // 需要更新布局
                setNeedsLayout()
            }
        }
        
        /// 自动调整
        private let hPriority = UILayoutPriority(700)
        private let vPriority = UILayoutPriority(800)
        
        private lazy var topConstraints = [NSLayoutConstraint]()
        private lazy var leftConstraints = [NSLayoutConstraint]()
    
        private(set) lazy var stateView = SIMChatStatusView(frame: CGRectZero)
        private(set) lazy var bubbleView = SIMChatBubbleView(frame: CGRectZero)
        private(set) lazy var portraitView = SIMChatPortraitView(frame: CGRectZero)
        private(set) lazy var visitCardView = SIMChatVisitCardView(frame: CGRectZero)
        
        public var conversation: SIMChatConversationProtocol?
    }
}

extension SIMChatBaseCell {
    ///
    /// 文本
    ///
    public class Text: Bubble {
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            // config views
            contentLabel.font = UIFont.systemFontOfSize(16)
            contentLabel.numberOfLines = 0
            contentLabel.textColor = UIColor.blackColor()
            // add views
            bubbleView.contentView.addSubview(contentLabel)
            // add constraints
            SIMChatLayout.make(contentLabel)
                .top.equ(bubbleView.contentView).top(8)
                .left.equ(bubbleView.contentView).left(8)
                .right.equ(bubbleView.contentView).right(8)
                .bottom.equ(bubbleView.contentView).bottom(8)
                .submit()
        }
        /// 显示类型
        public override var style: Style {
            didSet {
                switch style {
                case .Left:  contentLabel.textColor = UIColor.blackColor()
                case .Right: contentLabel.textColor = UIColor.whiteColor()
                case .Unknow: break
                }
            }
        }
        /// 消息内容
        public override var message: SIMChatMessageProtocol? {
            didSet {
                if let content = message?.content as? SIMChatBaseContent.Text {
                    self.contentLabel.text = content.content
                }
            }
        }
        private(set) lazy var contentLabel = SIMChatLabel(frame: CGRectZero)
    }
    ///
    /// 图片
    ///
    public class Image: Bubble {
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            // config
            previewImageView.clipsToBounds = true
            previewImageView.contentMode = .ScaleAspectFill
            previewImageView.translatesAutoresizingMaskIntoConstraints = false
            
            // add views
            bubbleView.contentView.addSubview(previewImageView)
            
            previewImageViewLayout = SIMChatLayout.make(previewImageView)
                .top.equ(bubbleView.contentView).top
                .left.equ(bubbleView.contentView).left
                .right.equ(bubbleView.contentView).right
                .bottom.equ(bubbleView.contentView).bottom
                .width.equ(0).priority(751)
                .height.equ(0).priority(751)
                .submit()
        }
        /// 消息内容
        public override var message: SIMChatMessageProtocol? {
            didSet {
                if let content = message?.content as? SIMChatBaseContent.Image {
                    let width = max(content.size.width, 32)
                    let height = max(content.size.height, 1)
                    let scale = min(min(135, width) / width, min(135, height) / height)
                    
                    previewImageViewLayout?.width = width * scale
                    previewImageViewLayout?.height = height * scale
                    
                    setNeedsLayout()
                    
                    if superview != nil {
                        previewImageView.image = content.image
                    }
                }
            }
        }
        
        private(set) var previewImageViewLayout: SIMChatLayout?
        private(set) lazy var previewImageView = UIImageView()
    }
    ///
    /// 音频
    ///
    public class Audio: Bubble {
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            let vs = ["c": titleLabel,
                "i": animationView]
            
            let ms = ["s0": 20,
                "m0": 0,
                "hp0": hPriority2,
                "hp1": hPriority2 - 1]
            
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
            addConstraints(NSLayoutConstraintMake("H:[i(s0)]", views: vs, metrics: ms))
            addConstraints(NSLayoutConstraintMake("V:[i(s0)]", views: vs, metrics: ms))
            
            // get constraints
            for c in bubbleView.contentView.constraints {
                if c.priority == hPriority2 {
                    leftConstraints2.append(c)
                }
            }
        }
        /// 显示类型
        public override var style: Style {
            didSet {
                // 没有改变
                guard oldValue != style else {
                    return
                }
                // 检查
                switch style {
                case .Left:
                    
                    animationView.animationDuration = 1
                    titleLabel.textColor = UIColor.blackColor()
                    (animationView.image, animationView.animationImages) = self.dynamicType.leftImages
                    
                case .Right:
                    
                    titleLabel.textColor = UIColor.whiteColor()
                    animationView.stopAnimating()
                    animationView.animationDuration = 1
                    (animationView.image, animationView.animationImages) = self.dynamicType.rightImages
                    
                case .Unknow:
                    break
                }
                
                for c in leftConstraints {
                    c.priority = style == .Left ? hPriority : 1
                }
                
                setNeedsLayout()
            }
        }
    /// 消息内容
        public override var message: SIMChatMessageProtocol? {
            didSet {
                if let _ = message?.content as? SIMChatBaseContent.Audio {
                    titleLabel.text = "99'99''"
                    //            // 播放中.
                    //            if content.playing {
                    //                animationView.startAnimating()
                    //            }
                }
            }
        }
        
        private let hPriority2 = UILayoutPriority(750)
        private lazy var leftConstraints2 = [NSLayoutConstraint]()
        
        private lazy var titleLabel = UILabel()
        private lazy var animationView = UIImageView()
    }
}

// MARK: - Util

extension SIMChatBaseCell {
    ///
    /// 提示信息
    ///
    public class Tips: Base {
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            // config
            titleLabel.numberOfLines = 0
            titleLabel.font = UIFont.systemFontOfSize(11)
            titleLabel.textColor = UIColor(hex: 0x7B7B7B)
            titleLabel.textAlignment = NSTextAlignment.Center
            // add views
            contentView.addSubview(titleLabel)
            // add constraints
            SIMChatLayout.make(titleLabel)
                .top.equ(contentView).top(16)
                .left.equ(contentView).left(8)
                .right.equ(contentView).right(8)
                .bottom.equ(contentView).bottom(8)
                .submit()
        }
        /// 关联的消息
        public override var message: SIMChatMessageProtocol? {
            didSet {
                if let content = message?.content as? SIMChatBaseContent.Tips {
                    titleLabel.text = content.content
                }
            }
        }
        private lazy var titleLabel = UILabel()
    }
    ///
    /// 日期信息
    ///
    public class Date: Base {
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            // config
            titleLabel.text = ""
            titleLabel.numberOfLines = 0
            titleLabel.font = UIFont.systemFontOfSize(11)
            titleLabel.textColor = UIColor(hex: 0x7B7B7B)
            titleLabel.textAlignment = NSTextAlignment.Center
            // add views
            contentView.addSubview(titleLabel)
            // add constraints
            SIMChatLayout.make(titleLabel)
                .top.equ(contentView).top(16)
                .left.equ(contentView).left(8)
                .right.equ(contentView).right(8)
                .bottom.equ(contentView).bottom(8)
                .submit()
        }
        /// 关联的消息
        public override var message: SIMChatMessageProtocol? {
            didSet {
                if let content = message?.content as? SIMChatBaseContent.Date {
                    titleLabel.text = "\(content.content)"
                }
            }
        }
        private lazy var titleLabel = UILabel()
    }
    ///
    /// 未知的信息
    ///
    public class Unknow: Base {
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            // config
            titleLabel.text = "未知的消息类型"
            titleLabel.numberOfLines = 0
            titleLabel.font = UIFont.systemFontOfSize(11)
            titleLabel.textColor = UIColor(hex: 0x7B7B7B)
            titleLabel.textAlignment = NSTextAlignment.Center
            // add views
            contentView.addSubview(titleLabel)
            // add constraints
            SIMChatLayout.make(titleLabel)
                .top.equ(contentView).top(16)
                .left.equ(contentView).left(8)
                .right.equ(contentView).right(8)
                .bottom.equ(contentView).bottom(8)
                .submit()
        }
        private lazy var titleLabel = UILabel()
    }
}




// MARK: - Resources
extension SIMChatBaseCell.Audio {

    /// 左边
    static let leftImages: (UIImage?, [UIImage]?) = {
        let a = NSMutableArray()
        for n in ["simchat_audio_receive_icon_nor",
                  "simchat_audio_receive_icon_1",
                  "simchat_audio_receive_icon_2",
                  "simchat_audio_receive_icon_3"] {
            if let img = UIImage(named: n) {
                a.addObject(img)
            }
        }
        return (a[0] as? UIImage, a.subarrayWithRange(NSMakeRange(1, a.count - 1)) as? [UIImage])
    }()
    
    /// 右边
    static let rightImages: (UIImage?, [UIImage]?) = {
        let a = NSMutableArray()
        for n in ["simchat_audio_send_icon_nor",
                  "simchat_audio_send_icon_1",
                  "simchat_audio_send_icon_2",
                  "simchat_audio_send_icon_3"] {
            if let img = UIImage(named: n) {
                a.addObject(img)
            }
        }
        return (a[0] as? UIImage, a.subarrayWithRange(NSMakeRange(1, a.count - 1)) as? [UIImage])
    }()
}