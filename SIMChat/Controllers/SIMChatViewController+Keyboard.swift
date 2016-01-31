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
        systemKeyboardFrame = CGRectMake(r1.minX, r1.minY, r1.width, h)
        // 更新键盘
        setKeyboardHeight(systemKeyboardFrame.height)
    }
    /// 键盘隐藏通知
    private dynamic func onKeyboardHideNtf(sender: NSNotification) {
        systemKeyboardFrame = CGRectZero
        // 更新键盘
        if inputBar.selectedBarButtonItem == nil {
            setKeyboardHeight(systemKeyboardFrame.height)
        }
    }
    /// 输入栏改变
    private dynamic func onInputBarChangeNtf(sender: NSNotification) {
        setKeyboardHeight(keyboardHeight)
    }
}

// MARK: - Keyboard
extension SIMChatViewController {
    /// 键盘高度
    private dynamic var keyboardHeight: CGFloat {
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
    public dynamic func setKeyboardHeight(height: CGFloat, animated: Bool = true) {
        if !animated {
            keyboardHeight = height
        } else {
            UIView.animateWithDuration(0.25) {
                self.keyboardHeight = height
            }
        }
    }
    
    /// 放弃
    public dynamic func onResignKeyboard(sender: AnyObject) {
        if inputBar.isFirstResponder() {
            inputBar.resignFirstResponder()
        } else {
            view.endEditing(true)
        }
    }
}


// MARK: - Panel

extension SIMChatViewController {
    /// 显示面板
    private func onShowPanel() {
        SIMLog.trace()
        
        let height = self.inputPanelView.frame.height
        
        UIView.animateWithDuration(0.25) {
            self.setKeyboardHeight(height, animated: false)
            self.inputPanelViewLayout?.top = -height
            self.inputPanelView.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
    }
    /// 隐藏面板
    private func onHidePanel() {
        SIMLog.trace()
        
        UIView.animateWithDuration(0.25) {
            self.setKeyboardHeight(self.systemKeyboardFrame.height, animated: false)
            self.inputPanelViewLayout?.top = 0
            self.inputPanelView.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
        inputPanelView.selectedItem = nil
    }
}

// MARK: - SIMChatInputPanelDelegate

extension SIMChatViewController: SIMChatInputPanelDelegate {
}

// MARK: - SIMChatInputPanelDelegateFace

extension SIMChatViewController: SIMChatInputPanelDelegateFace {
    /// 选择表情
    public func inputPanel(inputPanel: UIView, didSelectFace face: String) {
        SIMLog.debug(face)
        inputBar.text = (inputBar.text ?? "") + face
        // TODO: 更新contentOffset
    }
    /// 退格
    public func inputPanelShouldSelectBackspace(inputPanel: UIView) -> Bool {
        SIMLog.debug()
        guard let str = inputBar.text where !str.isEmpty else {
            return false
        }
        inputBar.text = str.substringToIndex(str.endIndex.advancedBy(-1))
        // TODO: 更新contentOffset
        return true
    }
    /// 回车
    public func inputPanelShouldReturn(inputPanel: UIView) -> Bool {
        SIMLog.debug()
        return true
    }
}

// MARK: - 
extension SIMChatViewController: SIMChatInputPanelDelegateTool {
    public func numberOfInputPanelToolItems(inputPanel: UIView) -> Int {
        return 0
    }
    public func inputPanel(inputPanel: UIView, itemAtIndex index: Int) -> SIMChatInputAccessory? {
        return nil//SIMChatInputToolAccessory("page:test", "测试", UIImage(named: "simchat_icons_location"))
    }
    
    public func inputPanel(inputPanel: UIView, didSelectTool item: SIMChatInputAccessory) {
        SIMLog.debug("\(item.accessoryIdentifier) => \(item.accessoryName)")
    }
}

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


// MARK: - Input Bar

extension SIMChatViewController: SIMChatInputBarDelegate {
    
    public func inputBar(inputBar: SIMChatInputBar, shouldSelectItem item: SIMChatInputAccessory) -> Bool {
        SIMLog.trace()
        // 第一次显示.
        if inputBar.selectedBarButtonItem == nil {
            onShowPanel()
        }
        return true
    }
    public func inputBar(inputBar: SIMChatInputBar, didSelectItem item: SIMChatInputAccessory) {
        SIMLog.trace()
        inputPanelView.selectedItem = item
    }
    public func inputBar(inputBar: SIMChatInputBar, didDeselectItem item: SIMChatInputAccessory) {
        SIMLog.trace()
        // 最后一次显示
        if inputBar.selectedBarButtonItem == nil {
            onHidePanel()
        }
    }
    public func inputBarShouldReturn(inputBar: SIMChatInputBar) -> Bool {
        // 发送.
        //sendMessageForText(self.textField.text ?? "")
        inputBar.text = nil
        return false
    }
}