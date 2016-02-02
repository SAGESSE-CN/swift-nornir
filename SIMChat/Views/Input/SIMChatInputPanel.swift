//
//  SIMChatInputPanel.swift
//  SIMChat
//
//  Created by sagesse on 1/22/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

@objc public protocol SIMChatInputPanelDelegate: NSObjectProtocol {
    
    // willShow
    // didShow
    // willHide
    // didHide
//    optional func inputPanel(inputPanel: UIView, willShowForAccessory accessory: SIMChatInputAccessory)
//    optional func inputPanel(inputPanel: UIView, didShowForAccessory accessory: SIMChatInputAccessory)
//    optional func inputPanel(inputPanel: UIView, willHideForAccessory accessory: SIMChatInputAccessory)
//    optional func inputPanel(inputPanel: UIView, didHideForAccessory accessory: SIMChatInputAccessory)
    
//    optional func inputPanelDidReturn(inputPanel: UIView)
//    optional func inputPanelDidBackspace(inputPanel: UIView)
}

public class SIMChatInputPanel: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
        
        //UIScreenEdgePanGestureRecognizer
    }
    
    /// 代理.
    public weak var delegate: SIMChatInputPanelDelegate?
    
    /// 面板样式
    public var selectedItem: SIMChatInputAccessory? {
        didSet {
            guard oldValue !== selectedItem else {
                return
            }
            if let accessory = selectedItem {
                let panel = (_allPanels.objectForKey(accessory.accessoryIdentifier) as? UIView) ?? {
                    guard let cls = self.dynamicType.subpanelClasses[accessory.accessoryIdentifier] else {
                        fatalError("unregistered panel type \(accessory.accessoryIdentifier)")
                    }
                    let view = cls.init()
                    _allPanels.setObject(view, forKey: accessory.accessoryIdentifier)
                    return view
                }()
                updateInputPanel(panel)
            } else {
                updateInputPanel(nil)
            }
        }
    }
    
    private var _inputPanel: UIView?
    private var _allPanels: NSCache = NSCache()
}

// MARK: - Life Cycle

extension SIMChatInputPanel {
    public override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(0, 253)
    }
}

// MARK: - Public Method
extension SIMChatInputPanel {
    /// 注册面板
    public static func registerClass(cls: UIView.Type, byIdentifier identifier: String) {
        SIMLog.debug("\(identifier) => \(NSStringFromClass(cls))")
        subpanelClasses[identifier] = cls
    }
    
    private static var subpanelClasses: Dictionary<String, UIView.Type> = [:]
}

extension SIMChatInputPanel {
    /// 初始化
    private func build() {
        self.dynamicType.registerClass(Tool.self,  byIdentifier: "kb:tool")
        self.dynamicType.registerClass(Face.self,  byIdentifier: "kb:face")
        self.dynamicType.registerClass(Audio.self, byIdentifier: "kb:audio")
    }
    /// 更新当前有输入面板
    private func updateInputPanel(newValue: UIView?) {
        guard _inputPanel != newValue else {
            return
        }
        // 隐藏
        if let view = _inputPanel {
            view.transform = CGAffineTransformIdentity
            UIView.animateWithDuration(0.25,
                animations: {
                    view.transform = CGAffineTransformMakeTranslation(0, self.bounds.height)
                },
                completion: { b in
                    guard self._inputPanel != view else {
                        return
                    }
                    view.removeFromSuperview()
                })
        }
        _inputPanel = newValue
        // 显示
        if let view = newValue {
            
            view.transform = CGAffineTransformIdentity
            view.frame = bounds
            view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            if view.respondsToSelector("delegate") {
                view.setValue(delegate, forKey: "delegate")
            }
            
            addSubview(view)
            
            view.transform = CGAffineTransformMakeTranslation(0, bounds.height)
            UIView.animateWithDuration(0.25) {
                view.transform = CGAffineTransformIdentity
            }
        }
    }
}

