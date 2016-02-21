//
//  SIMChatBundle.swift
//  SIMChat
//
//  Created by sagesse on 1/31/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

public class SIMChatBundle {
    // don't create
    private init() {
        let mb = NSBundle(identifier: "SA.SIMChat.Framework") ?? NSBundle.mainBundle()
        guard let path = mb.pathForResource("SIMChat", ofType: "bundle") else {
            fatalError("\"SIMChat.bundle\" no found, must add \"SIMChat.bundle\" to your project!")
        }
        guard let bundle = NSBundle(path: path) else {
            fatalError("\"SIMChat.bundle\" invalid")
        }
        _bundle = bundle
    }
    
    private var _bundle: NSBundle
    private static var _mainBundle = SIMChatBundle()
}

extension SIMChatBundle {
    /// 获取资源路径
    public static func resourcePath(resource: String) -> String? {
        guard let root = _mainBundle._bundle.resourcePath else {
            return nil
        }
        return "\(root)/\(resource)"
    }
}

extension SIMChatBundle {
    
    /// 获取图片
    public static func imageWithResource(resource: String) -> UIImage? {
        guard let path = resourcePath(resource) else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
    /// 获取data
    public static func dataWithResource(resource: String) -> NSData? {
        guard let path = resourcePath(resource) else {
            return nil
        }
        return NSData(contentsOfFile: path)
    }
}
