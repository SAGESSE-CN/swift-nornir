//
//  SACChatViewController.swift
//  SAChat
//
//  Created by SAGESSE on 01/11/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import SAInput

///
/// 聊天控制器
///
open class SACChatViewController: UIViewController {
    
    public required init(conversation: SACConversationType) {
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
        
        self.title = "正在和\(conversation.receiver.name ?? "<Unknow>")聊天"
        self.hidesBottomBarWhenPushed = true
        
        _init()
        _logger.trace()
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        //        SACNotificationCenter.removeObserver(self)
        
        _logger.trace()
    }
    
    open override func loadView() {
        super.loadView()
        self.view = _chatView
    }
    
    fileprivate lazy var _chatViewLayout: SACChatViewLayout = SACChatViewLayout()
    fileprivate lazy var _chatView: SACChatView = SACChatView(frame: .zero, chatViewLayout: self._chatViewLayout)
    
    open var conversation: SACConversationType
    
    
//    var isLandscape: Bool {
//        // iOS 8.0+
//        let io = UIScreen.main.value(forKey: "_interfaceOrientation") as! Int
//        if UIInterfaceOrientation(rawValue: io)?.isLandscape ?? false {
//            return true
//        }
//        return false
//    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = UIColor(colorLiteralRed: 0xec / 0xff, green: 0xed / 0xff, blue: 0xf1 / 0xff, alpha: 1)
        
        var datas: [SACMessageType] = []
        
        var tm: TimeInterval = 0
        for alignment: SACMessageAlignment in [.left, .right] {
            for showsAvatar: Bool in [true, false] {
                for showsCard: Bool in [true, false] {
                    //  time
                    if true {
                        let content = SACMessageTimeLineContent(date: .init(timeIntervalSinceNow: tm))
                        let msg = SACMessage(content: content)
                        datas.append(msg)
                    }
                    
                    for contentType: Int in (0 ..< 4) {
                        let content = { Void -> SACMessageContentType in
                            switch contentType {
                            case 0: return SACMessageTextContent()
                            case 1: return SACMessageImageContent()
                            case 2: return SACMessageVoiceContent()
                            default: return SACMessageNoticeContent.unsupport
                            }
                        }()
                        let msg = SACMessage(content: content)
                        
                        msg.date = .init(timeIntervalSinceNow: tm - TimeInterval(contentType) * 60)
                        
                        if !(content is SACMessageNoticeContent) {
                            msg.options.style = .bubble
                            msg.options.alignment = alignment
                            msg.options.showsCard = showsCard
                            msg.options.showsAvatar = showsAvatar
                        }
                        
                        datas.append(msg)
                    }
                    
                    tm -= 86400
                }
            }
        }
        
        _toolbar.delegate = self
        
        _chatView.backgroundColor = color
        _chatView.append(contentsOf: datas)
        
        if let group = SACEmoticonGroup(identifier: "com.qq.classic") {
            _emoticonGroups.append(group)
        }
        if let group = SACEmoticonGroup(identifier: "cn.com.a-li") {
            _emoticonGroups.append(group)
        }
    }
    

    var isLandscape: Bool {
        // iOS 8.0+
        let io = UIScreen.main.value(forKey: "_interfaceOrientation") as! Int
        if UIInterfaceOrientation(rawValue: io)?.isLandscape ?? false {
            return true
        }
        return false
    }
    
    private func _init() {
        
        _emoticonSendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        _emoticonSendBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10 + 8, 0, 8)
        _emoticonSendBtn.setTitle("Send", for: .normal)
        _emoticonSendBtn.setTitleColor(.white, for: .normal)
        _emoticonSendBtn.setTitleColor(.lightGray, for: .highlighted)
        _emoticonSendBtn.setTitleColor(.gray, for: .disabled)
        _emoticonSendBtn.setBackgroundImage(UIImage.sac_init(named: "chat_emoticon_btn_send_blue"), for: .normal)
        _emoticonSendBtn.setBackgroundImage(UIImage.sac_init(named: "chat_emoticon_btn_send_gray"), for: .disabled)
        _emoticonSendBtn.addTarget(self, action: #selector(_sendHandler(forEmoticon:)), for: .touchUpInside)
        _emoticonSendBtn.isEnabled = false
        
        _emoticonSettingBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        _emoticonSettingBtn.setImage(UIImage.sac_init(named: "chat_emoticon_btn_setting"), for: .normal)
        _emoticonSettingBtn.setBackgroundImage(UIImage.sac_init(named: "chat_emoticon_btn_send_gray"), for: .normal)
        _emoticonSettingBtn.setBackgroundImage(UIImage.sac_init(named: "chat_emoticon_btn_send_gray"), for: .highlighted)
        _emoticonSettingBtn.addTarget(self, action: #selector(_settingHandler(forEmoticon:)), for: .touchUpInside)
    }
    
    func send(forText text: NSAttributedString) {
        
        let message = SACMessage(content: SACMessageTextContent(attributedText: text))
        _chatView.append(message)
    }
    func send(forLargeEmoticon emoticon: SACEmoticonLarge) {
        _logger.trace("\(emoticon.title) \(emoticon.id)")
        
    }
    
    fileprivate dynamic func _sendHandler(forEmoticon sender: Any) {
        _logger.trace()
        
        // send text message
        send(forText: _toolbar.attributedText)
        // clear current text
        _toolbar.attributedText = nil
    }
    fileprivate dynamic func _settingHandler(forEmoticon sender: Any) {
        _logger.trace()
        
    }
    

    fileprivate lazy var _toolbar: SAIInputBar = SAIInputBar(type: .value1)
    fileprivate lazy var _contentView: UITableView = UITableView()
    
    fileprivate lazy var _emoticonGroups: [SACEmoticonGroup] = []
    fileprivate lazy var _emoticonSendBtn: UIButton = UIButton()
    fileprivate lazy var _emoticonSettingBtn: UIButton = UIButton()
    
    fileprivate weak var _inputItem: SAIInputItem?
    fileprivate lazy var _inputViews: [String: UIView] = [:]
    
    fileprivate lazy var _toolboxItems: [SAIToolboxItem] = {
        return [
            SAIToolboxItem("page:voip", "网络电话", UIImage.sac_init(named: "chat_tool_voip")),
            SAIToolboxItem("page:video", "视频电话", UIImage.sac_init(named: "chat_tool_video")),
            SAIToolboxItem("page:video_s", "短视频", UIImage.sac_init(named: "chat_tool_video_short")),
            SAIToolboxItem("page:favorite", "收藏", UIImage.sac_init(named: "chat_tool_favorite")),
            SAIToolboxItem("page:red_pack", "发红包", UIImage.sac_init(named: "chat_tool_red_pack")),
            SAIToolboxItem("page:transfer", "转帐", UIImage.sac_init(named: "chat_tool_transfer")),
            SAIToolboxItem("page:shake", "抖一抖", UIImage.sac_init(named: "chat_tool_shake")),
            SAIToolboxItem("page:file", "文件", UIImage.sac_init(named: "chat_tool_folder")),
            SAIToolboxItem("page:camera", "照相机", UIImage.sac_init(named: "chat_tool_camera")),
            SAIToolboxItem("page:pic", "相册", UIImage.sac_init(named: "chat_tool_pic")),
            SAIToolboxItem("page:ptt", "录音", UIImage.sac_init(named: "chat_tool_ptt")),
            SAIToolboxItem("page:music", "音乐", UIImage.sac_init(named: "chat_tool_music")),
            SAIToolboxItem("page:location", "位置", UIImage.sac_init(named: "chat_tool_location")),
            SAIToolboxItem("page:nameplate", "名片",   UIImage.sac_init(named: "chat_tool_share_nameplate")),
            SAIToolboxItem("page:aa", "AA制", UIImage.sac_init(named: "chat_tool_aa_collection")),
            SAIToolboxItem("page:gapp", "群应用", UIImage.sac_init(named: "chat_tool_group_app")),
            SAIToolboxItem("page:gvote", "群投票", UIImage.sac_init(named: "chat_tool_group_vote")),
            SAIToolboxItem("page:gvideo", "群视频", UIImage.sac_init(named: "chat_tool_group_video")),
            SAIToolboxItem("page:gtopic", "群话题", UIImage.sac_init(named: "chat_tool_group_topic")),
            SAIToolboxItem("page:gactivity", "群活动", UIImage.sac_init(named: "chat_tool_group_activity")),
        ]
    }()
}



// MARK: - SAInputBarDelegate & SAInputBarDisplayable

extension SACChatViewController: SAIInputBarDelegate, SAIInputBarDisplayable {
    
    open override var inputAccessoryView: UIView? {
        return _toolbar
    }
    open var scrollView: SAIInputBarScrollViewType {
        return _chatView
    }
    
    open override var canBecomeFirstResponder: Bool {
        return true
    }
    
    open func inputView(with item: SAIInputItem) -> UIView? {
        if let view = _inputViews[item.identifier] {
            return view
        }
        switch item.identifier {
        case "kb:audio":
            let view = SAIAudioInputView()
            view.dataSource = self
            view.delegate = self
            _inputViews[item.identifier] = view
            return view
            
        case "kb:photo":
            let view = SAIPhotoInputView()
            //view.dataSource = self
            //view.delegate = self
            _inputViews[item.identifier] = view
            return view
            
        case "kb:emoticon":
            let view = SAIEmoticonInputView()
            view.delegate = self
            view.dataSource = self
            _inputViews[item.identifier] = view
            return view
            
        case "kb:toolbox":
            let view = SAIToolboxInputView()
            view.delegate = self
            view.dataSource = self
            _inputViews[item.identifier] = view
            return view
            
        default:
            return nil
        }
    }
    
    open func inputViewContentSize(_ inputView: UIView) -> CGSize {
        if isLandscape {
            return CGSize(width: view.frame.width, height: 193)
        }
        return CGSize(width: view.frame.width, height: 253)
    }
    
    open func inputBar(_ inputBar: SAIInputBar, shouldSelectFor item: SAIInputItem) -> Bool {
        
        class TVC : UIViewController {
            override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
                super.touchesBegan(touches, with: event)
                dismiss(animated: true, completion: nil)
            }
        }
        
        if item.identifier == "kb:video"  {
            let vc = UIViewController()
//            vc.view.backgroundColor = .random
            self.navigationController?.pushViewController(vc, animated: true)
        } else if item.identifier == "kb:camera" {
            let vc = TVC()
//            vc.view.backgroundColor = .random
            self.present(vc, animated: true, completion: nil)
        }
        
        guard let _ = inputView(with: item) else {
            return false
        }
        return true
    }
    open func inputBar(_ inputBar: SAIInputBar, didSelectFor item: SAIInputItem) {
        _logger.debug(item.identifier)
        
        _inputItem = item
        
        if let kb = inputView(with: item) {
            inputBar.setInputMode(.selecting(kb), animated: true)
        }
    }
    
    open func inputBar(didChangeMode inputBar: SAIInputBar) {
        _logger.debug(inputBar.inputMode)
        
        if let item = _inputItem, !inputBar.inputMode.isSelecting {
            inputBar.deselectBarItem(item, animated: true)
        }
    }
    
    open func inputBar(didChangeText inputBar: SAIInputBar) {
        _emoticonSendBtn.isEnabled = inputBar.attributedText.length != 0
    }
    
    public func inputBar(shouldReturn inputBar: SAIInputBar) -> Bool {
        // send text message
        send(forText: inputBar.attributedText)
        // clear current text
        inputBar.attributedText = nil
        // intercept return event
        return false
    }
}

// MARK: - SAIAudioInputViewDataSource & SAIAudioInputViewDelegate

extension SACChatViewController: SAIAudioInputViewDataSource, SAIAudioInputViewDelegate {
    
    open func numberOfAudioTypes(in audio: SAIAudioInputView) -> Int {
        return 3
    }
    open func audio(_ audio: SAIAudioInputView, audioTypeForItemAt index: Int) -> SAIAudioType {
        return SAIAudioType(rawValue: index)!
    }
    
    open func audio(_ audio: SAIAudioInputView, shouldStartRecord url: URL) -> Bool {
        return true
    }
    open func audio(_ audio: SAIAudioInputView, didStartRecord url: URL) {
        _logger.trace()
    }
    
    open func audio(_ audio: SAIAudioInputView, didRecordFailure url: URL, duration: TimeInterval) {
        _logger.trace("\(url)(\(duration))")
    }
    open func audio(_ audio: SAIAudioInputView, didRecordComplete url: URL, duration: TimeInterval) {
        _logger.trace("\(url)(\(duration))")
    }
}


// MARK: - SAIEmoticonInputViewDataSource & SAIEmoticonInputViewDelegate

extension SACChatViewController: SAIEmoticonInputViewDataSource, SAIEmoticonInputViewDelegate {
 
    open func numberOfEmotionGroups(in emoticon: SAIEmoticonInputView) -> Int {
        return _emoticonGroups.count
    }
    open func emoticon(_ emoticon: SAIEmoticonInputView, emotionGroupForItemAt index: Int) -> SAIEmoticonGroup {
        return _emoticonGroups[index]
    }
    open func emoticon(_ emoticon: SAIEmoticonInputView, numberOfRowsForGroupAt index: Int) -> Int {
        if isLandscape {
            return _emoticonGroups[index].rowsInLandscape
        }
        return _emoticonGroups[index].rows
    }
    open func emoticon(_ emoticon: SAIEmoticonInputView, numberOfColumnsForGroupAt index: Int) -> Int {
        if isLandscape {
            return _emoticonGroups[index].columnsInLandscape
        }
        return _emoticonGroups[index].columns
    }
    open func emoticon(_ emoticon: SAIEmoticonInputView, moreViewForGroupAt index: Int) -> UIView? { 
        if _emoticonGroups[index].type.isSmall {
            return _emoticonSendBtn
        } else {
            return _emoticonSettingBtn
        }
    }
    
    open func emoticon(_ emoticon: SAIEmoticonInputView, insetForGroupAt index: Int) -> UIEdgeInsets {
        if isLandscape {
            return UIEdgeInsetsMake(4, 12, 4 + 24, 12)
        }
        return UIEdgeInsetsMake(12, 10, 12 + 24, 10)
    }
    
    open func emoticon(_ emoticon: SAIEmoticonInputView, shouldSelectFor item: SAIEmoticon) -> Bool {
        return true
    }
    open func emoticon(_ emoticon: SAIEmoticonInputView, didSelectFor item: SAIEmoticon) {
        _logger.debug(item)
        
        // 如果是删除, 直接回退
        if item.isBackspace {
            _toolbar.deleteBackward()
            return
        }
        // 如果是大表情, 直接发送
        if let emoticon = item as? SACEmoticonLarge {
            send(forLargeEmoticon: emoticon)
            return
        }
        // 如果是ID, 直接显示
        if let code = item.contents as? String {
            return _toolbar.insertText(code)
        }
        // 如果是图片, 添加
        if let image = item.contents as? UIImage {
            // 获取当前字体的大小
            let d = _toolbar.font?.descender ?? 0
            let h = _toolbar.font?.lineHeight ?? 0
            
            let attachment = NSTextAttachment()
            
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: d, width: h, height: h)
            
            _toolbar.insertAttributedText(NSAttributedString(attachment: attachment))
            return
        }
    }
    
    open func emoticon(_ emoticon: SAIEmoticonInputView, shouldPreviewFor item: SAIEmoticon?) -> Bool {
        return true
    }
    open func emoticon(_ emoticon: SAIEmoticonInputView, didPreviewFor item: SAIEmoticon?) {
        _logger.debug("\(item)")
    }
}


// MARK: - SAIToolboxInputViewDataSource & SAIToolboxInputViewDelegate

extension SACChatViewController: SAIToolboxInputViewDataSource, SAIToolboxInputViewDelegate {
    
    open func numberOfToolboxItems(in toolbox: SAIToolboxInputView) -> Int {
        return _toolboxItems.count
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, toolboxItemForItemAt index: Int) -> SAIToolboxItem {
        return _toolboxItems[index]
    }
    
    open func toolbox(_ toolbox: SAIToolboxInputView, numberOfRowsForSectionAt index: Int) -> Int {
        return 2
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, numberOfColumnsForSectionAt index: Int) -> Int {
        if isLandscape {
            return 6
        }
        return 4
    }
    
    open func toolbox(_ toolbox: SAIToolboxInputView, insetForSectionAt index: Int) -> UIEdgeInsets {
        if isLandscape {
            return UIEdgeInsetsMake(4, 12, 4, 12)
        }
        return UIEdgeInsetsMake(12, 10, 12, 10)
    }
    
    open func toolbox(_ toolbox: SAIToolboxInputView, shouldSelectFor item: SAIToolboxItem) -> Bool {
        return true
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, didSelectFor item: SAIToolboxItem) {
        _logger.debug(item.identifier)
    }
    
    open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

extension SACChatView: SAIInputBarScrollViewType {
}

