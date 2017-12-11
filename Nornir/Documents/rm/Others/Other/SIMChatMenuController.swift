//
//  SIMChatMenuController.swift
//  SIMChat
//
//  Created by sagesse on 1/30/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

/////
///// 抽象一个菜单, 实际上还是使用UIMenuController
/////
//public class SIMChatMenuController: NSObject {
//    public override init() {
//        super.init()
//        NotificationCenter.default.addObserver(self,
//            selector: #selector(type(of: self).onMenuWillHide(_:)),
//            name: NSNotification.Name.UIMenuControllerWillHideMenu,
//            object: nil)
//    }
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    public class func sharedMenuController() -> SIMChatMenuController {
//        return _sharedMenuController
//    }
//    
//    private weak var target: UIResponder?
//    private static var _sharedMenuController: SIMChatMenuController = SIMChatMenuController()
//}
//
//// MARK: - Forward to UIMenuController
//
//extension SIMChatMenuController {
//    public var menuItems: [UIMenuItem]? {
//        set { return UIMenuController.shared.menuItems = newValue }
//        get { return UIMenuController.shared.menuItems }
//    }
//}
//
//// MARK: - Public Method 
//extension SIMChatMenuController {
//    /// 显示的是否为自定义菜单
//    public func isCustomMenu() -> Bool {
//        return target != nil
//    }
//    /// 显示菜单
//    public func showMenu(_ target: UIResponder, withRect targetRect: CGRect, inView targetView: UIView, animated: Bool = true) {
//        self.target = target
//        UIMenuController.shared.setTargetRect(targetRect, in: targetView)
//        UIMenuController.shared.setMenuVisible(true, animated: animated)
//    }
//    /// 隐藏菜单
//    public func hideMenu(_ animated: Bool = true) {
//        UIMenuController.shared.setMenuVisible(false, animated: animated)
//    }
//}
//
//// MARK: - Event
//
//extension SIMChatMenuController {
//    /// 检查方法是否可用
//    public func canPerformAction(_ action: Selector, withSender sender: AnyObject?) -> Bool {
//        return target?.canPerformAction(action, withSender: sender) ?? false
//    }
//    /// 转发方法
//    public override func forwardingTarget(for aSelector: Selector) -> AnyObject? {
//        return target
//    }
//    /// 菜单隐藏.
//    private dynamic func onMenuWillHide(_ sender: Notification) {
//        // 隐藏的时候必须把target清空
//        target = nil
//    }
//}
//
