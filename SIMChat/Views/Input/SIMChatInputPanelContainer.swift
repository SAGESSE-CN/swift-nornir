//
//  SIMChatInputPanelContainer.swift
//  SIMChat
//
//  Created by sagesse on 2/9/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

///
/// 输入面板的容器类
///
public class SIMChatInputPanelContainer: UIView {
    
    public override func intrinsicContentSize() -> CGSize {
        super.intrinsicContentSize()
        return CGSizeMake(0, 253)
    }
    
    ///
    /// 注册面板
    ///
    public static func registerClass(cls: SIMChatInputPanelProtocol.Type, byItem item: SIMChatInputItemProtocol) {
        SIMLog.debug("\(item.itemIdentifier) => \(NSStringFromClass(cls))")
        _subpanelClasses[item.itemIdentifier] = cls
    }
    
    ///
    /// 当前显示的选项
    ///
    public var currentInputItem: SIMChatInputItemProtocol? {
        set { return _currentInputItem = newValue }
        get { return _currentInputItem }
    }
    ///
    /// 当前显示的面板
    ///
    public var currentInputPanelView: SIMChatInputPanelProtocol? {
        return _currentInputPanelView as? SIMChatInputPanelProtocol
    }
    
    ///
    /// 提供面板代理, 这个参数将会传递到每一个显示的面板
    ///
    public weak var delegate: SIMChatInputPanelDelegate?
    
    private var _currentInputItem: SIMChatInputItemProtocol? {
        didSet {
            guard oldValue !== _currentInputItem else {
                return
            }
            if let accessory = _currentInputItem {
                let panel = (_allPanels.objectForKey(accessory.itemIdentifier) as? UIView) ?? {
                    guard let cls = self.dynamicType._subpanelClasses[accessory.itemIdentifier] else {
                        fatalError("unregistered panel type \(accessory.itemIdentifier)")
                    }
                    let view = cls.inputPanel()
                    _allPanels.setObject(view, forKey: accessory.itemIdentifier)
                    return view
                }()
                _currentInputPanelView = panel
            } else {
                _currentInputPanelView = nil
            }
        }
    }
    private var _currentInputPanelView: UIView? {
        didSet {
            guard oldValue != _currentInputPanelView else {
                return
            }
            // 隐藏
            if let view = oldValue {
                view.transform = CGAffineTransformIdentity
                UIView.animateWithDuration(0.25,
                    animations: {
                        view.transform = CGAffineTransformMakeTranslation(0, self.bounds.height)
                    },
                    completion: { b in
                        guard self._currentInputPanelView != view else {
                            return
                        }
                        view.removeFromSuperview()
                    })
            }
            // 显示
            if let view = _currentInputPanelView {
                view.transform = CGAffineTransformIdentity
                view.frame = bounds
                view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                
                if let panel = view as? SIMChatInputPanelProtocol {
                    panel.delegate = delegate
                }
                
                addSubview(view)
                
                guard oldValue != nil else {
                    return
                }
                
                view.transform = CGAffineTransformMakeTranslation(0, bounds.height)
                UIView.animateWithDuration(0.25) {
                    view.transform = CGAffineTransformIdentity
                }
            }
        }
    }
    
    private lazy var _allPanels: NSCache = NSCache()
    private static var _subpanelClasses: Dictionary<String, SIMChatInputPanelProtocol.Type> = [:]
}