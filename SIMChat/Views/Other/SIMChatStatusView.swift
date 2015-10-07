//
//  SIMChatStatusView.swift
//  SIMChat
//
//  Created by sagesse on 9/26/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 消息状态显示
///
class SIMChatStatusView: SIMControl {
    /// 最小
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(20, 20)
    }
    /// 当前状态
    var status = SIMChatStatus.None {
        willSet {
            if newValue != status {
                var nv: UIView?
                // 每重情况都有不同的视图
                switch newValue {
                case .Waiting:
                    let av = showView as? UIActivityIndicatorView ?? UIActivityIndicatorView(activityIndicatorStyle: .Gray)
                    av.hidesWhenStopped = true
                    nv = av
                case .Failed:
                    let btn = showView as? UIButton ?? UIButton()
                    btn.setImage(SIMChatImageManager.messageFail, forState: .Normal)
                    btn.addTarget(self, action: "onRetry:", forControlEvents: .TouchUpInside)
                    nv = btn
                default:
                    break
                }
                if nv != showView {
                    showView?.removeFromSuperview()
                    if let nv = nv {
                        nv.frame = bounds
                        nv.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                        addSubview(nv)
                    }
                    showView = nv
                }
            }
            // 如果是停止状态, 恢复状态
            if let av = showView as? UIActivityIndicatorView where !av.isAnimating() {
                av.startAnimating()
            }
        }
    }
    
    private var showView: UIView?
}

// MARK: - Event
extension SIMChatStatusView {
    /// 重试
    private dynamic func onRetry(sender: AnyObject) {
        self.sendActionsForControlEvents(.TouchUpInside)
    }
}

/// 状态
enum SIMChatStatus {
    case None
    case Waiting
    case Failed
}
