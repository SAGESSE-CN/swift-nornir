//
//  SIMChatBaseEmoticon.swift
//  SIMChat
//
//  Created by sagesse on 2/10/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

///
/// 基础表情信息
///
public class SIMChatBaseEmoticon: NSObject, SIMChatEmoticon {
    
    public var name: String?
    
    public var image: String?
    public var image_gif: String?
    
    public var code: String = ""
    public var code_utf8: String?
    public var code_utf16: String?
    public var code_unicode: String?
    public var code_subunicode: String?
    
    public var type: Int = 0
    
    public weak var group: SIMChatEmoticonGroup?
    
    /// 关联的静态图
    public var png: UIImage? {
        guard let image = image, identifier = group?.identifier where !image.isEmpty else {
            return nil
        }
        return SIMChatBundle.imageWithResource("Emoticons/\(identifier)/\(image)")
    }
    /// 关联的动态图
    public var gif: UIImage? {
        guard let image = image_gif, identifier = group?.identifier where !image.isEmpty else {
            return nil
        }
        return SIMChatBundle.imageWithResource("Emoticons/\(identifier)/\(image)")
    }

//    public func toDictionary() -> Dictionary<String, AnyObject> {
//        let keys = self.dynamicType._keys ?? {
//            var keys: Array<String> = []
//            for v in Mirror(reflecting: self).children {
//                guard let name = v.label else {
//                    continue
//                }
//                if name == "group" {
//                    continue
//                }
//                keys.append(name)
//            }
//            self.dynamicType._keys = keys
//            return keys
//        }()
//        var dic: Dictionary<String, AnyObject> = [:]
//        keys.forEach {
//            guard let value = valueForKey($0) else {
//                return
//            }
//            dic[$0] = value
//        }
//        return dic
//    }
//    
//    private static var _keys: Array<String>?
}

