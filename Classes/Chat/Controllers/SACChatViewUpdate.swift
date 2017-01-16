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
    
    internal init(model: SACChatViewData, updateItems: Array<SACChatViewUpdateItem>) {
        _model = model
        _updateItems = updateItems
        _computeItemUpdates()
    }
    
    internal func apply(with chatView: SACChatView) {
        
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
    
    internal func _convert(index: Int) -> Int {
        // +n = 0 <= n <= count
        // -n = 0 <= (count - n + 1) <= count
        guard index < 0 else {
            return min(index, _model.count)
        }
        return max(min(_model.count + index + 1, _model.count), 0)
    }
    internal func _convert(indexs: [Int]) -> [Int] {
        // [] => []
        // [1] => [1,1]
        // [1,2] => [1,2]
        // [1,2,4] => [1,2,4,4]
        // [1,2,2,4] => [1,2,4,4]
        guard !indexs.isEmpty else {
            return []
        }
        // unique all index
        let uniqued = Set(indexs).sorted()
        // processing
        return (1 ..< uniqued.count).reduce(([uniqued.first!, uniqued.last!], uniqued.first!)) { result, offset in
            let cur = uniqued[offset]
            if result.1 + 1 == cur {
                return (result.0, cur)
            }
            var arr = result.0
            arr.insert(uniqued[offset - 1], at: arr.count - 1)
            arr.insert(uniqued[offset + 0], at: arr.count - 1)
            return (arr, cur)
        }.0
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
    
    private func _computeItemUpdates() {
        
        var os: Array<Int> = [] // offsets
        var vi: Array<SACChatViewUpdateItem> = [] // insert
        var vr: Array<SACChatViewUpdateItem> = [] // remove
        var vu: Array<SACChatViewUpdateItem> = [] // update
        var vm: Array<SACChatViewUpdateItem> = [] // move
        
        let (first, last) = _updateItems.sorted(by: {
            guard let index1 = $0.indexBeforeUpdate ?? $0.indexAfterUpdate else {
                return false
            }
            guard let index2 = $1.indexBeforeUpdate ?? $1.indexAfterUpdate else {
                return false
            }
            return index1 < index2
        }).reduce((.max, .min)) { result, item -> (Int, Int) in
            guard let index = item.indexAfterUpdate ?? item.indexBeforeUpdate else {
                return result
            }
            switch item {
            case .move: vm.append(item)
            case .insert: vi.append(item)
            case .update: vu.append(item)
            case .remove: vr.append(item)
            }
            switch item {
            case .move(let from, let to):
                return (min(result.0, min(from, to)), max(result.1, max(from, to)))
            default:
                return (min(result.0, index), max(result.1, index))
            }
        }
        
        let begin = first - 1
        let end = last + 1/*next*/ + 1/*offset*/
        let count = _model.count
        
        var vip: Int = 0
        var vrp: Int = 0
        var vup: Int = 0
        var vmp: Int = 0
        
        // 优先级: 插入 => 删除 => 更新 => 移动
        
        var items: Array<SACMessageType> = []
        // 复制受影响的消息
        (max(first, 0) ... min(last, count)).forEach { index in
            let p = index - first
            // 插入
            while vip < vi.count {
                switch vi[vip] {
                case .insert(let msg, let idx) where min(idx, end) == index:
                    // copy ...
                    items.append(msg)
                    
                default:
                    // skip
                    break
                }
                // next
                vip += 1
            }
            guard index < count else {
                // auto remove
                os.append(-1)
                return
            }
//            // 删除
//            if vrp < vr.count {
//                switch vr[vrp] {
//                case .remove(let idx) where idx == index:
//                    // removing ...
//                    os.append(-1)
//                    items.append(_model[index])
//                    // next
//                    vrp += 1
//                    // can't update or copy
//                    return
//                    
//                default:
//                    break
//                }
//            }
//            // 更新
//            if vup <  vu.count {
//                switch vu[vup] {
//                case .update(let msg, let idx) where idx == index:
//                    // updating ...
//                    os.append(items.count)
//                    items.append(msg)
//                    // next
//                    vup += 1
//                    // can't copy
//                    return
//                    
//                default:
//                    break
//                }
//            }
            // 复制
            if first < last {
                os.append(items.count)
                items.append(_model[index])
            }
        }
        // 移动消息
        
        
//        let (first, last) = _updateItems.reduce(()) {
//            switch $1 {
//            case .
//            }
//            return $0
//        }
        
        
        // convert messages and replace specify message
        let newElements = items as? [SACMessageType] ?? []
        let results = _convert(messages: newElements, first: _element(at: begin), last: _element(at: end - 1))
        _model.replaceSubrange(max(begin, 0) ..< min(end, count), with: results)
    }
    
    private var _timeInterval: TimeInterval = 60

    private var _model: SACChatViewData
    private var _updateItems: Array<SACChatViewUpdateItem>
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
