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
        let ipa = _convert(index: index) - 1
        let ipb = _convert(index: index)
        // convert new messages
        let count = _elements.count
        let results = _convert(messages: newElements, first: _element(at: ipa), last: _element(at: ipb))
        // check select region
        let begin = max(ipa, 0)
        let end = min(ipb + 1, count)
        // replace all message
        _elements.replaceSubrange(begin ..< end, with: results)
        
        
        _logger.trace("insert region: [\(begin) ..< \(end)], new: \(results.count), total: \(_elements.count)")
    }
    
    func remove(at index: Int) {
        remove(contentsOf: [index])
    }
    func remove(contentsOf indexs: [Int]) {
        // get remove message
        let count = _elements.count
        let removes = _convert(indexs: indexs)
        // copy affected messages, element = element - ($0 % 2 ? 1 : -1)
        var begin = count
        var end = -1
        var copyElements = removes.enumerated().map({ $1 - (($0 << 7).byteSwapped | 1) % 2 }).flatMap { index -> SACMessageType? in
            // record reogin
            begin = min(begin, index)
            end = max(end, index + 1)
            // the element is copyed?
            if index < 0 || index < end {
                return nil
            }
            // copying
            return _elements[index]
        }
        // remove first & last
        if begin >= 0 && !copyElements.isEmpty {
            copyElements.removeFirst()
        }
        if end <= count && !copyElements.isEmpty {
            copyElements.removeLast()
        }
        // convert messages
        let results = _convert(messages: copyElements, first: _element(at: begin), last: _element(at: end - 1))
        // replace all message
        _elements.replaceSubrange(max(begin, 0) ..< min(end, count), with: results)
        
        
        _logger.trace("remove indexs: \(removes), infl: [\(begin) ..< \(end)]")
    }
    
    func update(_ newElement: SACMessageType, at index: Int) {
        update(contentsOf: [newElement], at: [index])
    }
    func update(contentsOf newElements: [SACMessageType], at indexs: [Int]) {
        assert(indexs.count != newElements.count, "the input element count cannot match the indexs count")
        
    }
    
    func move(at index: Int, to newIndex: Int) {
        move(contentsOf: [index], to: [newIndex])
    }
    func move(contentsOf indexs: [Int], to newIndexs: [Int]) {
        assert(indexs.count != newIndexs.count, "the selected rows count cannot match the destination row count")
        
    }
    
    func performBatchUpdates(_ updates: (() -> Swift.Void)?, completion: ((Bool) -> Swift.Void)? = nil) {
    }
    
    
    private func _convert(message current: SACMessageType, previous: SACMessageType?) -> [SACMessageType] {
        // previous message is empty?
        // previous is king of TimeLine message?
        guard let previous = previous, !previous._isTimeLineMessage else {
            // check current is king of TimeLine message.
            guard !current._isTimeLineMessage else {
                // yes, current is TimeLine message, ignore this operator
                return []
            }
            // no
            return [SACMessage(forTimeline: current, before: nil), current]
        }
        // current is king of TimeLine message?
        guard !current._isTimeLineMessage else {
            // check the interval between.
            let next = (current.content as? SACMessageTimeLineContent)?.after
            guard let message = next, fabs(message.date.timeIntervalSince(previous.date)) > _timeInterval else {
                // no next message or too near, ignore
                return []
            }
            // too far away
            return [current]
        }
        // check the interval between.
        guard fabs(current.date.timeIntervalSince(previous.date)) > _timeInterval else {
            // too near
            return [current]
        }
        // too far away
        return [SACMessage(forTimeline: current, before: nil), current]
    }
    private func _convert(messages elements: [SACMessageType], first: SACMessageType?, last: SACMessageType?) -> [SACMessageType] {
        let arr = NSMutableArray(capacity: elements.count * 2 + 2)
        // if first is not TimeLine, add to result
        if let message = first, !message._isTimeLineMessage {
            arr.add(message)
        }
        // process
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
        // success
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
}
