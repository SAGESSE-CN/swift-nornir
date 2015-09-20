//
//  SIMChatInputView.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

//
// +---+------+---++---+
// | Y |      | @ || + |
// +---+------+---++---+
//                  

///
/// 聊天输入栏
/// - TODO: 未考虑扩展问题
///
class SIMChatTextField : SIMView {

    
//    let tool = UIButton()
//    let input = SFTextView()
//    let voice = UIButton()
//    let emoji = UIButton()
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(0, 44)
    }
   
}
