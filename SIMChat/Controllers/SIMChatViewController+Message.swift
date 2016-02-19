//
//  SIMChatViewController+Message.swift
//  SIMChat
//
//  Created by sagesse on 9/26/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit


extension SIMChatViewController {
    class MessageManager: NSObject {
        init(conversation: SIMChatConversationProtocol) {
            self.allMessages = []
            self.conversation = conversation
            super.init()
            self.conversation.delegate = self
        }
        
        private var allMessages: Array<SIMChatMessageProtocol>
        private var conversation: SIMChatConversationProtocol
        
        private var isLoading: Bool = false
        
        /// 快速映射
        private var _fastMap: Dictionary<String, String> = [:]
        
        var durationInterval: NSTimeInterval = 10
        
        lazy var header: UIView = {
            let view = UIView(frame: CGRectMake(0, 0, 320, 44))
            let ac = UIActivityIndicatorView(frame: CGRectMake(0, 0, 20, 20))
            
            ac.center = CGPointMake(view.frame.midX, view.frame.midY)
            ac.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
            ac.activityIndicatorViewStyle = .Gray
            ac.startAnimating()
            
            view.clipsToBounds = true
            view.addSubview(ac)
            
            return view
        }()
        
        var contentView: UITableView? {
            didSet {
                oldValue?.delegate = nil
                oldValue?.dataSource = nil
                //oldValue?.alpha = 1
                oldValue?.tableHeaderView = nil
                
                contentView?.delegate = self
                contentView?.dataSource = self
                //contentView?.alpha = 0
                contentView?.tableHeaderView = header
            }
        }
        
        private var manager: SIMChatManagerProtocol {
            guard let manager = conversation.manager else {
                fatalError("Must provider manager")
            }
            return manager
        }
    }
}

extension SIMChatViewController.MessageManager: UITableViewDelegate, UITableViewDataSource, SIMChatMessageCellDelegate, SIMChatMessageCellMenuDelegate, SIMChatConversationDelegate {
    /// some prepare
    func prepare() {
        // reigster all cell class
        manager.classProvider.registeredAllCells().forEach {
            self.contentView?.registerClass($0.1, forCellReuseIdentifier: $0.0)
            SIMLog.debug("\($0.0) => \(NSStringFromClass($0.1))")
        }
        // load
        dispatch_async(dispatch_get_main_queue()) {
            self._loadHistoryMessages()
        }
    }
    /// query reuseindentifier with message
    private func reuseIndentifierWithMessage(message: SIMChatMessageProtocol) -> String {
        // 获取前置类型
        if message.status == .Revoked {
            return SIMChatMessageRevokedContentKey
        }
        if message.status == .Destroyed {
            return SIMChatMessageDestoryedContentKey
        }
        if message.content is SIMChatBaseMessageTimeLineContent {
            return SIMChatMessageTimeLineContentKey
        }
        let key = NSStringFromClass(message.content.dynamicType)
        // 读取
        return _fastMap[key] ?? {
            var ds = SIMChatMessageUnknowContentKey
            // 查找可以使用的key
            if let x = manager.classProvider.registeredCell(message.content) {
                ds = x.0
            }
            // 快速缓存
            _fastMap[key] = ds
            return ds
        }()
    }
    
    /// 存在timeline
    private func _hasTimeLine(prev: SIMChatMessageProtocol?, _ next: SIMChatMessageProtocol?) -> Bool {
        return prev?.content is SIMChatBaseMessageTimeLineContent
            || next?.content is SIMChatBaseMessageTimeLineContent
    }
    
    /// 需要生成timeline
    private func _needMakeTimeLine(prev: SIMChatMessageProtocol?, _ next: SIMChatMessageProtocol?) -> Bool {
        // next必须存在并且要可以显示timeline
        guard let next = next where next.showsTimeLine else {
            return false
        }
        // next是时间, 表示己经创建
        if next.content is SIMChatBaseMessageTimeLineContent {
            return false
        }
        // prev可以不存在, 但如果存在就必须符合条件
        guard let prev = prev else {
            return true
        }
        // 如果上一个消息是时间, 表示己经创建过了.
        if prev.content is SIMChatBaseMessageTimeLineContent {
            return false
        }
        // 如果上一个不允许显示时间, 那就必须显示
        guard prev.showsTimeLine else {
            return true
        }
        // 都符合就检查时间
        return fabs(prev.date.timeIntervalSinceDate(next.date)) >= durationInterval
    }
    
    /// 需要移除
    private func _needRemoveTimeLine(prev: SIMChatMessageProtocol?, _ next: SIMChatMessageProtocol?) -> Bool {
        // 两个都是timeline
        if next?.content is SIMChatBaseMessageTimeLineContent
            && prev?.content is SIMChatBaseMessageTimeLineContent {
            return true
        }
        // 两个都不是timeline
        if !(next?.content is SIMChatBaseMessageTimeLineContent)
            && !(prev?.content is SIMChatBaseMessageTimeLineContent) {
            return false
        }
        // 必须要有创建才有删除
        if let _ = prev?.content as? SIMChatBaseMessageTimeLineContent {
            guard let nextMessage = next else {
                // 没有下一条了, 需要删除
                return true
            }
            if !nextMessage.showsTimeLine {
                // 不允许显示timeline
                return true
            }
        }
        if let _ = next?.content as? SIMChatBaseMessageTimeLineContent {
            guard let prevMessage = prev else {
                // 这是第一条
                return false
            }
            if !prevMessage.showsTimeLine {
                // 上一条消息不允许显示timeline, 那么这个就可以直接显示
                return false
            }
        }
        guard let next = next, prev = prev else {
            return false
        }
        // 计算
        return fabs(prev.date.timeIntervalSinceDate(next.date)) < durationInterval
    }
    
    /// 生成timeline
    private func _makeTimeLine(frontMessage: SIMChatMessageProtocol?, _ backMessage: SIMChatMessageProtocol?) -> SIMChatMessageProtocol {
        let content = SIMChatBaseMessageTimeLineContent(frontMessage: frontMessage, backMessage: backMessage)
        let messageClass = manager.classProvider.message
        let message = messageClass.messageWithContent(content,
            receiver: conversation.receiver,
            sender: conversation.sender)
        return message
    }
    
    
    // MARK: UITableViewDataSource
    
    /// 消息数量
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMessages.count
    }
    /// 计算高度
    @objc func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let message = allMessages[indexPath.row]
        let identifier = reuseIndentifierWithMessage(message)
        return tableView.fd_heightForCellWithIdentifier(identifier, cacheByKey: message.identifier) {
            if let mcell = $0 as? SIMChatMessageCellProtocol {
                // configuation
                mcell.conversation = self.conversation
                mcell.message = message
            }
        }
    }
    /// 创建
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = reuseIndentifierWithMessage(allMessages[indexPath.row])
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        
        // default configuation
        cell.selectionStyle = .None
        cell.backgroundColor = .clearColor()
        cell.clipsToBounds = true
        //cell.backgroundColor = indexPath.row <= 1 ? .orangeColor() : .clearColor()
        //cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.purpleColor() : UIColor.orangeColor()
        
        return cell
    }
    
    // MARK: UIScrollViewDelegate
    
    @objc func scrollViewDidScroll(scrollView: UIScrollView) {
//        SIMLog.debug("offset: \(scrollView.contentOffset)")
    }
    /// 开始拖动
    @objc func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//        SIMLog.trace()
//        scrollView.window?.endEditing(true)
//        SIMLog.debug("offset: \(scrollView.contentOffset)")
    }
    @objc func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        SIMLog.debug("offset: \(scrollView.contentOffset)")
//        SIMLog.debug("startOffsetY: \(scrollView.valueForKey("_startOffsetY"))")
//        SIMLog.debug("lastUpdateOffsetY: \(scrollView.valueForKey("_lastUpdateOffsetY"))")
    }
    /// 结束拖动
    @objc func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !scrollView.decelerating else {
            return
        }
        // 因为如果拖动的距离不足以支持滑动的话, scrollViewDidEndDecelerating是不会被调用的, 手动模拟一次
        scrollViewDidEndDecelerating(scrollView)
    }
    /// 结束滑动
    @objc func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        //SIMLog.trace(scrollView.contentOffset)
        // 允许加载更多并且没有正在加载
        guard contentView?.tableHeaderView != nil && !isLoading else {
            return
        }
        if scrollView.contentInset.top + scrollView.contentOffset.y <= header.frame.height {
            _loadHistoryMessages()
        }
    }
    /// 移到头部
    @objc func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        guard contentView?.tableHeaderView != nil && !isLoading else {
            return
        }
        _loadHistoryMessages()
    }
    
    // MARK: UITableViewDataSource
    
    /// 绑定
    @objc func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let message = allMessages[indexPath.row]
        if let mcell = cell as? SIMChatMessageCellProtocol {
            // custom configuation
            mcell.conversation = self.conversation
            mcell.message = message
            mcell.delegate = self
        }
    }

    // MARK: SIMChatConversationDelegate
    
    func conversation(conversation: SIMChatConversationProtocol, didReciveMessage message: SIMChatMessageProtocol) {
    }
    
    func conversation(conversation: SIMChatConversationProtocol, didRemoveMessage message: SIMChatMessageProtocol) {
    }
    
    func conversation(conversation: SIMChatConversationProtocol, didUpdateMessage message: SIMChatMessageProtocol) {
    }
    
    // MARK: SIMChatMessageCellDelegate
    
    // 点击消息
    func cellEvent(cell: SIMChatMessageCellProtocol, shouldPressMessage message: SIMChatMessageProtocol) -> Bool {
        return true
    }
    // 点击消息
    func cellEvent(cell: SIMChatMessageCellProtocol, didPressMessage message: SIMChatMessageProtocol) {
        SIMLog.debug(message.identifier)
        
        if message.content is SIMChatBaseMessageAudioContent {
            manager.mediaProvider.playWithMessage(message)
        }
    }
    
    // 长按消息
    func cellEvent(cell: SIMChatMessageCellProtocol, shouldLongPressMessage message: SIMChatMessageProtocol) -> Bool {
        return true
    }
    // 长按消息
    func cellEvent(cell: SIMChatMessageCellProtocol, didLongPressMessage message: SIMChatMessageProtocol) {
        SIMLog.debug(message.identifier)
        
        if let cell = cell as? SIMChatBaseMessageBubbleCell {
            // 准备菜单
            let mu = SIMChatMenuController.sharedMenuController()
            let responder = cell.window?.findFirstResponder()
            
            // 检查第一响应者, 如果为空或者是cell, 重新激活
            if responder == nil || responder is SIMChatBaseMessageBubbleCell {
                cell.becomeFirstResponder()
            }
            
            mu.menuItems = cell.bubbleMenuItems
            mu.showMenu(cell, withRect: cell.bubbleView.frame, inView: cell)
        }
    }
    
    // 点击用户
    func cellEvent(cell: SIMChatMessageCellProtocol, shouldPressUser user: SIMChatUserProtocol) -> Bool {
        return true
    }
    // 点击用户
    func cellEvent(cell: SIMChatMessageCellProtocol, didPressUser user: SIMChatUserProtocol) {
        SIMLog.debug(user.identifier)
    }
    
    // 长按用户
    func cellEvent(cell: SIMChatMessageCellProtocol, shouldLongPressUser user: SIMChatUserProtocol) -> Bool {
        return true
    }
    // 长按用户
    func cellEvent(cell: SIMChatMessageCellProtocol, didLongPressUser user: SIMChatUserProtocol) {
        SIMLog.debug(user.identifier)
    }
    
    // MARK: SIMChatMessageCellMenuDelegate
    
    // 复制
    func cellMenu(cell: SIMChatMessageCellProtocol, shouldCopyMessage message: SIMChatMessageProtocol) -> Bool {
        return true
    }
    // 复制
    func cellMenu(cell: SIMChatMessageCellProtocol, didCopyMessage message: SIMChatMessageProtocol) {
        SIMLog.debug(message.identifier)
    }
    
    // 删除
    func cellMenu(cell: SIMChatMessageCellProtocol, shouldRemoveMessage message: SIMChatMessageProtocol) -> Bool {
        return true
    }
    // 删除
    func cellMenu(cell: SIMChatMessageCellProtocol, didRemoveMessage message: SIMChatMessageProtocol) {
        SIMLog.debug(message.identifier)
        // 真正的删除消息
        conversation.removeMessage(message).response {
            do {
                if let error = $0.error {
                    throw error
                }
                // 删除消息(更新UI)
                self._removeMessages([message], animated: true)
            } catch let error as NSError {
                SIMLog.error(error)
            }
        }
    }
    
    /// 重试(发送/上传/下载)
    func cellMenu(cell: SIMChatMessageCellProtocol, shouldRetryMessage message: SIMChatMessageProtocol) -> Bool {
        return true
    }
    /// 重试(发送/上传/下载)
    func cellMenu(cell: SIMChatMessageCellProtocol, didRetryMessage message: SIMChatMessageProtocol) {
        SIMLog.debug(message.identifier)
    }
    
    // 撤销
    func cellMenu(cell: SIMChatMessageCellProtocol, shouldRevokeMessage message: SIMChatMessageProtocol) -> Bool {
        return true
    }
    // 撤销
    func cellMenu(cell: SIMChatMessageCellProtocol, didRevokeMessage message: SIMChatMessageProtocol) {
        SIMLog.debug(message.identifier)
        // 更新状态为revoked
        message.status = .Revoked
        // 更新
        _reloadMessages([message], animated: true)
    }
    
    // MARK: Message Operator
    
    
    ///
    /// 批量插入消息
    ///
    /// - parameter ms:       消息集合
    /// - parameter index:    如果为index < 0, 插入点为count + index + 1
    ///
    private func _insertMessages(ms: Array<SIMChatMessageProtocol>, atIndex index: Int) {
        guard let tableView = contentView where !ms.isEmpty else {
            return
        }
        SIMLog.trace()

        let count = allMessages.count
        let position = min(max(index >= 0 ? index : index + count + 1, 0), count)

        // tip1: 如果cell插入到visibleCells之前, 会导致contentSize改变(contentOffset不变),
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
        var visibleIndexPaths = tableView.indexPathsForVisibleRows
        var needResetOffset = /*!small &&*/ visibleIndexPaths?.contains({ position < $0.row }) ?? false
        
        // 需要插入的indexPaths
        // 需要删除的indexPaths
        var insertIndexPaths: Array<NSIndexPath> = []
        var removeIndexPaths: Array<NSIndexPath> = []
        var reloadIndexPaths: Array<NSIndexPath> = []
        
        /// 准备数据
        
        // 先获取插入点前后的消息
        var first: SIMChatMessageProtocol? = (position - 1 < count && position > 0) ? allMessages[position - 1] : nil
        let last: SIMChatMessageProtocol? = (position < count) ? allMessages[position] : nil
        
        var newMessages: Array<SIMChatMessageProtocol> = []
        
        // 格式化消息
        ms.forEach { m in
            // 如果消息是隐藏的跳过
            guard !m.option.contains(.Hidden) else {
                return
            }
            defer {
                first = m
                newMessages.append(m)
            }
            guard _needMakeTimeLine(first, m) else {
                // 检查不是是己经创建过了, 如果己经创建过了, 更新他
                if let content = first?.content as? SIMChatBaseMessageTimeLineContent {
                    content.frontMessage = first
                    content.backMessage = m
                }
                return
            }
            newMessages.append(_makeTimeLine(first, m))
        }
        
        // 检查最后一条数据的timeline
        // 必须要显示时间线才添加timeline
        if let prevMessage = newMessages.last, nextMessage = last {
            // 检查是否需要创建timeline
            if _needMakeTimeLine(prevMessage, nextMessage) {
                SIMLog.debug("add date at \(position)")
                newMessages.append(_makeTimeLine(prevMessage, nextMessage))
            } else if _needRemoveTimeLine(prevMessage, nextMessage) {
                SIMLog.debug("remove date at \(position)")
                removeIndexPaths.append(NSIndexPath(forRow: position, inSection: 0))
                allMessages.removeAtIndex(position)
                // 删除是谁?
                if visibleIndexPaths?[0].row == position {
                    visibleIndexPaths?.removeAtIndex(0)
                }
            } else if _hasTimeLine(prevMessage, nextMessage) {
                // 需要更新
                if let content = nextMessage.content as? SIMChatBaseMessageTimeLineContent {
                    content.frontMessage = prevMessage
                    content.backMessage = nextMessage
                    reloadIndexPaths.append(NSIndexPath(forRow: position, inSection: 0))
                }
            }
        }
        
        /// 如果并没有任何新消息(即全部是隐藏消息), 直接终止函数
        guard !newMessages.isEmpty else {
            SIMLog.debug("new message all is hidden")
            return
        }

        /// 更新UI
        
        // 插入数据
        newMessages.enumerate().forEach {
            insertIndexPaths.append(NSIndexPath(forRow: $0.index + position, inSection: 0))
            allMessages.insert($0.element, atIndex: min($0.index + position, allMessages.count))
        }
        
        // 在更新之前先获取到从contentOffset到第一个显示的单元格的偏移
        let oldContentOffset = tableView.contentOffset
        let firstVisibleCellFrame = needResetOffset ? tableView.rectForRowAtIndexPath(visibleIndexPaths![0]) : CGRectZero
        
//        var tx = CGFloat(0)
//            if true {
//            let sy = tableView.valueForKey("_startOffsetY") as? CGFloat ?? 0
//            let uy = tableView.valueForKey("_lastUpdateOffsetY") as? CGFloat ?? 0
//                tx = oldContentOffset.y - sy
//            SIMLog.debug(sy)
//            SIMLog.debug(uy)
//            SIMLog.debug(tx)
//                //SIMLog.debug(tableView.valueForKey("_pagingSpringPull"))
//            }
        
        // 禁止动画, 更新
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths(removeIndexPaths, withRowAnimation: .None)
            tableView.insertRowsAtIndexPaths(insertIndexPaths, withRowAnimation: .None)
            tableView.reloadRowsAtIndexPaths(reloadIndexPaths, withRowAnimation: .None)
            tableView.endUpdates()
        }

        // 需要更新?
        if needResetOffset {
            // 默认为0
            var idx = NSIndexPath(forRow: 0, inSection: 0)
            // 需要保持位置的cell
            if visibleIndexPaths!.count != 0 {
                idx = NSIndexPath(forRow: visibleIndexPaths![0].row + newMessages.count - removeIndexPaths.count, inSection: 0)
            }
            let distance = oldContentOffset.y - firstVisibleCellFrame.origin.y
            let oldFirstVisibleCellFrame = tableView.rectForRowAtIndexPath(idx)
            let newContentOffset = CGPointMake(0, oldFirstVisibleCellFrame.minY + distance)
            let addedContentSize = CGSizeMake(tableView.frame.width, oldFirstVisibleCellFrame.minY - firstVisibleCellFrame.minY)
            
            let hx = tableView.panGestureRecognizer.translationInView(tableView)
            
            SIMLog.debug("old content offset: \(oldContentOffset)")
            SIMLog.debug("first visible cell frame: \(firstVisibleCellFrame)")
            SIMLog.debug("content offset to first cell distance: \(distance)")
            SIMLog.debug("old first visible cell frame: \(oldFirstVisibleCellFrame)")
            SIMLog.debug("added content size: \(addedContentSize)")
            SIMLog.debug("new content offset: \(newContentOffset)")
            SIMLog.debug("tableView: dragging(\(tableView.dragging)), decelerating(\(tableView.decelerating)), tracking(\(tableView.tracking))")
            
            //SIMLog.debug("startOffsetY: \(tableView.valueForKey("_startOffsetY"))")
            //SIMLog.debug("lastUpdateOffsetY: \(tableView.valueForKey("_lastUpdateOffsetY"))")
            
            let sy = tableView.valueForKey("_startOffsetY") as? CGFloat ?? 0
            let uy = tableView.valueForKey("_lastUpdateOffsetY") as? CGFloat ?? 0
            
            SIMLog.debug("table pan translation: \(hx)")
            SIMLog.debug("offset to start offset: \(oldContentOffset.y - sy) => \(uy - sy)")
            
            tableView.setValue(newContentOffset.y + hx.y, forKey: "_startOffsetY")
            tableView.setValue(newContentOffset.y + hx.y, forKey: "_lastUpdateOffsetY")
            
            tableView.setContentOffset(newContentOffset, animated: false)
            
            // tableView.valueForKey("_updatePanGesture")
            
            SIMLog.debug("startOffsetY: \(tableView.valueForKey("_startOffsetY"))")
            SIMLog.debug("lastUpdateOffsetY: \(tableView.valueForKey("_lastUpdateOffsetY"))")
            SIMLog.debug("apply content offset: \(tableView.contentOffset)")
        }
    }
    
    ///
    /// 追加消息
    ///
    private func _appendMessages(ms: Array<SIMChatMessageProtocol>) {
        guard let tableView = self.contentView, last = ms.last else {
            return
        }
        
        SIMLog.trace()
        
        let isSelf = last.isSelf ?? false
        let isLasted = (tableView.indexPathsForVisibleRows?.last?.row ?? 0) + ms.count == tableView.numberOfRowsInSection(0)
        
        _insertMessages(ms, atIndex: -1)
        
        SIMLog.debug("self: \(isSelf) lasted: \(isLasted)")
        // 如果发送者是自己, 转到最后一行
        // 如果发送者是其他人, 并且当前行在最后一行, 转到最后一行
        if isSelf || isLasted {
            // 如果不是正在发送更新为己读
            // if last.status != .Sending {
            //     self.conversation.readMessage(last, nil, nil)
            // }
            // ok, 更新
            let idx = NSIndexPath(forRow: tableView.numberOfRowsInSection(0) - 1, inSection: 0)
            tableView.scrollToRowAtIndexPath(idx, atScrollPosition: .Bottom, animated: true)
        } else {
            // 更新未读数量
        }
    }
    
    ///
    /// 更新消息
    ///
    private func _reloadMessages(ms: Array<SIMChatMessageProtocol>, animated: Bool = true) {
        guard let tableView = self.contentView where !ms.isEmpty else {
            return
        }
        // TODO: 批量更新的测试没有做
        // 查找需要执行操作的单元格
        let indexs = ms.flatMap { e in
            return allMessages.indexOf{
                return $0 == e
            }
        }
        
        // 并没有操作
        guard !indexs.isEmpty else {
            return
        }
        
        SIMLog.trace("reload indexs: \(indexs)")
        
        var insertIndexPaths: Array<NSIndexPath> = []
        var reloadIndexPaths: Array<NSIndexPath> = []
        var removeIndexPaths: Array<NSIndexPath> = []
        
        indexs.forEach {
            
            let prev: SIMChatMessageProtocol? = ($0 - 1 < allMessages.count && $0 > 0) ? allMessages[$0 - 1] : nil
            let message = allMessages[$0]
            let next: SIMChatMessageProtocol? = ($0 + 1 < allMessages.count) ? allMessages[$0 + 1] : nil
            
            // 一定要重新计算高度
            tableView.fd_invalidateHeightForKey(message.identifier)
            
            if _needMakeTimeLine(message, next) {
                // 添加到下面
                let idx = $0 + 1
                SIMLog.debug("add time line at \($0 + 1)")
                allMessages.insert(_makeTimeLine(message, next), atIndex: idx)
                insertIndexPaths.append(NSIndexPath(forRow: $0, inSection: 0))
            }
            if _needRemoveTimeLine(prev, message) {
                // 需要删除, 优先删除上面的
                let idx = $0 - 1
                SIMLog.debug("remove time line at \(idx)")
                allMessages.removeAtIndex(idx)
                removeIndexPaths.append(NSIndexPath(forRow: $0 - 1, inSection: 0))
            }
            
            reloadIndexPaths.append(NSIndexPath(forRow: $0, inSection: 0))
        }
        
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths(reloadIndexPaths, withRowAnimation: .Fade)
        tableView.insertRowsAtIndexPaths(insertIndexPaths, withRowAnimation: .Fade)
        tableView.deleteRowsAtIndexPaths(removeIndexPaths, withRowAnimation: .Fade)
        tableView.endUpdates()
    }
    
    ///
    /// 删除消息
    ///
    private func _removeMessages(ms: Array<SIMChatMessageProtocol>, animated: Bool = true) {
        guard let tableView = self.contentView where !ms.isEmpty else {
            return
        }
        // TODO: 批量删除的测试没有做
        // 查找需要执行操作的单元格
        let indexs = ms.flatMap { e in
            return allMessages.indexOf{
                return $0 == e
            }
        }
        SIMLog.trace("remove indexs: \(indexs)")
        
        var reloadIndexPathsL: Array<NSIndexPath> = [] // Left
        var reloadIndexPathsR: Array<NSIndexPath> = [] // Right
        var reloadIndexPathsF: Array<NSIndexPath> = [] // Fade
        
        var removeIndexPaths: Array<NSIndexPath> = []
        var removeIndexPathsL: Array<NSIndexPath> = [] // Left
        var removeIndexPathsR: Array<NSIndexPath> = [] // Right
        
        let reloadMessage = { (message: SIMChatMessageProtocol, idx: NSIndexPath) in
            // 检查更新方向
            if message.isSelf {
                reloadIndexPathsR.append(idx)
            } else {
                reloadIndexPathsL.append(idx)
            }
        }
        let removeMessage = { (message: SIMChatMessageProtocol, idx: NSIndexPath) in
            removeIndexPaths.append(idx)
            // 检查删除方向
            if message.isSelf {
                removeIndexPathsR.append(idx)
            } else {
                removeIndexPathsL.append(idx)
            }
        }
        
        indexs.forEach {
            
            let prev: SIMChatMessageProtocol? = ($0 - 1 < allMessages.count && $0 > 0) ? allMessages[$0 - 1] : nil
            let message: SIMChatMessageProtocol = allMessages[$0]
            let next: SIMChatMessageProtocol? = ($0 + 1 < allMessages.count) ? allMessages[$0 + 1] : nil
            
            let indexPath = NSIndexPath(forRow: $0, inSection: 0)
            
            // 删除数据源
            allMessages.removeAtIndex($0 - removeIndexPaths.count)
            
            if _needMakeTimeLine(prev, next) {
                // 需要新加
                SIMLog.debug("add time line at \($0)")
                allMessages.insert(_makeTimeLine(prev, next), atIndex: $0)
                reloadMessage(message, indexPath)
                // 不可以删除.
                return
            } else if _needRemoveTimeLine(prev, next) {
                // 需要删除, 优先删除上面的
                SIMLog.debug("remove time line at \($0 - 1)")
                allMessages.removeAtIndex($0 - 1)
                removeMessage(message, NSIndexPath(forRow: $0 - 1, inSection: 0))
            } else if _hasTimeLine(prev, next) {
                // 需要更新
                if let content = prev?.content as? SIMChatBaseMessageTimeLineContent {
                    let idx = NSIndexPath(forRow: $0 - 1, inSection: 0)
                    content.frontMessage = prev
                    content.backMessage = next
                    reloadIndexPathsF.append(idx)
                } else if let content = next?.content as? SIMChatBaseMessageTimeLineContent {
                    let idx = NSIndexPath(forRow: $0 + 1, inSection: 0)
                    content.frontMessage = prev
                    content.backMessage = next
                    reloadIndexPathsF.append(idx)
                }
            }
            removeMessage(message, indexPath)
        }
        
        if animated {
            let cellsL = removeIndexPathsL.flatMap { tableView.cellForRowAtIndexPath($0) }
            let cellsR = removeIndexPathsR.flatMap { tableView.cellForRowAtIndexPath($0) }
            // 自定义删除动画
            UIView.animateWithDuration(0.25,
                animations: {
                    cellsL.forEach { $0.frame.origin = CGPointMake(-$0.frame.width, $0.frame.minY) }
                    cellsR.forEach { $0.frame.origin = CGPointMake(+$0.frame.width, $0.frame.minY) }
                },
                completion: { b in
                    // 必须要隐藏, 否则系统动画会暴露
                    cellsL.forEach { $0.hidden = true }
                    cellsR.forEach { $0.hidden = true }
                    // 使用系统的更新
                    tableView.beginUpdates()
                    tableView.deleteRowsAtIndexPaths(removeIndexPathsL, withRowAnimation: .Top)
                    tableView.deleteRowsAtIndexPaths(removeIndexPathsR, withRowAnimation: .Top)
                    tableView.reloadRowsAtIndexPaths(reloadIndexPathsL, withRowAnimation: .Left)
                    tableView.reloadRowsAtIndexPaths(reloadIndexPathsR, withRowAnimation: .Right)
                    tableView.reloadRowsAtIndexPaths(reloadIndexPathsF, withRowAnimation: .Fade)
                    tableView.endUpdates()
            })
        } else {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths(removeIndexPaths,  withRowAnimation: .None)
                tableView.reloadRowsAtIndexPaths(reloadIndexPathsL, withRowAnimation: .None)
                tableView.reloadRowsAtIndexPaths(reloadIndexPathsR, withRowAnimation: .None)
                tableView.endUpdates()
            }
        }
    }
    
    
    ///
    /// 加载历史消息
    ///
    private func _loadHistoryMessages() {
        guard !isLoading else {
            return
        }
        SIMLog.trace()
        // 防止多次加载
        isLoading = true
        
        // TODO: 动画有问题
        
        conversation.loadHistoryMessages(200).response { [weak self] in
            defer {
                self?.isLoading = false
            }
            guard let manager = self, tableView = self?.contentView else {
                return
            }
            let isFirstLoad = manager.allMessages.isEmpty
            if let allMessages = $0.value {
                // 如果所有的消息都加载完了, 关闭加载提示
                if manager.conversation.allMessagesIsLoaded {
                    UIView.performWithoutAnimation {
                        let h = tableView.tableHeaderView?.frame.height ?? 0
                        tableView.tableHeaderView = nil
                        tableView.contentOffset = CGPointMake(0, tableView.contentOffset.y - h)
                    }
                }
                // 插入消息
                manager._insertMessages(allMessages, atIndex: 0)
                // 如果是第一次加载, 更新到最后
                if isFirstLoad && !manager.allMessages.isEmpty {
                    SIMLog.debug("first load")
                    let idx = NSIndexPath(forRow: tableView.numberOfRowsInSection(0) - 1, inSection: 0)
                    tableView.scrollToRowAtIndexPath(idx, atScrollPosition: .Bottom, animated: false)
                }
            } else if let header = tableView.tableHeaderView {
                // 加载失败
                // TODO: 这或许有问题
                if tableView.contentInset.top + tableView.contentOffset.y <= header.frame.height {
                    tableView.setContentOffset(CGPointMake(0,  -tableView.contentInset.top + header.frame.height), animated: true)
                    //tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
                }
            }
        }
    }
    
    ///
    /// 发送消息
    ///
    func sendMessage(content: SIMChatMessageContentProtocol) {
        SIMLog.trace()
        
        let message = manager.classProvider.message.messageWithContent(content,
            receiver: conversation.receiver,
            sender: conversation.sender)
        
        _appendMessages([message])
    }

}

//// MARK: - Message Send
//extension SIMChatViewController {
//    ///
//    /// 发送文本
//    ///
//    func sendMessageForText(text: String) {
//        SIMLog.trace()
//        // 不能为空
//        if text.isEmpty {
//            let av = UIAlertView(title: "提示", message: "不能发送空内容", delegate: nil, cancelButtonTitle: "好")
//            return av.show()
//        }
//        // 发送
//        self.sendMessage(SIMChatMessageContentText(text: text))
//    }
//    ///
//    /// 发送声音
//    ///
//    func sendMessageForAudio(url: NSURL, duration: NSTimeInterval) {
//        SIMLog.trace()
//        if duration < 1 {
//            let av = UIAlertView(title: "提示", message: "录音时间太短", delegate: nil, cancelButtonTitle: "好")
//            return av.show()
//        }
//        // 生成连接
//        let nurl = NSURL(fileURLWithPath: String(format: "%@/upload/audio/%@.wav", NSTemporaryDirectory(), NSUUID().UUIDString))
//        // 检查目录并发送
//        do {
//            // 创建目录
//            try NSFileManager.defaultManager().createDirectoryAtURL(nurl.URLByDeletingLastPathComponent!, withIntermediateDirectories: true, attributes: nil)
//            // 移动文件
//            try NSFileManager.defaultManager().moveItemAtURL(url, toURL: nurl)
//            // 发送
//            self.sendMessage(SIMChatMessageContentAudio(url: nurl, duration: duration))
//            
//        } catch let e as NSError {
//            // 发送失败
//            SIMLog.debug(e)
//        }
//    }
//    ///
//    /// 发送图片
//    ///
//    func sendMessageForImage(image: UIImage) {
//        SIMLog.trace()
//        // 生成连接(这可以降低内存使用)
//        // let nurl = NSURL(fileURLWithPath: String(format: "%@/upload/image/%@.jpg", NSTemporaryDirectory(), NSUUID().UUIDString))
//        // 发送
//        self.sendMessage(SIMChatMessageContentImage(origin: image, thumbnail: image))
//    }
//    ///
//    /// 发送自定义消息
//    ///
//    func sendMessageForCustom(data: SIMChatMessageContentProtocol) {
//        SIMLog.trace()
//        // :)
//        self.sendMessage(data)
//    }
//    ///
//    /// 发送内容(禁止外部访问)
//    ///
//    private func sendMessage(content: SIMChatMessageContentProtocol) {
//        // 真正的发送
//        self.conversation.sendMessage(SIMChatMessage(content), isResend: false, nil, nil)
//    }
//    ///
//    /// 重新发送消息(禁止外部访问)
//    ///
//    private func resendMessage(m: SIMChatMessage) {
//        // 真正的发送
//        self.conversation.sendMessage(m, isResend: true, nil, nil)
//    }
//    
//    ///
//    /// 加载聊天历史
//    ///
//    func loadHistorys(total: Int, last: SIMChatMessage? = nil) {
//        SIMLog.trace()
//        // 查询消息
//        self.conversation.queryMessages(total, last: last, { [weak self] ms in
//            // 插入
//            self?.insertRows(ms.reverse(), atIndex: 0, animated: last != nil)
//            self?.latest = ms.last
//            // 这是第一次
//            if last == nil {
//                // 有多行
//                let cnt = self?.tableView.numberOfRowsInSection(0) ?? 0
//                if cnt != 0 {
//                    // 有多行?
//                    let idx = NSIndexPath(forRow: cnt - 1, inSection: 0)
//                    self?.tableView.scrollToRowAtIndexPath(idx, atScrollPosition: .Bottom, animated: false)
//                }
//                // 淡入
//                self?.tableView.alpha = 0
//                UIView.animateWithDuration(0.25) {
//                    self?.tableView.alpha = 1
//                }
//                // 标记为己读
//                if let m = ms.first {
//                    self?.conversation.readMessage(m, nil, nil)
//                }
//            }
//        }, nil)
//    }
//
//}
//
//// MARK: - Message Cell Event 
//extension SIMChatViewController : SIMChatMessageCellDelegate {
//    
//    /// 选择了删除.
//    func chatCellDidDelete(chatCell: SIMChatMessageCell) {
////        SIMLog.trace()
////        if let m = chatCell.message {
////            self.conversation.removeMessage(m, nil, nil)
////        }
//    }
//    /// 选择了复制
//    func chatCellDidCopy(chatCell: SIMChatMessageCell) {
//        SIMLog.trace()
//    }
//    /// 点击
//    func chatCellDidPress(chatCell: SIMChatMessageCell, withEvent event: SIMChatMessageCellEvent) {
//        SIMLog.trace(event.type.rawValue)
//        // 只处理气泡消息, 目前 
//        guard let message = chatCell.message where event.type == .Bubble else {
//            return
//        }
//        // 音频
//        if let ctx = chatCell.message?.content as? SIMChatMessageContentAudio {
//            // 有没有加载? 没有的话添加监听
//            if !ctx.url.storaged {
//                ctx.url.willSet({ [weak message] oldValue in
//                    SIMChatNotificationCenter.postNotificationName(SIMChatAudioManagerWillLoadNotification, object: message)
//                }).didSet({  [weak message] newValue in
//                    SIMChatNotificationCenter.postNotificationName(SIMChatAudioManagerDidLoadNotification, object: message)
//                })
//            }
//            // 获取
//            if let url = ctx.url.get() {
//                // 清除监控.
//                ctx.url.clean()
//                // 加载成功, 并且是没有在播放中
//                if let url = url where !ctx.playing {
//                    // 播放
//                    SIMChatAudioManager.sharedManager.delegate = nil
//                    SIMChatAudioManager.sharedManager.play(url)
//                    // :)
//                    ctx.played = true
//                    ctx.playing = true
//                } else {
//                    // 停止
//                    SIMChatAudioManager.sharedManager.delegate = nil
//                    SIMChatAudioManager.sharedManager.stop()
//                    // :(
//                    ctx.playing = false
//                }
//            } else {
//                // 正在加载中
//                // 如果正在播放其他。 停止他
//                SIMChatAudioManager.sharedManager.delegate = nil
//                SIMChatAudioManager.sharedManager.stop()
//            }
//            
//            return
//        }
//        // 图片
//        if let ctx = chatCell.message?.content as? SIMChatMessageContentImage {
//            let f = (chatCell as? SIMChatMessageCellImage)?.contentView2 ?? chatCell
//            let vc = SIMChatPhotoBrowserController()
//            
//            vc.content = ctx
//            
//            // 预览图片
//            self.presentViewController(vc, animated: true, fromView: f) { [weak vc] in
//                vc?.showDetailIfNeed()
//            }
//            // ok
//            return
//        }
//    }
//    /// 长按
//    func chatCellDidLongPress(chatCell: SIMChatMessageCell, withEvent event: SIMChatMessageCellEvent) {
//        // 只响应begin事件
//        guard let rec = event.sender as? UIGestureRecognizer where rec.state == .Began else {
//            return
//        }
//        SIMLog.trace(event.type.rawValue)
//        // 如果是气泡的按下事件
//        if event.type == .Bubble {
//            if let c = chatCell as? SIMChatMessageCellBubble {
//                // 准备菜单
//                let mu = UIMenuController.sharedMenuController()
//                // 进入激活状态
//                c.becomeFirstResponder()
//                // 菜单项
//                mu.menuItems = [UIMenuItem(title: "复制", action: "chatCellCopy:"),
//                                UIMenuItem(title: "删除", action: "chatCellDelete:")]
//                // 设置弹出区域
//                mu.setTargetRect(c.bubbleView.frame, inView: c)
//                mu.setMenuVisible(true, animated: true)
//            }
//        }
//    }
//}
