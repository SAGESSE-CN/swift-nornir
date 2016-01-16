//
//  SIMChatMessageCell+Text.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/////
///// 消息单元格-纯文本
/////
//class SIMChatMessageCellText: SIMChatMessageCellBubble {
//    /// 构建ui
//    override func build() {
//        super.build()
//    
//        let vs = ["c" : contentLabel]
//        
//        // config views
//        contentLabel.font = UIFont.systemFontOfSize(16)
//        contentLabel.numberOfLines = 0
//        contentLabel.textColor = UIColor.blackColor()
//        contentLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        // add views
//        bubbleView.contentView.addSubview(contentLabel)
//        
//        // add constraints
//        contentView.addConstraints(NSLayoutConstraintMake("H:|-(8)-[c]-(8)-|", views: vs))
//        contentView.addConstraints(NSLayoutConstraintMake("V:|-(8)-[c]-(8)-|", views: vs))
//        
//        // add kvos
//        SIMChatNotificationCenter.addObserver(self, selector: "onTextAttachmentChanged:", name: SIMChatTextAttachmentChangedNotification)
//    }
//    ///
//    /// 计算高度, 在计算之前需要设置好约束
//    ///
//    /// :returns: 合适的大小
//    ///
//    override func systemLayoutSizeFittingSize(targetSize: CGSize) -> CGSize {
//        // 额外的配置
//        self.contentLabel.preferredMaxLayoutWidth = 0
//        self.layoutIfNeeded()
//        self.contentLabel.preferredMaxLayoutWidth = contentLabel.bounds.width
//        // 继续计算
//        return super.systemLayoutSizeFittingSize(targetSize)
//    }
//    /// 检查是否使用.
//    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
//        // 允许复制
//        if action == "chatCellCopy:" {
//            return true
//        }
//        return super.canPerformAction(action, withSender: sender)
//    }
//    
//    /// 显示类型
//    override var style: SIMChatMessageCellStyle  {
//        willSet {
//            // 没有改变
//            guard newValue != style else {
//                return
//            }
//            switch newValue {
//            case .Left:  contentLabel.textColor = UIColor.blackColor()
//            case .Right: contentLabel.textColor = UIColor.whiteColor()
//            case .Unknow:
//                break
//            }
//        }
//    }
//    /// 消息内容
//    override var message: SIMChatMessageProtocol? {
//        didSet {
//            // 检查
//            guard let content = message?.content as? SIMChatMessageContentText else {
//                return
//            }
//            // 更新文本
//            self.contentLabel.text = content.text
//            self.contentLabel.preferredMaxLayoutWidth = 0
////            if self.contentLabel.attributedText?.hashValue != content.attributedText?.hashValue {
////                self.contentLabel.attributedText = content.attributedText
////                self.contentLabel.preferredMaxLayoutWidth = 0
////                //self.makeEmojiViews()
////            }
//        }
//    }
//    
//    private(set) lazy var emojiViews = [Int : SIMChatEmojiView]()
//    private(set) lazy var contentLabel = SIMChatLabel(frame: CGRectZero)
//}
//
//// MARK: - Emoji 
//extension SIMChatMessageCellText {
//    /// 生成表情视图
//    private func makeEmojiViews() {
//        // 检查参数
//        guard let text = self.contentLabel.attributedText where self.enabled  else {
//            // 清除
//            self.emojiViews.forEach {
//                $0.1.removeFromSuperview()
//            }
//            self.emojiViews.removeAll()
//            // ok
//            return
//        }
//        SIMLog.trace()
//        // 先保存一份
//        var tmp = self.emojiViews.values.reverse()
//        // clean
//        self.emojiViews.removeAll()
//        // :)
//        text.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, text.length), options: .LongestEffectiveRangeNotRequired) {
//            at, r, s in
//            // 检查类型
//            guard let at = at as? SIMChatEmojiAttachment else {
//                return
//            }
//            let v = tmp.first ?? SIMChatEmojiView()
//            // 清除
//            if !tmp.isEmpty {
//                tmp.removeFirst()
//            }
//            // config
//            v.emoji = at.emoji
//            v.backgroundColor = UIColor.orangeColor()
//            v.hidden = true
//            // :)
//            self.emojiViews[r.location] = v
//        }
//        // 删除
//        tmp.forEach {
//            $0.removeFromSuperview()
//        }
//        // 添加
//        self.emojiViews.forEach {
//            self.contentLabel.addSubview($0.1)
//        }
//    }
//}
//
//
//// MARK: - Event
//extension SIMChatMessageCellText {
//    /// 文本附加信息改变.
//    private dynamic func onTextAttachmentChanged(sender: NSNotification) {
//        // 检查参数
//        guard let at = sender.object as? SIMChatEmojiAttachment where self.enabled else {
//            return
//        }
//        guard let text = self.contentLabel.attributedText where text.length != 0 else {
//            return
//        }
//        guard let index = sender.userInfo?[SIMChatTextAttachmentCharIndexUserInfoKey] as? Int else {
//            return
//        }
//        guard let frame = sender.userInfo?[SIMChatTextAttachmentFrameUserInfoKey]?.CGRectValue else {
//            return
//        }
//        guard text.attribute(NSAttachmentAttributeName, atIndex: index, effectiveRange: nil) === at else {
//            return
//        }
//     
//        // 调整emoji的内容
//        if let v = self.emojiViews[index] {
//            v.frame = CGRectMake(frame.origin.x, frame.origin.y - frame.size.height, frame.size.width, frame.size.height)
//            v.hidden = false
//        }
//        
//        SIMLog.debug(at)
//    }
//    /// 复制
//    dynamic func chatCellCopy(sender: AnyObject) {
//        SIMLog.trace()
//        if let ctx = message?.content as? SIMChatMessageContentText {
//            // 复制进去:)
//            UIPasteboard.generalPasteboard().string = ctx.text
//            // 完成
//            self.delegate?.chatCellDidCopy?(self)
//        }
//    }
//}
//