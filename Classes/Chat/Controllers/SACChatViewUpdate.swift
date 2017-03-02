//
//  SACChatViewUpdate.swift
//  SAChat
//
//  Created by sagesse on 13/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal enum SACChatViewUpdateChangeItem {
    case insert(SACMessageType, at: Int)
    case update(SACMessageType, at: Int)
    case remove(at: Int)
    case move(at: Int,  to: Int)
}

internal enum SACChatViewUpdateChange: CustomStringConvertible {
    
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
    
    func offset(_ offset: Int) -> SACChatViewUpdateChange {
        let from = self.from + offset + max(min(self.from, 0), -1) * offset
        let to = self.to + offset + max(min(self.to, 0), -1) * offset
        // convert
        switch self {
        case .move: return .move(from: from, to: to)
        case .insert: return .insert(from: from, to: to)
        case .update: return .update(from: from, to: to)
        case .remove: return .remove(from: from, to: to)
        }
    }
}
internal class SACChatViewUpdateAnimation {
    init(change: SACChatViewUpdateChange, message: SACMessageType) {
        self.change = change
        self.message = message
    }
    
    var change: SACChatViewUpdateChange
    var message: SACMessageType
    
    var delay: TimeInterval = 0
    var options: UIViewAnimationOptions = .curveEaseInOut
    var duration: TimeInterval = 0
}

internal class SACChatViewUpdate: NSObject {
    
    
    internal init(newData: SACChatViewData, oldData: SACChatViewData, updateItems: Array<SACChatViewUpdateChangeItem>) {
        self.newData = newData
        self.oldData = oldData
        self.updateItems = updateItems
        super.init()
        self.updateChanges = _computeItemUpdates(newData, oldData, updateItems)
        self.updateAnimations = _computeItemAnimations(self.updateChanges ?? [])
        
    }
    
    internal func layoutAttributes(forUpdating layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes? {
        // convert to SACChatViewLayoutAttributes
        guard let layoutAttributes = layoutAttributes as? SACChatViewLayoutAttributes else {
            return nil
        }
        // check layout attributes
        if let newLayoutAttributes = layoutAttributes as? SACChatViewLayoutAnimationAttributes {
            return newLayoutAttributes
        }
        logger.debug("\(layoutAttributes.indexPath) => \(layoutAttributes.message!.identifier)")
        
        
        return nil
    }
    internal func layoutAttributes(forAppearing layoutAttributes: UICollectionViewLayoutAttributes, updateItem: UICollectionViewUpdateItem) -> UICollectionViewLayoutAttributes? {
        // create animation layout attributes
        guard let newLayoutAttributes = SACChatViewLayoutAnimationAttributes.animation(with: layoutAttributes, updateItem: updateItem) else {
            return layoutAttributes
        }
        logger.debug("\(newLayoutAttributes.indexPath) => \(newLayoutAttributes.message!.identifier)")
        
        let data = newData[layoutAttributes.indexPath.item]
        
        switch data.options.alignment {
        case .left:
            newLayoutAttributes.transform = .init(translationX: -newLayoutAttributes.frame.width, y: 0)
            
        case .right:
            newLayoutAttributes.transform = .init(translationX: newLayoutAttributes.frame.width, y: 0)
            
        case .center:
            newLayoutAttributes.transform = .identity
        }
        
        if updateItem.updateAction == .move {
            newLayoutAttributes.delay = 0.25
        }
        
        return newLayoutAttributes
    }
    internal func layoutAttributes(forDisappearing layoutAttributes: UICollectionViewLayoutAttributes, updateItem: UICollectionViewUpdateItem) -> UICollectionViewLayoutAttributes? {
        // create animation layout attributes
        guard let newLayoutAttributes = SACChatViewLayoutAnimationAttributes.animation(with: layoutAttributes, updateItem: updateItem) else {
            return layoutAttributes
        }
        logger.debug("\(newLayoutAttributes.indexPath) => \(newLayoutAttributes.message!.identifier)")
        
        let data = oldData[layoutAttributes.indexPath.item]
        
        
        switch data.options.alignment {
        case .left:
            newLayoutAttributes.transform = .init(translationX: -newLayoutAttributes.frame.width, y: 0)
            
        case .right:
            newLayoutAttributes.transform = .init(translationX: newLayoutAttributes.frame.width, y: 0)
            
        case .center:
            newLayoutAttributes.transform = .identity
        }
        
        return newLayoutAttributes
    }
    
    // MARK: compute
    
    internal func _computeItemUpdates(_ newData: SACChatViewData, _ oldData: SACChatViewData, _ updateItems: Array<SACChatViewUpdateChangeItem>) -> Array<SACChatViewUpdateChange> {
        // is empty?
        guard !updateItems.isEmpty else {
            return []
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
                guard abs(from - to) >= 1 else {
                    return result
                }
                // move message
                allMoves.append((from, to))
                // splite to insert & remove
                if let message = _element(at: from) {
                    allRemoves.append((from))
                    allInserts.append((to + 1, message))
                }
                // from + 1: the selected row will change
                return (min(min(from, to + 1), result.0), max(max(from + 1, to + 1), result.1))
                
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
            return []
        }
        // sort
        allInserts.sort { $0.0 < $1.0 }
        allUpdates.sort { $0.0 < $1.0 }
        allRemoves.sort { $0 < $1 }
        allMoves.sort { $0.0 < $1.0 }
        
        let count = oldData.count
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
            items.append(oldData[index])
        }
        // convert messages and replace specify message
        let newItems = items as? [SACMessageType] ?? []
        let convertedItems = _convert(messages: newItems, first: _element(at: begin), last: _element(at: end - 1))
        let selectedRange = Range<Int>(max(begin, 0) ..< min(end, count))
        let selectedItems = oldData.subarray(with: selectedRange)
        // compute index paths
        let start = selectedRange.lowerBound
        let diff = _diff(selectedItems, convertedItems).map { $0.offset(start) }
        // ::
        _logger.debug("select: [\(first) ..< \(last)], diff: \(diff)")
        // replace
        newData.elements = oldData.elements
        newData.replaceSubrange(selectedRange, with: convertedItems)
        
        return diff
    }
    internal func _computeItemAnimations(_ updateChanges: Array<SACChatViewUpdateChange>) -> Array<SACChatViewUpdateAnimation> {
        logger.debug(updateChanges)
        
        
        var delete: Array<SACChatViewUpdateAnimation> = []
        var insert: Array<SACChatViewUpdateAnimation> = []
        
        // 生成动画
        updateChanges.forEach {
            switch $0 {
            case .move(let from, let to):
                delete.append(.init(change: $0, message: newData[to]))
                insert.append(.init(change: $0, message: oldData[from]))
                
            case .update(let from, let to):
                delete.append(.init(change: $0, message: newData[to]))
                insert.append(.init(change: $0, message: oldData[from]))
                
            case .insert(_, let to):
                insert.append(.init(change: $0, message: newData[to]))
                
            case .remove(let from, _):
                delete.append(.init(change: $0, message: oldData[from]))
            }
        }
        
        // 0:u/d 1:n/a
        let udt: TimeInterval = 0
        let nat: TimeInterval = delete.isEmpty ? 0 : 0.25
        
        // update
        delete.forEach {
            $0.delay = udt
        }
        insert.forEach {
            $0.delay = udt
            if $0.change.isMove {
                $0.delay = nat
            }
        }
        
        // merge
        return delete + insert
    }
    
    // MARK: convert message
    
    internal func _convert(message current: SACMessageType, previous: SACMessageType?, next: SACMessageType?, first: SACMessageType?, last: SACMessageType?) -> [SACMessageType] {
        
        //     V-1         V-2         V-3         V-4
        // +---------+ +---------+ +---------+ +---------+
        // |    M   <| |    M    | |    M   <| |    M    |
        // |#   T   <| |#   M   <| |#   T   <| |#   M   <|
        // |    D    | |    D    | |    D    | |    D    |
        // |#   T   <| |#   T   <| |#   M   <| |#   M   <|
        // |    M   <| |    M   <| |    M    | |    M    |
        // +---------+ +---------+ +---------+ +---------+
        //
        
        // check vaild previous and vaild next time interval
        let ti = SACChatViewUpdate.minimuxTimeInterval
        let tprevious = _fetch(before: previous ?? first)
        var tcurrent = current
        
        // reset current message of after
        if let next = next, current._isTimeLineMessage {
            tcurrent = next
        }
        
        
        guard trunc(fabs(tprevious?._timeIntervalSince(tcurrent) ?? (ti + 1)) * 1000) > trunc(ti * 1000) else {
            // too near, check current message type
            guard current._isTimeLineMessage else {
                return [current]
            }
            // too near, current is lt-message, but this is no need, ignore
            return []
        }
        // too far away, if current is lt-message, ignore current message
        if let content = current.content as? SACMessageTimeLineContent {
            // if only one lt-message, ignore current lt-message
            if previous == nil && first == nil && next == nil && last == nil {
                return []
            }
            // if previous is empty, content lt-message is begin, reserved current lt-message
            if previous == nil && content.before == nil {
                return [_timeLine(with: current)]
            }
            // if next is empty(is end), ignore current lt-message
            if next == nil && last == nil {
                return []
            }
            // if previous is lt-message, has two lt-message, ignore current message
            if let content = previous?.content as? SACMessageTimeLineContent {
                // reset previous lt-message for after
                content.after = current
                // ignore current lt-message
                return []
            }
            // only reserved current lt-message
            return [_timeLine(with: current)]
        }
        // too far away, if previous is lt-message, ignore add lt-message required
        if let content = previous?.content as? SACMessageTimeLineContent {
                // reset previous lt-message for after
            content.after = current
            // only reserved current message
            return [current]
        }
        // too far away, if previous is empty, but first not is empty, ignore add lt-message required
        if previous == nil, first != nil {
            // only reserved current message
            return [current]
        }
        // too far away
        return [_timeLine(after: current, before: previous), current]
    }
    
    private func _convert(messages elements: [SACMessageType], first: SACMessageType?, last: SACMessageType?) -> [SACMessageType] {
        // merge
        let elements = [first].flatMap({ $0 }) + elements + [last].flatMap({ $0 })
        // processing
        return (0 ..< elements.count).reduce(NSMutableArray(capacity: elements.count * 2)) { result, index in
            // get context messages
            let previous = result.lastObject as? SACMessageType
            let current = elements[index]
            let next = (index + 1 < elements.count) ? elements[index + 1] : nil
            // convert & merge message
            result.addObjects(from: _convert(message: current, previous: previous, next: next, first: first, last: last))
            // continue
            return result
        } as! [SACMessageType]
    }
    
    // MARK: util
    
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
        guard index >= 0 && index < oldData.count else {
            return nil
        }
        return oldData[index]
    }
    
    fileprivate func _timeLine(with ltmessage: SACMessageType) -> SACMessageType {
        guard let content = ltmessage.content as? SACMessageTimeLineContent else {
            return _timeLine(after: ltmessage, before: nil)
        }
        let content2 = SACMessageTimeLineContent(date: content.after?.date ?? ltmessage.date)
        let message = SACMessage(content: content2)
        
        content2.before = content.before
        content2.after = content.after
        message.date = content.after?.date ?? ltmessage.date
        
        return message
    }
    fileprivate func _timeLine(after: SACMessageType, before: SACMessageType?) -> SACMessageType {
        let content = SACMessageTimeLineContent(date: after.date)
        let message = SACMessage(content: content)
        
        content.before = before
        content.after = after
        message.date = after.date
        
        return message
    }
    
    // MARK: compare
    
    private func _equal<T: SACMessageType>(_ lhs: T, _ rhs: T) -> Bool {
        // message is lt-message?
        if let lcnt = lhs.content as? SACMessageTimeLineContent, let rcnt = rhs.content as? SACMessageTimeLineContent {
            // check tl-message
            return lcnt.after?.identifier == rcnt.after?.identifier
        }
        // check other message
        return lhs.identifier == rhs.identifier
    }
    
    private func _diff<T: SACMessageType>(_ src: Array<T>, _ dest: Array<T>) -> Array<SACChatViewUpdateChange> {
        
        let len1 = src.count
        let len2 = dest.count
        
        var c = [[Int]](repeating: [Int](repeating: 0, count: len2 + 1), count: len1 + 1)
        
        // lcs + 动态规划
        for i in 1 ..< len1 + 1 {
            for j in 1 ..< len2 + 1 {
                if _equal(src[i - 1], (dest[j - 1])) {
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
            guard !_equal(src[i - 1], (dest[j - 1])) else {
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
        logger.debug(rms)
        logger.debug(adds)
        
        // automatic merge delete and update items
        results.append(contentsOf: rms.map({ item in
            let from = item.from
            let delElement = src[from]
            // can't merge to move item?
            if let addIndex = adds.index(where: { _equal(dest[$0.to], delElement) }) {
                let addItem = adds.remove(at: addIndex)
                return .move(from: from, to: addItem.to)
            }
            // can't merge to update item?
            if let addIndex = adds.index(where: { $0.to == from }) {
                let addItem = adds[addIndex]
                let addElement = dest[addItem.to]
                // the same type is allowed to merge
                if type(of: delElement.content) == type(of: addElement.content) {
                    adds.remove(at: addIndex)
                    return .update(from: from, to: addItem.to)
                }
            }
            return .remove(from: item.from, to: -1)
        }))
        // automatic merge insert items
        results.append(contentsOf: adds.map({ item in
            return .insert(from: -1, to: item.to)
        }))
        
        // sort
        return results.sorted { $0.from < $1.from }
    }
    
    // MARK: property
    
    internal let newData: SACChatViewData
    internal let oldData: SACChatViewData
 
    internal let updateItems: Array<SACChatViewUpdateChangeItem>
    internal var updateChanges: Array<SACChatViewUpdateChange>?
    internal var updateAnimations: Array<SACChatViewUpdateAnimation>?
    
    internal static var minimuxTimeInterval: TimeInterval = 60
}

fileprivate extension SACMessageType {
    
    
    fileprivate var _isTimeLineMessage: Bool {
        return content is SACMessageTimeLineContent
    }
    fileprivate func _timeIntervalSince(_ other: SACMessageType) -> TimeInterval {
        return date.timeIntervalSince(other.date)
    }
}

