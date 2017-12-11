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
        let mb = Bundle(identifier: "SA.SIMChat.Framework") ?? Bundle.main
        guard let path = mb.path(forResource: "SIMChat", ofType: "bundle") else {
            fatalError("\"SIMChat.bundle\" no found, must add \"SIMChat.bundle\" to your project!")
        }
        guard let bundle = Bundle(path: path) else {
            fatalError("\"SIMChat.bundle\" invalid")
        }
        _bundle = bundle
    }
    
    private var _bundle: Bundle
    private static var _mainBundle = SIMChatBundle()
//}
//
//extension SIMChatBundle {
    /// 获取资源路径
    public static func resourcePath(_ resource: String) -> String? {
        guard let root = _mainBundle._bundle.resourcePath else {
            return nil
        }
        return "\(root)/\(resource)"
    }
//}
//
//extension SIMChatBundle {
    
    /// 获取图片
    public static func imageWithResource(_ resource: String) -> UIImage? {
        guard let path = resourcePath(resource) else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
    /// 获取data
    public static func dataWithResource(_ resource: String) -> Data? {
        guard let path = resourcePath(resource) else {
            return nil
        }
        return (try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
}
