//
//  SIMChatStatusView.swift
//  SIMChat
//
//  Created by sagesse on 9/26/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

/////
///// 消息状态显示
/////
//class SIMChatStatusView: SIMControl {
//    /// 最小
//    override var intrinsicContentSize: CGSize {
//        return CGSize(width: 20, height: 20)
//    }
//    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        if CGRect(x: -10, y: -10, width: bounds.width + 20, height: bounds.height + 20).contains(point) {
//            return showView
//        }
//        return nil
//    }
//    
//    /// 当前状态
//    var status = SIMChatStatus.none {
//        willSet {
//            if newValue != status {
//                var nv: UIView?
//                // 每重情况都有不同的视图
//                switch newValue {
//                case .waiting:
//                    let av = showView as? UIActivityIndicatorView ?? UIActivityIndicatorView(activityIndicatorStyle: .gray)
//                    av.hidesWhenStopped = true
//                    nv = av
//                case .failed:
//                    let btn = showView as? UIButton ?? UIButton()
//                    btn.setImage(SIMChatImageManager.messageFail, for: UIControlState())
//                    btn.addTarget(self, action: #selector(type(of: self).onRetry(_:)), for: .touchUpInside)
//                    nv = btn
//                default:
//                    break
//                }
//                if nv != showView {
//                    showView?.removeFromSuperview()
//                    if let nv = nv {
//                        nv.frame = bounds
//                        nv.autoresizingMask = .flexibleWidth | .flexibleHeight
//                        addSubview(nv)
//                    }
//                    showView = nv
//                }
//            }
//            // 如果是停止状态, 恢复状态
//            if let av = showView as? UIActivityIndicatorView , !av.isAnimating {
//                av.startAnimating()
//            }
//        }
//    }
//    
//    private var showView: UIView?
//}
//
//// MARK: - Event
//extension SIMChatStatusView {
//    /// 重试
//    private dynamic func onRetry(_ sender: AnyObject) {
//        self.sendActions(for: .touchUpInside)
//    }
//}
//
///// 状态
//enum SIMChatStatus {
//    case none
//    case waiting
//    case failed
//}
