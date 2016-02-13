//
//  SIMChatViewController.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 聊天控制器
///
public class SIMChatViewController: UIViewController {
    ///
    /// 初始化
    ///
    public required init?(coder aDecoder: NSCoder) {
        fatalError("must use init(conversation:) initialze")
    }
    /// 初始化
    public required init(conversation: SIMChatConversationProtocol) {
        _conversation = conversation
        _messageManager = MessageManager(conversation: conversation)
        super.init(nibName: nil, bundle: nil)
        
        _messageManager.contentView = contentView
        
        hidesBottomBarWhenPushed = true
        
        let name = conversation.receiver.name ?? conversation.receiver.identifier
        if conversation.receiver.type == .User {
            title = "正在和\(name)聊天"
        } else {
            title = name
        }
    }
    deinit {
        SIMChatNotificationCenter.removeObserver(self)
        SIMLog.trace()
    }
    
    private var _contentViewLayout: SIMChatLayout?
    private var _inputBarLayout: SIMChatLayout?
    private var _inputPanelContainerLayout: SIMChatLayout?
    
    private var _lastKeyboardFrame: CGRect = CGRectZero
    
    private lazy var _contentView: UITableView = {
        let view = UITableView()
        return view
    }()
    private lazy var _inputPanelContainer: SIMChatInputPanelContainer = {
        let view = SIMChatInputPanelContainer(frame: CGRectZero)
        view.delegate = self
        return view
    }()
    private lazy var _inputBar: SIMChatInputBar = {
        let bar = SIMChatInputBar(frame: CGRectZero)
        let R = { (name: String) -> UIImage? in
            return UIImage(named: name)
        }
        bar.delegate = self
        bar.leftBarButtonItems = [
            SIMChatInputPanelAudioView.inputPanelItem()
        ]
        bar.rightBarButtonItems = [
            SIMChatInputPanelEmoticonView.inputPanelItem(),
            SIMChatInputPanelToolBoxView.inputPanelItem()
        ]
        // bar.bottomBarButtonItems = [
        //     SIMChatInputPanelAudioView.inputPanelItem(),
        //     SIMChatInputPanelEmoticonView.inputPanelItem(),
        //     SIMChatInputPanelToolBoxView.inputPanelItem()
        // ]
        return bar
    }()
    
    private var _forwarder: UIGestureRecognizerDelegateForwarder?
    private lazy var _backgroundView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    private lazy var _tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: "onResignKeyboard:")
        recognizer.delegate = self
        return recognizer
    }()
    
    private lazy var _inputPanelToolItems: [SIMChatInputItemProtocol] = {
        let R = { (n:String) -> UIImage? in
            SIMChatBundle.imageWithResource("InputPanel/\(n).png")
        }
        return [
            SIMChatInputToolBoxItem("page:voip", "网络电话", R("tool_voip")),
            SIMChatInputToolBoxItem("page:video", "视频电话", R("tool_video")),
            SIMChatInputToolBoxItem("page:video_s", "短视频", R("tool_video_short")),
            SIMChatInputToolBoxItem("page:favorite", "收藏", R("tool_favorite")),
            SIMChatInputToolBoxItem("page:red_pack", "发红包", R("tool_red_pack")),
            SIMChatInputToolBoxItem("page:transfer", "转帐", R("tool_transfer")),
            SIMChatInputToolBoxItem("page:shake", "抖一抖", R("tool_shake")),
            SIMChatInputToolBoxItem("page:file", "文件", R("tool_folder")),
            SIMChatInputToolBoxItem("page:camera", "照相机", R("tool_camera")),
            SIMChatInputToolBoxItem("page:pic", "相册", R("tool_pic")),
            SIMChatInputToolBoxItem("page:ptt", "录音", R("tool_ptt")),
            SIMChatInputToolBoxItem("page:music", "音乐", R("tool_music")),
            SIMChatInputToolBoxItem("page:location", "位置", R("tool_location")),
            SIMChatInputToolBoxItem("page:nameplate", "名片",   R("tool_share_nameplate")),
            SIMChatInputToolBoxItem("page:aa", "AA制", R("tool_aa_collection")),
            SIMChatInputToolBoxItem("page:gapp", "群应用", R("tool_group_app")),
            SIMChatInputToolBoxItem("page:gvote", "群投票", R("tool_group_vote")),
            SIMChatInputToolBoxItem("page:gvideo", "群视频", R("tool_group_video")),
            SIMChatInputToolBoxItem("page:gtopic", "群话题", R("tool_group_topic")),
            SIMChatInputToolBoxItem("page:gactivity", "群活动", R("tool_group_activity"))
        ]
    }()
    
    private var _conversation: SIMChatConversationProtocol
    private var _messageManager: MessageManager
    
    internal var messageManager: MessageManager { return _messageManager }
}

// MARK: - Public Propertys

extension SIMChatViewController {
    ///
    /// 聊天会话
    ///
    public var conversation: SIMChatConversationProtocol { return _conversation }
    ///
    /// 内容
    ///
    public var contentView: UITableView { return _contentView }
    public var contentViewLayout: SIMChatLayout? { return _contentViewLayout }
    ///
    /// 输入栏
    ///
    public var inputBar: SIMChatInputBar { return _inputBar }
    public var inputBarLayout: SIMChatLayout? { return _inputBarLayout }
    ///
    /// 输入面板(选择表情之类的)
    ///
    public var inputPanelContainer: SIMChatInputPanelContainer { return _inputPanelContainer }
    public var inputPanelContainerLayout: SIMChatLayout? { return _inputPanelContainerLayout }
    ///
    /// 聊天背景
    ///
    public var backgroundView: UIImageView { return _backgroundView }
    
}

extension SIMChatViewController {
    
    ///
    /// 输入面板
    ///
    public var inputPanelToolItems: Array<SIMChatInputItemProtocol> {
        return _inputPanelToolItems
    }
    
    ///
    /// 系统当前的键盘大小
    ///
    public var systemKeyboardFrame: CGRect {
        set { return _lastKeyboardFrame = newValue }
        get { return _lastKeyboardFrame }
    }
}

// MARK: - Life Cycle

extension SIMChatViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        SIMLog.trace()
        
        // 背景
        backgroundView.accessibilityLabel = "聊天背景"
        backgroundView.frame = view.bounds
        backgroundView.image = SIMChatImageManager.defaultBackground
        backgroundView.contentMode = .ScaleToFill
        backgroundView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        // 内容
        contentView.accessibilityLabel = "聊天内容"
        contentView.backgroundColor = .clearColor()
        contentView.showsHorizontalScrollIndicator = false
        contentView.showsVerticalScrollIndicator = false
        contentView.separatorStyle = .None
        
        inputBar.accessibilityLabel = "底部输入栏"
        inputPanelContainer.accessibilityLabel = "底部输入面板"
        
        // add event
        contentView.addGestureRecognizer(_tapGestureRecognizer)
        
        view.addSubview(backgroundView)
        view.addSubview(contentView)
        view.addSubview(inputBar)
        view.addSubview(inputPanelContainer)
        
        // 添加布局
        _contentViewLayout = SIMChatLayout.make(contentView)
            .top.equ(view).top
            .left.equ(view).left
            .right.equ(view).right
            .bottom.equ(view).bottom
            .submit()
        
        _inputBarLayout = SIMChatLayout.make(inputBar)
            .top.gte(view).top
            .left.equ(view).left
            .right.equ(view).right
            .bottom.equ(view).bottom
            .submit()
        
        _inputPanelContainerLayout = SIMChatLayout.make(inputPanelContainer)
            .top.equ(view).bottom
            .left.equ(view).left
            .right.equ(view).right
            .submit()
        
        SIMChatNotificationCenter.addObserver(self,
            selector: "onInputBarChangeNtf:",
            name: SIMChatInputBarFrameDidChangeNotification)
        
        // 初始化工作
        view.layoutIfNeeded()
        setKeyboardHeight(0, animated: false)
        
        _messageManager.prepare()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "onKeyboardShowNtf:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "onKeyboardHideNtf:", name: UIKeyboardWillHideNotification, object: nil)
        
        // 添加转发
        if let recognizer = navigationController?.interactivePopGestureRecognizer {
            _forwarder = UIGestureRecognizerDelegateForwarder(recognizer.delegate, to: [self])
            recognizer.delegate = _forwarder
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 禁止播放
        SIMChatAudioManager.sharedManager.stop()
        
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
        // 恢复原样
        if let recognizer = navigationController?.interactivePopGestureRecognizer {
            recognizer.delegate = _forwarder?.orign
            _forwarder = nil
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        // 更新inset, 否则tableView显示区域错误
        var edg = contentView.contentInset
        edg.top = topLayoutGuide.length + -(contentViewLayout?.top ?? 0)
        contentView.contentInset = edg
    }
}

extension SIMChatViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer == _tapGestureRecognizer {
            return !SIMChatMenuController.sharedMenuController().isCustomMenu()
        }
        if gestureRecognizer is UIScreenEdgePanGestureRecognizer {
            let pt = touch.locationInView(view)
            return !inputBar.frame.contains(pt) && !inputPanelContainer.frame.contains(pt)
        }
        return true
    }
}

////    init(conversation: SIMChatConversation) {
////        super.init(nibName: nil, bundle: nil)
////        self.conversation = conversation
////        self.conversation.delegate = self
////    }
//    /// 释放
//    deinit {
//        SIMLog.trace()
//        // 确保必须为空
//        SIMChatNotificationCenter.removeObserver(self)
//    }
////    /// 构建
////    override func build() {
////        SIMLog.trace()
////        
////        super.build()
////        
////        self.buildOfMessage()
////    }
//    
//    /// 加载完成
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let vs = ["tf" : textField]
//        
//        // 设置背景
//        view.backgroundColor = UIColor.clearColor()
//        view.layer.contents =  SIMChatImageManager.defaultBackground?.CGImage
//        view.layer.contentsGravity = kCAGravityResizeAspectFill//kCAGravityResize
//        view.layer.masksToBounds = true
//        // inputViewEx使用al
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.backgroundColor = UIColor(hex: 0xEBECEE)
//        textField.delegate = self
//        // tableView使用am
//        tableView.frame = view.bounds
//        tableView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
//        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
//        tableView.backgroundColor = UIColor.clearColor()
//        tableView.showsHorizontalScrollIndicator = false
//        tableView.showsVerticalScrollIndicator = true
//        tableView.rowHeight = 32
//        tableView.dataSource = self
//        tableView.delegate = self
//        //
//        maskView.backgroundColor = UIColor(white: 0, alpha: 0.2)
//        maskView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
//        
//        // add views
//        // 第一个视图必须是tableView, addSubview(tableView)在ios7下有点bug?
//        view.insertSubview(tableView, atIndex: 0)
//        view.insertSubview(textField, aboveSubview: tableView)
//        
//        //self.inputView = textField
//        //self.inputAccessoryView = textField
//        // add constraints
//        view.addConstraints(NSLayoutConstraintMake("H:|-(0)-[tf]-(0)-|", views: vs))
//        view.addConstraints(NSLayoutConstraintMake("V:[tf]|", views: vs))
//        
//        // add event
//        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "resignFirstResponder"))
//        
//        // 加载聊天历史
//        dispatch_async(dispatch_get_main_queue()) {
//            // 更新键盘
//            self.updateKeyboard(height: 0)
//            // 加载历史
//            self.loadHistorys(40)
//        }
//    }
//    
//    /// 视图将要出现
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        // add kvos
//        let center = NSNotificationCenter.defaultCenter()
//        
//        center.addObserver(self, selector: "onKeyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
//        center.addObserver(self, selector: "onKeyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
//    }
//    /// 视图将要消失
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        let center = NSNotificationCenter.defaultCenter()
//        
//        center.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
//        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
//        
//        // 禁止播放
//        SIMChatAudioManager.sharedManager.stop()
//    }
//    /// 放弃编辑
//    override func resignFirstResponder() -> Bool {
//        return textField.resignFirstResponder()
//    }
//    
//    /// 最新的消息
//    var latest: SIMChatMessage?
//    /// 会话
//    var conversation: SIMChatConversationProtocol! {
//        willSet { conversation.delegate = nil  }
//        didSet  { conversation.delegate = self }
//    }
//    
//    private(set) lazy var maskView = UIView()
//    private(set) lazy var tableView = UITableView()
//    private(set) lazy var textField = SIMChatInputBar(frame: CGRectZero)
//  
//    /// 数据源
//    internal lazy var source = Array<SIMChatMessage>()
//    
//    /// 单元格
//    internal lazy var testers = Dictionary<String, SIMChatMessageCellProtocol>()
//    internal lazy var relations = Dictionary<String, SIMChatMessageCellProtocol.Type>()
//    internal lazy var relationDefault = NSStringFromClass(SIMChatMessageContentUnknow.self)
//    
//    /// 自定义键盘
//    internal lazy var keyboard = UIView?()
//    internal lazy var keyboards = Dictionary<SIMChatInputBarItemStyle, UIView>()
//    internal lazy var keyboardHeight =  CGFloat(0)
//    internal lazy var keyboardHiddenAnimation = false
//}
//
//// MARK: - Content
//extension SIMChatViewController : UITableViewDataSource {
//    /// 行数
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return source.count
//    }
//    /// 获取每一行的高度
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        // 获取数据
//        let message = source[indexPath.row]
//        let key: String = {
//            let type = NSStringFromClass(message.content.dynamicType)
//            if self.relations[type] != nil {
//                return type
//            }
//            return self.relationDefault
//        }()
//        // 己经计算过了?
//        if message.height != 0 {
//            return message.height
//        }
//        // 获取测试单元格
//        let cell = testers[key] ?? {
//            let tmp = tableView.dequeueReusableCellWithIdentifier(key) as! SIMChatMessageCell
//            // 隐藏
//            tmp.enabled = false
//            // 缓存
//            self.testers[key] = tmp
//            // 创建完成
//            return tmp
//        }()
//        // 更新环境
//        if let cell = cell as? UIView {
//            cell.frame = CGRectMake(0, 0, tableView.bounds.width, tableView.rowHeight)
//        }
//        cell.message = message
//        // 计算高度
//        message.height = cell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
//        // 检查结果
//        SIMLog.debug("\(key): \(message.height)")
//        // ok
//        return message.height
//    }
//    ///
//    /// 加载单元格
//    ///
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        // 获取数据
//        let message = source[indexPath.row]
//        let key: String = {
//            let type = NSStringFromClass(message.content.dynamicType)
//            if self.relations[type] != nil {
//                return type
//            }
//            return self.relationDefault
//        }()
//        // 获取单元格, 如果不存在则创建
//        let cell = tableView.dequeueReusableCellWithIdentifier(key, forIndexPath: indexPath) as! SIMChatMessageCell
//        // 更新环境
//        cell.enabled = true
//        cell.message = message
//        cell.delegate = self
//        // 完成.
//        return cell
//    }
//}
//
//// MARK: - Content Event
//extension SIMChatViewController : UITableViewDelegate {
//    /// 开始拖动
//    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//        if scrollView === tableView && textField.selectedStyle != .None {
//            self.resignFirstResponder()
//        }
//    }
//    ///
//    /// 将要结束拖动
//    ///
//    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        //Log.debug(targetContentOffset.memory)
//        // 
//        // let pt = scrollView.contentOffset
//        // 
//        // //Log.debug("\(pt.y) \(targetContentOffset.memory.y)")
//        // if pt.y < -scrollView.contentInset.top && targetContentOffset.memory.y <= -scrollView.contentInset.top {
//        //     dispatch_async(dispatch_get_main_queue()) {
//        //         //self.loadMore(nil)
//        //     }
//        // }
//    }
//    /// 结束减速
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        if scrollView === tableView && scrollView.contentOffset.y <= -scrollView.contentInset.top {
//            // self.loadHistorys(40, latest: self.latest)
//        }
//    }
//}


