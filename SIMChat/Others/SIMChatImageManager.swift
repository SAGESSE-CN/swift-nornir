//
//  SIMChatImageManager.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SIMChatImageManager: NSObject {


    static let deleteImageNor = UIImage(named: "simchat_button_delete_nor")
    static let deleteImagePress = UIImage(named: "simchat_button_delete_press")

    /// 默认聊天背景
    static let defaultBackground = UIImage(named: "simchat_background_default")
    /// 默认头像
    static let defaultPortrait1 = UIImage(named: "simchat_portrait_default1")
    static let defaultPortrait2 = UIImage(named: "simchat_portrait_default2")
    
    static let defautlInputBackground = UIImage(named: "chat_bottom_textfield")
    static let inputItemImages: [SIMChatTextFieldItemStyle : (n: UIImage?, h: UIImage?)] = [
        .Keyboard   : (n: UIImage(named: "chat_bottom_keyboard_nor"),   h: UIImage(named: "chat_bottom_keyboard_press")),
        .Voice      : (n: UIImage(named: "chat_bottom_voice_nor"),      h: UIImage(named: "chat_bottom_voice_press")),
        .Emoji      : (n: UIImage(named: "chat_bottom_smile_nor"),      h: UIImage(named: "chat_bottom_smile_press")),
        .Tool       : (n: UIImage(named: "chat_bottom_up_nor"),         h: UIImage(named: "chat_bottom_up_press"))
    ]
}
