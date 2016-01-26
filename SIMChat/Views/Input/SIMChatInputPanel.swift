//
//  SIMChatInputPanel.swift
//  SIMChat
//
//  Created by sagesse on 1/22/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

public class SIMChatInputPanel: UIView {
//    /// 面板样式
//    public class Style: SIMChatInputBarAccessory {
//        @objc public var accessoryName: String? {
//            return "test"
//        }
//        @objc public var accessoryImage: UIImage? {
//            return UIImage(named: "chat_bottom_smile_nor")
//        }
//        @objc public var accessorySelecteImage: UIImage? {
//            return UIImage(named: "chat_bottom_smile_press")
//        }
//    }
//    @objc public enum Style: Int {
//        case None   = 0
//        case Emoji
//        case Tool
//        case Audio
//    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .redColor()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .redColor()
    }
    
    /// 面板样式
    public var selectedItem: SIMChatInputBarAccessory? {
        didSet {
        }
    }
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
    }
    
    private static var subpanels: Dictionary<String, UIView.Type> = [:]
}

