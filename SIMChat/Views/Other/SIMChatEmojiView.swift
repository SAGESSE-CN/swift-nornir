//
//  SIMChatFaceView.swift
//  SIMChat
//
//  Created by sagesse on 10/5/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 表情视图
///
class SIMChatFaceView: SIMView {
    /// 最合适的大小
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(36, 36)
    }
    /// 表情
    var face: String? {
        willSet {
            // 相同. 没什么好说的
            guard face != newValue else {
                return
            }
            // \u{7F}      Delete         UIButton
            // \u{XX}      Face          UILabel
            // {TYPE:NAME} Custom Face    UIImageView
            if let em = newValue {
                // 新的视图
                var view: UIView?
                if em == "\u{7F}" {
                    // 这是删除
                    let btn = showView as? UIButton ?? UIButton()
                    // :)
                    btn.frame = bounds
                    btn.setImage(SIMChatImageManager.images_face_delete_nor, forState: .Normal)
                    btn.setImage(SIMChatImageManager.images_face_delete_press, forState: .Highlighted)
                    btn.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                    // ok
                    view = btn
                } else if em.hasPrefix("{") && em.hasSuffix("}") {
                    // 这是自定义表情
                    let iv = showView as? UIImageView ?? UIImageView()
                    // config
                    iv.frame = bounds
                    // ok
                    view = iv
                } else {
                    // 这是系统表情
                    let lb = showView as? UILabel ?? UILabel()
                    // config
                    lb.frame = bounds
                    lb.text = em
                    lb.font = UIFont.systemFontOfSize(28)
                    lb.textAlignment = .Center
                    lb.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                    // ok
                    view = lb
                }
                // 替换(不同的情况下)
                if showView != view {
                    showView?.removeFromSuperview()
                    showView = view
                    addSubview(showView!)
                }
            } else {
                showView?.removeFromSuperview()
                showView = nil
            }
        }
    }
    /// 当前类型
    var showView: UIView?
}
