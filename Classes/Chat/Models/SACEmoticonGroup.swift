//
//  SACEmoticonGroup.swift
//  SAChat
//
//  Created by SAGESSE on 01/11/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import SAInput

open class SACEmoticonGroup: SAIEmoticonGroup {
    
    init?(contentsOfFile: String) {
        guard let dic = NSDictionary(contentsOfFile: contentsOfFile), let arr = dic["emoticons"] as? NSArray else {
            return nil
        }
        let directory = URL(fileURLWithPath: contentsOfFile).deletingLastPathComponent().path
        
        super.init()
        
        type = SAIEmoticonType(rawValue: dic["type"] as? Int ?? 0) ?? .small
        rows = dic["rows"] as? Int ?? 3
        columns = dic["columns"] as? Int ?? 7
        rowsInLandscape = dic["rowsInLandscape"] as? Int ?? 2
        columnsInLandscape = dic["columnsInLandscape"] as? Int ?? 13
        
        if let img = dic["image"] as? String {
            thumbnail = UIImage(contentsOfFile: "\(directory)/\(img)")
        }
        
        if type.isSmall {
            emoticons = SACEmoticon.emoticons(with: arr, at: directory)
        } else {
            emoticons = SACEmoticonLarge.emoticons(with: arr, at: directory)
        }
    }
    
    convenience init?(identifier : String) {
        let bundle = SACManager.mainBundle ?? .main
        guard let path = bundle.path(forResource: "emoticons.bundle/\(identifier)/Info", ofType: "plist") else {
            return nil
        }
        self.init(contentsOfFile: path)
    }
    
    open var rows: Int = 3
    open var columns: Int = 7
    open var rowsInLandscape: Int = 3
    open var columnsInLandscape: Int = 13
}
