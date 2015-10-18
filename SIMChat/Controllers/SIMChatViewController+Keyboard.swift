//
//  SIMChatViewController+Keyboard.swift
//  SIMChat
//
//  Created by sagesse on 9/26/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - Keyboard
extension SIMChatViewController {
    /// 更新键盘(类型)
    func updateKeyboard(style style: SIMChatTextFieldItemStyle) {
        SIMLog.trace()
        let newValue = self.makeKeyboard(style)
        // 隐藏旧的.
        if let view = self.keyboard {
            // 通知
            self.onKeyboardHidden(newValue?.bounds ?? CGRectZero, delay: self.textField.selectedStyle == .Keyboard)
            
            UIView.animateWithDuration(0.25) {
                view.layer.transform = CATransform3DMakeTranslation(0, 0, 1)
            }
        }
        // 切换键盘
        self.keyboard = newValue
        // 显示新的
        if let view = self.keyboard {
            // 通知
            self.onKeyboardShow(view.frame)
            
            UIView.animateWithDuration(0.25) {
                view.layer.transform = CATransform3DMakeTranslation(0, -view.bounds.height, 1)
            }
        }
    }
    /// 更新键盘(高度)
    func updateKeyboard(height newValue: CGFloat) {
        // 修正
        var fix = self.tableView.contentInset
        // 如果开启了自动调整, 并且更新了inset才开始计算
        if self.automaticallyAdjustsScrollViewInsets && self.tableView.contentInset.top != 0 {
            fix.top = self.tableView.contentInset.top + self.tableView.layer.transform.m42
        } else {
            fix.top = 0
        }
        // 计算
        let h1 = newValue
        let h2 = newValue + self.textField.bounds.height
        // 应用
        // NOTE: 约束在ios7里面表现得并不理想
        //       而且view.transform也有一些bug(约束+transform)
        //       只能使用layer.transform
        self.textField.layer.transform = CATransform3DMakeTranslation(0, -h1, 0)
        self.tableView.layer.transform = CATransform3DMakeTranslation(0, -h2, 0)
        self.tableView.contentInset = UIEdgeInsetsMake(h2 + fix.top, fix.left, fix.bottom, fix.right)
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(h2 + fix.top, fix.left, fix.bottom, fix.right)
        // :)
        SIMLog.debug("\(newValue), fix: \(NSStringFromUIEdgeInsets(fix))")
        // 更新
        self.keyboardHeight = newValue
    }
    /// 获取键盘.
    private func makeKeyboard(style: SIMChatTextFieldItemStyle) -> UIView? {
        // 己经加载过了?
        if let view = keyboards[style] {
            return view
        }
        // 并没有
        var kb: UIView!
        // 创建.
        switch style {
        case .Emoji: kb = SIMChatKeyboardEmoji(delegate: self)
        case .Voice: kb = SIMChatKeyboardAudio(delegate: self)
        case .Tool:  kb = SIMChatKeyboardTool(delegate: self, dataSource: self)
        default:     kb = nil
        }
        // 并没有创建成功?
        guard kb != nil else {
            return nil
        }
        
        // config
        kb.translatesAutoresizingMaskIntoConstraints = false
        kb.backgroundColor = self.textField.backgroundColor
        // add view
        self.view.addSubview(kb)
        // add constraints
        self.view.addConstraint(NSLayoutConstraintMake(kb, .Left,  .Equal, view, .Left))
        self.view.addConstraint(NSLayoutConstraintMake(kb, .Right, .Equal, view, .Right))
        self.view.addConstraint(NSLayoutConstraintMake(kb, .Top,   .Equal, view, .Bottom))
        ///
        kb.layoutIfNeeded()
        // 缓存
        self.keyboards[style] = kb
        // ok
        return kb
    }
    /// 键盘显示
    private dynamic func onKeyboardWillShow(sender: NSNotification) {
        // 获取高度
        if let r1 = sender.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
            // Note: 在iPad这可能会有键盘高度不变但y改变的情况
            let h = r1.height//self.view.bounds.height - r1.origin.y
            if self.keyboardHeight != h {
                SIMLog.trace()
                // 取消隐藏动画
                self.keyboardHiddenAnimation = false
                self.onKeyboardShow(CGRectMake(0, 0, r1.width, h))
            }
        }
    }
    /// 键盘隐藏
    private dynamic func onKeyboardWillHide(sender: NSNotification) {
        if self.keyboardHeight != 0 {
            SIMLog.trace()
            // 转发
            self.onKeyboardHidden(self.keyboard?.frame ?? CGRectZero, delay: false)
        }
    }
    ///
    /// 工具栏显示
    ///
    /// :param: frame 接下来键盘的大小
    ///
    private dynamic func onKeyboardShow(frame: CGRect) {
        SIMLog.debug(frame)
        
        // 填充动画
        UIView.animateWithDuration(0.25) {
            // 更新键盘高度
            self.updateKeyboard(height: frame.height)
        }
    }
    ///
    /// 工具栏显示 
    ///
    /// :param: frame 接下来键盘的大小
    /// :param: delay 是否需要延迟加载(键盘切换需要延迟一下)
    ///
    private dynamic func onKeyboardHidden(frame: CGRect, delay: Bool = false) {
        SIMLog.debug("\(frame) \(delay)")
        
        let block = { () -> () in
            // 填充动画
            UIView.animateWithDuration(0.25) {
                // 更新键盘高度
                self.updateKeyboard(height: frame.height)
            }
        }
        // 不需要确认, 直接执行
        if !delay {
            return block()
        }
        // 开始确认。
        self.keyboardHiddenAnimation = true
        // 延迟0.1s
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 0.1)), dispatch_get_main_queue()) {
            // 取消了
            if !self.keyboardHiddenAnimation {
                return
            }
            block()
        }
    }
}

// MARK: - Extension Keyboard Emoji
extension SIMChatViewController : SIMChatKeyboardEmojiDelegate {
    /// 选择了表情
    func chatKeyboardEmoji(chatKeyboardEmoji: SIMChatKeyboardEmoji, didSelectEmoji emoji: String) {
        let src = self.textField.contentSize.height
        // = . =更新value
        self.textField.text = (self.textField.text ?? "") + emoji
        // 更新contetnOffset, 如果需要的话..
        if src != self.textField.contentSize.height {
            self.textField.scrollViewToBottom()
        }
    }
    /// 选择了后退
    func chatKeyboardEmojiDidDelete(chatKeyboardEmoji: SIMChatKeyboardEmoji) {
        let src = self.textField.contentSize.height
        var str = self.textField.text
        // ..
        if str?.endIndex != str?.startIndex {
            str = str.substringToIndex(str.endIndex.advancedBy(-1))
        }
        // =. =更差value
        self.textField.text = str
        // 更新contetnOffset, 如果需要的话..
        if src != self.textField.contentSize.height {
            self.textField.scrollViewToBottom()
        }
    }
    /// 发送
    func chatKeyboardEmojiDidReturn(chatKeyboardEmoji: SIMChatKeyboardEmoji) {
        self.chatTextFieldShouldReturn(self.textField)
    }
}

// MARK: - Extension Keyboard Tool
extension SIMChatViewController : SIMChatKeyboardToolDataSource, SIMChatKeyboardToolDelegate {
    /// 需要扩展工具栏的数量
    func chatKeyboardTool(chatKeyboardTool: SIMChatKeyboardTool, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    /// item
    func chatKeyboardTool(chatKeyboardTool: SIMChatKeyboardTool, itemAtIndexPath indexPath: NSIndexPath) -> UIBarButtonItem? {
        return nil
    }
    /// 选中
    func chatKeyboardTool(chatKeyboardTool: SIMChatKeyboardTool, didSelectedItem item: UIBarButtonItem) {
        SIMLog.debug((item.title ?? "") + "(\(item.tag))")
        
        if item.tag == -1 {
            self.imagePickerForPhoto()
        } else if item.tag == -2 {
            self.imagePickerForCamera()
        }
    }
}

// MARK: - Extension Keyboard Audio
extension SIMChatViewController : SIMChatKeyboardAudioDelegate {
    /// 开始音频输入
    func chatKeyboardAudioDidBegin(chatKeyboardAudio: SIMChatKeyboardAudio) {
        SIMLog.trace()
        self.textField.enabled = false
        // 计算高度
        let size = self.view.window?.bounds.size ?? CGSizeZero
        let height = size.height - self.keyboardHeight - self.textField.bounds.height
        
        self.maskView.frame = CGRectMake(0, 0, size.width, height)
        self.maskView.alpha = 0
        self.view.window?.addSubview(self.maskView)
        // duang
        UIView.animateWithDuration(0.25) {
            self.maskView.alpha = 1
        }
    }
    /// 结束音频输入
    func chatKeyboardAudioDidEnd(chatKeyboardAudio: SIMChatKeyboardAudio) {
        SIMLog.trace()
        self.textField.enabled = true
        // duang
        UIView.animateWithDuration(0.25, animations: {
            self.maskView.alpha = 0
        }, completion: { f in
            if f {
                self.maskView.removeFromSuperview()
            }
        })
    }
    /// 得到结果
    func chatKeyboardAudioDidFinish(chatKeyboardAudio: SIMChatKeyboardAudio, url: NSURL, duration: NSTimeInterval) {
        self.sendMessageForAudio(url, duration: duration)
    }
}

// MARK: - Text Field
extension SIMChatViewController : SIMChatTextFieldDelegate {
    /// 选中..
    func chatTextField(chatTextField: SIMChatTextField, didSelectItem item: Int) {
        SIMLog.trace()
        if let style = SIMChatTextFieldItemStyle(rawValue: item) {
            self.updateKeyboard(style: style)
        }
    }
    /// ...
    func chatTextFieldContentSizeDidChange(chatTextField: SIMChatTextField) {
        // 填充动画更新
        UIView.animateWithDuration(0.25) {
            // 更新键盘高度
            self.view.layoutIfNeeded()
            self.updateKeyboard(height: self.keyboardHeight)
        }
    }
    /// ok
    func chatTextFieldShouldReturn(chatTextField: SIMChatTextField) -> Bool {
        // 发送.
        self.sendMessageForText(self.textField.text ?? "")
        self.textField.text = nil
        // 不可能return
        return false
    }
}

/// MAKR: - /// Select Image
extension SIMChatViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /// 完成选择
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // 修正方向.
        let image = (info[UIImagePickerControllerOriginalImage] as? UIImage)?.fixOrientation()
        // 关闭窗口
        picker.dismissViewControllerAnimated(true) {
            // 必须关闭完成才发送, = 。 =
            if image != nil {
                self.sendMessageForImage(image!)
            }
        }
    }
    /// 开始选择图片
    func imagePickerForPhoto() {
        SIMLog.trace()
        // 选择图片
        let picker = UIImagePickerController()
        
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        picker.modalPresentationStyle = .CurrentContext
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    /// 从摄像头选择
    func imagePickerForCamera() {
        SIMLog.trace()
        
        // 是否可以使用相机?
        guard UIImagePickerController.isSourceTypeAvailable(.Camera) else {
            let av = UIAlertView(title: "提示", message: "当前设备的相机不可用。", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "好")
            
            return av.show()
        }
        // 检查有没有权限
        if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Denied {
            let av = UIAlertView(title: "提示", message: "请在设备的\"设置-隐私-相机\"中允许访问相机。", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "好")
            
            return av.show()
        }
        
        // 拍摄图片
        let picker = UIImagePickerController()
        
        // 配置
        picker.sourceType = .Camera
        picker.delegate = self
        picker.editing = true
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
}