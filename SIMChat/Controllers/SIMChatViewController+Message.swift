//
//  SIMChatViewController+Message.swift
//  SIMChat
//
//  Created by sagesse on 9/26/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

//// MARK: - Message
//extension SIMChatViewController {
//    ///
//    /// 注册消息单元格
//    ///
//    /// :param: model   消息数据类
//    /// :param: cell    消息显示的单元格
//    ///
//    func registerClass(cell: SIMChatMessageCellProtocol.Type, _ model: SIMChatMessageContentProtocol.Type) {
//        let key = NSStringFromClass(model)
//        
//        SIMLog.debug("\(key) => \(NSStringFromClass(cell))")
//        // 保存起来
//        self.relations[key] = cell
//        // 注册到tabelView
//        self.tableView.registerClass(cell, forCellReuseIdentifier: key)
//    }
//    ///
//    /// 批量插入消息, TODO: 需要优化
//    ///
//    /// :param: ms       消息
//    /// :param: index    如果为index < 0, 插入点为count + index + 1
//    /// :param: animated 动画
//    ///
//    func insertRows(ms: [SIMChatMessage], atIndex index: Int, animated: Bool = true) {
//        SIMLog.trace()
//        
//        let st = 60.0
//        
//        let count = source.count
//        let position = min(max(index >= 0 ? index : index + count + 1, 0), count)
//        
//        // tip1: 如果cell插入到visibleCells之前, 会导致content改变(contentOffset不变), 
//        // tip2: 如果设置contentOffset会导致减速事件停止
//        // tip3: insertRowsAtIndexPaths的动画需要强制去除
//        // tip4: 不要在beginUpdates里面indexPath请求cell
//        //
//        // 插入位置:
//        //     [  ] + [ms] + [ds]
//        //     [ds] + [ms] + [ds]
//        //     [ds] + [ms] + [  ]
//        //
//        
//        // 检查是不是插入到visible之前
//        //let small = tableView.contentSize.height < tableView.bounds.height
//        var visibles = tableView.indexPathsForVisibleRows
//        let reoffset = /*!small &&*/ visibles?.contains({ position < $0.row }) ?? false
//        
//        // 需要插入的indexPaths
//        // 需要删除的indexPaths
//        // 需要更新的indexPaths
//        var inss = [NSIndexPath]()
//        var dels = [NSIndexPath]()
//        var upds = [NSIndexPath]()
//        
//        /// 准备数据 
//        
//        // 先搞到插入点之前的消息
//        // 再搞到插入点之后的消息
//        var first: SIMChatMessage? = position - 1 < count && position != 0 ? source[position - 1] : nil
//        let last: SIMChatMessage? = position < count ? source[position] : nil
//        
//        // 格式化消息
//        var fms = [SIMChatMessage]()
//        for m in ms {
//            // 两条消息时差为st
//            // 那么添加一个时间分隔线
//            if first == nil || fabs(first!.receiveTime - m.receiveTime) > st {
//                var time: SIMChatMessage!
//                // 如果前面的本来就是时间了.
//                if first?.content is SIMChatMessageContentDate {
//                    
//                    time = first
//                    upds.append(NSIndexPath(forRow: position + fms.count - 1, inSection: 0))
//                    
//                } else {
//                    
//                    time = SIMChatMessage()
//                    fms.append(time)
//                }
//                // 更新.
//                time.receiveTime = m.receiveTime
//                time.content = SIMChatMessageContentDate()
//                //time.makeDateWithMessage(m)
//            }
//            
//            fms.append(m)
//            first = m
//        }
//        
//        // 检查最后一条数据的时间
//        if first != nil && last != nil && !(fabs(first!.receiveTime - last!.receiveTime) > st) {
//            // 删除 position + fms.count
//            source.removeAtIndex(position)
//            // 
//            dels.append(NSIndexPath(forRow: position, inSection: 0))
//            // 删除是谁?
//            if visibles?[0].row == position {
//                visibles?.removeAtIndex(0)
//            }
//            SIMLog.debug("delete \(position)")
//        }
//        
//        /// 更新UI
//        
//        // 插入数据
//        for e in EnumerateSequence(fms) {
//            source.insert(e.element, atIndex: min(e.index + position, source.count))
//            inss.append(NSIndexPath(forRow: e.index + position, inSection: 0))
//        }
//        
//        // 在更新之前先获取到从contentOffset到visibles.first.top的偏移量
//        let offset = !reoffset ? CGPointZero :  {
//            // 获取origin
//            let o = self.tableView.contentOffset
//            // 禁止动画, 更新到top(会导致减速事件停止)
//            UIView.performWithoutAnimation {
//                self.tableView.scrollToRowAtIndexPath(visibles![0], atScrollPosition: .Top, animated: false)
//            }
//            // 获取top
//            let t = self.tableView.contentOffset //: CGPointMake(0, -self.tableView.contentInset.top * 2)
//            // ..
//            SIMLog.debug("src: \(o)")
//            SIMLog.debug("src offset: \(t)")
//            // ok
//            return CGPointMake(o.x - t.x, o.y - t.y)
//        }()
//        
//        // 禁止动画, 更新
//        UIView.performWithoutAnimation {
//            self.tableView.beginUpdates()
//            self.tableView.reloadRowsAtIndexPaths(upds, withRowAnimation: .None)
//            self.tableView.deleteRowsAtIndexPaths(dels, withRowAnimation: .None)
//            self.tableView.insertRowsAtIndexPaths(inss, withRowAnimation: .None)
//            self.tableView.endUpdates()
//        }
//        
//        // 需要更新?
//        if reoffset {
//            
//            // 默认为0
//            var idx = NSIndexPath(forRow: 0, inSection: 0)
//            
//            // 需要保持位置的cell
//            if visibles!.count != 0 {
//                idx = NSIndexPath(forRow: visibles![0].row + fms.count - dels.count, inSection: 0)
//            }
//            
//            // 更新到Top
//            UIView.performWithoutAnimation     {
//                self.tableView.scrollToRowAtIndexPath(idx, atScrollPosition: .Top, animated: false)
//            }
//            // 获取top位置
//            let t = self.tableView.contentOffset
//            // 更新contentOffset
//            self.tableView.setContentOffset(CGPointMake(t.x, t.y + offset.y), animated: false)
//            
////            // 如果。
////            if small && animated {
////                self.tableView.setContentOffset(CGPointMake(t.x, t.y + offset.y + self.tableView.contentInset.top), animated: false)
////                UIView.animateWithDuration(0.25) {
////                    self.tableView.setContentOffset(CGPointMake(t.x, t.y + offset.y), animated: false)
////                }
////            }
//            
//            SIMLog.debug("index: \(idx.row)")
//            SIMLog.debug("offset: \(offset)")
//            SIMLog.debug("content offset: \(t)")
//            SIMLog.debug("new content offset: \(self.tableView.contentOffset)")
//        }
//        
//        // TODO: small && animated, 关于过小的问题
//    }
//    /// 
//    /// 更新消息
//    /// 
//    /// :param: ms       消息
//    /// :param: animated 动画
//    /// 
//    func reloadRows(ms: SIMChatMessage, animated: Bool = true) {
//        SIMLog.trace()
//        // 更新.
//    }
//    ///
//    /// 删除消息
//    // TODO: 需要优化!!!
//    /// 
//    /// :param: ms       消息
//    /// :param: animated 动画
//    ///   
//    func deleteRows(m: SIMChatMessage, animated: Bool = true) {
//        SIMLog.trace()
//        
//        //let st = 60.0
//        var idxs = [Int]()
//        
//        if let idx = source.indexOf(m) {
//            // 如果前一个是时间, 同时删除他
//            if idx != 0 && idx - 1 < source.count && source[idx - 1].content is SIMChatMessageContentDate {
//                idxs.append(idx - 1) // 删除他
//            }
//            // 删除 。
//            idxs.append(idx)
//        }
//        
//        // 删除。
//        for i in ReverseCollection(idxs) {
//            source.removeAtIndex(i)
//        }
//        
//        // 重新加载...
//        let ani = !animated ? UIView.performWithoutAnimation : { b in b() }
//        let style: UITableViewRowAnimation = (m.sender! == self.conversation.sender) ? .Right : .Left
//        
//        ani { 
//            self.tableView.deleteRowsAtIndexPaths(idxs.map({NSIndexPath(forRow: $0, inSection: 0)}), withRowAnimation: style)
//        }
//    }
//    ///
//    /// 追加消息.
//    ///
//    func appendMessage(m: SIMChatMessage) {
//        
//        let isSelf = m.ownership
//        let isLasted = (tableView.indexPathsForVisibleRows?.last?.row ?? 0) + 1 == tableView.numberOfRowsInSection(0)
//        
//        self.insertRows([m], atIndex: -1)
//        
//        SIMLog.debug("self: \(isSelf) lasted: \(isLasted)")
//        
//        // 如果发送者是自己, 转到最后一行
//        // 如果发送者是其他人, 并且当前行在最后一行, 转到最后一行
//        if isSelf || isLasted {
//            // 如果不是正在发送更新为己读
//            if m.status != .Sending {
//                self.conversation.readMessage(m, nil, nil)
//            }
//            // ok, 更新
//            dispatch_async(dispatch_get_main_queue()) {
//                let cnt = self.tableView.numberOfRowsInSection(0)
//                let idx = NSIndexPath(forRow: cnt - 1, inSection: 0)
//                
//                self.tableView.scrollToRowAtIndexPath(idx, atScrollPosition: .Bottom, animated: true)
//            }
//        } else {
//            // 更新未读数量
//        }
//    }
//    /// 构建
//    func buildOfMessage() {
//        SIMLog.trace()
//        
//        // 聊天内容
//        self.registerClass(SIMChatMessageCellText.self,    SIMChatMessageContentText.self)
//        self.registerClass(SIMChatMessageCellAudio.self,   SIMChatMessageContentAudio.self)
//        self.registerClass(SIMChatMessageCellImage.self,   SIMChatMessageContentImage.self)
//        // 辅助
//        self.registerClass(SIMChatMessageCellTips.self,    SIMChatMessageContentTips.self)
//        self.registerClass(SIMChatMessageCellDate.self,    SIMChatMessageContentDate.self)
//        // 默认
//        self.registerClass(SIMChatMessageCellUnknow.self,  SIMChatMessageContentUnknow.self)
//    }
//}
//
//// MARK: - Message Conversation
//extension SIMChatViewController : SIMChatConversationDelegate {
//    
//    /// 新消息通知
//    func chatConversation(conversation: SIMChatConversationProtocol, didReciveMessage message: SIMChatMessage) {
//        dispatch_async(dispatch_get_main_queue()) {
//            self.appendMessage(message)
//        }
//    }
//    
//    /// 删除消息通知
//    func chatConversation(conversation: SIMChatConversationProtocol, didRemoveMessage message: SIMChatMessage) {
//        dispatch_async(dispatch_get_main_queue()) {
//            self.deleteRows(message)
//        }
//    }
//    
//    /// 更新消息通知
//    func chatConversation(conversation: SIMChatConversationProtocol, didUpdateMessage message: SIMChatMessage) {
//        dispatch_async(dispatch_get_main_queue()) {
//            // 需要检查时间
//            // 可能发生了改变
//            self.reloadRows(message)
//        }
//    }
//}
//
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
