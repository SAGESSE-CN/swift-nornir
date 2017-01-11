//
//  SACEmoticonGroup.swift
//  SIMChat
//
//  Created by SAGESSE on 9/14/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import SAInput

open class SACEmoticon: SAIEmoticon {
    
    public required init?(object: NSDictionary) {
        guard let id = object["id"] as? String, let title = object["title"] as? String, let type = object["type"] as? Int else {
            return nil
        }
        
        self.id = id
        self.title = title
        
        super.init()
        
        self.image = object["image"] as? String
        self.preview = object["preview"] as? String
        
        if type == 1 {
            self.contents = object["contents"]
        }
    }
    
    public static func emoticons(with objects: NSArray, at directory: String) -> [SACEmoticon] {
        return objects.flatMap {
            guard let dic = $0 as? NSDictionary else {
                return nil
            }
            guard let e = self.init(object: dic) else {
                return nil
            }
            if let name = e.preview {
                e.contents = UIImage(contentsOfFile: "\(directory)/\(name)")
            }
            return e
        }
    }
    
    var id: String
    var title: String
    
    var image: String?
    var preview: String?
}

