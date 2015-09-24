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
        
        self.registerClass(SIMChatCellText.self, SIMChatContentText.self)
        self.registerClass(SIMChatCellAudio.self, SIMChatContentAudio.self)
        self.registerClass(SIMChatCellImage.self, SIMChatContentImage.self)
        
        self.registerClass(SIMChatCellTips.self, SIMChatContentTips.self)
        self.registerClass(SIMChatCellDate.self, SIMChatContentDate.self)
        
        self.registerClass(SIMChatCellUnknow.self, SIMChatContentUnknow.self)
        
        let s = SIMChatUser(identifier: "self", name: "sagesse", gender: 1, portrait: nil)
        let o = SIMChatUser(identifier: "other", name: "swift", gender: 2)
        let c = SIMChatConversation(recver: o, sender: s)
        
        
        self.conversation = c
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
    private var keyboard: UIView? {
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

    private var keyboardHiddenAnimation = false
    private var keyboardHeight: CGFloat = 0 {
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
    
    /// 最新的消息
    var latest: SIMChatMessage?
    /// 会话
    var conversation: SIMChatConversation! {
        willSet { self.conversation?.delegate = nil }
        didSet  { self.conversation?.delegate = self }
    }
    
    private(set) lazy var tableView = UITableView()
    private(set) lazy var textField = SIMChatTextField(frame: CGRectZero)
    
    /// 数据源
    private lazy var source = Array<SIMChatMessage>()
    /// 测试单元格
    private lazy var testers = Dictionary<String, SIMChatCell>()
    /// 类型单元格映射
    private lazy var relations = Dictionary<String, SIMChatCell.Type>()
    /// 所有的自定义键盘
    private lazy var keyboards = [SIMChatTextFieldItemStyle : UIView]()
}

/// MARK: - /// Content
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
            if message.content != nil {
                let type = NSStringFromClass(message.content!.dynamicType)
                if self.relations[type] != nil {
                    return type
                }
            }
            return NSStringFromClass(SIMChatContentUnknow.self)
        }()
        // 己经计算过了?
        if message.height != 0 {
            return message.height
        }
        // 获取测试单元格
        let cell = testers[key] ?? {
            let tmp = tableView.dequeueReusableCellWithIdentifier(key) as! SIMChatCell
            // 隐藏
            tmp.hidden = true
            tmp.enabled = false
            // 缓存
            self.testers[key] = tmp
            // 创建完成
            return tmp
        }()
        // 预更新大小
        cell.frame = CGRectMake(0, 0, tableView.bounds.width, tableView.rowHeight)
        // 加载数据
        cell.reloadData(message, ofUser: self.conversation.sender)
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
            if message.content != nil {
                let type = NSStringFromClass(message.content!.dynamicType)
                if self.relations[type] != nil {
                    return type
                }
            }
            return NSStringFromClass(SIMChatContentUnknow.self)
        }()
        // 获取单元格, 如果不存在则创建
        let cell = tableView.dequeueReusableCellWithIdentifier(key, forIndexPath: indexPath) as! SIMChatCell
        // 重新加载数据
        //cell.delegate = self
        cell.reloadData(message, ofUser: self.conversation.sender)
        // 完成.
        return cell
    }
}

/// MARK: - /// Content Event
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
//        let pt = scrollView.contentOffset
//        
//        //Log.debug("\(pt.y) \(targetContentOffset.memory.y)")
//        if pt.y < -scrollView.contentInset.top && targetContentOffset.memory.y <= -scrollView.contentInset.top {
//            dispatch_async(dispatch_get_main_queue()) {
//                //self.loadMore(nil)
//            }
//        }
    }
    /// 结束减速
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView === tableView && scrollView.contentOffset.y <= -scrollView.contentInset.top {
//            // 查询.
//            self.conversation.query(40, last: self.lastMessage) { [weak self]ms, e in
//                // 查询成功?
//                if let ms = ms as? [SIMChatMessage] {
//                    // 没有更多了
//                    if ms.count == 0 {
//                        return
//                    }
//                    // 还有继续插入
//                    self?.insertMessages(ms.reverse(), atIndex: 0, animated: true)
//                    self?.latest = ms.last
//                }
//            }
        }
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
                self.send(image: image!)
            }
        }
    }
    /// 开始选择图片
    func onImagePickerForPhoto() {
        SIMLog.trace()
        // 选择图片
        let picker = UIImagePickerController()
        
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        picker.modalPresentationStyle = .CurrentContext
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    /// 从摄像头选择
    func onImagePickerForCamera() {
        SIMLog.trace()
//        // 获取权限
//        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
//        
//        // 检查权限 
//        if status == .Restricted || status == .Denied {
//            // 没有权限 
//            UIAlertView(title: "提示", message: "请在设备的\"设置-隐私-相机\"中允许访问相机。", delegate: nil, cancelButtonTitle: "确定").show()
//            // end
//            return
//        }
        // 拍摄图片
        let picker = UIImagePickerController()
        
        // TODO: bug
        picker.sourceType = .Camera
        picker.delegate = self
        picker.editing = true
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
}

/// MARK: - /// Message
extension SIMChatViewController {
    ///
    /// 注册消息单元格
    ///
    /// :param: model   消息数据类
    /// :param: cell    消息显示的单元格
    ///
    func registerClass(cell: SIMChatCell.Type, _ model: AnyClass) {
        let key = NSStringFromClass(model)
        
        SIMLog.debug("\(key) => \(cell)")
        // 保存起来
        self.relations[key] = cell
        // 注册到tabelView
        self.tableView.registerClass(cell, forCellReuseIdentifier: key)
    }
    ///
    /// 批量插入消息, TODO: 需要优化
    ///
    /// :param: ms       消息
    /// :param: index    如果为index < 0, 插入点为count + index + 1
    /// :param: animated 动画
    ///
    func insertRows(ms: [SIMChatMessage], atIndex index: Int, animated: Bool = true) {
        SIMLog.trace()
        
        let st = 60.0
        
        let count = source.count
        let position = min(max(index >= 0 ? index : index + count + 1, 0), count)
        
        // tip1: 如果cell插入到visibleCells之前, 会导致content改变(contentOffset不变), 
        // tip2: 如果设置contentOffset会导致减速事件停止
        // tip3: insertRowsAtIndexPaths的动画需要强制去除
        // tip4: 不要在beginUpdates里面indexPath请求cell
        //
        // 插入位置:
        //     [  ] + [ms] + [ds]
        //     [ds] + [ms] + [ds]
        //     [ds] + [ms] + [  ]
        //
        
        // 检查是不是插入到visible之前
        //let small = tableView.contentSize.height < tableView.bounds.height
        var visibles = tableView.indexPathsForVisibleRows
        let reoffset = /*!small &&*/ visibles?.contains({ position < $0.row }) ?? false
        
        // 需要插入的indexPaths
        // 需要删除的indexPaths
        // 需要更新的indexPaths
        var inss = [NSIndexPath]()
        var dels = [NSIndexPath]()
        var upds = [NSIndexPath]()
        
        /// 准备数据 
        
        // 先搞到插入点之前的消息
        // 再搞到插入点之后的消息
        var first: SIMChatMessage? = position - 1 < count && position != 0 ? source[position - 1] : nil
        let last: SIMChatMessage? = position < count ? source[position] : nil
        
        // 格式化消息
        var fms = [SIMChatMessage]()
        for m in ms {
            // 两条消息时差为st
            // 那么添加一个时间分隔线
            if first == nil || fabs(first!.recvTime - m.recvTime) > st {
                var time: SIMChatMessage!
                // 如果前面的本来就是时间了.
                if first?.content is SIMChatContentDate {
                    
                    time = first
                    upds.append(NSIndexPath(forRow: position + fms.count - 1, inSection: 0))
                    
                } else {
                    
                    time = SIMChatMessage()
                    fms.append(time)
                }
                // 更新.
                time.makeDateWithMessage(m)
            }
            
            fms.append(m)
            first = m
        }
        
        // 检查最后一条数据的时间
        if first != nil && last != nil && !(fabs(first!.recvTime - last!.recvTime) > st) {
            
            // 删除 position + fms.count
            source.removeAtIndex(position)
            // 
            dels.append(NSIndexPath(forRow: position, inSection: 0))
            
            // 删除是谁?
            if visibles?[0].row == position {
                visibles?.removeAtIndex(0)
            }
            
            SIMLog.debug("delete \(position)")
        }
        
        /// 更新UI
        
        // 插入数据
        for e in EnumerateSequence(fms) {
            source.insert(e.element, atIndex: min(e.index + position, source.count))
            inss.append(NSIndexPath(forRow: e.index + position, inSection: 0))
        }
        
        // 在更新之前先获取到从contentOffset到visibles.first.top的偏移量
        let offset = !reoffset ? CGPointZero :  {
            // 获取origin
            let o = self.tableView.contentOffset
            // 禁止动画, 更新到top(会导致减速事件停止)
            UIView.performWithoutAnimation {
                self.tableView.scrollToRowAtIndexPath(visibles![0], atScrollPosition: .Top, animated: false)
            }
            // 获取top
            let t = self.tableView.contentOffset //: CGPointMake(0, -self.tableView.contentInset.top * 2)
            // ..
            SIMLog.debug("src: \(o)")
            SIMLog.debug("src offset: \(t)")
            // ok
            return CGPointMake(o.x - t.x, o.y - t.y)
        }()
        
        // 禁止动画, 更新
        UIView.performWithoutAnimation {
            self.tableView.beginUpdates()
            self.tableView.reloadRowsAtIndexPaths(upds, withRowAnimation: .None)
            self.tableView.deleteRowsAtIndexPaths(dels, withRowAnimation: .None)
            self.tableView.insertRowsAtIndexPaths(inss, withRowAnimation: .None)
            self.tableView.endUpdates()
        }
        
        // 需要更新?
        if reoffset {
            
            // 默认为0
            var idx = NSIndexPath(forRow: 0, inSection: 0)
            
            // 需要保持位置的cell
            if visibles!.count != 0 {
                idx = NSIndexPath(forRow: visibles![0].row + fms.count - dels.count, inSection: 0)
            }
            
            // 更新到Top
            UIView.performWithoutAnimation     {
                self.tableView.scrollToRowAtIndexPath(idx, atScrollPosition: .Top, animated: false)
            }
            // 获取TOP位置
            let t = self.tableView.contentOffset
            // 更新contentOffset
            self.tableView.setContentOffset(CGPointMake(t.x, t.y + offset.y), animated: false)
            
//            // 如果。
//            if small && animated {
//                self.tableView.setContentOffset(CGPointMake(t.x, t.y + offset.y + self.tableView.contentInset.top), animated: false)
//                UIView.animateWithDuration(0.25) {
//                    self.tableView.setContentOffset(CGPointMake(t.x, t.y + offset.y), animated: false)
//                }
//            }
            
            SIMLog.debug("index: \(idx.row)")
            SIMLog.debug("offset: \(offset)")
            SIMLog.debug("content offset: \(t)")
            SIMLog.debug("new content offset: \(self.tableView.contentOffset)")
        }
        
        // TODO: small && animated, 关于过小的问题
    }
    /// 
    /// 更新消息
    /// 
    /// :param: ms       消息
    /// :param: animated 动画
    /// 
    func reloadRows(ms: SIMChatMessage, animated: Bool = true) {
        SIMLog.trace()
        // 更新.
    }
    
    ///   
    /// 删除消息
    /// TODO: 需要优化!!!
    /// 
    /// :param: ms       消息
    /// :param: animated 动画
    ///   
    func deleteRows(m: SIMChatMessage, animated: Bool = true) {
        SIMLog.trace()
        
        //let st = 60.0
        var idxs = [Int]()
        
        if let idx = source.indexOf(m) {
            // 如果前一个是时间, 同时删除他
            if idx != 0 && idx - 1 < source.count && source[idx - 1].content is SIMChatContentDate {
                idxs.append(idx - 1) // 删除他
            }
            // 删除 。
            idxs.append(idx)
        }
        
        // 删除。
        for i in ReverseCollection(idxs) {
            source.removeAtIndex(i)
        }
        
        // 重新加载...
        let ani = !animated ? UIView.performWithoutAnimation : { b in b() }
        let style: UITableViewRowAnimation = (m.sender == self.conversation.sender) ? .Right : .Left
        
        ani { 
            self.tableView.deleteRowsAtIndexPaths(idxs.map({NSIndexPath(forRow: $0, inSection: 0)}), withRowAnimation: style)
        }
    }
    ///
    /// 清除所有消息
    ///
    func clearRows(animated: Bool = true) {
    }
    ///
    /// 追加消息.
    ///
    func appendMessage(m: SIMChatMessage) {
        
        let isSelf = m.sender == self.conversation.sender
        let isLasted = (tableView.indexPathsForVisibleRows?.last?.row ?? 0) + 1 == tableView.numberOfRowsInSection(0)
        
        
        self.insertRows([m], atIndex: -1)
        
        SIMLog.debug("self: \(isSelf) lasted: \(isLasted)")
        
        // 如果发送者是自己, 转到最后一行
        // 如果发送者是其他人, 并且当前行在最后一行, 转到最后一行
        if isSelf || isLasted {
            // 更新为己读
            self.conversation.read(m)
            // ok, 更新
            dispatch_async(dispatch_get_main_queue()) {
                let cnt = self.tableView.numberOfRowsInSection(0)
                let idx = NSIndexPath(forRow: cnt - 1, inSection: 0)
                
                self.tableView.scrollToRowAtIndexPath(idx, atScrollPosition: .Bottom, animated: true)
            }
        } else {
            // 更新未读数量
        }
    }
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
        case .Voice: kb = SIMChatKeyboardAudio()
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
            // Note: 在iPad这可能会有键盘高度不变但y改变的情况
            let h = self.view.bounds.height - r1.origin.y
            if self.keyboardHeight != h {
                SIMLog.trace()
                // 取消隐藏动画
                self.keyboardHiddenAnimation = false
                self.onKeyboardShow(CGRectMake(0, 0, r1.width, h))
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
        self.send(text: textField.text)
        self.textField.text = nil
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
        
        if item.tag == -1 {
            self.onImagePickerForPhoto()
        } else if item.tag == -2 {
            self.onImagePickerForCamera()
        }
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
    /// ...
    func chatTextFieldContentSizeDidChange(chatTextField: SIMChatTextField) {
//        // 填充动画更新
        UIView.animateWithDuration(0.25) {
            // 更新键盘高度
            self.view.layoutIfNeeded()
            self.keyboardHeight = self.keyboardHeight + 0
        }
    }
    /// ok
    func chatTextFieldShouldReturn(chatTextField: SIMChatTextField) -> Bool {
        // 发送.
        self.send(text: textField.text)
        self.textField.text = nil
        // 不可能return
        return false
    }
}

/// MARK: - /// Message Event
extension SIMChatViewController : SIMChatConversationDelegate {
    /// 发送消息通知
    func chatConversation(conversation: SIMChatConversation, didSendMessage message: SIMChatMessage) {
        dispatch_async(dispatch_get_main_queue()) {
            self.appendMessage(message)
        }
    }
    /// 新消息通知
    func chatConversation(conversation: SIMChatConversation, didReceiveMessage message: SIMChatMessage) {
        dispatch_async(dispatch_get_main_queue()) {
            self.appendMessage(message)
        }
    }
    /// 删除通知
    func chatConversation(conversation: SIMChatConversation, didRemoveMessage message: SIMChatMessage) {
        // 己删除  
        self.deleteRows(message)
    }
}

/// MARK: - /// Message Send
extension SIMChatViewController {
    ///
    /// 发送文本
    ///
    func send(text data: String?) {
        SIMLog.trace()
        
        // 不能为空
        guard let text = data where !text.isEmpty else {
            return
        }
        
        let m = SIMChatMessage()
        
        m.content = SIMChatContentText(text: data ?? "")
        
        // 发送
        self.conversation?.send(m)
    }
    ///
    /// 发送声音
    ///
    func send(audio data: NSData?, duration: NSTimeInterval) {
        SIMLog.trace()
        
        let m = SIMChatMessage()
        
        m.content = SIMChatContentAudio(data: data, duration: duration)
        
        // 发送
        self.conversation?.send(m)
    }
    ///
    /// 发送图片
    ///
    func send(image data: UIImage) {
        SIMLog.trace()
        
        let m = SIMChatMessage()
        
        m.content = SIMChatContentImage(origin: data, thumbnail: data)
        
        // 发送
        self.conversation?.send(m)
    }
    ///
    /// 发送自定义消息
    ///
    func send(custom data: AnyObject?) {
        
        let m = SIMChatMessage()
        
        m.content = data
        
        // 发送
        self.conversation?.send(m)
    }
}
