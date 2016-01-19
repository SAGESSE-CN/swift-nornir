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
        public var message: SIMChatMessageProtocol?
        public var conversation: SIMChatConversationProtocol?
    }
}

extension SIMChatBaseCell {
    ///
    /// 文本
    ///
    public class Text: Bubble {
    }
    ///
    /// 图片
    ///
    public class Image: Bubble {
    }
    ///
    /// 音频
    ///
    public class Audio: Bubble {
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

