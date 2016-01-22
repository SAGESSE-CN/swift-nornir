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
    ///
    /// 键盘显示通知
    ///
    private dynamic func onKeyboardShowNtf(sender: NSNotification) {
        if let r1 = sender.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
            // Note: 在iPad这可能会有键盘高度不变但y改变的情况
            let h = r1.height//self.view.bounds.height - r1.origin.y
            self.onKeyboardShow(CGRectMake(0, 0, r1.width, h))
        }
    }
    ///
    /// 键盘隐藏通知
    ///
    private dynamic func onKeyboardHideNtf(sender: NSNotification) {
        if (inputPanelViewLayout?.bottom ?? -1) < 0 {
            onKeyboardHidden(CGRectZero)
        }
    }
}

// MARK: - Keyboard
extension SIMChatViewController {
    /// 更新键盘高度
    public var keyboardHeight: CGFloat {
        set {
            SIMLog.trace(newValue)
            
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
    /// 更新类型
    private func onUpdateKeyboardStyle(style: SIMChatTextFieldItemStyle) {
        SIMLog.trace()
        
        // TODO: 逻辑混乱, 需要重新设计
        
        let height = self.inputPanelView.frame.height
        
        if style == .None {
            onUpdateKeyboardHeight(0)
        } else if keyboardHeight != height {
            onUpdateKeyboardHeight(height)
        }
        UIView.animateWithDuration(0.25) {
            if style == .None || style == .Keyboard {
                self.inputPanelViewLayout?.bottom = -height
            } else {
                self.inputPanelViewLayout?.bottom = 0//-height
            }
            self.inputPanelView.layoutIfNeeded()
            self.view.layoutIfNeeded()
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
    
    /// 更新键盘(类型)
    func updateKeyboard(style style: SIMChatTextFieldItemStyle) {
        SIMLog.trace()
//        let newValue = self.makeKeyboard(style)
//        // 隐藏旧的.
//        if let view = self.keyboard {
//            // 通知
//            self.onKeyboardHidden(newValue?.bounds ?? CGRectZero, delay: self.textField.selectedStyle == .Keyboard)
//            
//            UIView.animateWithDuration(0.25) {
//                view.layer.transform = CATransform3DMakeTranslation(0, 0, 1)
//            }
//        }
//        // 切换键盘
//        self.keyboard = newValue
//        // 显示新的
//        if let view = self.keyboard {
//            // 通知
//            self.onKeyboardShow(view.frame)
//            
//            UIView.animateWithDuration(0.25) {
//                view.layer.transform = CATransform3DMakeTranslation(0, -view.bounds.height, 1)
//            }
//        }
    }
//    /// 更新键盘(高度)
//    func updateKeyboard(height newValue: CGFloat) {
    
        
//        // 修正
//        var fix = self.tableView.contentInset
//        // 如果开启了自动调整, 并且更新了inset才开始计算
//        if self.automaticallyAdjustsScrollViewInsets && self.tableView.contentInset.top != 0 {
//            fix.top = self.tableView.contentInset.top + self.tableView.layer.transform.m42
//        } else {
//            fix.top = 0
//        }
//        // 计算
//        let h1 = newValue
//        let h2 = newValue + self.textField.bounds.height
//        // 应用
//        // NOTE: 约束在ios7里面表现得并不理想
//        //       而且view.transform也有一些bug(约束+transform)
//        //       只能使用layer.transform
//        self.textField.layer.transform = CATransform3DMakeTranslation(0, -h1, 0)
//        self.tableView.layer.transform = CATransform3DMakeTranslation(0, -h2, 0)
//        //self.textField.transform = CGAffineTransformMakeTranslation(0, -h1)
//        //self.tableView.transform = CGAffineTransformMakeTranslation(0, -h2)
//        self.tableView.contentInset = UIEdgeInsetsMake(h2 + fix.top, fix.left, fix.bottom, fix.right)
//        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(h2 + fix.top, fix.left, fix.bottom, fix.right)
//        // :)
//        SIMLog.debug("\(newValue), fix: \(NSStringFromUIEdgeInsets(fix))")
//        // 更新
//        self.keyboardHeight = newValue
//    }
    /// 获取键盘.
    private func makeKeyboard(style: SIMChatTextFieldItemStyle) -> UIView? {
        return nil
//        // 己经加载过了?
//        if let view = keyboards[style] {
//            return view
//        }
//        // 并没有
//        var kb: UIView!
//        // 创建.
//        switch style {
//        case .Emoji: kb = SIMChatKeyboardEmoji(delegate: self)
//        case .Voice: kb = SIMChatKeyboardAudio(delegate: self)
//        case .Tool:  kb = SIMChatKeyboardTool(delegate: self, dataSource: self)
//        default:     kb = nil
//        }
//        // 并没有创建成功?
//        guard kb != nil else {
//            return nil
//        }
//        
//        // config
//        kb.translatesAutoresizingMaskIntoConstraints = false
//        kb.backgroundColor = self.textField.backgroundColor
//        // add view
//        self.view.addSubview(kb)
//        // add constraints
//        self.view.addConstraint(NSLayoutConstraintMake(kb, .Left,  .Equal, view, .Left))
//        self.view.addConstraint(NSLayoutConstraintMake(kb, .Right, .Equal, view, .Right))
//        self.view.addConstraint(NSLayoutConstraintMake(kb, .Top,   .Equal, view, .Bottom))
//        ///
//        kb.layoutIfNeeded()
//        // 缓存
//        self.keyboards[style] = kb
//        // ok
//        return kb
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
    /// :param: delay 是否需要延迟加载(键盘切换需要延迟一下)
    ///
    private dynamic func onKeyboardHidden(frame: CGRect) {
        SIMLog.debug(frame)
        onUpdateKeyboardHeight(frame.height)
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



// MARK: - Input bar

extension SIMChatViewController: SIMChatTextFieldDelegate {
    /// 选中..
    func chatTextField(chatTextField: SIMChatTextField, didSelectItem item: Int) {
        SIMLog.trace()
        if let style = SIMChatTextFieldItemStyle(rawValue: item) {
            onUpdateKeyboardStyle(style)
        }
    }
    /// 高度改变
    func chatTextFieldContentSizeDidChange(chatTextField: SIMChatTextField) {
        SIMLog.trace()
        self.onUpdateKeyboardHeight(self.keyboardHeight)
    }
    /// ok
    func chatTextFieldShouldReturn(chatTextField: SIMChatTextField) -> Bool {
//        // 发送.
//        self.sendMessageForText(self.textField.text ?? "")
//        self.textField.text = nil
        // 不可能return
        return false
    }
}