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
    case equal(from: Int, to: Int)
    case insert(at: Int)
    case remove(at: Int)
    
    var description: String {
        switch self {
        case .equal(let from, let to):
            return " \(from)/\(to)"
            
        case .insert(let index):
            return "+N/\(index)"
            
        case .remove(let index):
            return "-\(index)/N"
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
    
    ///
    /// 比较数组差异
    /// (+1, src.index, dest.index) // add
    /// ( 0, src.index, dest.index) // equal
    /// (-1, src.index, dest.index) // remove
    private func _diff(_ src: Array<SACMessageType>, _ dest: Array<SACMessageType>) -> Array<SACChatViewUpdateChange> {
        
        let len1 = src.count
        let len2 = dest.count
        
        var c = [[Int]](repeating: [Int](repeating: 0, count: len2 + 1), count: len1 + 1)
        
        // lcs + 动态规划
        for i in 1 ..< len1 + 1 { 
            for j in 1 ..< len2 + 1 {
                if src[i - 1] === dest[j - 1] {
                    c[i][j] = c[i - 1][j - 1] + 1
                } else {
                    c[i][j] = max(c[i - 1][j], c[i][j - 1])
                }
            }
        }
        
        var r = [SACChatViewUpdateChange]()
        var i = len1
        var j = len2
        
        // create the optimal path
        repeat {
            guard i != 0 else {
                // the remaining is add
                while j > 0 {
                    r.append(.insert(at: j - 1))
                    j -= 1
                }
                break
            }
            guard j != 0 else {
                // the remaining is remove
                while i > 0 {
                    r.append(.remove(at: i - 1))
                    i -= 1
                }
                break
            }
            guard src[i - 1] !== dest[j - 1]  else {
                // no change, ignore
                //r.append(.equal(from: i - 1, to: j - 1))
                i -= 1
                j -= 1
                continue
            }
            // check the weight
            if c[i - 1][j] > c[i][j - 1] {
                // is remove
                r.append(.remove(at: i - 1))
                i -= 1
            } else {
                // is add
                r.append(.insert(at: j - 1))
                j -= 1
            }
        } while i > 0 || j > 0
        
        return r.reversed()
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
        var offsets: Array<Int> = []
        
        // processing
        (first ... last).forEach { index in
            // do you need to insert the operation?
            while ii < allInserts.endIndex && allInserts[ii].0 == index {
                items.append(allInserts[ii].1)
                ii += 1
            }
            // do you need to do this?
            guard index < last && index < count else {
                // no auto remove
                offsets.append(-1)
                return
            }
            // do you need to remove the operation?
            while ir < allRemoves.endIndex && allRemoves[ir] == index {
                // removing
                offsets.append(-1)
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
                offsets.append(items.count)
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
            offsets.append(items.count)
            items.append(_model[index])
        }
        // convert messages and replace specify message
        let newItems = items as? [SACMessageType] ?? []
        let convertedItems = _convert(messages: newItems, first: _element(at: begin), last: _element(at: end - 1))
        let selectedRange = Range<Int>(max(begin, 0) ..< min(end, count))
        let selectedItems = _model.subarray(with: selectedRange)
        // compute index paths
        let diff = _diff(selectedItems, convertedItems)
        
        // 找移动和更新的
        
        print(diff)
        
        // replace
        _model.replaceSubrange(selectedRange, with: convertedItems)
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

