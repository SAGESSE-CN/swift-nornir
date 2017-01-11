//
//  SACViewController+Keyboard.swift
//  SAC
//
//  Created by SAGESSE on 9/26/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit
import AVFoundation

//extension SACViewController: /*SACInputBarDelegate,*/ SACInputPanelToolBoxDelegate, SACInputPanelEmoticonViewDelegate, SACInputPanelAudioViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//    
//    // MARK: SACInputPanelAudioViewDelegate
//    
//    ///
//    /// 请求一个音频录音器, 如果拒绝该请求返回nil
//    ///
//    public func inputPanelAudioRecorder(_ inputPanel: UIView, resource: SACResourceProtocol) -> SACMediaRecorderProtocol? {
//        return nil
////        return manager.mediaProvider.audioRecorder(resource)
//    }
//    ///
//    /// 请求一个音频播放器, 如果拒绝该请求返回nil
//    ///
//    public func inputPanelAudioPlayer(_ inputPanel: UIView, resource: SACResourceProtocol) -> SACMediaPlayerProtocol? {
//        return nil
////        return manager.mediaProvider.audioPlayer(resource)
//    }
//    
//    ///
//    /// 将要发送音频
//    ///
//    public func inputPanelShouldSendAudio(_ inputPanel: UIView, resource: SACResourceProtocol, duration: TimeInterval) -> Bool {
//        if duration < 1 {
//            SACMessageBox.Alert.error("录音时间太短了")
//            return false
//        }
//        return true
//    }
//    ///
//    /// 发送音频
//    ///
//    public func inputPanelDidSendAudio(_ inputPanel: UIView, resource: SACResourceProtocol, duration: TimeInterval) {
//        SIMLog.trace(resource.resourceURL)
//        
//        let content = SACBaseMessageAudioContent(origin: resource, duration: duration)
//        
//        content.localURL = resource.resourceURL
//        
//        DispatchQueue.main.async {
//            self.messageManager.sendMessage(content)
//        }
//    }
//    
//    // MARK: SACInputBarDelegate
//    
//    // TODO: No imp
////    public func inputBar(inputBar: SACInputBar, shouldSelectItem item: SACInputItemProtocol) -> Bool {
////        SIMLog.trace(item.itemIdentifier)
////        switch item.itemIdentifier {
////        case let x where x.isEmpty:
////            // 空不能选择
////            return false
////        case "kb:photo":
////            // 从相册选择图片
////            imagePickerWithPhoto()
////            return false
////        case "kb:camera":
////            // 从相机选择图片
////            imagePickerWithCamera()
////            return false
////        default:
////            // 显示面板
////            // 第一次显示.
////            if inputBar.selectedBarButtonItem == nil {
////                onShowPanel()
////            }
////            return true
////        }
////    }
////    public func inputBar(inputBar: SACInputBar, didSelectItem item: SACInputItemProtocol) {
////        SIMLog.trace()
////        inputBar.editing = (item.itemIdentifier == "kb:emoticon")
////        inputPanelContainer.currentInputItem = item
////    }
////    public func inputBar(inputBar: SACInputBar, didDeselectItem item: SACInputItemProtocol) {
////        SIMLog.trace()
////        // 最后一次显示
////        if inputBar.selectedBarButtonItem == nil {
////            inputBar.editing = false
////            onHidePanel()
////        }
////    }
////    public func inputBarShouldReturn(inputBar: SACInputBar) -> Bool {
////        // 发送.
////        if let text = inputBar.text where !text.isEmpty {
////            inputBar.clearText()
////            dispatch_async(dispatch_get_main_queue()) {
////                self.messageManager.sendMessage(SACBaseMessageTextContent(content: text))
////            }
////        }
////        return false
////    }
//    
//    // MARK: SACInputPanelEmoticonViewDelegate
//    
//    ///
//    /// 获取表情组数量
//    ///
//    public func numberOfGroupsInInputPanelEmoticon(_ inputPanel: UIView) -> Int {
//        return 0
//    }
//    ///
//    /// 获取一个表情组
//    ///
//    public func inputPanel(_ inputPanel: UIView, emoticonGroupAtIndex index: Int) -> SACEmoticonGroup? {
//        return nil
//    }
//    ///
//    /// 将要选择表情, 返回false拦截该处理
//    ///
//    public func inputPanel(_ inputPanel: UIView, shouldSelectEmoticon emoticon: SACEmoticon) -> Bool {
//        return true
//    }
//    ///
//    /// 选择了表情
//    ///
//    public func inputPanel(_ inputPanel: UIView, didSelectEmoticon emoticon: SACEmoticon) {
//        SIMLog.debug("\(emoticon.code)")
////        if emoticon.type == 0 {
////            // 表情
////            let attachment = NSTextAttachment()
////            attachment.image = emoticon.png
////            attachment.bounds = CGRectMake(0, -4, 20, 20)
////            inputBar.insertAttributedText(NSAttributedString(attachment: attachment))
////        } else {
////            // emoji & text
////            inputBar.insertText(emoticon.code)
////        }
//    }
//    ///
//    /// 点击了返回, 返回false拦截该处理
//    ///
//    public func inputPanelShouldReturn(_ inputPanel: UIView) -> Bool {
////        return inputBarShouldReturn(inputBar)
//        return true
//    }
//    ///
//    /// 点击了退格, 返回false拦截该处理
//    ///
//    public func inputPanelShouldBackspace(_ inputPanel: UIView) -> Bool {
//        SIMLog.debug()
////        guard inputBar.hasText() else {
////            return false
////        }
////        inputBar.deleteBackward()
//        return true
//    }
//    
//    // MARK: SACInputPanelToolBoxDelegate
//    
//    ///
//    /// 获取工具箱中的工具数量
//    ///
//    public func numberOfItemsInInputPanelToolBox(_ inputPanel: UIView) -> Int {
//        return inputPanelToolItems.count
//    }
//    ///
//    /// 获取工具箱中的每一个工具
//    ///
//    public func inputPanel(_ inputPanel: UIView, toolBoxItemAtIndex index: Int) -> SACInputItemProtocol? {
//        return inputPanelToolItems[index]
//    }
//    
//    ///
//    /// 将要选择工具, 返回false表示拦截接下来的操作
//    ///
//    public func inputPanel(_ inputPanel: UIView, shouldSelectToolBoxItem item: SACInputItemProtocol) -> Bool {
//        return true
//    }
//    ///
//    /// 选择工具
//    ///
//    public func inputPanel(_ inputPanel: UIView, didSelectToolBoxItem item: SACInputItemProtocol) {
//        SIMLog.debug("\(item.itemIdentifier) => \(item.itemName)")
//    }
//    
//    // MARK: UIImagePickerControllerDelegate
//    
//    ///
//    /// 图片选择完成
//    ///
//    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
//            return
//        }
//        // 写到文件
//        let path = NSTemporaryDirectory() + "\(Date()).jpg"
//        try? UIImageJPEGRepresentation(image, 0.75)?.write(to: URL(fileURLWithPath: path), options: .atomicWrite)
//        
//        picker.dismiss(animated: true) {
//            SIMLog.trace()
//            let content = SACBaseMessageImageContent(origin: SACBaseImageResource(path), size: image.size)
//            content.localURL = URL(fileURLWithPath: path)
//            self.messageManager.sendMessage(content)
//        }
//    }
//    
//    // MARK: - Public Method
//    
//    public func imagePickerWithPhoto() {
//        SIMLog.trace()
//        // 拍摄图片
//        let picker = UIImagePickerController()
//        // 配置
//        picker.sourceType = .photoLibrary
//        picker.delegate = self
//        //picker.editing = true
//        present(picker, animated: true, completion: nil)
//    }
//    
//    public func imagePickerWithCamera() {
//        SIMLog.trace()
//        // 是否可以使用相机?
//        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
//            let av = UIAlertView(title: "提示", message: "当前设备的相机不可用。", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "好")
//            
//            return av.show()
//        }
//        // 检查有没有权限
//        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .denied {
//            let av = UIAlertView(title: "提示", message: "请在设备的\"设置-隐私-相机\"中允许访问相机。", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "好")
//            
//            return av.show()
//        }
//        // 拍摄图片
//        let picker = UIImagePickerController()
//        // 配置
//        picker.sourceType = .camera
//        picker.delegate = self
//        //picker.editing = true
//        present(picker, animated: true, completion: nil)
//    }
//    
////    ///
////    /// 更新高度
////    ///
////    public dynamic func setKeyboardHeight(height: CGFloat, animated: Bool = true) {
////        if !animated {
////            keyboardHeight = height
////        } else {
////            UIView.animateWithDuration(0.25) {
////                self.keyboardHeight = height
////            }
////        }
////    }
////    
////    // MARK: - Private Method
////    
////    /// 键盘高度
////    private dynamic var keyboardHeight: CGFloat {
////        set {
////            SIMLog.trace("\(newValue) => \(inputBar.frame.height)")
////            
////            // 必须先更新inset, 否则如果offset在0的位置时会产生肉眼可见的抖动
////            var edg = contentView.contentInset
////            edg.top = topLayoutGuide.length + newValue + inputBar.frame.height
////            contentView.contentInset = edg
////            contentView.scrollIndicatorInsets = edg
////            
////            // 必须同时更新
////            contentViewLayout?.top = -(newValue + inputBar.frame.height)
////            contentViewLayout?.bottom = newValue + inputBar.frame.height
////            contentView.layoutIfNeeded()
////            
////            inputBarLayout?.bottom = newValue
////            inputBar.layoutIfNeeded()
////        }
////        get {
////            return inputBarLayout?.bottom ?? 0
////        }
////    }
////    
////    /// 显示面板
////    private func onShowPanel() {
////        SIMLog.trace()
////        
////        let height = self.inputPanelContainer.frame.height
////        
////        UIView.animateWithDuration(0.25) {
////            self.setKeyboardHeight(height, animated: false)
////            self.inputPanelContainerLayout?.top = -height
////            self.inputPanelContainer.layoutIfNeeded()
////            self.view.layoutIfNeeded()
////        }
////    }
////    /// 隐藏面板
////    private func onHidePanel() {
////        SIMLog.trace()
////        
////        UIView.animateWithDuration(0.25) {
////            self.setKeyboardHeight(self.systemKeyboardFrame.height, animated: false)
////            self.inputPanelContainerLayout?.top = 0
////            self.inputPanelContainer.layoutIfNeeded()
////            self.view.layoutIfNeeded()
////        }
////        inputPanelContainer.currentInputItem = nil
////    }
////    /// 键盘显示通知
////    internal dynamic func onKeyboardShowNtf(sender: NSNotification) {
////        guard let r1 = sender.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue else {
////            return
////        }
////        // Note: 在iPad这可能会有键盘高度不变但y改变的情况
////        let h = r1.height//self.view.bounds.height - r1.origin.y
////        systemKeyboardFrame = CGRectMake(r1.minX, r1.minY, r1.width, h)
////        // 更新键盘
////        setKeyboardHeight(systemKeyboardFrame.height)
////    }
////    /// 键盘隐藏通知
////    internal dynamic func onKeyboardHideNtf(sender: NSNotification) {
////        systemKeyboardFrame = CGRectZero
////        // 更新键盘
////        if inputBar.selectedBarButtonItem == nil {
////            setKeyboardHeight(systemKeyboardFrame.height)
////        }
////    }
////    /// 输入栏改变
////    internal dynamic func onInputBarChangeNtf(sender: NSNotification) {
////        setKeyboardHeight(keyboardHeight)
////    }
////    /// 放弃输入
////    internal dynamic func onResignKeyboard(sender: AnyObject) {
////        if inputBar.isFirstResponder() {
////            inputBar.resignFirstResponder()
////        } else {
////            view.endEditing(true)
////        }
////    }
//}
//
////extension SACViewController: SACInputPanelAudioDelegate {
////    public func inputPanelShouldStartRecord(inputPanel: UIView) -> SACRequest<Void>? {
////        SIMLog.trace()
////    }
////    public func inputPanelDidStartRecord(inputPanel: UIView) {
////        SIMLog.trace()
////    }
////    public func inputPanelDidStopRecord(inputPanel: UIView) {
////        SIMLog.trace()
////    }
////}
//
////// MARK: - Extension Keyboard Audio
////extension SACViewController : SACKeyboardAudioDelegate {
////    /// 开始音频输入
////    func chatKeyboardAudioDidBegin(chatKeyboardAudio: SACKeyboardAudio) {
////        SIMLog.trace()
////        self.textField.enabled = false
////        // 计算高度
////        let size = self.view.window?.bounds.size ?? CGSizeZero
////        let height = size.height - self.keyboardHeight - self.textField.bounds.height
////        
////        self.maskView.frame = CGRectMake(0, 0, size.width, height)
////        self.maskView.alpha = 0
////        self.view.window?.addSubview(self.maskView)
////        // duang
////        UIView.animateWithDuration(0.25) {
////            self.maskView.alpha = 1
////        }
////    }
////    /// 结束音频输入
////    func chatKeyboardAudioDidEnd(chatKeyboardAudio: SACKeyboardAudio) {
////        SIMLog.trace()
////        self.textField.enabled = true
////        // duang
////        UIView.animateWithDuration(0.25, animations: {
////            self.maskView.alpha = 0
////        }, completion: { f in
////            if f {
////                self.maskView.removeFromSuperview()
////            }
////        })
////    }
////    /// 得到结果
////    func chatKeyboardAudioDidFinish(chatKeyboardAudio: SACKeyboardAudio, url: NSURL, duration: NSTimeInterval) {
////        self.sendMessageForAudio(url, duration: duration)
////    }
////}
//
//
/////// MAKR: - /// Select Image
////extension SACViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
////    /// 完成选择
////    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
////        // 修正方向.
////        let image = (info[UIImagePickerControllerOriginalImage] as? UIImage)?.fixOrientation()
////        // 关闭窗口
////        picker.dismissViewControllerAnimated(true) {
////            // 必须关闭完成才发送, = 。 =
////            if image != nil {
////                self.sendMessageForImage(image!)
////            }
////        }
////    }
////    /// 开始选择图片
////    func imagePickerForPhoto() {
////        SIMLog.trace()
////        // 选择图片
////        let picker = UIImagePickerController()
////        
////        picker.sourceType = .PhotoLibrary
////        picker.delegate = self
////        picker.modalPresentationStyle = .CurrentContext
////        
////        self.presentViewController(picker, animated: true, completion: nil)
////    }
////    /// 从摄像头选择
////    func imagePickerForCamera() {
////        SIMLog.trace()
////        
////        // 是否可以使用相机?
////        guard UIImagePickerController.isSourceTypeAvailable(.Camera) else {
////            let av = UIAlertView(title: "提示", message: "当前设备的相机不可用。", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "好")
////            
////            return av.show()
////        }
////        // 检查有没有权限
////        if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Denied {
////            let av = UIAlertView(title: "提示", message: "请在设备的\"设置-隐私-相机\"中允许访问相机。", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "好")
////            
////            return av.show()
////        }
////        
////        // 拍摄图片
////        let picker = UIImagePickerController()
////        
////        // 配置
////        picker.sourceType = .Camera
////        picker.delegate = self
////        picker.editing = true
////        
////        self.presentViewController(picker, animated: true, completion: nil)
////    }
////}
//
