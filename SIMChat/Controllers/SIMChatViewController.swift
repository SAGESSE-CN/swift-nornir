//
//  SIMChatViewController.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SIMChatViewController: SIMViewController {
    
    /// 构建
    override func build() {
        super.build()
    }

    /// 加载完成
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vs = ["tf" : textField]
        
        
        // 设置背景
        view.backgroundColor = UIColor.clearColor()
        view.layer.contents =  SIMChatImageManager.defaultBackground?.CGImage
        view.layer.contentsGravity = kCAGravityResizeAspectFill//kCAGravityResize
        view.layer.masksToBounds = true
        // inputViewEx使用al
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(hex: 0xEBECEE)
        textField.delegate = self
        // tableView使用am
        tableView.frame = view.bounds
        tableView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = true
        tableView.rowHeight = 32
//        tableView.dataSource = self
//        tableView.delegate = self
        
        // add views
        
        // 第一个视图必须是tableView, addSubview(tableView)在ios7下有点bug?
        view.insertSubview(tableView, atIndex: 0)
        view.insertSubview(textField, aboveSubview: tableView)
        
        // add constraints
        view.addConstraints(NSLayoutConstraintMake("H:|[tf]|", views: vs))
        view.addConstraints(NSLayoutConstraintMake("V:[tf]|", views: vs))
        
        // add event
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "resignFirstResponder"))
    }
    /// 视图将要出现
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // add kvos
        let center = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: "onKeyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "onKeyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    /// 视图将要消失
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let center = NSNotificationCenter.defaultCenter()
        
        center.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    /// 放弃编辑
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
        return true
    }
    /// 当前使用的键盘
    private(set) var keyboard: UIView? {
        didSet {
            // 隐藏旧的.
            if let view = oldValue {
                // 通知
                self.onKeyboardHidden(keyboard?.bounds ?? CGRectZero, delay: textField.selectedStyle == .Keyboard)
                // 动画更新
                UIView.animateWithDuration(0.25) {
                    // .
                    view.layer.transform = CATransform3DMakeTranslation(0, 0, 1)
                }
            }
            // 显示新的
            if let view = keyboard {
                // 通知
                self.onKeyboardShow(view.frame)
                // 动画更新
                UIView.animateWithDuration(0.25) {
                    //
                    view.layer.transform = CATransform3DMakeTranslation(0, -view.bounds.height, 1)
                }
            }
        }
    }

    private(set) var keyboardStyle = 0
    private(set) var keyboardHiddenAnimation = false
    private(set) var keyboardHeight: CGFloat = 0 {
        willSet {
            
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
            SIMLog.debug("Keyboard Height: \(newValue), fix: \(NSStringFromUIEdgeInsets(fix))")
        }
    }
    
    private(set) lazy var tableView = UITableView()
    private(set) lazy var textField = SIMChatTextField(frame: CGRectZero)
    
    private(set) lazy var keyboards = [SIMChatTextFieldItemStyle : UIView]()
}

/// MARK: - /// Keyboard
extension SIMChatViewController {
    
    /// 获取键盘.
    func keyboard(style: SIMChatTextFieldItemStyle) -> UIView? {
        // 己经加载过了?
        if let view = keyboards[style] {
            return view
        }
        // 并没有
        var kb: UIView!
        // 创建.
        switch style {
        case .Emoji: kb = SIMChatKeyboardEmoji(delegate: self)
        case .Voice: kb = UIView()
        case .Tool:  kb = SIMChatKeyboardTool(delegate: self, dataSource: self)
        default:     kb = nil
        }
        // 并没有创建成功?
        guard kb != nil else {
            return nil
        }
        
        // config
        kb.translatesAutoresizingMaskIntoConstraints = false
        kb.backgroundColor = textField.backgroundColor
        // add view
        view.addSubview(kb)
        // add constraints
        view.addConstraint(NSLayoutConstraintMake(kb, .Left,  .Equal, view, .Left))
        view.addConstraint(NSLayoutConstraintMake(kb, .Right, .Equal, view, .Right))
        view.addConstraint(NSLayoutConstraintMake(kb, .Top,   .Equal, view, .Bottom))
        ///
        kb.layoutIfNeeded()
        // 缓存
        keyboards[style] = kb
        // ok
        return kb
    }
    /// 键盘显示
    func onKeyboardWillShow(sender: NSNotification) {
        // 获取高度
        if let r1 = sender.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
            if self.keyboardHeight != r1.height {
                SIMLog.trace()
                // 取消隐藏动画
                self.keyboardHiddenAnimation = false
                self.onKeyboardShow(r1)
            }
        }
    }
    /// 键盘隐藏
    func onKeyboardWillHide(sender: NSNotification) {
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
    func onKeyboardShow(frame: CGRect) {
        SIMLog.debug(frame)
        
        // 填充动画
        UIView.animateWithDuration(0.25) {
            // 更新键盘高度
            self.keyboardHeight = frame.height
        }
    }
    ///
    /// 工具栏显示 
    ///
    /// :param: frame 接下来键盘的大小
    /// :param: delay 是否需要延迟加载(键盘切换需要延迟一下)
    ///
    func onKeyboardHidden(frame: CGRect, delay: Bool = false) {
        SIMLog.debug("\(frame) \(delay)")
        
        let block = { () -> () in
            // 填充动画
            UIView.animateWithDuration(0.25) {
                // 更新键盘高度
                self.keyboardHeight = frame.height
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

/// MARK: - /// Extension Keyboard Emoji
extension SIMChatViewController : SIMChatKeyboardEmojiDelegate {
    /// 选择了表情
    func chatKeyboardEmoji(chatKeyboardEmoji: SIMChatKeyboardEmoji, didSelectEmoji emoji: String) {
        let src = textField.contentSize.height
        // = . =更新value
        textField.text = (textField.text ?? "") + emoji
        // 更新contetnOffset, 如果需要的话..
        if src != textField.contentSize.height {
            textField.scrollViewToBottom()
        }
    }
    /// 选择了后退
    func chatKeyboardEmojiDidDelete(chatKeyboardEmoji: SIMChatKeyboardEmoji) {
        let src = textField.contentSize.height
        var str = textField.text
        // ..
        if str?.endIndex != str?.startIndex {
            str = str.substringToIndex(str.endIndex.advancedBy(-1))
        }
        // =. =更差value
        textField.text = str
        // 更新contetnOffset, 如果需要的话..
        if src != textField.contentSize.height {
            textField.scrollViewToBottom()
        }
    }
    /// 发送
    func chatKeyboardEmojiDidReturn(chatKeyboardEmoji: SIMChatKeyboardEmoji) {
        SIMLog.debug("发送文本")
    }
}

/// MARK: - /// Extension Keyboard Tool
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
    }
}

/// MARK: - /// Extension Keyboard Audio
extension SIMChatViewController {
}

/// MARK: - /// Text Field
extension SIMChatViewController : SIMChatTextFieldDelegate {

    /// 选中..
    func chatTextField(chatTextField: SIMChatTextField, didSelectItem item: Int) {
        SIMLog.trace()
        if let style = SIMChatTextFieldItemStyle(rawValue: item) {
            self.keyboard = keyboard(style)
        }
    }
    
}
