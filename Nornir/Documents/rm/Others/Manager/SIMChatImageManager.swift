//
//  SIMChatImageManager.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SIMChatImageManager: NSObject {
    
    static var messageFail = UIImage(named: "simchat_message_fail")
    static var messageSurccess = UIImage(named: "simchat_message_succ")

    static var images_face_delete_nor = UIImage(named: "simchat_button_delete_nor")
    static var images_face_delete_press = UIImage(named: "simchat_button_delete_press")
    
    static var imageDownloadFail = UIImage(named: "simchat_images_fail")
    static var defaultImage = UIImage(named: "simchat_images_default")
    
    static var images_face_preview = UIImage(named: "simchat_images_emoji_preview")
    

    /// 默认聊天背景
    static var defaultBackground = UIImage(named: "simchat_background_default")
    /// 默认头像
    static var defaultPortrait1 = UIImage(named: "simchat_portrait_default1")
    static var defaultPortrait2 = UIImage(named: "simchat_portrait_default2")
    
    static var defaultBubbleRecive = UIImage(named: "simchat_bubble_recive")
    static var defaultBubbleSend = UIImage(named: "simchat_bubble_send")
    
    static var defautlInputBackground = UIImage(named: "chat_bottom_textfield")
//    static var inputItemImages: [SIMChatInputBarItemStyle : (n: UIImage?, h: UIImage?)] = [
//        .Keyboard   : (n: UIImage(named: "chat_bottom_keyboard_nor"),   h: UIImage(named: "chat_bottom_keyboard_press")),
//        .Voice      : (n: UIImage(named: "chat_bottom_voice_nor"),      h: UIImage(named: "chat_bottom_voice_press")),
//        .Face      : (n: UIImage(named: "chat_bottom_smile_nor"),      h: UIImage(named: "chat_bottom_smile_press")),
//        .Tool       : (n: UIImage(named: "chat_bottom_up_nor"),         h: UIImage(named: "chat_bottom_up_press"))
//    ]
    
}
