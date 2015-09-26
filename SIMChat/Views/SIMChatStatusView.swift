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
    /// 构建
    override func build() {
        super.build()
        
        // config
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setImage(SIMChatImageManager.messageFail, forState: .Normal)
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        
        // add views
        addSubview(retryButton)
        addSubview(activityIndicatorView)
        
        // add constraints
        addConstraint(NSLayoutConstraintMake(activityIndicatorView, .CenterX, .Equal, self, .CenterX))
        addConstraint(NSLayoutConstraintMake(activityIndicatorView, .CenterY, .Equal, self, .CenterY))
        
        addConstraint(NSLayoutConstraintMake(retryButton, .CenterX, .Equal, self, .CenterX))
        addConstraint(NSLayoutConstraintMake(retryButton, .CenterY, .Equal, self, .CenterY))
        
        // add event
        retryButton.addTarget(self, action: "onRetry:", forControlEvents: .TouchUpInside)
        
        // :)
        self.status = .Failed
    }
    /// 最小
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(20, 20)
    }
    /// 当前状态
    var status = SIMChatStatus.None {
        willSet {
            switch newValue {
            case .None:
                self.retryButton.hidden = true
                self.activityIndicatorView.hidden = true
                self.activityIndicatorView.stopAnimating()
            case .Waiting:
                self.retryButton.hidden = true
                self.activityIndicatorView.hidden = false
                self.activityIndicatorView.startAnimating()
            case .Failed:
                self.retryButton.hidden = false
                self.activityIndicatorView.hidden = true
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
   
    private lazy var retryButton = UIButton()
    private lazy var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
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
