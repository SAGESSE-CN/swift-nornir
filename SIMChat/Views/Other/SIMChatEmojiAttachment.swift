//
//  SIMChatTextAttachment.swift
//  SIMChat
//
//  Created by sagesse on 10/6/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 附件:)
class SIMChatEmojiAttachment: NSTextAttachment {
    /// 请求图片
    override func imageForBounds(imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        SIMLog.debug("index: \(charIndex), ib: \(imageBounds), tc: \(textContainer)")
        // 把image转为view
        delegate?.textAttachment?(self, viewForEmoji: emoji, bounds: imageBounds, characterIndex: charIndex)
        // 不要显示东西
        return nil
    }
    /// 请求大小
    override func attachmentBoundsForTextContainer(textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        SIMLog.debug("index: \(charIndex)")//, lf: \(lineFrag) gp: \(position), tc: \(textContainer)")
        // ok
        return delegate?.textAttachment?(self, boundsForEmoji: emoji, characterIndex: charIndex) ?? CGRectMake(0, 0, 40, 40)
    }
    // 表情
    lazy var emoji: String = ""
    /// 代理
    weak var delegate: SIMChatEmojiAttachmentDelegate?
}

// MARK: - Delegate
@objc protocol SIMChatEmojiAttachmentDelegate : NSObjectProtocol {
    optional func textAttachment(textAttachment: SIMChatEmojiAttachment, viewForEmoji emoji: String, bounds: CGRect, characterIndex charIndex: Int)
    optional func textAttachment(textAttachment: SIMChatEmojiAttachment, boundsForEmoji emoji: String, characterIndex charIndex: Int) -> CGRect
}
