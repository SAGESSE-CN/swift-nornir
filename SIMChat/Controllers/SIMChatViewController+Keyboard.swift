//
//  SIMChatViewController+Keyboard.swift
//  SIMChat
//
//  Created by sagesse on 9/26/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - Keyboard Notification

extension SIMChatViewController {
    /// 键盘显示通知
    private dynamic func onKeyboardShowNtf(sender: NSNotification) {
        guard let r1 = sender.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue else {
            return
        }
        // Note: 在iPad这可能会有键盘高度不变但y改变的情况
        let h = r1.height//self.view.bounds.height - r1.origin.y
        onKeyboardShow(CGRectMake(0, 0, r1.width, h))
    }
    /// 键盘隐藏通知
    private dynamic func onKeyboardHideNtf(sender: NSNotification) {
        if inputBar.selectedBarButtonItem == nil {
            onKeyboardHidden(CGRectZero)
        }
    }
    /// 输入栏改变
    private dynamic func onInputBarChangeNtf(sender: NSNotification) {
        onUpdateKeyboardHeight(keyboardHeight)
    }
}

// MARK: - Keyboard
extension SIMChatViewController {
    /// 更新键盘高度
    public var keyboardHeight: CGFloat {
        set {
            SIMLog.trace("\(newValue) => \(inputBar.frame.height)")
            
            // 必须先更新inset, 否则如果offset在0的位置时会产生肉眼可见的抖动
            var edg = contentView.contentInset
            edg.top = topLayoutGuide.length + newValue + inputBar.frame.height
            contentView.contentInset = edg
            
            // 必须同时更新
            contentViewLayout?.top = -(newValue + inputBar.frame.height)
            contentViewLayout?.bottom = newValue + inputBar.frame.height
            contentView.layoutIfNeeded()
            
            inputBarLayout?.bottom = newValue
            inputBar.layoutIfNeeded()
        }
        get {
            return inputBarLayout?.bottom ?? 0
        }
    }
    /// 更新高度
    private func onUpdateKeyboardHeight(height: CGFloat) {
        UIView.animateWithDuration(0.25) {
            self.keyboardHeight = height
        }
    }
    
    /// 放弃
    private dynamic func onResignKeyboard(sender: AnyObject) {
        if inputBar.isFirstResponder() {
            inputBar.resignFirstResponder()
        } else {
            view.endEditing(true)
        }
    }
    
    ///
    /// 工具栏显示
    ///
    /// :param: frame 接下来键盘的大小
    ///
    private dynamic func onKeyboardShow(frame: CGRect) {
        SIMLog.debug(frame)
        onUpdateKeyboardHeight(frame.height)
    }
    ///
    /// 工具栏显示 
    ///
    /// :param: frame 接下来键盘的大小
    ///
    private dynamic func onKeyboardHidden(frame: CGRect) {
        SIMLog.debug(frame)
        onUpdateKeyboardHeight(frame.height)
    }
}


// MARK: - Panel

extension SIMChatViewController {
    /// 显示面板
    private func onPanelShow() {
        SIMLog.trace()
        
        let height = self.inputPanelView.frame.height
        UIView.animateWithDuration(0.25) {
            self.keyboardHeight = height
            self.inputPanelViewLayout?.top = -height
            self.inputPanelView.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
    }
    /// 隐藏面板
    private func onPanelHide() {
        SIMLog.trace()
        UIView.animateWithDuration(0.25) {
            if !self.inputBar.isFirstResponder() {
                self.keyboardHeight = 0
            }
            self.inputPanelViewLayout?.top = 0
            self.inputPanelView.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
        inputPanelView.selectedItem = nil
    }
}

//// MARK: - Extension Keyboard Emoji
//extension SIMChatViewController : SIMChatKeyboardEmojiDelegate {
//    /// 选择了表情
//    func chatKeyboardEmoji(chatKeyboardEmoji: SIMChatKeyboardEmoji, didSelectEmoji emoji: String) {
//        let src = self.textField.contentSize.height
//        // = . =更新value
//        self.textField.text = (self.textField.text ?? "") + emoji
//        // 更新contetnOffset, 如果需要的话..
//        if src != self.textField.contentSize.height {
//            self.textField.scrollViewToBottom()
//        }
//    }
//    /// 选择了后退
//    func chatKeyboardEmojiDidDelete(chatKeyboardEmoji: SIMChatKeyboardEmoji) {
//        let src = self.textField.contentSize.height
//        var str = self.textField.text
//        // ..
//        if str?.endIndex != str?.startIndex {
//            str = str.substringToIndex(str.endIndex.advancedBy(-1))
//        }
//        // =. =更差value
//        self.textField.text = str
//        // 更新contetnOffset, 如果需要的话..
//        if src != self.textField.contentSize.height {
//            self.textField.scrollViewToBottom()
//        }
//    }
//    /// 发送
//    func chatKeyboardEmojiDidReturn(chatKeyboardEmoji: SIMChatKeyboardEmoji) {
//        self.chatTextFieldShouldReturn(self.textField)
//    }
//}
//
//// MARK: - Extension Keyboard Tool
//extension SIMChatViewController : SIMChatKeyboardToolDataSource, SIMChatKeyboardToolDelegate {
//    /// 需要扩展工具栏的数量
//    func chatKeyboardTool(chatKeyboardTool: SIMChatKeyboardTool, numberOfItemsInSection section: Int) -> Int {
//        return 0
//    }
//    /// item
//    func chatKeyboardTool(chatKeyboardTool: SIMChatKeyboardTool, itemAtIndexPath indexPath: NSIndexPath) -> UIBarButtonItem? {
//        return nil
//    }
//    /// 选中
//    func chatKeyboardTool(chatKeyboardTool: SIMChatKeyboardTool, didSelectedItem item: UIBarButtonItem) {
//        SIMLog.debug((item.title ?? "") + "(\(item.tag))")
//        
//        if item.tag == -1 {
//            self.imagePickerForPhoto()
//        } else if item.tag == -2 {
//            self.imagePickerForCamera()
//        }
//    }
//}
//
//// MARK: - Extension Keyboard Audio
//extension SIMChatViewController : SIMChatKeyboardAudioDelegate {
//    /// 开始音频输入
//    func chatKeyboardAudioDidBegin(chatKeyboardAudio: SIMChatKeyboardAudio) {
//        SIMLog.trace()
//        self.textField.enabled = false
//        // 计算高度
//        let size = self.view.window?.bounds.size ?? CGSizeZero
//        let height = size.height - self.keyboardHeight - self.textField.bounds.height
//        
//        self.maskView.frame = CGRectMake(0, 0, size.width, height)
//        self.maskView.alpha = 0
//        self.view.window?.addSubview(self.maskView)
//        // duang
//        UIView.animateWithDuration(0.25) {
//            self.maskView.alpha = 1
//        }
//    }
//    /// 结束音频输入
//    func chatKeyboardAudioDidEnd(chatKeyboardAudio: SIMChatKeyboardAudio) {
//        SIMLog.trace()
//        self.textField.enabled = true
//        // duang
//        UIView.animateWithDuration(0.25, animations: {
//            self.maskView.alpha = 0
//        }, completion: { f in
//            if f {
//                self.maskView.removeFromSuperview()
//            }
//        })
//    }
//    /// 得到结果
//    func chatKeyboardAudioDidFinish(chatKeyboardAudio: SIMChatKeyboardAudio, url: NSURL, duration: NSTimeInterval) {
//        self.sendMessageForAudio(url, duration: duration)
//    }
//}


///// MAKR: - /// Select Image
//extension SIMChatViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    /// 完成选择
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        // 修正方向.
//        let image = (info[UIImagePickerControllerOriginalImage] as? UIImage)?.fixOrientation()
//        // 关闭窗口
//        picker.dismissViewControllerAnimated(true) {
//            // 必须关闭完成才发送, = 。 =
//            if image != nil {
//                self.sendMessageForImage(image!)
//            }
//        }
//    }
//    /// 开始选择图片
//    func imagePickerForPhoto() {
//        SIMLog.trace()
//        // 选择图片
//        let picker = UIImagePickerController()
//        
//        picker.sourceType = .PhotoLibrary
//        picker.delegate = self
//        picker.modalPresentationStyle = .CurrentContext
//        
//        self.presentViewController(picker, animated: true, completion: nil)
//    }
//    /// 从摄像头选择
//    func imagePickerForCamera() {
//        SIMLog.trace()
//        
//        // 是否可以使用相机?
//        guard UIImagePickerController.isSourceTypeAvailable(.Camera) else {
//            let av = UIAlertView(title: "提示", message: "当前设备的相机不可用。", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "好")
//            
//            return av.show()
//        }
//        // 检查有没有权限
//        if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Denied {
//            let av = UIAlertView(title: "提示", message: "请在设备的\"设置-隐私-相机\"中允许访问相机。", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "好")
//            
//            return av.show()
//        }
//        
//        // 拍摄图片
//        let picker = UIImagePickerController()
//        
//        // 配置
//        picker.sourceType = .Camera
//        picker.delegate = self
//        picker.editing = true
//        
//        self.presentViewController(picker, animated: true, completion: nil)
//    }
//}


// MARK: - Input Bar Util Class

extension SIMChatViewController {
    class BarButtonItem: SIMChatInputBarAccessory {
        @objc var accessoryIdentifier: String {
            return "test"
        }
        @objc var accessoryName: String? {
            return "test"
        }
        @objc var accessoryImage: UIImage? {
            return UIImage(named: "chat_bottom_smile_nor")
        }
        @objc var accessorySelecteImage: UIImage? {
            return UIImage(named: "chat_bottom_smile_press")
        }
    }
}


// MARK: - Input Bar

extension SIMChatViewController: SIMChatInputBarDelegate {
    /// 检查是否可以选中
    public func inputBar(inputBar: SIMChatInputBar, shouldSelectItem item: SIMChatInputBarAccessory) -> Bool {
        SIMLog.trace()
        // 第一次显示.
        if inputBar.selectedBarButtonItem == nil {
            onPanelShow()
        }
        return true
    }
    /// 选中了
    public func inputBar(inputBar: SIMChatInputBar, didSelectItem item: SIMChatInputBarAccessory) {
        SIMLog.trace()
        inputPanelView.selectedItem = item
    }
    /// 取消了
    public func inputBar(inputBar: SIMChatInputBar, didDeselectItem item: SIMChatInputBarAccessory) {
        SIMLog.trace()
        // 最后一次显示
        if inputBar.selectedBarButtonItem == nil {
            onPanelHide()
        }
    }
    /// 按下回车
    public func inputBarShouldReturn(inputBar: SIMChatInputBar) -> Bool {
        // 发送.
        //sendMessageForText(self.textField.text ?? "")
        inputBar.text = nil
        return false
    }
    
//    /// ok
//    func chatTextFieldShouldReturn(chatTextField: SIMChatInputBar) -> Bool {
////        // 发送.
////        self.sendMessageForText(self.textField.text ?? "")
////        self.textField.text = nil
//        // 不可能return
//        return false
//    }
}