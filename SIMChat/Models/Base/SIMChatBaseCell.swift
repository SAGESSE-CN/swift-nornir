//
//  SIMChatBaseCell.swift
//  SIMChat
//
//  Created by sagesse on 1/17/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

///
/// 打包起来
///
public struct SIMChatBaseCell {}


// MARK: - Base

extension SIMChatBaseCell {
    ///
    /// 最基本的实现
    ///
    public class Base: UITableViewCell, SIMChatCellProtocol {
    }
    ///
    /// 包含一个气泡
    ///
    public class Bubble: UITableViewCell, SIMChatCellProtocol {
    }
}

extension SIMChatBaseCell {
    ///
    /// 文本
    ///
    public class Text: Bubble {
    }
    ///
    /// 图片
    ///
    public class Image: Bubble {
    }
    ///
    /// 音频
    ///
    public class Audio: Bubble {
    }
}

// MARK: - Util

extension SIMChatBaseCell {
    ///
    /// 提示信息
    ///
    public class Tips: Base {
    }
    ///
    /// 日期信息
    ///
    public class Date: Base {
    }
    ///
    /// 未知的信息
    ///
    public class Unknow: Base {
    }
}