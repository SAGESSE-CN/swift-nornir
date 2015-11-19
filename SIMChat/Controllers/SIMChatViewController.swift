//
//  SIMChatViewController.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SIMChatViewController: SIMViewController {
    /// 初始化
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /// 初始化
    init(conversation: SIMChatConversation) {
        super.init(nibName: nil, bundle: nil)
        self.conversation = conversation
        self.conversation.delegate = self
    }
    /// 释放
    deinit {
        SIMLog.trace()
        // 确保必须为空
        SIMChatNotificationCenter.removeObserver(self)
    }
    /// 构建
    override func build() {
        SIMLog.trace()
        
        super.build()
        
        self.buildOfMessage()
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
        tableView.dataSource = self
        tableView.delegate = self
        //
        maskView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        maskView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        // add views
        // 第一个视图必须是tableView, addSubview(tableView)在ios7下有点bug?
        view.insertSubview(tableView, atIndex: 0)
        view.insertSubview(textField, aboveSubview: tableView)
        
        //self.inputView = textField
        //self.inputAccessoryView = textField
        // add constraints
        view.addConstraints(NSLayoutConstraintMake("H:|-(0)-[tf]-(0)-|", views: vs))
        view.addConstraints(NSLayoutConstraintMake("V:[tf]|", views: vs))
        
        // add event
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "resignFirstResponder"))
        
        // 加载聊天历史
        dispatch_async(dispatch_get_main_queue()) {
            // 更新键盘
            self.updateKeyboard(height: 0)
            // 加载历史
            self.loadHistorys(40)
        }
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
        
        // 禁止播放
        SIMChatAudioManager.sharedManager.stop()
    }
    /// 放弃编辑
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    /// 最新的消息
    var latest: SIMChatMessage?
    /// 会话
    var conversation: SIMChatConversationProtocol! {
        willSet { conversation.delegate = nil  }
        didSet  { conversation.delegate = self }
    }
    
    private(set) lazy var maskView = UIView()
    private(set) lazy var tableView = UITableView()
    private(set) lazy var textField = SIMChatTextField(frame: CGRectZero)
  
    /// 数据源
    internal lazy var source = Array<SIMChatMessage>()
    
    /// 单元格
    internal lazy var testers = Dictionary<String, SIMChatMessageCellProtocol>()
    internal lazy var relations = Dictionary<String, SIMChatMessageCellProtocol.Type>()
    internal lazy var relationDefault = NSStringFromClass(SIMChatMessageContentUnknow.self)
    
    /// 自定义键盘
    internal lazy var keyboard = UIView?()
    internal lazy var keyboards = Dictionary<SIMChatTextFieldItemStyle, UIView>()
    internal lazy var keyboardHeight =  CGFloat(0)
    internal lazy var keyboardHiddenAnimation = false
}

// MARK: - Content
extension SIMChatViewController : UITableViewDataSource {
    /// 行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    /// 获取每一行的高度
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // 获取数据
        let message = source[indexPath.row]
        let key: String = {
            let type = NSStringFromClass(message.content.dynamicType)
            if self.relations[type] != nil {
                return type
            }
            return self.relationDefault
        }()
        // 己经计算过了?
        if message.height != 0 {
            return message.height
        }
        // 获取测试单元格
        let cell = testers[key] ?? {
            let tmp = tableView.dequeueReusableCellWithIdentifier(key) as! SIMChatMessageCell
            // 隐藏
            tmp.enabled = false
            // 缓存
            self.testers[key] = tmp
            // 创建完成
            return tmp
        }()
        // 更新环境
        if let cell = cell as? UIView {
            cell.frame = CGRectMake(0, 0, tableView.bounds.width, tableView.rowHeight)
        }
        cell.message = message
        // 计算高度
        message.height = cell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        // 检查结果
        SIMLog.debug("\(key): \(message.height)")
        // ok
        return message.height
    }
    ///
    /// 加载单元格
    ///
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 获取数据
        let message = source[indexPath.row]
        let key: String = {
            let type = NSStringFromClass(message.content.dynamicType)
            if self.relations[type] != nil {
                return type
            }
            return self.relationDefault
        }()
        // 获取单元格, 如果不存在则创建
        let cell = tableView.dequeueReusableCellWithIdentifier(key, forIndexPath: indexPath) as! SIMChatMessageCell
        // 更新环境
        cell.enabled = true
        cell.message = message
        cell.delegate = self
        // 完成.
        return cell
    }
}

// MARK: - Content Event
extension SIMChatViewController : UITableViewDelegate {
    /// 开始拖动
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView === tableView && textField.selectedStyle != .None {
            self.resignFirstResponder()
        }
    }
    ///
    /// 将要结束拖动
    ///
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //Log.debug(targetContentOffset.memory)
        // 
        // let pt = scrollView.contentOffset
        // 
        // //Log.debug("\(pt.y) \(targetContentOffset.memory.y)")
        // if pt.y < -scrollView.contentInset.top && targetContentOffset.memory.y <= -scrollView.contentInset.top {
        //     dispatch_async(dispatch_get_main_queue()) {
        //         //self.loadMore(nil)
        //     }
        // }
    }
    /// 结束减速
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView === tableView && scrollView.contentOffset.y <= -scrollView.contentInset.top {
            // self.loadHistorys(40, latest: self.latest)
        }
    }
}
