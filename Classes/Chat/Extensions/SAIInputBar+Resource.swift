//
//  SAInputBar+Resource.swift
//  SIMChat
//
//  Created by SAGESSE on 8/31/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import SAInput

public enum SAIInputBarType: Int {
    case `default` // wx: center
    case value1  // qq: center + bottom
    case value2  // qqzone: center + top
}

public extension SAIInputBar {
    public convenience init(type: SAIInputBarType) {
        self.init()
        
        switch type {
        case .default: _setupForDefault()
        case .value1: _setupForValue1()
        case .value2: _setupForValue2()
        }
        
        //self.translucent = false
        //self.backgroundColor = UIColor(argb: 0xFFECEDF1)
        // _lineView.backgroundColor = UIColor(argb: 0x4D000000)
    }
    
    private func _barItem(_ identifier: String, _ nName: String, _ hName: String) -> SAIInputItem {
        let item = SAIInputItem()
        
        item.identifier = identifier
        item.size = CGSize(width: 34, height: 34)
        
        let nImage = UIImage.sac_init(named: "\(nName).png")
        let hImage = UIImage.sac_init(named: "\(hName).png")
        item.setImage(nImage, for: [.normal])
        item.setImage(hImage, for: [.highlighted])
        item.setImage(hImage, for: [.selected, .normal])

        return item
    }
    
    private func _setupForDefault() {
        _logger.trace()
        
        let lbs = [
            _barItem("kb:audio", "chat_bottom_PTT_nor", "chat_bottom_PTT_press"),
        ]
        let rbs = [
            _barItem("kb:emoticon", "chat_bottom_emoticon_nor", "chat_bottom_emoticon_press"),
            _barItem("kb:toolbox", "chat_bottom_more_nor", "chat_bottom_more_press"),
        ]
        setBarItems(lbs, atPosition: .left)
        setBarItems(rbs, atPosition: .right)
    }
    private func _setupForValue1() {
        _logger.trace()
        
        let bbs = [
            _barItem("kb:audio", "chat_bottom_PTT_nor", "chat_bottom_PTT_press"),
            
            _barItem("kb:video", "chat_bottom_PTV_nor", "chat_bottom_PTV_press"),
            _barItem("kb:photo", "chat_bottom_photo_nor", "chat_bottom_photo_press"),
            _barItem("kb:camera", "chat_bottom_Camera_nor", "chat_bottom_Camera_press"),
            _barItem("page:red_pack", "chat_bottom_red_pack_nor", "chat_bottom_red_pack_press"),
            
            _barItem("kb:emoticon", "chat_bottom_emoticon_nor", "chat_bottom_emoticon_press"),
            _barItem("kb:toolbox", "chat_bottom_more_nor", "chat_bottom_more_press"),
        ]
        bbs.first?.alignment = .left
        bbs.last?.alignment = .right
        setBarItems(bbs, atPosition: .bottom)
    }
    private func _setupForValue2() {
        
    }
}
