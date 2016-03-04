//
//  SIMChatViewController+Message.swift
//  SIMChat
//
//  Created by sagesse on 9/26/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit


extension SIMChatViewController {
    class MessageManager: NSObject, SIMChatBrowseAnimatedTransitioningTarget {
        init(conversation: SIMChatConversationProtocol) {
            _allMessages = []
            _conversation = conversation
            super.init()
            _conversation.delegate = self
        }
        
        /// 最后操作的消息
        private weak var _lastOperatorMessage: SIMChatMessageProtocol?
        
        private var _allMessages: Array<SIMChatMessageProtocol>
        private var _conversation: SIMChatConversationProtocol
        private var _isLoading: Bool = false
        /// 快速映射
        private var _fastMap: Dictionary<String, String> = [:]
        
        var durationInterval: NSTimeInterval = 60
        
        /// 目标view
        weak var targetView: UIImageView?
        
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
                oldValue?.tableHeaderView = nil
                
                contentView?.delegate = self
                contentView?.dataSource = self
                //contentView?.keyboardDismissMode = .OnDrag //.Interactive
                contentView?.tableHeaderView = header
            }
        }
        
        private var mediaProvider: SIMChatMediaProvider {
            return manager.mediaProvider
        }
        
        private var manager: SIMChatManagerProtocol {
            guard let manager = _conversation.manager else {
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
    
    /// 使用索引获取消息(安全的)
    private func _messageWithIndex(index: Int) -> SIMChatMessageProtocol? {
        guard index >= 0 && index < _allMessages.count else {
            return nil
        }
        return _allMessages[index]
    }
    
    /// 获取索引(结果和参数顺序有关)
    private func _indexsOfMessages(messages: Array<SIMChatMessageProtocol>) -> Array<Int> {
//        // 批量操作测试
//        if true {
//            var x = messages.flatMap { e in
//                return _allMessages.indexOf{
//                    return $0 == e
//                }
//            }
//            if let f = x.first {
//                if true {
//                    // 连续操作内容
//                    x.append(f - 1)
//                } else {
//                    // 非连续操作内容
//                    x.append(f - 2)
//                }
//            }
//            return x
//        }
        return messages.flatMap { e in
            return _allMessages.indexOf{
                return $0 == e
            }
        }
    }
    
    ///
    /// 检查是否存在timeline
    ///
    private func _hasTimeLine(prev: SIMChatMessageProtocol?, _ next: SIMChatMessageProtocol?) -> Bool {
        return prev?.content is SIMChatBaseMessageTimeLineContent
            || next?.content is SIMChatBaseMessageTimeLineContent
    }
    
    ///
    /// 检查是否需要生成timeline
    ///
    private func _needMakeTimeLine(prev: SIMChatMessageProtocol?, _ next: SIMChatMessageProtocol?) -> Bool {
        // 如果存在timeline就不需要添加
        if _hasTimeLine(prev, next) {
            return false
        }
        // next必须存在并且要可以显示timeline
        guard let next = next where next.showsTimeLine else {
            return false
        }
        // prev可以不存在, 但如果存在就必须符合条件
        guard let prev = prev else {
            return true
        }
        // 如果上一个不允许显示时间, 那就必须显示
        if !prev.showsTimeLine {
            return true
        }
        // 都符合就检查时间
        return fabs(prev.date.timeIntervalSinceDate(next.date)) >= durationInterval
    }
    
    ///
    /// 检查是否需要移除timeline
    ///
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
        if let content = prev?.content as? SIMChatBaseMessageTimeLineContent {
            guard let nextMessage = next else {
                // 没有下一条了, 需要删除
                return true
            }
            if !nextMessage.showsTimeLine {
                // 不允许显示timeline
                return true
            }
            // 如果有上上一条消息, 检查他
            if let pprevMessage = content.frontMessage {
//                if !pprevMessage.showsTimeLine {
//                    // 上上一个不允许显示
//                    return false
//                }
                return fabs(pprevMessage.date.timeIntervalSinceDate(nextMessage.date)) < durationInterval
            }
        }
        if let content = next?.content as? SIMChatBaseMessageTimeLineContent {
            guard let prevMessage = prev else {
                // 这是第一条
                return false
            }
            if !prevMessage.showsTimeLine {
                // 上一条消息不允许显示timeline, 那么这个就可以直接显示
                return false
            }
            // 如果有下下一条消息, 检查他
            if let nnextMessage = content.backMessage {
                return fabs(nnextMessage.date.timeIntervalSinceDate(prevMessage.date)) < durationInterval
            }
        }
        guard let next = next, prev = prev else {
            return false
        }
        // 计算
        return fabs(prev.date.timeIntervalSinceDate(next.date)) < durationInterval
    }
    
    ///
    /// 检查是否需要更新
    ///
    private func _needUpdateTimeLine(frontMessage: SIMChatMessageProtocol?, _ backMessage: SIMChatMessageProtocol?) -> Bool {
        // 如果没有timeline, 就谈不上更新了
        if !_hasTimeLine(frontMessage, backMessage) {
            return false
        }
        // 后一条消息改变了
        if let content = frontMessage?.content as? SIMChatBaseMessageTimeLineContent {
            return content.backMessage !== backMessage
        }
        // 前一条消息改变了
        if let content = backMessage?.content as? SIMChatBaseMessageTimeLineContent {
            return content.frontMessage !== frontMessage
        }
        return false
    }
    
    private func _updateTimeLine(frontMessage: SIMChatMessageProtocol?, _ backMessage: SIMChatMessageProtocol?) {
        if let content = frontMessage?.content as? SIMChatBaseMessageTimeLineContent {
            content.backMessage = backMessage
        }
        if let content = backMessage?.content as? SIMChatBaseMessageTimeLineContent {
            content.frontMessage = frontMessage
        }
    }
    /// 生成timeline
    private func _makeTimeLine(frontMessage: SIMChatMessageProtocol?, _ backMessage: SIMChatMessageProtocol?) -> SIMChatMessageProtocol {
        let content = SIMChatBaseMessageTimeLineContent(frontMessage: frontMessage, backMessage: backMessage)
        let messageClass = manager.classProvider.message
        let message = messageClass.messageWithContent(content,
            receiver: _conversation.receiver,
            sender: _conversation.sender)
        return message
    }
    
    /// 获取timeline
    private func _timeLine(prevIndex: Int, _ nextIndex: Int) -> (Int, SIMChatMessageProtocol) {
        if let prevMessage = self._messageWithIndex(prevIndex) {
            if prevMessage.content is SIMChatBaseMessageTimeLineContent {
                return (prevIndex, prevMessage)
            }
        }
        if let nextMessage = self._messageWithIndex(nextIndex) {
            if nextMessage.content is SIMChatBaseMessageTimeLineContent {
                return (nextIndex, nextMessage)
            }
        }
        fatalError("time not found!")
    }
    
    // MARK: Message
    
    ///
    /// 移动消息, 如果有多条消息, 按参数顺序加到index之后
    ///
    private func _moveMessages(ms: Array<SIMChatMessageProtocol>, toIndex index: Int, animated: Bool = true) {
        guard let tableView = self.contentView where !ms.isEmpty else {
            return
        }
        // 计算插入点
        let count = _allMessages.count
        let position = min(max(index >= 0 ? index : index + count, 0), count)
        var newMessages = Array<SIMChatMessageProtocol>()
        // 查找需要执行操作的单元格并转换为组
        let indexs = _indexsOfMessages(ms)
        let indexGroups = indexs.filter({$0 != position}).sort().splitInGroup {
            $0 + 1 == $1
        }
        guard !indexGroups.isEmpty else {
            return
        }
        // 辅助函数
        let animation = { (m: SIMChatMessageProtocol) -> UITableViewRowAnimation in
            // 如果是timeline, 取决于他关联的是什么
            let isSelf = (m.content as? SIMChatBaseMessageTimeLineContent)?.backMessage?.isSelf ?? m.isSelf
            // 转换为方向
            return isSelf ? .Right : .Left
        }
        
        SIMChatUpdatesTransactionPerform(tableView, &_allMessages, animated) { maker in
            indexs.forEach {
                let beginMessage = newMessages.last ?? _allMessages[position]
                let message = _allMessages[$0]
                // 检查timeline
                if _needMakeTimeLine(beginMessage, message) {
                    // 需要添加一个新的timeline
                    let tl = (position + 1, _makeTimeLine(beginMessage, message))
                    maker.insert(tl.1, atIndex: tl.0, withAnimation: animation(tl.1))
                } else if newMessages.isEmpty && _needRemoveTimeLine(beginMessage, message) {
                    // 需要删除
                    maker.removeAtIndex(position, withAnimation: animation(message))
                } else if newMessages.isEmpty && _needUpdateTimeLine(beginMessage, message) {
                    // 需要更新
                    _updateTimeLine(beginMessage, message)
                    maker.reloadAtIndex(position, withAnimation: .Fade)
                }
                // 不要移动时间
                if message.content is SIMChatBaseMessageTimeLineContent {
                    maker.removeAtIndex($0, withAnimation: animation(message))
                } else {
                    newMessages.append(message)
                    maker.moveFromIndex($0, toIndex: position, withAnimation: animation(message))
                }
                // 最后一条的时候检查插入点的那一条消息
                guard $0 == indexs.last else {
                    return
                }
                let lastMessage = _messageWithIndex(position + 1)
                if _needMakeTimeLine(message, lastMessage) {
                    // 需要添加一个新的timeline
                    let tl = (position + 1, _makeTimeLine(message, lastMessage))
                    maker.insert(tl.1, atIndex: tl.0, withAnimation: animation(message))
                } else if _needRemoveTimeLine(message, lastMessage) {
                    // 需要删除
                    maker.removeAtIndex(position + 1, withAnimation: animation(message))
                } else if _needUpdateTimeLine(message, lastMessage) {
                    // 需要更新
                    _updateTimeLine(message, lastMessage)
                    maker.reloadAtIndex(position + 1, withAnimation: .Fade)
                }
            }
            indexGroups.forEach {
                // 获取需要检查的消息
                let begin = $0.first! - 1
                let end = $0.last! + 1
                let beginMessage = _messageWithIndex(begin)
                let endMessage = _messageWithIndex(end)
                // 检查timeline
                if _needMakeTimeLine(beginMessage, endMessage) {
                    // 需要添加一个新的timeline, + 1是为了删除了一条
                    let tl = ($0.first!, _makeTimeLine(beginMessage, endMessage))
                    maker.insert(tl.1, atIndex: tl.0, withAnimation: .Fade)
                } else if _needRemoveTimeLine(beginMessage, endMessage) {
                    // 需要删除, 优先删除上面的, 删除区间之后index就是last了
                    let tl = _timeLine(begin, end)
                    maker.removeAtIndex(tl.0, withAnimation: animation(tl.1))
                } else if _needUpdateTimeLine(beginMessage, endMessage) {
                    // 需要更新
                    let tl = _timeLine(begin, end)
                    _updateTimeLine(beginMessage, endMessage)
                    maker.reloadAtIndex(tl.0, withAnimation: .Fade)
                }
            }
        }
    }
    
    ///
    /// 批量插入消息
    ///
    /// - parameter ms:       消息集合
    /// - parameter index:    如果为index < 0, 插入点为count + index + 1
    ///
    private func _insertMessages(ms: Array<SIMChatMessageProtocol>, atIndex: Int, animated: Bool = true) {
        guard let tableView = contentView where !ms.isEmpty else {
            return
        }
        let newMessages = ms.filter { !$0.option.contains(.Hidden) }
        guard !newMessages.isEmpty else {
            return
        }
        
        // 计算插入点
        let count = _allMessages.count
        let position = min(max(atIndex >= 0 ? atIndex : atIndex + count + 1, 0), count)
        
        SIMLog.trace("insert position: \(position) => \(count)")

        // tip1: 如果cell插入到visibleCells之前, 会导致contentSize改变(contentOffset不变),
        // tip2: 如果设置contentOffset会导致减速事件停止
        // tip3: insertRowsAtIndexPaths的动画需要强制去除
        // tip4: 不要在beginUpdates里面indexPath请求cell

        // 检查是不是插入到visible之前
        //let small = tableView.contentSize.height < tableView.bounds.height
        var visibleIndexPaths = tableView.indexPathsForVisibleRows
        let needResetOffset = /*!small &&*/ visibleIndexPaths?.contains({ position < $0.row }) ?? false
        
        // 在更新之前先获取到从contentOffset到第一个显示的单元格的偏移
        let oldContentOffset = tableView.contentOffset
        let firstVisibleCellFrame = needResetOffset ? tableView.rectForRowAtIndexPath(visibleIndexPaths![0]) : CGRectZero
        
        SIMChatUpdatesTransactionPerform(tableView, &_allMessages, animated) { maker in
            var message = _messageWithIndex(position - 1)
            newMessages.forEach {
                // 检查timeline
                if _needMakeTimeLine(message, $0) {
                    // 需要添加一个新的timeline
                    let tl = (position, _makeTimeLine(message, $0))
                    maker.insert(tl.1, atIndex: tl.0, withAnimation: .Fade)
                } else if $0 === newMessages.first && _needRemoveTimeLine(message, $0) {
                    // 需要删除
                    maker.removeAtIndex(position, withAnimation: .Fade)
                } else if $0 === newMessages.first && _needUpdateTimeLine(message, $0) {
                    // 需要更新
                    _updateTimeLine(message, $0)
                    maker.reloadAtIndex(position, withAnimation: .Fade)
                }
                // 插入
                message = $0
                maker.insert($0, atIndex: position, withAnimation: .Fade)
                // 最后一条的时候检查插入点的后一条消息
                guard $0 === newMessages.last else {
                    return
                }
                guard let lastMessage = _messageWithIndex(position) else {
                    return
                }
                if _needMakeTimeLine($0, lastMessage) {
                    // 需要添加一个新的timeline
                    let tl = (position, _makeTimeLine($0, lastMessage))
                    maker.insert(tl.1, atIndex: tl.0, withAnimation: .Fade)
                } else if _needRemoveTimeLine($0, lastMessage) {
                    // 需要删除
                    maker.removeAtIndex(position, withAnimation: .Fade)
                } else if _needUpdateTimeLine($0, lastMessage) {
                    // 需要更新
                    _updateTimeLine($0, lastMessage)
                    maker.reloadAtIndex(position, withAnimation: .Fade)
                }
            }
        }
        
        // 需要更新?
        if needResetOffset {
            // 默认为0
            var idx = NSIndexPath(forRow: 0, inSection: 0)
            // 需要保持位置的cell
            if visibleIndexPaths!.count != 0 {
                idx = NSIndexPath(forRow: visibleIndexPaths![0].row + (_allMessages.count - count), inSection: 0)
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
    /// 更新消息
    ///
    private func _reloadMessages(ms: Array<SIMChatMessageProtocol>, animated: Bool = true) {
        guard let tableView = contentView where !ms.isEmpty else {
            return
        }
        // 查找需要执行操作的单元格并转换为组
        let indexGroups = _indexsOfMessages(ms).sort().splitInGroup {
            $0 + 1 == $1
        }
        guard !indexGroups.isEmpty else {
            return
        }
        SIMLog.trace()
        
        SIMChatUpdatesTransactionPerform(tableView, &_allMessages, animated) {  maker in
            indexGroups.forEach {
                // 更新区间内所有的消息
                ($0.first! ... $0.last!).forEach {
                    if let message = _messageWithIndex($0) {
                        tableView.fd_invalidateHeightForKey(message.identifier)
                    }
                    maker.reloadAtIndex($0, withAnimation: .Fade)
                }
                // 检查区间内的timeline
                ($0.first! ... $0.last! + 1).forEach {
                    // 获取需要检查的消息
                    let begin = $0 - 1
                    let end = $0
                    let beginMessage = _messageWithIndex(begin)
                    let endMessage = _messageWithIndex(end)
                    // 检查timeline
                    if _needMakeTimeLine(beginMessage, endMessage) {
                        // 需要添加一个新的timeline, + 1是为了删除了一条
                        let tl = ($0, _makeTimeLine(beginMessage, endMessage))
                        maker.insert(tl.1, atIndex: tl.0, withAnimation: .Fade)
                    } else if _needRemoveTimeLine(beginMessage, endMessage) {
                        // 需要删除, 优先删除上面的, 删除区间之后index就是last了
                        let tl = _timeLine(begin, end)
                        maker.removeAtIndex(tl.0, withAnimation: .Fade)
                    } else if _needUpdateTimeLine(beginMessage, endMessage) {
                        // 需要更新
                        let tl = _timeLine(begin, end)
                        _updateTimeLine(beginMessage, endMessage)
                        maker.reloadAtIndex(tl.0, withAnimation: .Fade)
                    }
                }
            }
        }
    }
    
    ///
    /// 删除消息
    ///
    private func _removeMessages(ms: Array<SIMChatMessageProtocol>, animated: Bool = true) {
        guard let tableView = contentView where !ms.isEmpty else {
            return
        }
        // 查找需要执行操作的单元格并转换为组
        let indexGroups = _indexsOfMessages(ms).sort().splitInGroup {
            $0 + 1 == $1
        }
        guard !indexGroups.isEmpty else {
            return
        }
        SIMLog.trace()
        
        // 辅助函数
        let animation = { (m: SIMChatMessageProtocol) -> UITableViewRowAnimation in
            // 如果是timeline, 取决于他关联的是什么
            let isSelf = (m.content as? SIMChatBaseMessageTimeLineContent)?.backMessage?.isSelf ?? m.isSelf
            // 转换为方向
            return isSelf ? .Right : .Left
        }
        // 生成然后执行
        SIMChatUpdatesTransactionPerform(tableView, &_allMessages, animated) { maker in
            indexGroups.forEach {
                // 移除区间内所有的消息
                ($0.first! ... $0.last!).forEach {
                    maker.removeAtIndex($0, withAnimation: animation(_allMessages[$0]))
                }
                // 需要删除区间边界上的的消息
                let begin = $0.first! - 1
                let end = $0.last! + 1
                let beginMessage = _messageWithIndex(begin)
                let endMessage = _messageWithIndex(end)
                // 检查timeline
                if _needMakeTimeLine(beginMessage, endMessage) {
                    // 需要添加一个新的timeline, + 1是为了删除了一条
                    let tl = ($0.first!, _makeTimeLine(beginMessage, endMessage))
                    maker.insert(tl.1, atIndex: tl.0, withAnimation: .Fade)
                } else if _needRemoveTimeLine(beginMessage, endMessage) {
                    // 需要删除, 优先删除上面的, 删除区间之后index就是last了
                    let tl = _timeLine(begin, end)
                    maker.removeAtIndex(tl.0, withAnimation: animation(tl.1))
                } else if _needUpdateTimeLine(beginMessage, endMessage) {
                    // 需要更新
                    let tl = _timeLine(begin, end)
                    _updateTimeLine(beginMessage, endMessage)
                    maker.reloadAtIndex(tl.0, withAnimation: .Fade)
                }
            }
        }
    }
    
    ///
    /// 追加消息
    ///
    private func _appendMessages(ms: Array<SIMChatMessageProtocol>, animated: Bool = true) {
        guard let tableView = self.contentView, last = ms.last else {
            return
        }
        
        SIMLog.trace()
        
        let isSelf = last.isSelf ?? false
        let isLasted = (tableView.indexPathsForVisibleRows?.last?.row ?? 0) + ms.count == tableView.numberOfRowsInSection(0)
        
        _insertMessages(ms, atIndex: -1, animated: false)
        
        SIMLog.debug("self: \(isSelf) lasted: \(isLasted)")
        // 如果发送者是自己, 转到最后一行
        // 如果发送者是其他人, 并且当前行在最后一行, 转到最后一行
        if isSelf || isLasted {
            // 如果不是正在发送更新为己读
            // if last.status != .Sending {
            //     self._conversation.readMessage(last, nil, nil)
            // }
            // ok, 更新
            let idx = NSIndexPath(forRow: tableView.numberOfRowsInSection(0) - 1, inSection: 0)
            tableView.scrollToRowAtIndexPath(idx, atScrollPosition: .Bottom, animated: animated)
        } else {
            // 更新未读数量
        }
    }
    
    ///
    /// 加载历史消息
    ///
    private func _loadHistoryMessages() {
        guard !_isLoading else {
            return
        }
        SIMLog.trace()
        // 防止多次加载
        _isLoading = true
        
        // TODO: 动画有问题
        
        _conversation.loadHistoryMessages(200).response { [weak self] in
            defer {
                self?._isLoading = false
            }
            guard let sself = self, tableView = self?.contentView else {
                return
            }
            let isFirstLoad = sself._allMessages.isEmpty
            if let _allMessages = $0.value {
                // 如果所有的消息都加载完了, 关闭加载提示
                if sself._conversation.allMessagesIsLoaded {
                    UIView.performWithoutAnimation {
                        let h = tableView.tableHeaderView?.frame.height ?? 0
                        tableView.tableHeaderView = nil
                        tableView.contentOffset = CGPointMake(0, tableView.contentOffset.y - h)
                    }
                }
                // 插入消息
                sself._insertMessages(_allMessages, atIndex: 0, animated: false)
                // 如果是第一次加载, 更新到最后
                if isFirstLoad && !sself._allMessages.isEmpty {
                    SIMLog.debug("first load")
                    let idx = NSIndexPath(forRow: tableView.numberOfRowsInSection(0) - 1, inSection: 0)
                    tableView.scrollToRowAtIndexPath(idx, atScrollPosition: .Bottom, animated: false)
                    // 加点淡入的动画
                    let visibleCells = tableView.visibleCells
                    visibleCells.forEach { $0.alpha = 0 }
                    UIView.animateWithDuration(0.25) {
                        visibleCells.forEach { $0.alpha = 1 }
                    }
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
    /// 自动放弃(停止播放)
    private func _autoResignMessage(message: SIMChatMessageProtocol) {
        // 最后操作的就是删除的这一条消息, 这需要停止当前正在进行的工作
        if message == _lastOperatorMessage {
            mediaProvider.stop()
        }
    }
    
    // MARK: UITableViewDataSource
    
    /// 消息数量
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _allMessages.count
    }
    /// 计算高度
    @objc func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let message = _allMessages[indexPath.row]
        let identifier = reuseIndentifierWithMessage(message)
        return tableView.fd_heightForCellWithIdentifier(identifier, cacheByKey: message.identifier) {
            if let mcell = $0 as? SIMChatMessageCellProtocol {
                // configuation
                mcell.conversation = self._conversation
                mcell.message = message
            }
        }
    }
    /// 创建
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = reuseIndentifierWithMessage(_allMessages[indexPath.row])
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
        guard contentView?.tableHeaderView != nil && !_isLoading else {
            return
        }
        if scrollView.contentInset.top + scrollView.contentOffset.y <= header.frame.height {
            _loadHistoryMessages()
        }
    }
    /// 移到头部
    @objc func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        guard contentView?.tableHeaderView != nil && !_isLoading else {
            return
        }
        _loadHistoryMessages()
    }
    
    // MARK: UITableViewDataSource
    
    /// 绑定
    @objc func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let message = _allMessages[indexPath.row]
        if let mcell = cell as? SIMChatMessageCellProtocol {
            // custom configuation
            mcell.conversation = self._conversation
            mcell.message = message
            mcell.delegate = self
        }
    }

    // MARK: SIMChatConversationDelegate
    
    /// 接收到消息
    func conversation(conversation: SIMChatConversationProtocol, didReciveMessage message: SIMChatMessageProtocol) {
        SIMLog.debug()
        _appendMessages([message], animated: true)
    }
    
    /// 删除消息请求
    func conversation(conversation: SIMChatConversationProtocol, didRemoveMessage message: SIMChatMessageProtocol) {
        SIMLog.debug()
        _removeMessages([message], animated: true)
    }
    
    /// 更新消息请求
    func conversation(conversation: SIMChatConversationProtocol, didUpdateMessage message: SIMChatMessageProtocol) {
        SIMLog.debug()
        _reloadMessages([message], animated: true)
    }
    
    // MARK: SIMChatMessageCellDelegate
    
    // 点击消息
    func cellEvent(cell: SIMChatMessageCellProtocol, shouldPressMessage message: SIMChatMessageProtocol) -> Bool {
        return true
    }
    // 点击消息
    func cellEvent(cell: SIMChatMessageCellProtocol, didPressMessage message: SIMChatMessageProtocol) {
        guard let cell = cell as? UITableViewCell else {
            return // 未知错误
        }
        
        SIMLog.debug(message.identifier)
       
        switch message.content {
        case let content as SIMChatBaseMessageImageContent:
            if let view = (cell as? SIMChatBaseMessageImageCell)?.imageView where view.image != nil {
                targetView = view
                mediaProvider.imageBrowser().browse(content, withTarget: self)
            }
        case let content as SIMChatBaseMessageAudioContent:
            // 音频.
            let player = mediaProvider.audioPlayer(content.origin)
            if !player.playing {
                player.play()
            } else {
                player.stop()
            }
        default:
            break
        }
        _lastOperatorMessage = message
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
        
        _autoResignMessage(message)
        _conversation.removeMessage(message).response { [weak self] in
            // 检查操作状态
            if let error = $0.error {
                SIMLog.error(error)
                return
            }
            // 更新ui
            self?._removeMessages([message], animated: true)
        }
    }
    
    /// 重试(发送/上传/下载)
    func cellMenu(cell: SIMChatMessageCellProtocol, shouldRetryMessage message: SIMChatMessageProtocol) -> Bool {
        return true
    }
    /// 重试(发送/上传/下载)
    func cellMenu(cell: SIMChatMessageCellProtocol, didRetryMessage message: SIMChatMessageProtocol) {
        SIMLog.debug(message.identifier)
        // 重新发送
        _autoResignMessage(message)
        _conversation.sendMessage(message, isResend: true).response { //[weak self] in
            // 检查操作状态
            if let error = $0.error {
                SIMLog.error(error)
                return
            }
        }
        // 不用等结果, 直接移动
        _moveMessages([message], toIndex: -1, animated: true)
    }
    
    // 撤销
    func cellMenu(cell: SIMChatMessageCellProtocol, shouldRevokeMessage message: SIMChatMessageProtocol) -> Bool {
        return true
    }
    // 撤销
    func cellMenu(cell: SIMChatMessageCellProtocol, didRevokeMessage message: SIMChatMessageProtocol) {
        SIMLog.debug(message.identifier)
        // 更新状态为revoked
        _autoResignMessage(message)
        _conversation.updateMessage(message, status: .Revoked).response { [weak self] in
            // 检查操作状态
            if let error = $0.error {
                SIMLog.error(error)
                return
            }
            // 更新ui
            self?._reloadMessages([message], animated: true)
        }
    }
    
    ///
    /// 发送消息
    ///
    func sendMessage(content: SIMChatMessageContentProtocol) {
        SIMLog.trace()
        let message = manager.classProvider.message.messageWithContent(content,
            receiver: _conversation.receiver,
            sender: _conversation.sender)
        
        // 发送
        _conversation.sendMessage(message).response {
            // 检查操作状态
            if let error = $0.error {
                SIMLog.error(error)
                return
            }
        }
        // 不用等结果
        _appendMessages([message], animated: true)
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
//        self._conversation.sendMessage(SIMChatMessage(content), isResend: false, nil, nil)
//    }
//    ///
//    /// 重新发送消息(禁止外部访问)
//    ///
//    private func resendMessage(m: SIMChatMessage) {
//        // 真正的发送
//        self._conversation.sendMessage(m, isResend: true, nil, nil)
//    }
//    
//    ///
//    /// 加载聊天历史
//    ///
//    func loadHistorys(total: Int, last: SIMChatMessage? = nil) {
//        SIMLog.trace()
//        // 查询消息
//        self._conversation.queryMessages(total, last: last, { [weak self] ms in
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
//                    self?._conversation.readMessage(m, nil, nil)
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
////            self._conversation.removeMessage(m, nil, nil)
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
