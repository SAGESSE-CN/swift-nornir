//
//  SIMChatInputPanel.swift
//  SIMChat
//
//  Created by sagesse on 1/22/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

public class SIMChatInputPanel: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
    }
    
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
        return CGSizeMake(0, 216)
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
        self.dynamicType.registerClass(Emoji.self, byIdentifier: "kb:emoji")
        self.dynamicType.registerClass(Audio.self, byIdentifier: "kb:audio")
    }
    /// 更新当前有输入面板
    private func updateInputPanel(newValue: UIView?) {
        guard _inputPanel != newValue else {
            return
        }
        // 隐藏
        if let view = _inputPanel {
            UIView.animateWithDuration(0.25,
                animations: {
                    view.transform = CGAffineTransformMakeTranslation(0, self.bounds.height)
                },
                completion: { b in
                    view.transform = CGAffineTransformIdentity
                    view.removeFromSuperview()
                })
        }
        _inputPanel = newValue
        // 显示
        if let view = newValue {
            
            view.frame = bounds
            view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            addSubview(view)
            
            view.transform = CGAffineTransformMakeTranslation(0, bounds.height)
            UIView.animateWithDuration(0.25) {
                view.transform = CGAffineTransformIdentity
            }
        }
    }
}
