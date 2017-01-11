//
//  SIMChatUpdatesTransaction.swift
//  SIMChat
//
//  Created by sagesse on 2/20/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

/// 延迟加载的元素, 为了解决移动时数据未知的问题
private enum LazyElement<Element> {
    case index(Int)
    case element(Element)
    
    var index: Int? {
        switch self {
        case .index(let idx): return idx
        default: return nil
        }
    }
    var element: Element? {
        switch self {
        case .element(let e): return e
        default: return nil
        }
    }
}

public class SIMChatUpdatesTransaction<Element> {
    /// 插入一行
    public func insert(_ newElement: Element, atIndex: Int, withAnimation: UITableViewRowAnimation = .none) {
        guard !checkIndexInCall || atIndex <= _count else {
            fatalError("index out of range")
        }
        if _inserts[atIndex] == nil {
            _inserts[atIndex] = []
        }
        _inserts[atIndex]?.append((.element(newElement), withAnimation))
    }
    
    /// 重新加载一行
    public func reloadAtIndex(_ index: Int, withAnimation: UITableViewRowAnimation = .none) {
        guard !checkIndexInCall || index < _count else {
            fatalError("index out of range")
        }
        _reloads[index] = withAnimation
    }
    
    /// 删除一行
    public func removeAtIndex(_ index: Int, withAnimation: UITableViewRowAnimation = .none) {
        guard index < _count else {
            fatalError("index out of range")
        }
        _removes[index] = withAnimation
    }
    
    /// 移动一行
    public func moveFromIndex(_ fromIndex: Int, toIndex: Int, withAnimation: UITableViewRowAnimation = .none) {
        guard fromIndex != toIndex else {
            return
        }
        guard !checkIndexInCall || (fromIndex < _count && toIndex < _count) else {
            fatalError("index out of range")
        }
        let toIndex = toIndex + (toIndex > fromIndex ? +1 : -0)
        
        if _inserts[toIndex] == nil {
            _inserts[toIndex] = []
        }
        
        _moves[fromIndex] = (toIndex, withAnimation)
        _inserts[toIndex]?.append((.index(fromIndex), withAnimation))
        _removes[fromIndex] = withAnimation
    }
    
    /// 应用修改
    func apply(_ tableView: UITableView, _ datas: inout Array<Element>, _ animated: Bool) {
        // 填充数据.
        _inserts.forEach { k, v in
            v.enumerated().forEach {
                guard let idx = $1.0.index else {
                    return
                }
                _inserts[k]?[$0] = (.element(datas[idx]), $1.1)
            }
        }
        //_moves.forEach { log("move element from index: \($0), to index: \($1.0)") }
        
        var indexs = Set<Int>()
        var modifier = 0
        // 合并
        indexs.formUnion(Array(_inserts.keys))
        indexs.formUnion(Array(_removes.keys))
        indexs.formUnion(Array(_reloads.keys))
        
        var insertIndexPaths: Dictionary<UITableViewRowAnimation, Array<IndexPath>> = [:]
        var reloadIndexPaths: Dictionary<UITableViewRowAnimation, Array<IndexPath>> = [:]
        var removeIndexPaths: Dictionary<UITableViewRowAnimation, Array<IndexPath>> = [:]
        
        indexs.sorted().forEach { index in
            //log("-- BEGIN: \(datas)")
            if let ops = _inserts[index] {
                // 插入
                var count = 0
                let position = index + modifier
                ops.reversed().forEach {
                    guard let data = $0.element else {
                        return
                    }
                    let indexPath = IndexPath(row: position + count, section: 0)
                    if insertIndexPaths[$1] == nil {
                        insertIndexPaths[$1] = []
                    }
                    count += 1
                    modifier += 1
                    //log("insert element at index: \(position), at row: \(indexPath.row)")
                    datas.insert(data, at: position)
                    insertIndexPaths[$1]?.append(indexPath)
                }
            }
            if let op = _removes[index] {
                let position = index + modifier
                // 删除
                let indexPath = IndexPath(row: index, section: 0)
                if removeIndexPaths[op] == nil {
                    removeIndexPaths[op] = []
                }
                modifier -= 1
                //log("remove element at index: \(position), at row: \(indexPath.row)")
                datas.remove(at: position)
                removeIndexPaths[op]?.append(indexPath)
            } else if let op = _reloads[index] {
                //let position = index + modifier
                let indexPath = IndexPath(row: index, section: 0)
                // 刷新
                if reloadIndexPaths[op] == nil {
                    reloadIndexPaths[op] = []
                }
                //log("reload element at index: \(position), at row: \(indexPath.row)")
                reloadIndexPaths[op]?.append(indexPath)
            }
            //log("-- END: \(datas)")
        }
        // 没有任何需要操作的东西
        if insertIndexPaths.isEmpty && reloadIndexPaths.isEmpty && removeIndexPaths.isEmpty {
            return
        }
        guard animated else {
            // 禁止动画
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                insertIndexPaths.forEach { tableView.insertRows(at: $1, with: .none) }
                reloadIndexPaths.forEach { tableView.reloadRows(at: $1, with: .none) }
                removeIndexPaths.forEach { tableView.deleteRows(at: $1, with: .none) }
                tableView.endUpdates()
            }
            return
        }
        
        if (removeIndexPaths[.left]?.count)! > 0 || (removeIndexPaths[.right]?.count)! > 0 {
            let rl = removeIndexPaths[.left] ?? []
            let rr = removeIndexPaths[.right] ?? []
            // 获取当前显示的Cell
            let visibleCells = tableView.visibleCells
            let visibleRows = tableView.indexPathsForVisibleRows
            let cellsL: [UITableViewCell] = rl.flatMap {
                guard let index = visibleRows?.index(of: $0) else {
                    return nil
                }
                return visibleCells[index]
            }
            let cellsR: [UITableViewCell] = rr.flatMap {
                guard let index = visibleRows?.index(of: $0) else {
                    return nil
                }
                return visibleCells[index]
            }
            // 需要执行动画的cell不在显示区域
            if !cellsL.isEmpty || !cellsR.isEmpty {
                // 自定义删除动画,
                let enabled = tableView.isScrollEnabled
                tableView.isScrollEnabled = false
                UIView.animate(withDuration: 0.25,
                    animations: {
                        cellsL.forEach { $0.frame.origin = CGPoint(x: -$0.frame.width, y: $0.frame.minY) }
                        cellsR.forEach { $0.frame.origin = CGPoint(x: +$0.frame.width, y: $0.frame.minY) }
                    },
                    completion: { b in
                        if !tableView.isScrollEnabled {
                            tableView.isScrollEnabled = enabled
                        }
                        // 必须要隐藏, 否则系统动画会暴露
                        cellsL.forEach {
                            $0.frame.origin = CGPoint(x: -$0.frame.width, y: $0.frame.minY)
                            $0.isHidden = true
                        }
                        cellsR.forEach {
                            $0.frame.origin = CGPoint(x: +$0.frame.width, y: $0.frame.minY)
                            $0.isHidden = true
                        }
                        // 使用系统的更新剩下的
                        tableView.beginUpdates()
                        insertIndexPaths.forEach { tableView.insertRows(at: $1, with: $0) }
                        reloadIndexPaths.forEach { tableView.reloadRows(at: $1, with: $0) }
                        removeIndexPaths.forEach {
                            if $0 == .left || $0 == .right {
                                tableView.deleteRows(at: $1, with: .top)
                            } else {
                                tableView.deleteRows(at: $1, with: $0)
                            }
                        }
                        tableView.endUpdates()
                    })
                return
            }
        }
        // 使用系统动画
        tableView.beginUpdates()
        insertIndexPaths.forEach { tableView.insertRows(at: $1, with: $0) }
        reloadIndexPaths.forEach { tableView.reloadRows(at: $1, with: $0) }
        removeIndexPaths.forEach { tableView.deleteRows(at: $1, with: $0) }
        tableView.endUpdates()
    }
    
    public var checkIndexInCall: Bool = true
    
    private func log(_ message: Any,
        function: StaticString = #function,
        file: String = #file,
        line: Int = #line) {
            //SIMLog.debug(message, function, line, file)
    }
    
    private var _count: Int
    private var _moves:   Dictionary<Int, (Int, UITableViewRowAnimation)> = [:]
    private var _inserts: Dictionary<Int, Array<(LazyElement<Element>, UITableViewRowAnimation)>> = [:]
    private var _removes: Dictionary<Int, UITableViewRowAnimation> = [:]
    private var _reloads: Dictionary<Int, UITableViewRowAnimation> = [:]
    
    init(count: Int) { _count = count }
}

///
/// 提供一个事务操作, 在闭包内的修改操作只会在闭包结果后才生效
///
/// - parameter tableView 需要操作的视图
/// - parameter datas 关联的数据
/// - parameter aniamted 是否开启动画
/// - parameter handler 一些操作
///
public func SIMChatUpdatesTransactionPerform<Element>(
    _ tableView: UITableView,
    _ datas: inout Array<Element>,
    _ animated: Bool = false,
    _ handler: (SIMChatUpdatesTransaction<Element>) -> Void) {
        let transaction = SIMChatUpdatesTransaction<Element>(count: datas.count)
        handler(transaction)
        transaction.apply(tableView, &datas, animated)
}

