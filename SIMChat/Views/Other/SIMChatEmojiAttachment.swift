//
//  SIMChatTextAttachment.swift
//  SIMChat
//
//  Created by sagesse on 10/6/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/// 附件:)
class SIMChatFaceAttachment: NSTextAttachment {
    /// 初始化
    init(face: String, attributedText: NSAttributedString) {
        self.face = face
        super.init(data: nil, ofType: nil)
    }
    /// 初始化
    required init?(coder aDecoder: NSCoder) {
        self.face = "<Unknow>"
        super.init(coder: aDecoder)
    }
    /// 请求图片
    override func imageForBounds(imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        textContainer?.heightTracksTextView = true
        // 附加信息
        let info = [SIMChatTextAttachmentFrameUserInfoKey : NSValue(CGRect: imageBounds),
                    SIMChatTextAttachmentCharIndexUserInfoKey : charIndex]
        // 投送:)
        SIMChatNotificationCenter.postNotificationName(SIMChatTextAttachmentChangedNotification, object: self, userInfo: info)
        // 不要显示东西
        return nil
    }
    /// 请求大小
    override func attachmentBoundsForTextContainer(textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        // ok
        return CGRectMake(0, -lineFrag.height, 28, 28)
    }
    /// 表情
    var face: String
}


/// 内容改变
let SIMChatTextAttachmentChangedNotification = "SIMChatLabelAttachmentChangedNotification"

/// 附加信息
let SIMChatTextAttachmentFrameUserInfoKey = "SIMChatLabelAttachmentFrameUserInfoKey"
let SIMChatTextAttachmentCharIndexUserInfoKey = "SIMChatTextAttachmentCharIndexUserInfoKey"
