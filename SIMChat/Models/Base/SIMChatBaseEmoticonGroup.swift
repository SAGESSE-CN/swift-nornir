//
//  SIMChatBaseEmoticonGroup.swift
//  SIMChat
//
//  Created by sagesse on 2/10/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

///
/// 表情组
///
public class SIMChatBaseEmoticonGroup: NSObject, SIMChatEmoticonGroup {

    public var identifier: String = ""
    
    /// 组名
    public var name: String?
    /// 图标
    public var icon: UIImage? {
        guard let image = image else {
            return nil
        }
        return SIMChatBundle.imageWithResource("Emoticons/\(image)")
    }
    /// 默认组
    public dynamic var isDefault: Bool {
        return is_default
    }
    
    /// 子组
    public var groups: Array<SIMChatEmoticonGroup>?
    /// 该组表情所有的表情
    public lazy var emoticons: Array<SIMChatEmoticon> = self.loadEmoticons()
    
    internal dynamic var image: String?
    internal dynamic var is_default: Bool = false
    internal dynamic var sub_groups: NSArray? {
        didSet {
            groups = sub_groups?.flatMap {
                let g = SIMChatBaseEmoticonGroup()
                g.setValuesForKeysWithDictionary($0 as! [String : AnyObject])
                return g
            }
        }
    }
    
    /// 加载表情
    internal func loadEmoticons() -> Array<SIMChatEmoticon> {
        // 如果有子组, 直接加载子组
        if let subgroups = groups {
            var nemoticons: Array<SIMChatEmoticon> = []
            subgroups.forEach {
                nemoticons.appendContentsOf($0.emoticons)
            }
            return nemoticons
        }
        guard let path = SIMChatBundle.resourcePath("Emoticons/\(identifier)/Info.plist"),
            let emoticons = NSArray(contentsOfFile: path) as? Array<NSDictionary> else {
                return []
        }
        
        return emoticons.map {
            let em = SIMChatBaseEmoticon()
            em.setValuesForKeysWithDictionary($0 as! [String : AnyObject])
            em.group = self
            return em
        }
    }
    
    /// 加载内置表情组
    internal static func loadGroupWithBuiltIn() -> Array<SIMChatEmoticonGroup> {
        guard let path = SIMChatBundle.resourcePath("Emoticons/emoticons.plist"),
            let packages = NSArray(contentsOfFile: path) as? Array<NSDictionary> else {
                SIMLog.error("file \"SIMChat.bundle/Emoticons/emoticons.plist\" load fail!")
                return []
        }
        return packages.map {
            let group = SIMChatBaseEmoticonGroup()
            group.setValuesForKeysWithDictionary($0 as! [String : AnyObject])
            return group
        }
    }
}
