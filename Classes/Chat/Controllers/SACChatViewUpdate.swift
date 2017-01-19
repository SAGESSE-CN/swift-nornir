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
}
enum SACChatViewUpdateChange: CustomStringConvertible {
    
    case move(from: Int, to: Int)
    case update(from: Int, to: Int)
    case insert(from: Int, to: Int)
    case remove(from: Int, to: Int)
    
    var from: Int {
        switch self {
        case .move(let from, _): return from
        case .insert(let from, _): return from
        case .update(let from, _): return from
        case .remove(let from, _): return from
        }
    }
    var to: Int {
        switch self {
        case .move(_, let to): return to
        case .insert(_, let to): return to
        case .update(_, let to): return to
        case .remove(_, let to): return to
        }
    }
    
    var isMove: Bool {
        switch self {
        case .move: return true
        default: return false
        }
    }
    var isUpdate: Bool {
        switch self {
        case .update: return true
        default: return false
        }
    }
    var isRemove: Bool {
        switch self {
        case .remove: return true
        default: return false
        }
    }
    var isInsert: Bool {
        switch self {
        case .insert: return true
        default: return false
        }
    }
    
    
    var description: String {
        let from = self.from >= 0 ? "\(self.from)" : "N"
        let to = self.to >= 0 ? "\(self.to)" : "N"
        
        switch self {
        case .move: return "M\(from)/\(to)"
        case .insert: return "A\(from)/\(to)"
        case .update: return "R\(from)/\(to)"
        case .remove: return "D\(from)/\(to)"
        }
    }
}

internal class SACChatViewUpdate: NSObject {
    
    internal init(model: SACChatViewData) {
        _model = model
        super.init()
    }
    
    internal func apply(with updateItems: Array<SACChatViewUpdateItem>, to chatView: SACChatView) {
        _computeItemUpdates(updateItems)
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
    
    private func _diff<T: SACMessageType>(_ src: Array<T>, _ dest: Array<T>) -> Array<SACChatViewUpdateChange> {
        
        let len1 = src.count
        let len2 = dest.count
        
        var c = [[Int]](repeating: [Int](repeating: 0, count: len2 + 1), count: len1 + 1)
        
        // lcs + 动态规划
        for i in 1 ..< len1 + 1 {
            for j in 1 ..< len2 + 1 {
                if src[i - 1] == dest[j - 1] {
                    c[i][j] = c[i - 1][j - 1] + 1
                } else {
                    c[i][j] = max(c[i - 1][j], c[i][j - 1])
                }
            }
        }
        
        var i = len1
        var j = len2
        
        var rms: Array<(from: Int, to: Int)> = []
        var adds: Array<(from: Int, to: Int)> = []
        
        // create the optimal path
        repeat {
            guard i != 0 else {
                // the remaining is add
                while j > 0 {
                    adds.append((from: i - 1, to: j - 1))
                    j -= 1
                }
                break
            }
            guard j != 0 else {
                // the remaining is remove
                while i > 0 {
                    rms.append((from: i - 1, to: j - 1))
                    i -= 1
                }
                break
            }
            guard src[i - 1] != dest[j - 1]  else {
                // no change, ignore
                i -= 1
                j -= 1
                continue
            }
            // check the weight
            if c[i - 1][j] > c[i][j - 1] {
                // is remove
                rms.append((from: i - 1, to: j - 1))
                i -= 1
            } else {
                // is add
                adds.append((from: i - 1, to: j - 1))
                j -= 1
            }
        } while i > 0 || j > 0
        
        var results: Array<SACChatViewUpdateChange> = []
        results.reserveCapacity(rms.count + adds.count)
        
        // move(f,t): f = remove(f), t = insert(t), new move(f,t): f = remove(f), t = insert(f)
        // update(f,t): f = remove(f), t = insert(t), new update(f,t): f = remove(f), t = insert(f)
        
        // automatic merge delete and update items
        results.append(contentsOf: rms.map({ item in
            let from = item.from
            let delElement = src[from]
            // can't merge to move item?
            if let addIndex = adds.index(where: { dest[$0.to] == delElement }) {
                let addItem = adds.remove(at: addIndex)
                return .move(from: from, to: addItem.from)
            }
            // can't merge to update item?
            if let addIndex = adds.index(where: { $0.to == from }) {
                let addItem = adds[addIndex]
                let addElement = dest[addItem.to]
                // the same type is allowed to merge
                if type(of: delElement.content) == type(of: addElement.content) {
                    adds.remove(at: addIndex)
                    return .update(from: from, to: addItem.from)
                }
            }
            return .remove(from: item.from, to: item.to)
        }))
        // automatic merge insert items
        results.append(contentsOf: adds.map({ item in
            return .insert(from: item.from, to: item.to)
        }))
        
        // sort
        return results.sorted { $0.from < $1.from }
    }
    
    internal func _computeItemUpdates(_ updateItems: Array<SACChatViewUpdateItem>) {
        
        // is empty?
        guard !updateItems.isEmpty else {
            return
        }
        var allInserts: Array<(Int, SACMessageType)> = []
        var allUpdates: Array<(Int, SACMessageType)> = []
        var allRemoves: Array<(Int)> = []
        var allMoves: Array<(Int, Int)> = []
        
        // get max & min
        let (first, last) = updateItems.reduce((.max, .min)) { result, item -> (Int, Int) in
            
            switch item {
            case .move(let from, let to):
                // ignore for source equ dest
                guard abs(from - to) >= 2 else {
                    return result
                }
                // move message
                allMoves.append((from, to))
                // splite to insert & remove
                if let message = _element(at: from) {
                    allRemoves.append((from))
                    allInserts.append((to, message))
                }
                // from + 1: the selected row will change
                return (min(min(from, to), result.0), max(max(from + 1, to), result.1))
                
            case .remove(let index):
                // remove message
                allRemoves.append((index))
                return (min(index, result.0), max(index + 1, result.1))
                
            case .update(let message, let index):
                // update message
                allUpdates.append((index, message))
                return (min(index, result.0), max(index + 1, result.1))
                
            case .insert(let message, let index):
                // insert message
                allInserts.append((index, message))
                return (min(index, result.0), max(index, result.1))
            }
        }
        // is empty
        guard first != .max && last != .min else {
            return
        }
        // sort
        allInserts.sort { $0.0 < $1.0 }
        allUpdates.sort { $0.0 < $1.0 }
        allRemoves.sort { $0 < $1 }
        allMoves.sort { $0.0 < $1.0 }
        
        let count = _model.count
        let begin = first - 1 // prev
        let end = last + 1 // next
        
        var ii = allInserts.startIndex
        var iu = allUpdates.startIndex
        var ir = allRemoves.startIndex
        var im = allMoves.startIndex
        
        // priority: insert > remove > update > move
        
        var items: Array<SACMessageType> = []
        
        // processing
        (first ... last).forEach { index in
            // do you need to insert the operation?
            while ii < allInserts.endIndex && allInserts[ii].0 == index {
                items.append(allInserts[ii].1)
                ii += 1
            }
            // do you need to do this?
            guard index < last && index < count else {
                return
            }
            // do you need to remove the operation?
            while ir < allRemoves.endIndex && allRemoves[ir] == index {
                // adjust previous tl-message & next tl-message, if needed
                if let content = _element(at: index - 1)?.content as? SACMessageTimeLineContent {
                    content.after = nil
                }
                if let content = _element(at: index + 1)?.content as? SACMessageTimeLineContent {
                    content.before = nil
                }
                // move to next operator(prevent repeat operation)
                while ir < allRemoves.endIndex && allRemoves[ir] == index {
                    ir += 1
                }
                // can't update or copy
                return 
            }
            // do you need to update the operation?
            while iu < allUpdates.endIndex && allUpdates[iu].0 == index {
                let message = allUpdates[iu].1
                // updating
                items.append(message)
                // adjust previous tl-message & next tl-message, if needed
                if let content = _element(at: index - 1)?.content as? SACMessageTimeLineContent {
                    content.after = message
                }
                if let content = _element(at: index + 1)?.content as? SACMessageTimeLineContent {
                    content.before = message
                }
                // move to next operator(prevent repeat operation)
                while iu < allUpdates.endIndex && allUpdates[iu].0 == index {
                    iu += 1
                }
                // can't copy
                return
            }
            // copy
            items.append(_model[index])
        }
        // convert messages and replace specify message
        let newItems = items as? [SACMessageType] ?? []
        let convertedItems = _convert(messages: newItems, first: _element(at: begin), last: _element(at: end - 1))
        let selectedRange = Range<Int>(max(begin, 0) ..< min(end, count))
        let selectedItems = _model.subarray(with: selectedRange)
        // compute index paths
        let start = selectedRange.lowerBound
        let diff = _diff(selectedItems, convertedItems).map({ item -> SACChatViewUpdateChange in
            switch item {
            case .move(let from, let to): return .move(from: from + start, to: to + start)
            case .insert(let from, let to): return .insert(from: from + start, to: to + start)
            case .update(let from, let to): return .update(from: from + start, to: to + start)
            case .remove(let from, let to): return .remove(from: from + start, to: to + start)
            }
        })
        _logger.debug("select: [\(first) ..< \(last)], diff: \(diff)")
        // replace
        _model.replaceSubrange(selectedRange, with: convertedItems)
        _changes = diff
    }
    
    private var _model: SACChatViewData
    private var _changes: Array<SACChatViewUpdateChange>?
    
    private var _timeInterval: TimeInterval = 60
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

