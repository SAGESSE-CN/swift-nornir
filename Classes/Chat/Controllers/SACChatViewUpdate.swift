//
//  SACChatViewUpdate.swift
//  SAChat
//
//  Created by sagesse on 13/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

enum SACChatViewUpdateItem {
    case insert(SACMessageType, at: Int)
    case update(SACMessageType, at: Int)
    case remove(at: Int)
    case move(at: Int,  to: Int)
    
    /// nil for insert
    var indexBeforeUpdate: Int? {
        switch self {
        case .insert(_, let index):
            return nil
            
        case .update(_, let index):
            return index
        
        case .remove(let index):
            return index
            
        case .move(let index, _):
            return index
            
        default:
            return nil
        }
        
    }
    
    // nil for remove
    var indexAfterUpdate: Int? {
        switch self {
        case .insert(_, let index):
            return index
            
        case .update(_, let index):
            return index
            
        case .remove(let index):
            return nil
            
        case .move(_, let index):
            return index
            
        default:
            return nil
        }
    }
}

internal class SACChatViewUpdate {
    
    internal init(model: SACChatViewData) {
        _model = model
    }
    
    internal func apply(with updateItems: Array<SACChatViewUpdateItem>, to chatView: SACChatView) {
        _computeItemUpdates(updateItems)
    }
    
    private func _convert(message current: SACMessageType, previous: SACMessageType?) -> [SACMessageType] {
        
        // if current and previous is lt-message
        guard !(current._isTimeLineMessage && (previous?._isTimeLineMessage ?? false)) else {
            // ignore the message
            return []
        }
        
        // get vaild previous and next message.
        let vp = _fetch(before: previous)
        let vn = _fetch(after: current)
        
        // check vaild previous and vaild next time interval
        guard let next = vn, fabs(vp?._timeIntervalSince(next) ?? .greatestFiniteMagnitude) > _timeInterval else {
            // too near, check current message type
            guard !current._isTimeLineMessage else {
                // current is lt-message, but this is no need, ignore
                return []
            }
            return [current]
        }
        
        // too far away, checkout current is lt-message
        if let content = current.content as? SACMessageTimeLineContent {
            // current is lt-message
            content.before = previous
            // no change, continue use
            return [current]
        }
        
        // too far away
        return [SACMessage(forTimeline: current, before: vp), current]
    }
    private func _convert(messages elements: [SACMessageType], first: SACMessageType?, last: SACMessageType?) -> [SACMessageType] {
        
        // if first is not TimeLine, add to result
        let arr = NSMutableArray(capacity: elements.count * 2 + 2)
        if let message = first, !message._isTimeLineMessage {
            arr.add(message)
        }
        
        // processing
        _ = (0 ... elements.count).reduce(first) {
            // get previous message
            let previous = ($0 as? SACMessageTimeLineContent)?.before ?? $0
            // get current message
            guard let current = ($1 < elements.count) ? elements[$1] : last else {
                return nil
            }
            // merge message
            let results = _convert(message: current, previous: previous)
            // is empty, ignore
            guard !results.isEmpty else {
                return $0
            }
            arr.addObjects(from: results)
            // continue
            return current
        }
        
        return arr as! [SACMessageType]
    }
    
    private func _fetch(after message: SACMessageType?) -> SACMessageType? {
        guard let content = message?.content as? SACMessageTimeLineContent else {
            return message
        }
        return content.after
    }
    private func _fetch(before message: SACMessageType?) -> SACMessageType? {
        guard let content = message?.content as? SACMessageTimeLineContent else {
            return message
        }
        return content.before
    }
    
    internal func _element(at index: Int) -> SACMessageType? {
        guard index >= 0 && index < _model.count else {
            return nil
        }
        return _model[index]
    }
    
    internal func _computeItemUpdates(_ updateItems: Array<SACChatViewUpdateItem>) {
        
        var allInserts: Array<(Int, SACMessageType)> = []
        var allUpdates: Array<(Int, SACMessageType)> = []
        var allRemoves: Array<(Int)> = []
        var allMoves: Array<(Int, Int)> = []
        
        let (first, last) = updateItems.sorted(by: {
            guard let index1 = $0.indexBeforeUpdate ?? $0.indexAfterUpdate else {
                return false
            }
            guard let index2 = $1.indexBeforeUpdate ?? $1.indexAfterUpdate else {
                return false
            }
            return index1 < index2
        }).reduce((.max, .min)) { result, item -> (Int, Int) in
            
            switch item {
            case .move(let from, let to):
                
                allMoves.append((from, to))
                return (min(min(from, to), result.0), max(max(from, to) + 1, result.1))
                
            case .remove(let index):
                
                allRemoves.append((index))
                return (min(index, result.0), max(index + 1, result.1))
                
            case .update(let message, let index):
                
                allUpdates.append((index, message))
                return (min(index, result.0), max(index + 1, result.1))
                
            case .insert(let message, let index):
                
                allInserts.append((index, message))
                return (min(index, result.0), max(index, result.1))
            }
        }
        
        let count = _model.count
        let begin = first - 1 // prev
        let end = last + 1 // next
        
        print("copyed: \(first) ..< \(last)")
        print("affected: \(begin) ..< \(end)")
        
        var ii = allInserts.startIndex
        var iu = allUpdates.startIndex
        var ir = allRemoves.startIndex
        var im = allMoves.startIndex
        
        // 优先级: 插入 => 删除 => 更新 => 移动
        
        var items: Array<SACMessageType> = []
        var offsets: Array<Int> = []
        
        (first ... last).forEach { index in
            
            // inserting
            while ii < allInserts.endIndex && allInserts[ii].0 == index {
                items.append(allInserts[ii].1)
                ii += 1
            }
            // is end?
            guard index < last && index < count else {
                // auto remove
                offsets.append(-1)
                return
            }
            // remove
            while ir < allRemoves.endIndex && allRemoves[ir] == index {
                // remove
                offsets.append(-1)
                // adjust previous tl-message & next tl-message, if needed
                if let content = _element(at: index - 1)?.content as? SACMessageTimeLineContent {
                    content.after = nil
                }
                if let content = _element(at: index + 1)?.content as? SACMessageTimeLineContent {
                    content.before = nil
                }
                ir += 1
                // can't update or copy
                return 
            }
            // update
            while iu < allUpdates.endIndex && allUpdates[iu].0 == index {
                let message = allUpdates[iu].1
                // update
                offsets.append(items.count)
                items.append(message)
                // adjust previous tl-message & next tl-message, if needed
                if let content = _element(at: index - 1)?.content as? SACMessageTimeLineContent {
                    content.after = message
                }
                if let content = _element(at: index + 1)?.content as? SACMessageTimeLineContent {
                    content.before = message
                }
                iu += 1
                // can't copy
                return
            }
            // copy
            offsets.append(items.count)
            items.append(_model[index])
        }
        
//        var vip: Int = 0
//        var vrp: Int = 0
//        var vup: Int = 0
//        var vmp: Int = 0
//        
//        // 优先级: 插入 => 删除 => 更新 => 移动
//        
//        var items: Array<SACMessageType> = []
//        // 复制受影响的消息
//        (max(first, 0) ... min(last, count)).forEach { index in
//            let p = index - first
//            // 插入
//            while vip < vi.count {
//                switch vi[vip] {
//                case .insert(let msg, let idx) where min(idx, end) == index:
//                    // copy ...
//                    items.append(msg)
//                    
//                default:
//                    // skip
//                    break
//                }
//                // next
//                vip += 1
//            }
//            guard index < count else {
//                // auto remove
//                os.append(-1)
//                return
//            }
////            // 删除
////            if vrp < vr.count {
////                switch vr[vrp] {
////                case .remove(let idx) where idx == index:
////                    // removing ...
////                    os.append(-1)
////                    items.append(_model[index])
////                    // next
////                    vrp += 1
////                    // can't update or copy
////                    return
////                    
////                default:
////                    break
////                }
////            }
////            // 更新
////            if vup <  vu.count {
////                switch vu[vup] {
////                case .update(let msg, let idx) where idx == index:
////                    // updating ...
////                    os.append(items.count)
////                    items.append(msg)
////                    // next
////                    vup += 1
////                    // can't copy
////                    return
////                    
////                default:
////                    break
////                }
////            }
//            // 复制
//            if first < last {
//                os.append(items.count)
//                items.append(_model[index])
//            }
//        }
//        // 移动消息
//        
//        
////        let (first, last) = _updateItems.reduce(()) {
////            switch $1 {
////            case .
////            }
////            return $0
////        }
//        
//        
        // convert messages and replace specify message
        let newElements = items as? [SACMessageType] ?? []
        let results = _convert(messages: newElements, first: _element(at: begin), last: _element(at: end - 1))
        _model.replaceSubrange(max(begin, 0) ..< min(end, count), with: results)
    }
    
    private var _timeInterval: TimeInterval = 60

    private var _model: SACChatViewData
}

fileprivate extension SACMessageType {
    
    
    fileprivate var _isTimeLineMessage: Bool {
        return content is SACMessageTimeLineContent
    }
    fileprivate func _timeIntervalSince(_ other: SACMessageType) -> TimeInterval {
        // if message is lt-message, read for after message
        let a = (self.content as? SACMessageTimeLineContent)?.after ?? self
        let b = (other.content as? SACMessageTimeLineContent)?.after ?? other
        // calc
        return a.date.timeIntervalSince(b.date)
    }
    
}
