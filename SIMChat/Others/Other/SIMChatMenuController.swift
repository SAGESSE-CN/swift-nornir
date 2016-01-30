//
//  SIMChatMenuController.swift
//  SIMChat
//
//  Created by sagesse on 1/30/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit


public class SIMChatMenuController: NSObject {
    public override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "onMenuWillHide:",
            name: UIMenuControllerWillHideMenuNotification,
            object: nil)
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public class func sharedMenuController() -> SIMChatMenuController {
        return _sharedMenuController
    }
    
    private weak var target: UIResponder?
    private static var _sharedMenuController: SIMChatMenuController = SIMChatMenuController()
}

// MARK: - Forward to UIMenuController

extension SIMChatMenuController {
    public var menuItems: [UIMenuItem]? {
        set { return UIMenuController.sharedMenuController().menuItems = newValue }
        get { return UIMenuController.sharedMenuController().menuItems }
    }
}

// MARK: - Public Method 
extension SIMChatMenuController {
    /// 自定义菜单
    public func isCustomMenu() -> Bool {
        return target != nil
    }
    /// 显示菜单
    public func showMenu(target: UIResponder, withRect targetRect: CGRect, inView targetView: UIView, animated: Bool = true) {
        self.target = target
        UIMenuController.sharedMenuController().setTargetRect(targetRect, inView: targetView)
        UIMenuController.sharedMenuController().setMenuVisible(true, animated: animated)
    }
    /// 隐藏菜单
    public func hideMenu(animated: Bool = true) {
        UIMenuController.sharedMenuController().setMenuVisible(false, animated: animated)
    }
}

// MARK: - Event

extension SIMChatMenuController {
    /// 检查方法是否可用
    public func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return target?.canPerformAction(action, withSender: sender) ?? false
    }
    /// 转发方法
    public override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        return target
    }
    /// 菜单隐藏.
    private dynamic func onMenuWillHide(sender: NSNotification) {
        // 隐藏的时候必须把target清空
        target = nil
    }
}

