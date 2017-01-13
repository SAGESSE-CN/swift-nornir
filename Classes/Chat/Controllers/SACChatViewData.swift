//
//  SACChatViewData.swift
//  SAChat
//
//  Created by sagesse on 09/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

class SACChatViewData: NSObject {
    
    var count: Int {
        return _elements.count
    }
    
    
    func insert(_ newElement: SACMessageType, at index: Int) {
        insert(contentsOf: [newElement], at: index)
    }
    func insert(contentsOf newElements: [SACMessageType], at index: Int) {
        
        // make affected region
        let begin = _convert(index: index) - 1
        let end = _convert(index: index) + 1
        
        // convert new messages
        let count = _elements.count
        let results = _convert(messages: newElements, first: _element(at: begin), last: _element(at: end - 1))
        
        // replace specify message
        _elements.replaceSubrange(max(begin, 0) ..< min(end, count), with: results)
        
        
        _logger.trace("insert region: [\(begin) ..< \(end)], new: \(results.count), total: \(_elements.count)")
    }
    
    func remove(at index: Int) {
        remove(contentsOf: [index])
    }
    func remove(contentsOf indexs: [Int]) {
        // get remove message
        let count = _elements.count
        let removes = _convert(indexs: indexs)
        
        // check indexs
        guard !removes.isEmpty else {
            return
        }
        
        // copy affected messages
        let begin = removes.first! - 1
        let end = removes.last! + 1/*next message*/ + 1/*last + 1*/
        let copyElements = NSMutableArray(capacity: (end - begin) + 1)
        let _ = (0 ..< removes.count).filter({ $0 % 2 == 0 }).reduce(nil) { p, i -> Int? in
            // get lower bound & upper bound
            let l = removes[i + 0]
            let u = removes[i + 1]
            // need to connect the last position?
            if let p = p, l > 0, p <= l {
                // copy top (p + 1 ..< l)
                let result = _elements[p ..< l]
                // adjust previous lt-message
                if let content = result.first?.content as? SACMessageTimeLineContent {
                    content.before = nil
                }
                // adjust next lt-message
                if let content = result.last?.content as? SACMessageTimeLineContent {
                    content.after = nil
                }
                // merge
                copyElements.addObjects(from: Array(result))
            }
            // move to bottom + 1
            return u + 1
        }
        
        // convert messages and replace specify message
        let newElements = copyElements as? [SACMessageType] ?? []
        let results = _convert(messages: newElements, first: _element(at: begin), last: _element(at: end - 1))
        _elements.replaceSubrange(max(begin, 0) ..< min(end, count), with: results)
        
        
        _logger.trace("remove items: \(removes), infl: [\(begin) ..< \(end)]")
    }
    
    func update(_ newElement: SACMessageType, at index: Int) {
        update(contentsOf: [newElement], at: [index])
    }
    func update(contentsOf newElements: [SACMessageType], at indexs: [Int]) {
        assert(indexs.count == newElements.count, "the input element count cannot match the indexs count")
        // checkout new elements
        guard !newElements.isEmpty else {
            return // is empty, ignore
        }
        let first = indexs.min()!
        let last = indexs.max()!
        
        // copy affected messages
        let begin = first - 1
        let end = last + 1/*next message*/ + 1/*last + 1*/
        var copyElements = Array(_elements[max(first, 0) ..< min(last + 1, count)])
        
        // replace update the message
        indexs.enumerated().forEach { offset, index in
            let nm = newElements[offset]
            let idx = index - first
            // processing
            guard idx >= 0 && idx < copyElements.count else {
                return // over bundary, ignore
            }
            copyElements[idx] = nm
            // adjust previous lt-message
            if let content = _element(at: index - 1)?.content as? SACMessageTimeLineContent {
                content.after = nm
            }
            // adjust next lt-message
            if let content = _element(at: index + 1)?.content as? SACMessageTimeLineContent {
                content.before = nm
            }
        }
        
        // convert messages and replace specify message
        let results = _convert(messages: copyElements, first: _element(at: begin), last: _element(at: end - 1))
        _elements.replaceSubrange(max(begin, 0) ..< min(end, count), with: results)
        
        
        _logger.trace("update items: \(indexs), infl: [\(begin) ..< \(end)]")
    }
    
    func performBatchUpdates(_ updates: (() -> Swift.Void)?, completion: ((Bool) -> Swift.Void)? = nil) {
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
            return min(index, _elements.count)
        }
        return max(min(_elements.count + index + 1, _elements.count), 0)
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
        guard index >= 0 && index < _elements.count else {
            return nil
        }
        return _elements[index]
    }
    
    
    private lazy var _timeInterval: TimeInterval = 60
     lazy var _elements: [SACMessageType] = []
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
